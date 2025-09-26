from datetime import UTC, datetime, timedelta
from unittest.mock import patch

import pytest

from app.core import security
from app.core.config import settings  # Import settings to patch it


# Patch settings for consistent testing
@pytest.fixture(autouse=True)
def mock_settings():
    with patch.object(settings, "SECRET_KEY", "super-secret-test-key"), \
         patch.object(settings, "ACCESS_TOKEN_EXPIRE_MINUTES", 60):
        yield

def test_verify_password_correct():
    plain_password = "testpassword"
    hashed_password = security.get_password_hash(plain_password) # Use the actual hashing function
    assert security.verify_password(plain_password, hashed_password) is True

def test_verify_password_incorrect():
    plain_password = "testpassword"
    wrong_password = "wrongpassword"
    hashed_password = security.get_password_hash(plain_password)
    assert security.verify_password(wrong_password, hashed_password) is False

def test_create_access_token():
    data = {"sub": "testuser"}
    token = security.create_access_token(data)
    assert isinstance(token, str)
    assert len(token) > 0

    # Decode the token to check its contents
    decoded_token = security.jwt.decode(token, settings.SECRET_KEY, algorithms=[security.ALGORITHM])
    assert decoded_token["sub"] == "testuser"
    assert "exp" in decoded_token

    # Check expiration time
    expiration_time = datetime.fromtimestamp(decoded_token["exp"], tz=UTC)
    # Allow a small delta for execution time
    assert expiration_time > datetime.now(UTC) + timedelta(minutes=59)
    assert expiration_time < datetime.now(UTC) + timedelta(minutes=61)

def test_create_access_token_with_custom_expiry():
    data = {"sub": "testuser"}
    expires_delta = timedelta(minutes=5)
    token = security.create_access_token(data, expires_delta=expires_delta)

    decoded_token = security.jwt.decode(token, settings.SECRET_KEY, algorithms=[security.ALGORITHM])
    expiration_time = datetime.fromtimestamp(decoded_token["exp"], tz=UTC)

    # Check expiration time with custom delta
    assert expiration_time > datetime.now(UTC) + timedelta(minutes=4)
    assert expiration_time < datetime.now(UTC) + timedelta(minutes=6)
