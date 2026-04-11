SHELL := /bin/bash
.DEFAULT_GOAL := help

# -------------------------------------------------
# Variables — override from CLI or .env
# -------------------------------------------------
-include .env

REGISTRY    ?= ghcr.io
IMAGE_OWNER ?= $(shell git config --get remote.origin.url 2>/dev/null \
                  | sed 's|.*[:/]\([^/]*/[^.]*\).*|\1|' | tr '[:upper:]' '[:lower:]')
IMAGE_NAME  ?= $(REGISTRY)/$(IMAGE_OWNER)/$(notdir $(CURDIR))
VERSION     ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
PORT        ?= 8080
PLATFORMS   ?= linux/amd64,linux/arm64
COMPOSE_FILE ?= docker-compose.yml

# -------------------------------------------------
# Image targets
# -------------------------------------------------
.PHONY: docker-build docker-push docker-pull docker-run docker-stop \
        docker-buildx docker-scan docker-clean

docker-build: ## Build the Docker image
	docker build \
	  --build-arg VERSION=$(VERSION) \
	  --tag $(IMAGE_NAME):$(VERSION) \
	  --tag $(IMAGE_NAME):latest \
	  .

docker-push: docker-build ## Push image to registry
	docker push $(IMAGE_NAME):$(VERSION)
	docker push $(IMAGE_NAME):latest

docker-pull: ## Pull latest image from registry
	docker pull $(IMAGE_NAME):latest

docker-run: ## Run container locally
	docker run --rm -it \
	  --env-file .env \
	  -p $(PORT):$(PORT) \
	  $(IMAGE_NAME):$(VERSION)

docker-stop: ## Stop all running containers from this image
	docker ps -q --filter "ancestor=$(IMAGE_NAME)" | xargs -r docker stop

docker-buildx: ## Multi-arch build and push with buildx
	docker buildx build \
	  --platform $(PLATFORMS) \
	  --build-arg VERSION=$(VERSION) \
	  --tag $(IMAGE_NAME):$(VERSION) \
	  --push .

docker-scan: docker-build ## Scan image for vulnerabilities with Trivy
	trivy image $(IMAGE_NAME):$(VERSION)

docker-clean: ## Remove local image(s)
	docker rmi -f $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):latest 2>/dev/null || true

# -------------------------------------------------
# Compose targets
# -------------------------------------------------
.PHONY: up down logs ps

up: ## Start all compose services
	docker compose -f $(COMPOSE_FILE) up -d

down: ## Stop and remove compose services
	docker compose -f $(COMPOSE_FILE) down

logs: ## Tail compose logs (SERVICE= to filter)
	docker compose -f $(COMPOSE_FILE) logs -f $(SERVICE)

ps: ## List compose services
	docker compose -f $(COMPOSE_FILE) ps

# -------------------------------------------------
# Help
# -------------------------------------------------
.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
