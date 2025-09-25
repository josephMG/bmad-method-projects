# Security

## Input Validation

*   **Validation Library:** **Pydantic**. It is integrated directly into FastAPI.
*   **Validation Location:** Strictly at the **API Boundary**. All data from an incoming request is validated by a Pydantic schema before it ever reaches the business logic.
*   **Required Rules:** We will use a whitelist approach; any unknown fields in a request body will be rejected.

## Authentication & Authorization

*   **Auth Method:** **JWT (JSON Web Tokens)** sent via the `Authorization: Bearer <token>` header.
*   **Session Management:** The system is **100% stateless**. No server-side sessions will be used.
*   **Required Patterns:** A reusable FastAPI dependency will be created to validate the JWT on protected endpoints and retrieve the current user. This dependency will be required for any endpoint that accesses or modifies user-specific data.

## Secrets Management

*   **Development:** Secrets (e.g., database passwords) will be stored in a local `.env` file, which **MUST** be included in `.gitignore`.
*   **Production:** Secrets will be injected as **environment variables** by the hosting environment (e.g., AWS Secrets Manager feeding into the ECS task definition).
*   **Code Requirements:** Secrets must NEVER be hardcoded. They must only be accessed via the central Pydantic `Settings` object.

## API Security

*   **Rate Limiting:** *(Post-MVP)* A middleware will be added to limit the number of requests per user to prevent abuse.
*   **CORS Policy:** A CORS (Cross-Origin Resource Sharing) middleware will be configured to only allow requests from the specific, approved frontend application's domain.
*   **HTTPS Enforcement:** The production load balancer will enforce HTTPS on all connections.

## Data Protection

*   **Encryption at Rest:** The production database (AWS RDS) will have encryption at rest enabled.
*   **Encryption in Transit:** All network traffic will be encrypted using TLS (HTTPS).
*   **PII Handling:** The only sensitive PII is the user's password, which MUST only be stored after being strongly hashed with `bcrypt`.
*   **Logging Restrictions:** Under no circumstances should plaintext passwords, API keys, or JWTs be logged.

## Dependency Security

*   **Scanning Tool:** We will use **GitHub's Dependabot** to automatically scan for known vulnerabilities in our third-party packages.
*   **Update Policy:** Dependabot will be configured to automatically create pull requests to update vulnerable dependencies.

## Security Testing

*   **SAST Tool:** The `Bandit` static analysis tool will be integrated into the CI/CD pipeline to run on every pull request, scanning for common Python security issues.

---
