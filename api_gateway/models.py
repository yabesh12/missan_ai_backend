# api_gateway/models.py

from sqlalchemy import Column, String, Integer, DateTime
from sqlalchemy.ext.declarative import declarative_base
import uuid
from datetime import datetime

Base = declarative_base()

class Call(Base):
    __tablename__ = "calls"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    caller = Column(String, nullable=False)
    receiver = Column(String, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)
    duration = Column(Integer, nullable=False)
