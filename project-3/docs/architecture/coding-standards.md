# Coding Standards

## Core Standards

*   **Languages & Runtimes:** All Python code must be compatible with **Python 3.11**.
*   **Style & Linting:** We will use **Ruff** for all linting and code formatting. It is an extremely fast, all-in-one tool that replaces Black, isort, and Flake8. Configuration will be stored in `pyproject.toml` to enforce a single, consistent style.
*   **Test Organization:** All tests must be placed in the `/tests` directory. Test files must be named `test_*.py`. The **Arrange-Act-Assert** pattern must be used within tests.

## Naming Conventions

We will adhere strictly to the standard **PEP 8** style guide for all Python code. No project-specific deviations are defined.

## Critical Rules for AI Agents

These rules are non-negotiable and must be followed in all generated code:

1.  **Use the Service Layer:** All business logic MUST be implemented in files within the `app/services/` directory. The API layer (`app/api/`) is strictly for handling HTTP requests/responses and calling the service layer.
2.  **Use the CRUD/Repository Layer:** All database interactions MUST go through functions defined in the `app/crud/` directory. Do NOT use SQLAlchemy models or sessions directly in the API or service layers.
3.  **Use Dependency Injection:** All dependencies (e.g., database sessions, service classes) MUST be acquired using FastAPI's `Depends` system in the API layer. Do not create instances of services or sessions manually within endpoint functions.
4.  **No Secrets in Code:** NEVER hardcode secrets (passwords, API keys, etc.). All configuration MUST be loaded from the environment via the Pydantic `Settings` object in `app/core/config.py`.
5.  **Raise Specific Exceptions:** For all business logic errors (e.g., user not found, email already exists), raise a specific custom exception from the service layer. Do not return `None` or raise generic `Exception`s.

## Language-Specific Guidelines

No additional language-specific guidelines are needed. The combination of Ruff and the critical rules above is sufficient.

---
