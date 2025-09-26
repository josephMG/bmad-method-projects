import uuid
from datetime import datetime, timedelta

import pytest
from freezegun import freeze_time
from httpx import AsyncClient
from sqlalchemy.orm import Session

from app.core.security import get_password_hash
from app.crud.crud_user import soft_delete_users_marked_for_deletion
from app.models.user import User


@pytest.mark.asyncio()
async def test_update_user_profile_success(
    client: AsyncClient,
    test_db: Session,
    create_test_user_and_token,
):
    user_id, token = create_test_user_and_token
    user = test_db.query(User).filter(User.id == user_id).first()

    update_data = {"full_name": "Updated Name", "email": "updated@example.com"}

    prev_updated_at = user.updated_at
    response = await client.put(
        "/api/v1/users/me",
        json=update_data,
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 200
    data = response.json()
    assert data["full_name"] == "Updated Name"
    assert data["email"] == "updated@example.com"
    assert "updated_at" in data

    # Verify in database
    updated_user_from_db = test_db.query(User).filter(User.id == user.id).first()
    assert updated_user_from_db.full_name == "Updated Name"
    assert updated_user_from_db.email == "updated@example.com"
    assert updated_user_from_db.updated_at != prev_updated_at
    # Check if timestamp was updated
    assert isinstance(updated_user_from_db.updated_at, datetime)


@pytest.mark.asyncio()
async def test_update_user_profile_invalid_email_format(
    client: AsyncClient,
    create_test_user_and_token,
):
    _, token = create_test_user_and_token

    update_data = {"email": "invalid-email"}

    response = await client.put(
        "/api/v1/users/me",
        json=update_data,
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 422  # Unprocessable Entity for validation errors
    assert "value is not a valid email address" in response.json()["detail"][0]["msg"]


@pytest.mark.asyncio()
async def test_update_user_profile_duplicate_email(
    client: AsyncClient,
    test_db: Session,
    create_test_user_and_token,
):
    user, token = create_test_user_and_token

    # Create another user with an email that will cause a conflict
    duplicate_email_user = User(
        id=uuid.uuid4(),
        email="duplicate@example.com",
        username="duplicateuser",
        hashed_password=get_password_hash("password"),
        is_active=True,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )
    test_db.add(duplicate_email_user)
    test_db.commit()
    test_db.refresh(duplicate_email_user)

    update_data = {"email": "duplicate@example.com"}

    response = await client.put(
        "/api/v1/users/me",
        json=update_data,
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "Email already registered"


@pytest.mark.asyncio()
async def test_update_user_profile_unauthenticated(client: AsyncClient):
    update_data = {"full_name": "Unauthorized User"}

    response = await client.put("/api/v1/users/me", json=update_data)

    assert response.status_code == 401
    assert response.json()["detail"] == "Not authenticated"


@pytest.mark.asyncio()
async def test_update_user_profile_updated_at_verification(
    client: AsyncClient,
    test_db: Session,
    create_test_user_and_token,
):
    user_id, token = create_test_user_and_token
    user = test_db.query(User).filter(User.id == user_id).first()

    # Ensure initial updated_at is recorded
    initial_updated_at = user.updated_at

    # Wait a bit to ensure updated_at changes
    await client.put(
        "/api/v1/users/me",
        json={"full_name": "Another Name"},
        headers={"Authorization": f"Bearer {token}"},
    )

    updated_user_from_db = test_db.query(User).filter(User.id == user.id).first()
    assert updated_user_from_db.updated_at != initial_updated_at
    assert isinstance(updated_user_from_db.updated_at, datetime)
    assert updated_user_from_db.full_name == "Another Name"


@pytest.mark.asyncio()
async def test_delete_user_account_marks_for_deletion_success(
    client: AsyncClient,
    test_db: Session,
    create_test_user_and_token,
):
    user_id, token = create_test_user_and_token
    response = await client.request(
        "DELETE",
        "/api/v1/users/me",
        json={"current_password": "testpassword"},
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 204

    # Verify user is marked for deletion in the database
    user_marked_for_deletion = test_db.query(User).filter(User.id == user_id).first()
    assert user_marked_for_deletion is not None
    assert user_marked_for_deletion.is_active is False
    assert user_marked_for_deletion.is_deleted is False  # Not immediately soft-deleted
    assert user_marked_for_deletion.deletion_requested_at is not None
    assert isinstance(user_marked_for_deletion.deletion_requested_at, datetime)

    # Verify user is not retrievable via API (due to is_active=False)
    response_get = await client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response_get.status_code == 404  # UserNotFoundException from service layer


@pytest.mark.asyncio()
async def test_delete_user_account_unauthenticated(client: AsyncClient):
    response = await client.delete("/api/v1/users/me")

    assert response.status_code == 401
    assert response.json()["detail"] == "Not authenticated"


@pytest.mark.asyncio()
async def test_delete_user_account_already_marked_for_deletion(
    client: AsyncClient,
    test_db: Session,
    create_test_user_and_token,
):
    user_id, token = create_test_user_and_token

    # Mark the user for deletion first
    await client.request(
        "DELETE",
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
        json={"current_password": "testpassword"},
    )

    # Attempt to delete again (user already marked for deletion)
    response = await client.request(
        "DELETE",
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
        json={"current_password": "testpassword"},
    )
    assert response.status_code == 404  # Should return 404 if user is already inactive

    user_after_second_request = test_db.query(User).filter(User.id == user_id).first()
    assert user_after_second_request.is_active is False
    assert user_after_second_request.is_deleted is False
    assert user_after_second_request.deletion_requested_at is not None


@pytest.mark.asyncio()
async def test_delete_user_account_reauthentication_success(
    client: AsyncClient,
    test_db: Session,
    create_test_user_and_token,
):
    user_id, token = create_test_user_and_token

    response = await client.request(
        "DELETE",
        "/api/v1/users/me",
        json={"current_password": "testpassword"},
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 204
    # Verify user is marked for deletion in the database
    user_marked_for_deletion = test_db.query(User).filter(User.id == user_id).first()
    assert user_marked_for_deletion is not None
    assert user_marked_for_deletion.is_active is False
    assert user_marked_for_deletion.is_deleted is False
    assert user_marked_for_deletion.deletion_requested_at is not None
    assert isinstance(user_marked_for_deletion.deletion_requested_at, datetime)

    # Verify user is not retrievable via API (due to is_active=False)
    response_get = await client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response_get.status_code == 404  # UserNotFoundException from service layer


@pytest.mark.asyncio()
async def test_delete_user_account_reauthentication_incorrect_password(
    client: AsyncClient,
    test_db: Session,
    create_test_user_and_token,
):
    user_id, token = create_test_user_and_token

    response = await client.request(
        "DELETE",
        "/api/v1/users/me",
        json={"current_password": "wrongpassword"},
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "Incorrect current password"
    # Verify user is NOT deleted from the database
    user_still_exists = test_db.query(User).filter(User.id == user_id).first()
    assert user_still_exists is not None


@pytest.mark.asyncio()
async def test_delete_user_account_delayed_deletion_flow(
    client: AsyncClient,
    test_db: Session,
    create_test_user_and_token,
):
    user_id, token = create_test_user_and_token

    # 1. Request user deletion
    response = await client.request(
        "DELETE",
        "/api/v1/users/me",
        json={"current_password": "testpassword"},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 204

    # 2. Verify that the user is marked for deletion (is_active=False, deletion_requested_at is set, is_deleted=False)
    user_after_request = test_db.query(User).filter(User.id == user_id).first()
    assert user_after_request is not None
    assert user_after_request.is_active is False
    assert user_after_request.is_deleted is False
    assert user_after_request.deletion_requested_at is not None
    assert isinstance(user_after_request.deletion_requested_at, datetime)

    # 3. Simulate the passage of 24 hours
    with freeze_time(datetime.utcnow() + timedelta(hours=24, minutes=1)):
        # 4. Call the soft_delete_users_marked_for_deletion function
        soft_delete_users_marked_for_deletion(test_db)
        test_db.refresh(user_after_request)

        # 5. Verify that the user is now fully soft-deleted (is_deleted=True, deleted_at is set)
        user_after_delayed_delete = (
            test_db.query(User).filter(User.id == user_id).first()
        )
        assert user_after_delayed_delete is not None
        assert user_after_delayed_delete.is_active is False
        assert user_after_delayed_delete.is_deleted is True
        assert user_after_delayed_delete.deleted_at is not None
        assert isinstance(user_after_delayed_delete.deleted_at, datetime)
        assert user_after_delayed_delete.deletion_requested_at is not None

    # Verify user is not retrievable via API after full deletion
    response_get = await client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response_get.status_code == 404  # UserNotFoundException from service layer
