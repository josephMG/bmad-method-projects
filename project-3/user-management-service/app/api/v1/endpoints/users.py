from typing import Annotated

from fastapi import APIRouter, Depends, status, Response
from sqlalchemy.orm import Session

from app.api.v1 import dependencies
from app.models.user import User
from app.schemas import user as user_schema
from app.schemas.user import PasswordUpdate, UserUpdate, UserDelete
from app.services import user_service
from app.db.session import get_db

router = APIRouter()

@router.get("/users/me", response_model=user_schema.UserRead)
def read_users_me(current_user: Annotated[User, Depends(dependencies.get_current_user)]):
    """Get current user.
    """
    return current_user

@router.put("/users/me", response_model=user_schema.UserRead)
def update_users_me(
    user_update: UserUpdate,
    current_user: Annotated[User, Depends(dependencies.get_current_user)],
    db: Session = Depends(get_db)
):
    """
    Update current user's profile information.
    """
    updated_user = user_service.update_user_profile(
        db, current_user.id, user_update
    )
    return updated_user

@router.put("/users/me/password", status_code=status.HTTP_204_NO_CONTENT)
def change_password(
    password_update: PasswordUpdate,
    current_user: Annotated[User, Depends(dependencies.get_current_user)],
    db: Session = Depends(get_db)
):
    """
    Change the authenticated user's password.
    """
    user_service.change_user_password_service(db, current_user, password_update)
    return Response(status_code=status.HTTP_204_NO_CONTENT)

@router.delete("/users/me", status_code=status.HTTP_204_NO_CONTENT)
def delete_users_me(
    user_delete: user_schema.UserDelete,
    current_user: Annotated[User, Depends(dependencies.get_current_user)],
    db: Session = Depends(get_db)
):
    """
    Delete current user's account.
    """
    user_service.delete_user_account(db, current_user.id, user_delete.current_password)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
