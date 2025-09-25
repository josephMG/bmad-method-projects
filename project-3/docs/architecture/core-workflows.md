# Core Workflows

## 1. User Registration Workflow

This diagram illustrates the process of a new user successfully registering.

```mermaid
sequenceDiagram
    participant User
    participant API Layer
    participant Business Logic
    participant Security Component
    participant Data Access Layer

    User->>+API Layer: POST /register (email, password)
    API Layer->>+Business Logic: register_user(email, password)
    Business Logic->>+Data Access Layer: get_user_by_email(email)
    Data Access Layer-->>-Business Logic: (user not found)
    Business Logic->>+Security Component: hash_password(password)
    Security Component-->>-Business Logic: hashed_password
    Business Logic->>+Data Access Layer: create_user(email, hashed_password)
    Data Access Layer-->>-Business Logic: new_user
    Business Logic-->>-API Layer: (registration successful)
    API Layer-->>-User: HTTP 201 Created
```

## 2. User Login Workflow

This diagram illustrates a registered user successfully logging in and receiving a JWT.

```mermaid
sequenceDiagram
    participant User
    participant API Layer
    participant Business Logic
    participant Security Component
    participant Data Access Layer

    User->>+API Layer: POST /login (email, password)
    API Layer->>+Business Logic: authenticate_user(email, password)
    Business Logic->>+Data Access Layer: get_user_by_email(email)
    Data Access Layer-->>-Business Logic: user_record
    Business Logic->>+Security Component: verify_password(password, user_record.hashed_password)
    Security Component-->>-Business Logic: (password is valid)
    Business Logic->>+Security Component: create_access_token(user_id)
    Security Component-->>-BusinessLogic: jwt_token
    Business Logic-->>-API Layer: jwt_token
    API Layer-->>-User: { "access_token": "...", "token_type": "bearer" }
```

---
