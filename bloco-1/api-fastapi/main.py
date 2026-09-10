import logging
import time
from contextlib import asynccontextmanager
from typing import List

from fastapi import Depends, FastAPI, HTTPException, Response, status
from sqlalchemy import text
from sqlalchemy.orm import Session

import models
import schemas
from database import Base, engine, get_db

logger = logging.getLogger("uvicorn")


def wait_and_init_db(max_retries: int = 10, initial_delay: int = 2):
    """Aguarda o banco responder com retry exponencial e sincroniza o schema."""
    delay = initial_delay
    for attempt in range(1, max_retries + 1):
        try:
            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            logger.info("Conexão com o PostgreSQL estabelecida!")

            # Cria as tabelas com a conexão confirmada
            Base.metadata.create_all(bind=engine)
            logger.info("Tabelas verificadas/criadas com sucesso!")
            return
        except Exception as err:
            logger.warning(
                f"Banco indisponível na tentativa {attempt}/{max_retries}: {err}"
            )
            if attempt == max_retries:
                logger.error(
                    "Não foi possível conectar ao banco após todas as tentativas. "
                    "A API continuará inicializando, mas requisições ao banco falharão."
                )
                return
            time.sleep(delay)
            delay = min(delay * 2, 10)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: tenta conectar e criar tabelas sem crashar o processo
    wait_and_init_db()
    yield
    # Shutdown: fecha pools e conexões pendentes graciosamente
    engine.dispose()


app = FastAPI(
    title="E-Commerce Orders API",
    description="API comercial para gestão de clientes e pedidos, estruturada para labs DevOps",
    version="1.0.0",
    lifespan=lifespan,
)


@app.get("/health", tags=["Health"])
def health_check(db: Session = Depends(get_db)):
    """Valida a saúde do container e testa a conexão real com o banco."""
    try:
        db.execute(text("SELECT 1"))
        return {"status": "healthy", "database": "connected"}
    except Exception as err:
        logger.warning(f"Healthcheck falhou: {err}")
        return Response(
            content='{"status": "unhealthy", "database": "disconnected"}',
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            media_type="application/json",
        )


# --- Endpoints: Customers ---
@app.post(
    "/customers/",
    response_model=schemas.CustomerResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Customers"],
)
def create_customer(customer: schemas.CustomerCreate, db: Session = Depends(get_db)):
    existing = (
        db.query(models.Customer)
        .filter(models.Customer.email == customer.email)
        .first()
    )
    if existing:
        raise HTTPException(status_code=400, detail="E-mail já cadastrado")

    new_customer = models.Customer(**customer.model_dump())
    db.add(new_customer)
    db.commit()
    db.refresh(new_customer)
    return new_customer


@app.get(
    "/customers/",
    response_model=List[schemas.CustomerResponse],
    tags=["Customers"],
)
def list_customers(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(models.Customer).offset(skip).limit(limit).all()


@app.get(
    "/customers/{customer_id}",
    response_model=schemas.CustomerResponse,
    tags=["Customers"],
)
def get_customer(customer_id: int, db: Session = Depends(get_db)):
    customer = (
        db.query(models.Customer)
        .filter(models.Customer.id == customer_id)
        .first()
    )
    if not customer:
        raise HTTPException(status_code=404, detail="Cliente não encontrado")
    return customer


# --- Endpoints: Orders ---
@app.post(
    "/orders/",
    response_model=schemas.OrderResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Orders"],
)
def create_order(order: schemas.OrderCreate, db: Session = Depends(get_db)):
    customer = (
        db.query(models.Customer)
        .filter(models.Customer.id == order.customer_id)
        .first()
    )
    if not customer:
        raise HTTPException(
            status_code=404,
            detail="Cliente não encontrado para vincular o pedido",
        )

    new_order = models.Order(**order.model_dump())
    db.add(new_order)
    db.commit()
    db.refresh(new_order)
    return new_order


@app.get(
    "/orders/",
    response_model=List[schemas.OrderResponse],
    tags=["Orders"],
)
def list_orders(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(models.Order).offset(skip).limit(limit).all()