from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.endpoints import auth, users
from app.db.base import Base  # noqa
from app.models import user  # noqa

# Create all tables in the database
# Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="User Management Service",
    description="API for user registration, authentication, and profile management.",
    version="1.0.0",
    redirect_slashes=False,  # Disable strict slash matching to prevent CORS preflight redirects
)

origins = [
    "http://localhost:3000",  # Next.js frontend
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=[
        "GET",
        "POST",
        "PUT",
        "DELETE",
        "OPTIONS",
    ],  # Explicitly allow OPTIONS for preflight
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/v1", tags=["Authentication"])
app.include_router(users.router, prefix="/api/v1", tags=["Users"])
