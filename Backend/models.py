# SathiAI Backend Models (SQLAlchemy)

from sqlalchemy import Column, Integer, String, Float, Boolean, Date, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from database import Base
import datetime

class Scheme(Base):
    __tablename__ = 'schemes'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    benefit = Column(String)
    eligibility = Column(String)
    required_documents = Column(String)
    application_steps = Column(String)
    official_portal = Column(String)
    category = Column(String)
    state = Column(String)
    district = Column(String)
    description = Column(String)

class Market(Base):
    __tablename__ = 'markets'
    id = Column(Integer, primary_key=True, index=True)
    crop = Column(String)
    price = Column(Float)
    market = Column(String)
    state = Column(String)
    district = Column(String)
    date = Column(Date)
    trend = Column(String)

class Skill(Base):
    __tablename__ = 'skills'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    duration = Column(String)
    certificate = Column(Boolean)
    center = Column(String)
    category = Column(String)
    state = Column(String)
    district = Column(String)
    description = Column(String)

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    village = Column(String)
    occupation = Column(String)
    language = Column(String)
    voice_preference = Column(Boolean)
    state = Column(String)
    district = Column(String)
    location = Column(String)
    notifications = relationship('Notification', back_populates='user')

class Notification(Base):
    __tablename__ = 'notifications'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    message = Column(String)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    user = relationship('User', back_populates='notifications')
