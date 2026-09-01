from typing import List
from fastapi import Depends, FastAPI, HTTPException, status
from sqlalchemy.orm import Session

import models
import schemas
from database import Base, engine, get_db

# Cria as tabelas na inicialização
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="E-Commerce Orders API",
    description="API comercial para gestão de clientes e pedidos, estruturada para labs DevOps",
    version="1.0.0"
)

@app.get("/health", status_code=status.HTTP_200_OK, tags=["Health"])
def health_check():
    return {"status": "healthy"}

# --- Endpoints: Customers ---
@app.post("/customers/", response_model=schemas.CustomerResponse, status_code=status.HTTP_201_CREATED, tags=["Customers"])
def create_customer(customer: schemas.CustomerCreate, db: Session = Depends(get_db)):
    existing = db.query(models.Customer).filter(models.Customer.email == customer.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="E-mail já cadastrado")
    
    new_customer = models.Customer(**customer.model_dump())
    db.add(new_customer)
    db.commit()
    db.refresh(new_customer)
    return new_customer

@app.get("/customers/", response_model=List[schemas.CustomerResponse], tags=["Customers"])
def list_customers(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(models.Customer).offset(skip).limit(limit).all()

@app.get("/customers/{customer_id}", response_model=schemas.CustomerResponse, tags=["Customers"])
def get_customer(customer_id: int, db: Session = Depends(get_db)):
    customer = db.query(models.Customer).filter(models.Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Cliente não encontrado")
    return customer

# --- Endpoints: Orders ---
@app.post("/orders/", response_model=schemas.OrderResponse, status_code=status.HTTP_201_CREATED, tags=["Orders"])
def create_order(order: schemas.OrderCreate, db: Session = Depends(get_db)):
    customer = db.query(models.Customer).filter(models.Customer.id == order.customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Cliente não encontrado para vincular o pedido")
    
    new_order = models.Order(**order.model_dump())
    db.add(new_order)
    db.commit()
    db.refresh(new_order)
    return new_order

@app.get("/orders/", response_model=List[schemas.OrderResponse], tags=["Orders"])
def list_orders(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(models.Order).offset(skip).limit(limit).all()