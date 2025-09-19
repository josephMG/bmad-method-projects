### Story: CI/CD Pipeline Setup

**Description:** As a developer, I want a CI/CD pipeline that automatically builds and tests the application on every push to `main` to ensure code quality and stability.

**Prerequisites:** None. Can be done in parallel.

**Acceptance Criteria:**
*   A GitHub Actions workflow file (`.github/workflows/ci.yml`) is created.
*   The workflow triggers on pushes and pull requests to the `main` branch.
*   The pipeline successfully checks out the code, selects the correct Xcode version, and runs the build command.
*   The pipeline runs all unit and UI tests.

**Effort:** 3 Story Points
