---
name: makefile-docker
description: Makefile targets for building, tagging, pushing, and running Docker containers
---

# Makefile Docker Targets

Standard targets for managing Docker images and containers via Make.

## When to use

Use this skill when:
- Writing Docker-related Makefile targets
- Standardising image build/push/run workflows
- Integrating `docker compose` lifecycle into Make

## Instructions

### Core variables

```makefile
REGISTRY   ?= ghcr.io
IMAGE_OWNER ?= $(shell git config --get remote.origin.url | sed 's|.*[:/]\([^/]*/[^.]*\).*|\1|' | tr '[:upper:]' '[:lower:]')
IMAGE_NAME  ?= $(REGISTRY)/$(IMAGE_OWNER)/$(notdir $(CURDIR))
VERSION     ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
```

### Standard targets

```makefile
.PHONY: docker-build docker-push docker-pull docker-run docker-stop docker-clean

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

docker-stop: ## Stop all containers from this image
	docker ps -q --filter "ancestor=$(IMAGE_NAME)" | xargs -r docker stop

docker-clean: ## Remove local image(s)
	docker rmi -f $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):latest 2>/dev/null || true
```

### Multi-platform buildx

```makefile
PLATFORMS ?= linux/amd64,linux/arm64

.PHONY: docker-buildx
docker-buildx: ## Multi-arch build and push with buildx
	docker buildx build \
	  --platform $(PLATFORMS) \
	  --build-arg VERSION=$(VERSION) \
	  --tag $(IMAGE_NAME):$(VERSION) \
	  --push .
```

### Docker Compose helpers

```makefile
COMPOSE_FILE ?= docker-compose.yml

.PHONY: up down logs ps

up: ## Start all services
	docker compose -f $(COMPOSE_FILE) up -d

down: ## Stop and remove all services
	docker compose -f $(COMPOSE_FILE) down

logs: ## Tail compose service logs (SERVICE= to filter)
	docker compose -f $(COMPOSE_FILE) logs -f $(SERVICE)

ps: ## Show running compose services
	docker compose -f $(COMPOSE_FILE) ps
```

### Scanning for vulnerabilities

```makefile
.PHONY: docker-scan
docker-scan: docker-build ## Scan image with Trivy
	trivy image $(IMAGE_NAME):$(VERSION)
```

### Build-arg pattern for secrets (BuildKit)

```makefile
.PHONY: docker-build-secret
docker-build-secret: ## Build with SSH/secret mount (requires BuildKit)
	DOCKER_BUILDKIT=1 docker build \
	  --secret id=npmrc,src=$(HOME)/.npmrc \
	  --tag $(IMAGE_NAME):$(VERSION) .
```

### Best practices

- Pin base image digests in `Dockerfile` for reproducibility.
- Use `.dockerignore` to exclude build artefacts and secrets.
- Never bake secrets into layers; use `--secret` or build-time args for non-sensitive config only.
- Tag images with both a specific version and `latest` for convenience.
