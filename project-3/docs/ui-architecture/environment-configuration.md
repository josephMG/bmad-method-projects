# Environment Configuration

### Required Environment Variables
- `NEXT_PUBLIC_API_BASE_URL`: The base URL for the backend API (e.g., `http://app:8000/api/v1` when running with `docker-compose`).

### Example `.env.local` (for local development outside of docker-compose):
```
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000/api/v1
```

### Example `docker-compose.yml` (for development with Docker):
```yaml
  nextjs-frontend:
    # ... other configurations ...
    environment:
      NEXT_PUBLIC_API_BASE_URL: http://app:8000/api/v1
```