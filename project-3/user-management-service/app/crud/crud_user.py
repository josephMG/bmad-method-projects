"""
CRUD operations for User model.
"""

from uuid import UUID
from uuid import UUID
from datetime import datetime

from sqlalchemy.orm import Session

from app.models.user import User
from app.schemas.user import UserCreate


def get_user(db: Session, user_id: UUID) -> User | None:
    """
    Get an active, non-deleted user by ID.
    """
    return db.query(User).filter(User.id == user_id, User.is_deleted == False).first()


def get_user_by_email(db: Session, email: str) -> User | None:
    """
    Get an active, non-deleted user by email.
    """
    return db.query(User).filter(User.email == email, User.is_deleted == False).first()


def get_user_by_username(db: Session, username: str) -> User | None:
    """
    Get an active, non-deleted user by username.
    """
    return db.query(User).filter(User.username == username, User.is_deleted == False).first()


def create_user(db: Session, user: UserCreate, hashed_password: str) -> User:
    """
    Create a new user.
    """
    db_user = User(
        email=user.email,
        username=user.username,
        full_name=user.full_name,
        hashed_password=hashed_password,
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def update_user(db: Session, db_user: User, obj_in: dict) -> User:
    """
    Update a user's attributes.
    """
    for field, value in obj_in.items():
        setattr(db_user, field, value)
    db_user.updated_at = datetime.utcnow()  # Explicitly set updated_at
    db.commit()
    db.refresh(db_user)
    return db_user


def update_user_password(db: Session, user: User, hashed_password: str) -> User:
    """
    Update a user's password.
    """
    user.hashed_password = hashed_password
    db.commit()
    db.refresh(user)
    return user

def delete_user(db: Session, user_id: UUID):
    """
    Soft delete a user by ID.
    """
    db_user = db.query(User).filter(User.id == user_id).first()
    if db_user:
        db_user.is_deleted = True
        db_user.deleted_at = datetime.utcnow()
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
