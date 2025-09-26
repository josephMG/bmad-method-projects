import pytest
from httpx import AsyncClient
from sqlalchemy.orm import Session

from app.core.security import verify_password
from app.models.user import User


# Helper function to register and login a user
async def register_and_login_user(client: AsyncClient, test_db: Session, email: str, username: str, password: str):
    user_data = {
        "email": email,
        "username": username,
        "password": password,
    }
    await client.post("/api/v1/register", json=user_data)

    login_data = {
        "username": username,
        "password": password,
    }
    response = await client.post("/api/v1/token", data=login_data)
    return response.json()["access_token"]

@pytest.mark.asyncio()
async def test_register_user_success(client: AsyncClient, test_db: Session):
    user_data = {
        "email": "test_integration@example.com",
        "username": "test_integration_user",
        "password": "SecurePassword123",
        "full_name": "Test Integration User",
    }
    response = await client.post("/api/v1/register", json=user_data)

    assert response.status_code == 201
    data = response.json()
    assert data["email"] == user_data["email"]
    assert data["username"] == user_data["username"]
    assert "id" in data
    assert "created_at" in data
    assert "updated_at" in data
    assert data["is_active"] is True

    # Verify user is in the database
    user_in_db = test_db.query(User).filter(User.email == user_data["email"]).first()
    assert user_in_db is not None
    assert user_in_db.email == user_data["email"]
    assert user_in_db.username == user_data["username"]
    assert user_in_db.is_active is True
    assert user_in_db.hashed_password is not None
    assert user_in_db.full_name == user_data["full_name"]

@pytest.mark.asyncio()
async def test_register_user_email_exists(client: AsyncClient, test_db: Session):
    # First, register a user
    user_data = {
        "email": "existing_email@example.com",
        "username": "unique_user_for_email_test",
        "password": "SecurePassword123",
    }
    await client.post("/api/v1/register", json=user_data)

    # Try to register again with the same email
    duplicate_user_data = {
        "email": "existing_email@example.com",
        "username": "another_user",
        "password": "AnotherSecurePassword",
    }
    response = await client.post("/api/v1/register", json=duplicate_user_data)

    assert response.status_code == 400
    assert response.json()["detail"] == "Email already registered"

@pytest.mark.asyncio()
async def test_register_user_username_exists(client: AsyncClient, test_db: Session):
    # First, register a user
    user_data = {
        "email": "unique_email_for_username_test@example.com",
        "username": "existing_username",
        "password": "SecurePassword123",
    }
    await client.post("/api/v1/register", json=user_data)

    # Try to register again with the same username
    duplicate_user_data = {
        "email": "another_email@example.com",
        "username": "existing_username",
        "password": "AnotherSecurePassword",
    }
    response = await client.post("/api/v1/register", json=duplicate_user_data)

    assert response.status_code == 400
    assert response.json()["detail"] == "Username already registered"

@pytest.mark.asyncio()
async def test_register_user_invalid_email(client: AsyncClient):
    user_data = {
        "email": "invalid-email",
        "username": "testuser",
        "password": "SecurePassword123",
    }
    response = await client.post("/api/v1/register", json=user_data)
    assert response.status_code == 422 # Unprocessable Entity for Pydantic validation error

@pytest.mark.asyncio()
async def test_register_user_short_password(client: AsyncClient):
    user_data = {
        "email": "test@example.com",
        "username": "testuser",
        "password": "short", # Min length is 8
    }
    response = await client.post("/api/v1/register", json=user_data)
    assert response.status_code == 422 # Unprocessable Entity for Pydantic validation error

@pytest.mark.asyncio()
async def test_login_for_access_token_success(client: AsyncClient, test_db: Session):
    # First, register a user to log in with
    user_data = {
        "email": "login_test@example.com",
        "username": "login_user",
        "password": "LoginSecurePassword123",
    }
    await client.post("/api/v1/register", json=user_data)

    # Now, attempt to log in
    login_data = {
        "username": user_data["username"],
        "password": user_data["password"],
    }
    response = await client.post("/api/v1/token", data=login_data)

    assert response.status_code == 200
    token_data = response.json()
    assert "access_token" in token_data
    assert token_data["token_type"] == "bearer"
    assert isinstance(token_data["access_token"], str)
    assert len(token_data["access_token"]) > 0

@pytest.mark.asyncio()
async def test_login_for_access_token_incorrect_password(client: AsyncClient, test_db: Session):
    # First, register a user
    user_data = {
        "email": "wrong_pass@example.com",
        "username": "wrong_pass_user",
        "password": "CorrectPassword123",
    }
    await client.post("/api/v1/register", json=user_data)

    # Attempt to log in with incorrect password
    login_data = {
        "username": user_data["username"],
        "password": "IncorrectPassword",
    }
    response = await client.post("/api/v1/token", data=login_data)

    assert response.status_code == 401
    assert response.json()["detail"] == "Incorrect username or password"

@pytest.mark.asyncio()
async def test_login_for_access_token_non_existent_user(client: AsyncClient):
    # Attempt to log in with a non-existent user
    login_data = {
        "username": "non_existent_user",
        "password": "AnyPassword123",
    }
    response = await client.post("/api/v1/token", data=login_data)

    assert response.status_code == 401
    assert response.json()["detail"] == "Incorrect username or password"

@pytest.mark.asyncio()
async def test_change_password_success(client: AsyncClient, test_db: Session):
    # Register and login a user
    email = "change_pass_user@example.com"
    username = "change_pass_user"
    old_password = "OldSecurePassword123"
    new_password = "NewSecurePassword456"

    access_token = await register_and_login_user(client, test_db, email, username, old_password)

    # Get the user from the database to verify hashed password later
    user_in_db_before = test_db.query(User).filter(User.email == email).first()
    assert user_in_db_before is not None
    old_hashed_password = user_in_db_before.hashed_password

    # Attempt to change password
    password_update_data = {
        "current_password": old_password,
        "new_password": new_password,
    }
    response = await client.put(
        "/api/v1/users/me/password",
        json=password_update_data,
        headers={"Authorization": f"Bearer {access_token}"},
    )

    assert response.status_code == 204

    # Verify password changed in DB
    user_in_db_after = test_db.query(User).filter(User.email == email).first()
    assert user_in_db_after is not None
    assert user_in_db_after.hashed_password != old_hashed_password
    assert verify_password(new_password, user_in_db_after.hashed_password) is True

    # Try to login with old password (should fail)
    login_data_old = {
        "username": username,
        "password": old_password,
    }
    response_old_login = await client.post("/api/v1/token", data=login_data_old)
    assert response_old_login.status_code == 401

    # Try to login with new password (should succeed)
    login_data_new = {
        "username": username,
        "password": new_password,
    }
    response_new_login = await client.post("/api/v1/token", data=login_data_new)
    assert response_new_login.status_code == 200


@pytest.mark.asyncio()
async def test_change_password_incorrect_current_password(client: AsyncClient, test_db: Session):
    # Register and login a user
    email = "incorrect_pass_user@example.com"
    username = "incorrect_pass_user"
    old_password = "OldSecurePassword123"
    new_password = "NewSecurePassword456"

    access_token = await register_and_login_user(client, test_db, email, username, old_password)

    # Attempt to change password with incorrect current password
    password_update_data = {
        "current_password": "WrongOldPassword",
        "new_password": new_password,
    }
    response = await client.put(
        "/api/v1/users/me/password",
        json=password_update_data,
        headers={"Authorization": f"Bearer {access_token}"},
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "Incorrect current password"

    # Verify password did not change in DB
    user_in_db = test_db.query(User).filter(User.email == email).first()
    assert user_in_db is not None
    assert verify_password(old_password, user_in_db.hashed_password) is True


@pytest.mark.asyncio()
async def test_change_password_unauthenticated(client: AsyncClient):
    password_update_data = {
        "current_password": "AnyPassword",
        "new_password": "NewPassword",
    }
    response = await client.put(
        "/api/v1/users/me/password",
        json=password_update_data,
    )
    assert response.status_code == 401
    assert response.json()["detail"] == "Not authenticated"
