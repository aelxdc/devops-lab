# redis_client.py
import os
import redis

REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379/0")

# Pool de conexões resiliente com retry automático em caso de timeout
redis_pool = redis.ConnectionPool.from_url(
    REDIS_URL,
    max_connections=20,
    socket_timeout=2.0,
    socket_connect_timeout=2.0,
    retry_on_timeout=True,
    decode_responses=True
)

redis_client = redis.Redis(connection_pool=redis_pool)

def get_redis():
    """Dependência para injeção nos endpoints FastAPI"""
    return redis_client