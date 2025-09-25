"""
Business logic for user-related operations.
"""
from uuid import UUID
from uuid import UUID
from uuid import UUID
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from datetime import datetime
from app.crud import crud_user
from app.schemas.user import UserCreate, PasswordUpdate, UserUpdate
from app.core.security import get_password_hash, verify_password
from app.models.user import User


class UserNotFoundException(HTTPException):
    def __init__(self):
        super().__init__(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")


class DuplicateEmailException(HTTPException):
    def __init__(self):
        super().__init__(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")


def create_user_service(db: Session, user: UserCreate) -> User:
    """
    Service to create a new user.
    """
    db_user_by_email = crud_user.get_user_by_email(db, email=user.email)
    if db_user_by_email:
        raise DuplicateEmailException()
    db_user_by_username = crud_user.get_user_by_username(db, username=user.username)
    if db_user_by_username:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered",
        )

    hashed_password = get_password_hash(user.password)
    return crud_user.create_user(db=db, user=user, hashed_password=hashed_password)

def update_user_profile(
    db: Session, user_id: int, user_update: UserUpdate
) -> User:
    """
    Service to update a user's profile information.
    """
    db_user = crud_user.get_user(db, user_id=user_id)
    if not db_user:
        raise UserNotFoundException()

    if user_update.email and user_update.email != db_user.email:
        existing_user = crud_user.get_user_by_email(db, email=user_update.email)
        if existing_user and existing_user.id != user_id:
            raise DuplicateEmailException()

    update_data = user_update.model_dump(exclude_unset=True)
    return crud_user.update_user(db, db_user=db_user, obj_in=update_data)

def change_user_password_service(
    db: Session, user: User, password_update: PasswordUpdate
) -> User:
    """
    Service to change a user's password.
    """
    if not verify_password(password_update.current_password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect current password",
        )

    hashed_password = get_password_hash(password_update.new_password)
    return crud_user.update_user_password(db=db, user=user, hashed_password=hashed_password)

def delete_user_account(db: Session, user_id: int, current_password: str):
    """
    Service to delete a user's account.
    """
    db_user = crud_user.get_user(db, user_id=user_id)
    if not db_user:
        raise UserNotFoundException()

    if not verify_password(current_password, db_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect current password",
        )
    crud_user.delete_user(db, user_id=user_id)
    db_user.is_active = False
    db.commit()