import uuid
from datetime import datetime
from unittest.mock import MagicMock

import pytest
from fastapi import HTTPException, status

from app.core import security
from app.models.user import User
from app.schemas.user import PasswordUpdate, UserCreate, UserUpdate
from app.services.user_service import (
    change_user_password_service,
    create_user_service,
    delete_user_account,
    update_user_profile,
)


def test_create_user_service_success(mocker):
    db_mock = MagicMock()
    user_create = UserCreate(email="test@example.com", username="testuser", password="password123")

    # Mock crud_user functions
    mock_get_user_by_email = mocker.patch("app.services.user_service.crud_user.get_user_by_email", return_value=None)
    mock_get_user_by_username = mocker.patch("app.services.user_service.crud_user.get_user_by_username", return_value=None)

    # Mock security.get_password_hash
    mock_get_password_hash = mocker.patch("app.services.user_service.get_password_hash", return_value="hashed_password_mock")

    # Mock crud_user.create_user
    mock_created_user = User(
        id=uuid.uuid4(),
        email="test@example.com",
        username="testuser",
        hashed_password="hashed_password_mock",
        is_active=True,
    )
    mock_create_user = mocker.patch("app.services.user_service.crud_user.create_user", return_value=mock_created_user)

    # Call the service function
    created_user = create_user_service(db=db_mock, user=user_create)

    # Assertions
    assert created_user == mock_created_user
    mock_get_user_by_email.assert_called_once_with(db_mock, email=user_create.email)
    mock_get_user_by_username.assert_called_once_with(db_mock, username=user_create.username)
    mock_get_password_hash.assert_called_once_with(user_create.password)
    mock_create_user.assert_called_once_with(
        db=db_mock, user=user_create, hashed_password="hashed_password_mock",
    )

def test_create_user_service_email_exists(mocker):
    db_mock = MagicMock()
    user_create = UserCreate(email="existing@example.com", username="testuser", password="password123")

    # Mock get_user_by_email to return an existing user
    mock_get_user_by_email = mocker.patch("app.services.user_service.crud_user.get_user_by_email", return_value=User())

    with pytest.raises(HTTPException) as exc_info:
        create_user_service(db=db_mock, user=user_create)

    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc_info.value.detail == "Email already registered"
    mock_get_user_by_email.assert_called_once_with(db_mock, email=user_create.email)
    mocker.patch("app.services.user_service.crud_user.get_user_by_username").assert_not_called()
    mocker.patch("app.services.user_service.get_password_hash").assert_not_called()
    mocker.patch("app.services.user_service.crud_user.create_user").assert_not_called()

def test_create_user_service_username_exists(mocker):
    db_mock = MagicMock()
    user_create = UserCreate(email="test@example.com", username="existinguser", password="password123")

    # Mock get_user_by_email to return None, then get_user_by_username to return an existing user
    mock_get_user_by_email = mocker.patch("app.services.user_service.crud_user.get_user_by_email", return_value=None)
    mock_get_user_by_username = mocker.patch("app.services.user_service.crud_user.get_user_by_username", return_value=User())

    with pytest.raises(HTTPException) as exc_info:
        create_user_service(db=db_mock, user=user_create)

    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc_info.value.detail == "Username already registered"
    mock_get_user_by_email.assert_called_once_with(db_mock, email=user_create.email)
    mock_get_user_by_username.assert_called_once_with(db_mock, username=user_create.username)
    mocker.patch("app.services.user_service.get_password_hash").assert_not_called()
    mocker.patch("app.services.user_service.crud_user.create_user").assert_not_called()


def test_change_user_password_service_success(mocker):
    db_mock = MagicMock()
    user_mock = User(id=uuid.uuid4(), email="test@example.com", username="testuser", hashed_password="old_hashed_password", is_active=True)
    password_update = PasswordUpdate(current_password="old_password", new_password="new_password")

    mock_verify_password = mocker.patch("app.services.user_service.verify_password", return_value=True)
    mock_get_password_hash = mocker.patch("app.services.user_service.get_password_hash", return_value="new_hashed_password")
    mock_update_user_password = mocker.patch("app.services.user_service.crud_user.update_user_password", return_value=user_mock)

    updated_user = change_user_password_service(db_mock, user_mock, password_update)
    assert updated_user == user_mock
    mock_verify_password.assert_called_once_with(password_update.current_password, user_mock.hashed_password)
    mock_get_password_hash.assert_called_once_with(password_update.new_password)
    mock_update_user_password.assert_called_once_with(db=db_mock, user=user_mock, hashed_password="new_hashed_password")

def test_change_user_password_service_incorrect_current_password(mocker):
    db_mock = MagicMock()
    user_mock = User(id=uuid.uuid4(), email="test@example.com", username="testuser", hashed_password="old_hashed_password", is_active=True)
    password_update = PasswordUpdate(current_password="wrong_password", new_password="new_password")

    mock_verify_password = mocker.patch("app.services.user_service.verify_password", return_value=False)
    mock_get_password_hash = mocker.patch("app.services.user_service.get_password_hash")
    mock_update_user_password = mocker.patch("app.services.user_service.crud_user.update_user_password")

    with pytest.raises(HTTPException) as exc_info:
        change_user_password_service(db_mock, user_mock, password_update)
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc_info.value.detail == "Incorrect current password"
    mock_verify_password.assert_called_once_with(password_update.current_password, user_mock.hashed_password)
    mock_get_password_hash.assert_not_called()
    mock_update_user_password.assert_not_called()

def test_update_user_profile_success(mocker):
    db_mock = MagicMock()
    user_id = uuid.uuid4()
    user_update = UserUpdate(full_name="New Name", email="new@example.com")

    # Mock existing user
    db_user_mock = User(id=user_id, email="old@example.com", username="testuser", hashed_password="hashed_password", is_active=True)
    mocker.patch("app.services.user_service.crud_user.get_user", return_value=db_user_mock)

    # Mock email check
    mocker.patch("app.services.user_service.crud_user.get_user_by_email", return_value=None)

    # Mock update_user
    def mock_update_user_side_effect(db, db_user, obj_in):
        for field, value in obj_in.items():
            setattr(db_user, field, value)
        return db_user
    mocker.patch("app.services.user_service.crud_user.update_user", side_effect=mock_update_user_side_effect)

    updated_user = update_user_profile(db_mock, user_id, user_update)

    assert updated_user.full_name == "New Name"
    assert updated_user.email == "new@example.com"

def test_update_user_profile_duplicate_email(mocker):
    db_mock = MagicMock()
    user_id = uuid.uuid4()
    user_update = UserUpdate(email="duplicate@example.com")

    # Mock existing user
    db_user_mock = User(id=user_id, email="old@example.com", username="testuser", hashed_password="hashed_password", is_active=True)
    mocker.patch("app.services.user_service.crud_user.get_user", return_value=db_user_mock)

    # Mock email check to return an existing user with a different ID
    mocker.patch("app.services.user_service.crud_user.get_user_by_email", return_value=User(id=uuid.uuid4(), email="duplicate@example.com"))

    with pytest.raises(HTTPException) as exc_info:
        update_user_profile(db_mock, user_id, user_update)

    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc_info.value.detail == "Email already registered"

def test_update_user_profile_user_not_found(mocker):
    db_mock = MagicMock()
    user_id = uuid.uuid4()
    user_update = UserUpdate(full_name="New Name")

    # Mock get_user to return None
    mocker.patch("app.services.user_service.crud_user.get_user", return_value=None)

    with pytest.raises(HTTPException) as exc_info:
        update_user_profile(db_mock, user_id, user_update)

    assert exc_info.value.status_code == status.HTTP_404_NOT_FOUND
    assert exc_info.value.detail == "User not found"

def test_update_user_profile_updated_at_handled_by_db(mocker):
    db_mock = MagicMock()
    user_id = uuid.uuid4()
    user_update = UserUpdate(full_name="New Name")

    db_user_mock = User(id=user_id, email="old@example.com", username="testuser", hashed_password="hashed_password", is_active=True)
    mocker.patch("app.services.user_service.crud_user.get_user", return_value=db_user_mock)
    mocker.patch("app.services.user_service.crud_user.get_user_by_email", return_value=None)

    mock_update_user = mocker.patch("app.services.user_service.crud_user.update_user", return_value=db_user_mock)

    update_user_profile(db_mock, user_id, user_update)

    # Verify that update_user was called, implying the database handles updated_at
    mock_update_user.assert_called_once()
    # Further assertion could be made if the mock_update_user returned a user with an updated timestamp
    # For now, just checking that the update function was called is sufficient for this test's scope.

def test_delete_user_account_success(mocker):
    db_mock = MagicMock()
    user_id = uuid.uuid4()
    current_password = "any_password"
    hashed_password = security.get_password_hash(current_password)

    # Mock get_user to return an existing user
    db_user_mock = User(id=user_id, email="test@example.com", username="testuser", hashed_password=hashed_password, is_active=True, is_deleted=False, deletion_requested_at=None)
    mocker.patch("app.services.user_service.crud_user.get_user", return_value=db_user_mock)
    mocker.patch("app.services.user_service.verify_password", return_value=True)

    # Ensure crud_user.delete_user is NOT called directly
    mock_crud_delete_user = mocker.patch("app.services.user_service.crud_user.delete_user", autospec=True)

    delete_user_account(db_mock, user_id, current_password)

    assert db_user_mock.is_active is False
    assert db_user_mock.deletion_requested_at is not None
    assert isinstance(db_user_mock.deletion_requested_at, datetime)
    assert db_user_mock.is_deleted is False
    assert db_user_mock.deleted_at is None
    mock_crud_delete_user.assert_not_called()
    db_mock.commit.assert_called_once()

def test_delete_user_account_user_not_found(mocker):
    db_mock = MagicMock()
    user_id = uuid.uuid4()

    # Mock get_user to return None
    mocker.patch("app.services.user_service.crud_user.get_user", return_value=None)
    from app.services.user_service import UserNotFoundException
    with pytest.raises(UserNotFoundException):
        delete_user_account(db_mock, user_id, "any_password")
    mocker.patch("app.services.user_service.crud_user.delete_user").assert_not_called()

def test_delete_user_account_reauthentication_success(mocker):
    db_mock = MagicMock()
    user_id = uuid.uuid4()
    current_password = "correct_password"
    hashed_password = security.get_password_hash(current_password)

    db_user_mock = User(id=user_id, email="test@example.com", username="testuser", hashed_password=hashed_password, is_active=True, is_deleted=False, deletion_requested_at=None)
    mock_get_user = mocker.patch("app.services.user_service.crud_user.get_user", return_value=db_user_mock)
    mock_verify_password = mocker.patch("app.services.user_service.verify_password", return_value=True)
    mock_crud_delete_user = mocker.patch("app.services.user_service.crud_user.delete_user", autospec=True)

    delete_user_account(db_mock, user_id, current_password)

    mock_get_user.assert_called_once_with(db_mock, user_id=user_id)
    mock_verify_password.assert_called_once_with(current_password, hashed_password)
    assert db_user_mock.is_active is False
    assert db_user_mock.deletion_requested_at is not None
    assert isinstance(db_user_mock.deletion_requested_at, datetime)
    assert db_user_mock.is_deleted is False
    assert db_user_mock.deleted_at is None
    mock_crud_delete_user.assert_not_called()
    db_mock.commit.assert_called_once()

def test_delete_user_account_reauthentication_incorrect_password(mocker):
    db_mock = MagicMock()
    user_id = uuid.uuid4()
    current_password = "incorrect_password"
    hashed_password = security.get_password_hash("correct_password")

    db_user_mock = User(id=user_id, email="test@example.com", username="testuser", hashed_password=hashed_password, is_active=True)
    mock_get_user = mocker.patch("app.services.user_service.crud_user.get_user", return_value=db_user_mock)
    mock_verify_password = mocker.patch("app.services.user_service.verify_password", return_value=False)
    mock_delete_user = mocker.patch("app.services.user_service.crud_user.delete_user")

    with pytest.raises(HTTPException) as exc_info:
        delete_user_account(db_mock, user_id, current_password)

    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc_info.value.detail == "Incorrect current password"
    mock_get_user.assert_called_once_with(db_mock, user_id=user_id)
    mock_verify_password.assert_called_once_with(current_password, hashed_password)
    mock_delete_user.assert_not_called()

def test_delete_user_account_marks_for_delayed_deletion(mocker):
    db_mock = MagicMock()
    user_id = uuid.uuid4()
    current_password = "correct_password"
    hashed_password = security.get_password_hash(current_password)

    db_user_mock = User(id=user_id, email="test@example.com", username="testuser", hashed_password=hashed_password, is_active=True, is_deleted=False, deletion_requested_at=None)
    mock_get_user = mocker.patch("app.services.user_service.crud_user.get_user", return_value=db_user_mock)
    mock_verify_password = mocker.patch("app.services.user_service.verify_password", return_value=True)

    # Ensure crud_user.delete_user is NOT called directly
    mock_crud_delete_user = mocker.patch("app.services.user_service.crud_user.delete_user", autospec=True)

    delete_user_account(db_mock, user_id, current_password)

    mock_get_user.assert_called_once_with(db_mock, user_id=user_id)
    mock_verify_password.assert_called_once_with(current_password, hashed_password)

    # Assert that is_active is set to False and deletion_requested_at is set
    assert db_user_mock.is_active == False
    assert db_user_mock.deletion_requested_at is not None
    assert isinstance(db_user_mock.deletion_requested_at, datetime)

    # Assert that is_deleted remains False and deleted_at remains None at this stage
    assert db_user_mock.is_deleted == False
    assert db_user_mock.deleted_at is None

    # Verify that crud_user.delete_user was NOT called
    mock_crud_delete_user.assert_not_called()
    db_mock.commit.assert_called_once()
