# Infrastructure and Deployment

## Infrastructure as Code (IaC)

*   **Tool:** **Terraform (~1.7)** will be used for provisioning and managing cloud infrastructure.
    *   *Rationale:* Terraform is a cloud-agnostic, widely-adopted standard that allows us to define our infrastructure declaratively, ensuring it is versioned and repeatable.
*   **Location:** IaC code will reside in an `infrastructure/` directory at the root of the service's repository.
*   **Approach:** Terraform will be used to define all necessary AWS resources, including the ECS cluster, Fargate task definitions, RDS for PostgreSQL instance, networking (VPC, subnets), and security groups.

## Deployment Strategy

*   **Strategy:** **Blue/Green Deployment**. When a new version is deployed, a new "green" environment is created alongside the existing "blue" environment. Traffic is only switched to the green environment after it passes health checks. The old blue environment is kept on standby for a short period to allow for instant rollbacks.
    *   *Rationale:* This strategy provides zero-downtime deployments and minimizes risk.
*   **CI/CD Platform:** **GitHub Actions**.
    *   *Rationale:* It integrates seamlessly with GitHub repositories and provides a robust, configurable platform for building, testing, and deploying our containerized application.
*   **Pipeline Configuration:** The CI/CD pipeline will be defined in `.github/workflows/deploy.yml`.

## Environments

*   **Development:** Local developer environment managed via `docker-compose`. This allows for rapid testing and iteration.
*   **Staging:** A production-like environment hosted on AWS. Deployed automatically on merges to the `develop` branch. Used for integration testing and QA.
*   **Production:** The live environment serving end-users. Deployed automatically on merges to the `main` branch after successful staging deployment.

## Environment Promotion Flow

The promotion of code from development to production will follow a standard GitFlow-like model:

`Feature Branch -> Pull Request -> `develop` Branch (Deploys to Staging) -> Pull Request -> `main` Branch (Deploys to Production)`

## Rollback Strategy

*   **Primary Method:** With a Blue/Green strategy, a rollback is achieved by simply redirecting traffic back to the previous, stable "blue" environment. This is a near-instantaneous operation.
*   **Trigger Conditions:** Rollbacks can be triggered automatically by a high rate of application errors (>1% 5xx errors) detected by monitoring tools post-deployment, or manually if an issue is discovered.
*   **Recovery Time Objective (RTO):** < 5 minutes.

---
