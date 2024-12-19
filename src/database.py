import os
from dotenv import find_dotenv, load_dotenv

import sqlalchemy as sql
import sqlalchemy.ext.declarative as declarative
from sqlalchemy import orm

load_dotenv(find_dotenv())

POSTGRES_USER=os.getenv("POSTGRES_USER")
POSTGRES_DB=os.getenv("POSTGRES_DB")
POSTGRES_PASSWORD=os.getenv("POSTGRES_PASSWORD")

DATABASE_URL = f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@postgres:5432/{POSTGRES_DB}"

engine = sql.create_engine(DATABASE_URL)

SessionLocal = orm.sessionmaker(
    autocommit = False,
    autoflush = False,
    bind = engine,
)

Base = declarative.declarative_base()