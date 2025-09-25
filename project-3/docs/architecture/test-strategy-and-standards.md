# Test Strategy and Standards

## Testing Philosophy

*   **Approach:** We will follow a **Test-After Development** approach. Tests will be written immediately after a feature is implemented. All code must be accompanied by tests in the same pull request.
*   **Coverage Goals:** We will aim for **>90%** code coverage on critical business logic (`services`) and data access (`crud`) layers, with an overall project coverage target of **>85%**.
*   **Test Pyramid:** We will maintain a balanced test pyramid: a wide base of fast **Unit Tests**, a smaller layer of **Integration Tests**, and a minimal set of **End-to-End (E2E) Tests** (post-MVP).

## Test Types and Organization

*   **Unit Tests**
    *   **Framework:** **Pytest**
    *   **Location & Convention:** `tests/unit/test_*.py`
    *   **Mocking Library:** Python's built-in `unittest.mock`.
    *   **AI Agent Requirements:**
        *   Generate tests for all public methods and functions.
        *   Mock all external dependencies (e.g., mock the data access layer when testing the service layer).
        *   Follow the Arrange-Act-Assert pattern.

*   **Integration Tests**
    *   **Scope:** To test the service from the API boundary down to a real database, ensuring all layers work together correctly.
    *   **Location:** `tests/integration/`
    *   **Test Infrastructure:**
        *   **Database:** We will use **Testcontainers** to programmatically spin up a real PostgreSQL Docker container for the test suite. This ensures our tests run against an environment that is identical to production.

*   **End-to-End (E2E) Tests**
    *   **Framework:** *(Post-MVP)* **Pytest with Playwright**.
    *   **Scope:** *(Post-MVP)* To test critical user journeys (like registration and login) by automating a real browser against a deployed `Staging` environment.

## Test Data Management

*   **Strategy:** We will use the **Factory pattern** (with a library like `factory-boy`) to create consistent, reusable test data.
*   **Fixtures:** Reusable test setup, such as database connections or authenticated user clients, will be managed using **Pytest fixtures** in `conftest.py`.
*   **Cleanup:** Each test will run inside an isolated database transaction that is automatically rolled back after the test completes, ensuring a clean state for every test and preventing side effects.

## Continuous Testing

*   **CI Integration:** The GitHub Actions CI pipeline will run the full suite of unit and integration tests on every pull request. Merging will be blocked if tests fail or if coverage drops below the target.
*   **Security Tests:** We will integrate the `Bandit` static analysis security tool into the CI pipeline to automatically scan for common Python security issues.

---
