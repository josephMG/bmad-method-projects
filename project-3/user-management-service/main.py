from fastapi import FastAPI

from app.api.v1.endpoints import auth, users
from app.db.base import Base  # noqa
from app.db.session import engine
from app.models import user  # noqa

# Create all tables in the database
# Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="User Management Service",
    description="API for user registration, authentication, and profile management.",
    version="1.0.0",
)

app.include_router(auth.router, prefix="/api/v1", tags=["Authentication"])
app.include_router(users.router, prefix="/api/v1", tags=["Users"])
