DOCKER_USER ?= yourdockerhubuser
TAG        ?= latest
VITE_API_URL ?= http://localhost:30800

.PHONY: up down logs migrate makemigration build push helm-install helm-upgrade test

up:
	docker compose up --build

down:
	docker compose down

logs:
	docker compose logs -f

migrate:
	docker compose run --rm backend alembic upgrade head

# Usage: make makemigration name="add users table"
makemigration:
	docker compose run --rm backend alembic revision --autogenerate -m "$(name)"

build:
	docker build -t $(DOCKER_USER)/dinspin-backend:$(TAG) ./backend
	docker build --build-arg VITE_API_URL=$(VITE_API_URL) -t $(DOCKER_USER)/dinspin-frontend:$(TAG) ./frontend

push:
	docker push $(DOCKER_USER)/dinspin-backend:$(TAG)
	docker push $(DOCKER_USER)/dinspin-frontend:$(TAG)

helm-install:
	helm install dinspin ./helm/dinspin --wait \
	  --set secret.postgresPassword=changeme \
	  --set backend.image=$(DOCKER_USER)/dinspin-backend \
	  --set backend.tag=$(TAG) \
	  --set frontend.image=$(DOCKER_USER)/dinspin-frontend \
	  --set frontend.tag=$(TAG) \
	  --set migrations.tag=$(TAG)

test:
	cd bruno && bru run meals --env local

helm-upgrade:
	helm upgrade dinspin ./helm/dinspin \
	  --set secret.postgresPassword=changeme \
	  --set backend.image=$(DOCKER_USER)/dinspin-backend \
	  --set backend.tag=$(TAG) \
	  --set frontend.image=$(DOCKER_USER)/dinspin-frontend \
	  --set frontend.tag=$(TAG) \
	  --set migrations.tag=$(TAG)
