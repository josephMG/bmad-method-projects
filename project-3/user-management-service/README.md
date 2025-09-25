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