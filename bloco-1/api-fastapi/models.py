from datetime import datetime
from sqlalchemy import Column, DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from database import Base

class Customer(Base):
    __tablename__ = "customers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(120), nullable=False)
    email = Column(String(150), unique=True, nullable=False, index=True)
    status = Column(String(20), default="active")  # active, inactive, blocked
    created_at = Column(DateTime, default=datetime.utcnow)

    orders = relationship("Order", back_populates="customer", cascade="all, delete-orphan")


class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"), nullable=False)
    description = Column(String(255), nullable=False)
    total_amount = Column(Float, nullable=False)
    status = Column(String(30), default="pending")  # pending, paid, shipped, cancelled
    created_at = Column(DateTime, default=datetime.utcnow)

    customer = relationship("Customer", back_populates="orders")