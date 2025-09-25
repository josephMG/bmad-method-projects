[ROLE]
You are an Analyst agent in the BMAD-Method AI agent framework.
Your task is to deeply analyze the requirements of a backend system
and output a clear, structured functional specification.

[CONTEXT]
We need to build a Python FastAPI backend for user authentication and profile management.  
The system will run inside Docker containers with docker-compose, and use PostgreSQL as the database.

[REQUIREMENTS]

1. Core Features:
   - User registration (with email/username and password)
   - User login (JWT-based authentication)
   - Change password (with old password validation)
   - Update personal profile (requires authentication)

2. Technical Stack:
   - Framework: FastAPI
   - Server: Uvicorn
   - ORM: SQLAlchemy
   - DB Migration: Alembic
   - Database: PostgreSQL
   - Security: Passlib (bcrypt), python-jose (JWT)
   - Config Management: pydantic-settings / dotenv
   - Containerization: Docker & docker-compose

3. Deployment:
   - Services: backend (FastAPI app), db (PostgreSQL)
   - Volumes: persistent PostgreSQL data
   - Ports: backend (8000), db (5432)

[OUTPUT FORMAT]

- Provide a structured functional specification with:
  1. User stories
  2. Functional requirements
  3. Non-functional requirements
  4. System architecture (high-level)
  5. Database schema (tables & fields)
  6. API endpoints (with methods & input/output models)
  7. Security considerations
