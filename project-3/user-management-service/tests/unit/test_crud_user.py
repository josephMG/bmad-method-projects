import uuid
from datetime import datetime, timedelta
from unittest.mock import MagicMock

from app.crud.crud_user import soft_delete_users_marked_for_deletion
from app.models.user import User


def test_soft_delete_users_marked_for_deletion_success(mocker):
    db_mock = MagicMock()

    # Create mock users
    user_to_delete_1 = User(
        id=uuid.uuid4(),
        email="delete1@example.com",
        username="deleteuser1",
        hashed_password="hashed",
        is_active=False,
        is_deleted=False,
        deletion_requested_at=datetime.utcnow() - timedelta(hours=25),
    )
    user_to_delete_2 = User(
        id=uuid.uuid4(),
        email="delete2@example.com",
        username="deleteuser2",
        hashed_password="hashed",
        is_active=False,
        is_deleted=False,
        deletion_requested_at=datetime.utcnow() - timedelta(days=2),
    )
    user_not_to_delete_active = User(
        id=uuid.uuid4(),
        email="active@example.com",
        username="activeuser",
        hashed_password="hashed",
        is_active=True,
        is_deleted=False,
        deletion_requested_at=datetime.utcnow() - timedelta(hours=25),
    )
    user_not_to_delete_recent_request = User(
        id=uuid.uuid4(),
        email="recent@example.com",
        username="recentuser",
        hashed_password="hashed",
        is_active=False,
        is_deleted=False,
        deletion_requested_at=datetime.utcnow() - timedelta(hours=23),
    )
    user_already_deleted = User(
        id=uuid.uuid4(),
        email="already@example.com",
        username="alreadydeleted",
        hashed_password="hashed",
        is_active=False,
        is_deleted=True,
        deletion_requested_at=datetime.utcnow() - timedelta(hours=25),
        deleted_at=datetime.utcnow() - timedelta(hours=1),
    )

    db_mock.query.return_value.filter.return_value.all.return_value = [
        user_to_delete_1, user_to_delete_2,
    ]

    soft_delete_users_marked_for_deletion(db_mock)

    # Assertions for users that should be soft-deleted
    assert user_to_delete_1.is_deleted == True
    assert user_to_delete_1.deleted_at is not None
    assert user_to_delete_2.is_deleted == True
    assert user_to_delete_2.deleted_at is not None

    # Assertions for users that should NOT be soft-deleted
    assert user_not_to_delete_active.is_deleted == False
    assert user_not_to_delete_active.deleted_at is None
    assert user_not_to_delete_recent_request.is_deleted == False
    assert user_not_to_delete_recent_request.deleted_at is None
    assert user_already_deleted.is_deleted == True # Should remain True
    assert user_already_deleted.deleted_at is not None # Should remain its original value

    db_mock.commit.assert_called_once()
