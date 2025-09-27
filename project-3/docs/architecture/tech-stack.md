# Tech Stack

## Cloud Infrastructure

*   **Provider:** **AWS (Recommended)**, GCP, or Azure
*   **Key Services:**
    *   **Compute:** Amazon ECS (Elastic Container Service) with Fargate for serverless container execution.
    *   **Database:** Amazon RDS for PostgreSQL for a managed database service.
    *   **Container Registry:** Amazon ECR (Elastic Container Registry) to store Docker images.
*   **Deployment Regions:** To be determined based on user location (e.g., `us-east-1`).

## Technology Stack Table

| Category | Technology | Version | Purpose | Rationale |
| :--- | :--- | :--- | :--- | :--- |
| **Language** | Python | 3.11 | Primary backend language | Modern, stable, and widely supported with a rich ecosystem for web development. |
| **Runtime** | Node.js | 20.x LTS | JS runtime for tooling/frontend | Required for many modern frontend frameworks (like the suggested Next.js). |
| **Backend Framework** | FastAPI | ~0.110.0 | Core backend framework | High-performance, easy to learn, and includes automatic API docs. |
| **Web Server** | Uvicorn | ~0.27.0 | ASGI web server | A lightning-fast ASGI server, required for running FastAPI. |
| **ORM** | SQLAlchemy | ~2.0 | Database object-relational mapper | The de-facto standard for Python SQL toolkits, providing robust data mapping. |
| **DB Migration** | Alembic | ~1.13.0 | Database migration tool | Handles database schema changes in a structured, versioned way. Integrates with SQLAlchemy. |
| **Security** | Passlib[bcrypt] | ~1.7.4 | Password hashing | Provides strong, one-way hashing for securely storing user passwords. |
| **Security** | python-jose | ~3.3.0 | JWT handling | For creating, signing, and verifying JSON Web Tokens for authentication. |
| **Configuration** | pydantic-settings | ~2.1.0 | Configuration management | Manages application settings from environment variables and .env files. |
| **Package Manager** | uv | ~0.1.15 | Python package management | An extremely fast and modern package manager for Python. |
| **Database** | PostgreSQL | 16 | Relational database | Powerful, open-source, and reliable object-relational database system. |
| **Infrastructure** | Docker & Docker Compose | latest | Containerization | To create, deploy, and run the application in isolated containers for consistency. |
| **Frontend** | Next.js | latest | React framework for frontend | Provides server-side rendering, static site generation, and a great developer experience for React applications. |
| **Frontend UI** | Material-UI | latest | React UI component library | Comprehensive suite of UI tools to implement Google's Material Design. |
| **Frontend State** | Redux Toolkit | latest | State management for React | Official opinionated toolset for efficient Redux development. |
| **Frontend Data Fetching** | RTK Query | latest | Data fetching and caching for Redux | Built on Redux Toolkit, simplifies data fetching, caching, and invalidation. |
| **Frontend HTTP Client** | Axios | latest | Promise-based HTTP client | Widely used for making HTTP requests from the browser and Node.js. |

---
