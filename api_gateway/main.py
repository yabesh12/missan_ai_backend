import os
from api_gateway.routes import call_routes
from fastapi import FastAPI, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import httpx


app = FastAPI(title="API Gateway")

# Read CORS settings and Keycloak URL from environment variables
allowed_origins = os.environ.get("CORS_ALLOWED_ORIGINS", "*").split(",")
keycloak_url = os.environ.get("KEYCLOAK_URL", "http://keycloak:8180/realms/missan/protocol/openid-connect")

# Setup CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Set up OAuth2 with token URL
oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{keycloak_url}/token")

# Token verification with Keycloak
async def verify_token(token: str = Depends(oauth2_scheme)):
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{keycloak_url}/userinfo",
            headers={"Authorization": f"Bearer {token}"}
        )

    if response.status_code != 200:
        raise HTTPException(status_code=401, detail="Invalid token or unauthorized")
    return response.json()

@app.get("/")
async def root():
    return {"message": "API Gateway is running"}

# Secure routes using Keycloak authentication
# app.include_router(billing_routes.router, prefix="/billing", dependencies=[Depends(verify_token)])
app.include_router(call_routes.router, prefix="/calls")
# app.include_router(user_routes.router, prefix="/users", dependencies=[Depends(verify_token)])
