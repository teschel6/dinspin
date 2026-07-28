# Dinner Spinner

A self hosted web app to answer the age old question of "Whats for dinner?"

- This app is mostly vibe coded 🤖 use at your own peril

<img width="665" height="556" alt="image" src="https://github.com/user-attachments/assets/a6f256c5-430c-4f74-a9ad-8ca471893109" />

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
# Build both images (no backend URL baked in — same image works anywhere)
make build DOCKER_USER=yourdockerhubuser TAG=abc1234

# Push to Docker Hub
make push DOCKER_USER=yourdockerhubuser TAG=abc1234
```

## Deploying to Kubernetes

### Using `make`

```bash
# First install (--wait ensures postgres is ready before the post-install migrations job runs)
make helm-install DOCKER_USER=yourdockerhubuser TAG=abc1234 API_URL=http://homeserver-ip:30800 NAMESPACE=dinspin

# Subsequent deploys (triggers pre-upgrade migrations job before rolling out new pods)
make helm-upgrade DOCKER_USER=yourdockerhubuser TAG=abc1234 API_URL=http://homeserver-ip:30800 NAMESPACE=dinspin
```
