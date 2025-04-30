# api_gateway/routes/call_routes.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List
from datetime import datetime

from api_gateway.database import SessionLocal
from api_gateway.models import Call

router = APIRouter()

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class CallCreate(BaseModel):
    caller: str
    receiver: str
    timestamp: datetime
    duration: int

class CallResponse(CallCreate):
    id: str

    class Config:
        orm_mode = True

@router.post("/", response_model=CallResponse)
def create_call(call: CallCreate, db: Session = Depends(get_db)):
    db_call = Call(**call.dict())
    db.add(db_call)
    db.commit()
    db.refresh(db_call)
    return db_call

@router.get("/", response_model=List[CallResponse])
def read_calls(db: Session = Depends(get_db)):
    return db.query(Call).all()

@router.get("/{call_id}", response_model=CallResponse)
def read_call(call_id: str, db: Session = Depends(get_db)):
    call = db.query(Call).filter(Call.id == call_id).first()
    if not call:
        raise HTTPException(status_code=404, detail="Call not found")
    return call

@router.delete("/{call_id}")
def delete_call(call_id: str, db: Session = Depends(get_db)):
    call = db.query(Call).filter(Call.id == call_id).first()
    if not call:
        raise HTTPException(status_code=404, detail="Call not found")
    db.delete(call)
    db.commit()
    return {"detail": "Call deleted"}
