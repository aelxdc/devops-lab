from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, EmailStr

# --- Order Schemas ---
class OrderBase(BaseModel):
    description: str
    total_amount: float
    status: Optional[str] = "pending"

class OrderCreate(OrderBase):
    customer_id: int

class OrderResponse(OrderBase):
    id: int
    customer_id: int
    created_at: datetime

    class Config:
        from_attributes = True


# --- Customer Schemas ---
class CustomerBase(BaseModel):
    name: str
    email: EmailStr
    status: Optional[str] = "active"

class CustomerCreate(CustomerBase):
    pass

class CustomerResponse(CustomerBase):
    id: int
    created_at: datetime
    orders: List[OrderResponse] = []

    class Config:
        from_attributes = True