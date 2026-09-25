from datetime import datetime
from typing import List, Optional
from enum import Enum
from pydantic import BaseModel, EmailStr

# --- Order Schemas ---
class OrderStatus(str, Enum):
    PENDING = "pendente"
    PROCESSING = "processando"
    SHIPPED = "enviado"
    DELIVERED = "entregue"
    CANCELLED = "cancelado"


class OrderUpdateStatus(BaseModel):
    status: OrderStatus  # Garante que só aceita valores válidos (ex: enviado, entregue)

class OrderBase(BaseModel):
    customer_id: int
    total_amount: float
    description: str

class OrderCreate(OrderBase):
    pass

# Certifique-se de que o seu OrderResponse tenha o campo status:
class OrderResponse(BaseModel):
    id: int
    customer_id: int
    total_amount: float
    status: str
    description: str


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