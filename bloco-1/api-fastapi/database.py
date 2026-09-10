import os
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

DATABASE_URL = os.getenv(
    "DATABASE_URL"
)

# Cria o engine síncrono com pool resiliente
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,  # Descarta conexões mortas e reconecta sozinho se o banco cair
    pool_recycle=1800,    # Recicla conexões a cada 30 minutos
    pool_size=10,
    max_overflow=20,
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
