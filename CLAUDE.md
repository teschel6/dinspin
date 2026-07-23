# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

- **Backend**: FastAPI (Python 3.12), SQLAlchemy 2.x, Alembic migrations, psycopg2
- **Frontend**: Vue 3, Vite, served via nginx in production
- **Database**: PostgreSQL 16
- **Deployment**: Helm chart targeting a single-node home server with NodePort services (no ingress)
- **Images**: Pushed to Docker Hub

## Local development

```bash
# Start all services (postgres, backend with hot-reload, frontend with HMR)
make up

# Run migrations against the local docker-compose postgres
make migrate

# Generate a new migration after adding/changing SQLAlchemy models
make makemigration name="add users table"
```

Frontend dev server: http://localhost:5173  
Backend API: http://localhost:8000  
Backend docs: http://localhost:8000/docs

## Building and pushing images

```bash
# Build both images (VITE_API_URL baked in at build time)
make build DOCKER_USER=yourdockerhubuser TAG=abc1234 VITE_API_URL=http://homeserver-ip:30800

# Push to Docker Hub
make push DOCKER_USER=yourdockerhubuser TAG=abc1234
```

`VITE_API_URL` is embedded into the frontend bundle at build time via Vite's `import.meta.env`. It must point to the backend's NodePort address as seen from the browser.

## Deploying to Kubernetes

```bash
# First install (--wait ensures postgres is ready before the post-install migrations job runs)
make helm-install DOCKER_USER=yourdockerhubuser TAG=abc1234 VITE_API_URL=http://homeserver-ip:30800

# Subsequent deploys (triggers pre-upgrade migrations job before rolling out new pods)
make helm-upgrade DOCKER_USER=yourdockerhubuser TAG=abc1234
```

Always pass the real `secret.postgresPassword` via `--set` or a `values.secret.yaml` kept out of git.

## Architecture

### Backend (`backend/`)

- `app/config.py` — `Settings` (pydantic-settings); reads `DATABASE_URL` from env
- `app/database.py` — SQLAlchemy engine, `SessionLocal`, `Base` (DeclarativeBase), `get_db` dependency
- `app/main.py` — FastAPI app instance; add routers here

When adding models: define them in `app/models/` (or `app/models.py`), import them in `alembic/env.py` so autogenerate can detect schema changes.

### Alembic

Migrations live in `backend/alembic/versions/`. `alembic/env.py` reads `DATABASE_URL` from the environment — the value in `alembic.ini` is a placeholder and is always overridden.

### Frontend (`frontend/`)

- `src/config.js` — exports `apiUrl` derived from `VITE_API_URL` env var
- `src/App.vue` — root component; add routes/views from here

### Helm chart (`helm/dinspin/`)

- One `Secret` (`-db-secret`) holds all DB credentials and the full `DATABASE_URL`
- Postgres runs as a `Deployment` (single replica) backed by a `PersistentVolumeClaim`
- Migrations run as a Helm hook `Job` (`post-install` and `pre-upgrade`) using the backend image with `alembic upgrade head`
- Frontend and backend are each a `Deployment` + `NodePort` Service
- NodePorts: frontend `30080`, backend `30800`

### Migration hook behaviour

- **`post-install`**: fires after all resources (including postgres) are deployed. Use `--wait` so postgres is ready before the job runs.
- **`pre-upgrade`**: fires before new pods roll out, guaranteeing schema is current before the new backend version starts.
- Failed jobs are kept for debugging; succeeded jobs are cleaned up automatically.
- Migrations must be backward-compatible with the currently running backend version (additive changes only within a single release).
