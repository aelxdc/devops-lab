import logging
import time
from contextlib import asynccontextmanager
from typing import List

from fastapi import Depends, FastAPI, HTTPException, Response, status
from rq import Queue
from sqlalchemy import text
from sqlalchemy.orm import Session

import models
import schemas
from database import Base, engine, get_db
from redis_client import get_redis, redis_client
from tasks import process_order_task

logger = logging.getLogger("uvicorn")
orders_queue = Queue("orders_queue", connection=redis_client)


def wait_and_init_dependencies(max_retries: int = 10, initial_delay: int = 2):
    """Aguarda o Postgres e o Redis ficarem prontos na subida da aplicação."""
    delay = initial_delay
    for attempt in range(1, max_retries + 1):
        db_ok, redis_ok = False, False

        # 1. Checa Postgres
        try:
            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            Base.metadata.create_all(bind=engine)
            db_ok = True
        except Exception as err:
            logger.warning(
                f"[Tentativa {attempt}/{max_retries}] Postgres indisponível: {err}"
            )

        # 2. Checa Redis
        try:
            redis_client.ping()
            redis_ok = True
        except Exception as err:
            logger.warning(
                f"[Tentativa {attempt}/{max_retries}] Redis indisponível: {err}"
            )

        if db_ok and redis_ok:
            logger.info("PostgreSQL e Redis conectados e operacionais!")
            return

        if attempt == max_retries:
            logger.error("Falha ao inicializar conexões com Postgres ou Redis.")
            return

        time.sleep(delay)
        delay = min(delay * 2, 10)


@asynccontextmanager
async def lifespan(app: FastAPI):
    wait_and_init_dependencies()
    yield
    engine.dispose()
    redis_client.close()


app = FastAPI(
    title="E-Commerce Orders API",
    description="API de pedidos com Postgres e fila de processamento assíncrono via Redis",
    version="1.0.0",
    lifespan=lifespan,
)


@app.get("/health", tags=["Health"])
def health_check(db: Session = Depends(get_db)):
    """Valida a saúde de todos os serviços essenciais (PostgreSQL + Redis)."""
    status_report = {"postgres": "disconnected", "redis": "disconnected"}
    healthy = True

    try:
        db.execute(text("SELECT 1"))
        status_report["postgres"] = "connected"
    except Exception as err:
        logger.warning(f"Healthcheck Postgres falhou: {err}")
        healthy = False

    try:
        redis_client.ping()
        status_report["redis"] = "connected"
    except Exception as err:
        logger.warning(f"Healthcheck Redis falhou: {err}")
        healthy = False

    if not healthy:
        return Response(
            content=f'{{"status": "unhealthy", "services": {status_report}}}',
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            media_type="application/json",
        )

    return {"status": "healthy", "services": status_report}


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
    # 1. Valida se o cliente existe
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

    # 2. Cria o objeto no banco
    new_order = models.Order(**order.model_dump())
    db.add(new_order)
    db.commit()
    db.refresh(new_order)

    # 3. Notifica a fila assíncrona do Redis
    try:
        r = get_redis_client()
        payload = {
            "event": "ORDER_CREATED",
            "order_id": new_order.id,
            "customer_id": new_order.customer_id,
        }
        r.rpush(ORDER_QUEUE_NAME, json.dumps(payload))
        logger.info(f"Evento do pedido {new_order.id} enviado para o Redis.")
    except Exception as err:
        logger.warning(f"Falha ao enfileirar no Redis (não bloqueante): {err}")

    # 4. OBRIGATÓRIO: Retornar a instância do pedido criado
    return new_order

    new_order = models.Order(**order.model_dump())
    db.add(new_order)
    db.commit()
    db.refresh(new_order)

# --- Endpoint: Atualizar Status do Pedido ---
@app.patch(
    "/orders/{order_id}/status",
    response_model=schemas.OrderResponse,
    tags=["Orders"],
)
def update_order_status(
    order_id: int,
    status_data: schemas.OrderUpdateStatus,
    db: Session = Depends(get_db),
):
    # 1. Busca o pedido existente
    order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Pedido não encontrado")

    # 2. Atualiza o status
    order.status = status_data.status.value
    db.commit()
    db.refresh(order)

    # 3. (Opcional) Publica evento de atualização na fila do Redis
    try:
        r = get_redis_client()
        event_payload = {
            "event": "ORDER_STATUS_UPDATED",
            "order_id": order.id,
            "new_status": order.status,
        }
        r.rpush("queue:order_events", json.dumps(event_payload))
    except Exception as err:
        logger.warning(
            f"Não foi possível enviar evento de status para o Redis: {err}"
        )

    return order

    # Enfileira o processamento assíncrono no Redis sem travar a requisição HTTP
    try:
        orders_queue.enqueue(
            process_order_task,
            order_id=new_order.id,
            customer_id=new_order.customer_id,
        )
    except Exception as err:
        logger.error(f"Erro ao despachar tarefa para a fila do Redis: {err}")
        # A requisição não precisa falhar caso a fila esteja indisponível

    return new_order


@app.get(
    "/orders/",
    response_model=List[schemas.OrderResponse],
    tags=["Orders"],
)
def list_orders(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(models.Order).offset(skip).limit(limit).all()