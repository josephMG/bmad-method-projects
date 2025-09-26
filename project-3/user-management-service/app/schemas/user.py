"""Pydantic schemas for User model.
"""
import datetime
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field


class UserBase(BaseModel):
    """Base schema for user attributes.
    """
    email: EmailStr = Field(..., example="user@example.com")
    username: str = Field(..., min_length=3, max_length=50, example="testuser")
    full_name: str | None = Field(None, max_length=100, example="Test User")

class UserCreate(UserBase):
    """Schema for creating a new user.
    """
    password: str = Field(..., min_length=8, example="a_strong_password")

class UserRead(UserBase):
    """Schema for reading user data.
    """
    id: UUID
    is_active: bool
    created_at: datetime.datetime
    updated_at: datetime.datetime

    class Config:
        from_attributes = True

class Token(BaseModel):
    """Schema for the JWT access token.
    """
    access_token: str
    token_type: str = "bearer"

class TokenData(BaseModel):
    """Schema for the data encoded in the JWT.
    """
    username: str | None = None

class UserUpdate(BaseModel):
    """Schema for updating user profile information.
    """
    full_name: str | None = Field(None, max_length=100, example="Updated User Name")
    email: EmailStr | None = Field(None, example="updated_email@example.com")

class PasswordUpdate(BaseModel):
    """Schema for updating a user's password.
    """
    current_password: str = Field(..., example="CurrentSecurePassword123")
    new_password: str = Field(..., min_length=8, example="NewSecurePassword456")

class UserDelete(BaseModel):
    """Schema for user deletion, requiring current password for re-authentication.
    """
    current_password: str = Field(..., example="CurrentSecurePassword123")
