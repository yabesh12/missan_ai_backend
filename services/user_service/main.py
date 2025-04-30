from fastapi import FastAPI, Depends, HTTPException, Form
from fastapi.security import OAuth2PasswordBearer
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import httpx
import os

app = FastAPI()

# Keycloak configuration
KEYCLOAK_URL = "http://localhost:8180/realms/myrealm/protocol/openid-connect"
KEYCLOAK_CLIENT_ID = "myclient"
KEYCLOAK_CLIENT_SECRET = "myclient-secret"

# FastAPI dependency to extract token
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/token")

# Utility to verify token via Keycloak userinfo endpoint
async def verify_token(token: str):
    url = f"{KEYCLOAK_URL}/userinfo"
    headers = {
        "Authorization": f"Bearer {token}"
    }

    async with httpx.AsyncClient() as client:
        response = await client.get(url, headers=headers)

    if response.status_code != 200:
        raise HTTPException(status_code=401, detail="Invalid token or unauthorized")
    
    return response.json()

# User model to return in response
class User(BaseModel):
    username: str
    email: str
    full_name: str

# 🆕 Token generation endpoint using Keycloak
@app.post("/token")
async def login(username: str = Form(...), password: str = Form(...)):
    url = f"{KEYCLOAK_URL}/token"
    data = {
        "grant_type": "password",
        "client_id": KEYCLOAK_CLIENT_ID,
        "client_secret": KEYCLOAK_CLIENT_SECRET,
        "username": username,
        "password": password
    }

    headers = {"Content-Type": "application/x-www-form-urlencoded"}

    async with httpx.AsyncClient() as client:
        response = await client.post(url, data=data, headers=headers)

    if response.status_code != 200:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    return response.json()

# Fetch user info using Keycloak's /userinfo endpoint
@app.get("/user/{user_id}", response_model=User)
async def get_user(user_id: str, token: str = Depends(oauth2_scheme)):
    user_info = await verify_token(token)
    
    return User(
        username=user_info['preferred_username'],
        email=user_info['email'],
        full_name=user_info.get('name', '')
    )
    
    
@app.get("/me", response_model=User)
async def get_me(token: str = Depends(oauth2_scheme)):
    user_info = await verify_token(token)
    return User(
        username=user_info['preferred_username'],
        email=user_info['email'],
        full_name=user_info.get('name', '')
    )
