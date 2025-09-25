# Source Tree

This is the proposed directory structure for the User Management service:

```plaintext
user-management-service/
├── alembic/                    # Alembic migration scripts
│   ├── versions/               # Individual migration files
│   └── env.py                  # Alembic configuration
├── app/                        # Main application source code
│   ├── __init__.py
│   ├── api/                    # API layer with versioned routers
│   │   ├── __init__.py
│   │   └── v1/
│   │       ├── __init__.py
│   │       └── endpoints/
│   │           ├── auth.py
│   │           └── users.py
│   ├── core/                   # Core logic: config, security
│   │   ├── __init__.py
│   │   ├── config.py           # Pydantic settings
│   │   └── security.py         # JWT and password logic
│   ├── crud/                   # Data Access Layer (CRUD functions)
│   │   ├── __init__.py
│   │   └── crud_user.py
│   ├── db/                     # Database session management
│   │   ├── __init__.py
│   │   └── session.py
│   ├── models/                 # SQLAlchemy ORM models
│   │   ├── __init__.py
│   │   └── user.py
│   ├── schemas/                # Pydantic API schemas
│   │   ├── __init__.py
│   │   └── user.py
│   └── services/               # Business Logic Layer
│       ├── __init__.py
│       └── user_service.py
├── tests/                      # Application tests
│   ├── __init__.py
│   └── conftest.py             # Pytest fixtures and test setup
├── .env.example                # Example environment variables
├── .gitignore
├── main.py                     # Application entry point (Uvicorn starts here)
└── pyproject.toml              # Project dependencies and metadata (for uv)
```

---
