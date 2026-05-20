import os
from dotenv import find_dotenv, load_dotenv

import sqlalchemy as sql
import sqlalchemy.ext.declarative as declarative
from sqlalchemy import orm

load_dotenv(find_dotenv())

POSTGRES_USER = os.getenv("POSTGRES_USER")
POSTGRES_DB = os.getenv("POSTGRES_DB")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")


def _build_database_url() -> str:
    explicit = os.getenv("DATABASE_URL")
    if explicit:
        return explicit

    host = os.getenv("POSTGRES_HOST", "postgres")
    port = os.getenv("POSTGRES_PORT", "5432")
    return (
        f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}"
        f"@{host}:{port}/{POSTGRES_DB}"
    )


DATABASE_URL = _build_database_url()

engine = sql.create_engine(DATABASE_URL)

SessionLocal = orm.sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)

Base = declarative.declarative_base()
