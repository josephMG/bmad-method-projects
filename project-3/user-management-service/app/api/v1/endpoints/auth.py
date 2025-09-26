"""API endpoints for user authentication (registration and login).
"""
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app import schemas
from app.core import security
from app.crud import crud_user
from app.db.session import get_db
from app.services import user_service

router = APIRouter()

@router.post("/register", response_model=schemas.user.UserRead, status_code=status.HTTP_201_CREATED)
def register_user(user: schemas.user.UserCreate, db: Session = Depends(get_db)):
    """Register a new user.
    """
    return user_service.create_user_service(db=db, user=user)

@router.post("/token", response_model=schemas.user.Token)
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    """Log in a user to get a JWT access token.
    """
    user = crud_user.get_user_by_username(db, username=form_data.username)
    if not user or not security.verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = security.create_access_token(
        data={"sub": user.username},
    )
    return {"access_token": access_token, "token_type": "bearer"}
