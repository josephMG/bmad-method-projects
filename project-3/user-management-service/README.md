# User Management Service

## Running Tests

To run the tests for this service, use the following `docker-compose` command:

```bash
docker-compose run --rm test pytest tests/
```

### Command Breakdown:

*   `docker-compose run`: This command executes a one-off command on a service defined in your `docker-compose.yml`.
*   `--rm`: This flag ensures that the test container is automatically removed after it exits, keeping your system clean.
*   `test`: This specifies the service named `test` in your `docker-compose.yml`. This service is configured to build from `Dockerfile.test` and includes all necessary dependencies and database access for testing.
*   `pytest tests/`: This is the command executed inside the `test` service container. It instructs `pytest` to discover and run all test files located within the `tests/` directory.

## Accessing Containers and Database

### Accessing the Application Container (app)

To run commands directly within the `app` container (e.g., for development or debugging):

```bash
docker-compose exec app bash
```

Once inside the container, you can execute Python commands using `uv run` (e.g., `uv run python your_script.py` or `uv run alembic ...`).

### Accessing the Database Container (db)

To access the PostgreSQL database directly (e.g., to inspect data or run SQL queries):

1.  **Access the `db` container's bash shell:**
    ```bash
    docker-compose exec db bash
    ```

2.  **Connect to the PostgreSQL database:**
    Once inside the `db` container, you can connect to the `user_management_db` using `psql`:
    ```bash
    psql -U user --password -d user_management_db
    ```
    When prompted, enter the password `password` (as defined in `docker-compose.yml`).