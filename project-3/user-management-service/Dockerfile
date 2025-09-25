FROM python:3.11-slim-bookworm

WORKDIR /app

# Install uv
RUN pip install uv

# Copy dependency files and install dependencies
COPY ./pyproject.toml /app/
RUN uv sync
RUN uv pip install ruff

# Copy the rest of the application code
COPY ./app /app/app
COPY ./alembic /app/alembic
COPY ./alembic.ini /app/
COPY ./main.py /app/

# Copy scripts
COPY --chmod=755 ./scripts/wait-for-it.sh /app/scripts/wait-for-it.sh
COPY --chmod=755 ./entrypoint.sh /app/entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]