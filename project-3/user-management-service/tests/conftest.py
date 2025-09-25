import os
from datetime import datetime, timedelta

import pytest

from fastapi.testclient import TestClient
from httpx import ASGITransport, AsyncClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import settings
from app.core.security import get_password_hash
from app.db.base import Base
from app.db.session import get_db
from app.models.user import User  # Explicitly import User model
from main import app

# Use a test database URL
engine = create_engine(
    os.environ.get(
        "DATABASE_URL",
        "postgresql://user:password@db:5432/test_user_management_db",
    )
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="session")
def db_engine():
    Base.metadata.create_all(bind=engine)
    yield engine
    Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def test_db(db_engine):
    connection = db_engine.connect()
    transaction = connection.begin()
    session = TestingSessionLocal(bind=connection)

    try:
        yield session
    finally:
        session.close()
        transaction.rollback()
        connection.close()


@pytest.fixture(scope="function")
async def client(test_db):
    app.dependency_overrides[get_db] = lambda: test_db
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as ac:
        yield ac
    app.dependency_overrides.clear()


@pytest.fixture(scope="function")
async def create_test_user_and_token(client: AsyncClient, test_db: Session):
    # Create a user directly in the database
    hashed_password = get_password_hash("testpassword")
    user = User(
        email="testuser@example.com",
        username="testuser",
        hashed_password=hashed_password,
        is_active=True,
        created_at=datetime(2023, 1, 1, 0, 0, 0),
        updated_at=datetime(2023, 1, 1, 0, 0, 0),
    )
    test_db.add(user)
    test_db.commit()
    print(f"Type of user.id: {type(user.id)}")
    print(f"Value of user.id: {user.id}")

    # Log in to get a token
    login_data = {"username": "testuser", "password": "testpassword"}
    response = await client.post("/api/v1/token", data=login_data)
    token = response.json()["access_token"]

    return user.id, token
