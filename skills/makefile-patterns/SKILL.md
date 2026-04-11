---
name: makefile-patterns
description: Common reusable Makefile patterns, recipes, and idioms for productive developer workflows
---

# Makefile Patterns

Reusable patterns and idioms for productive, readable Makefiles.

## When to use

Use this skill when:
- Adding common workflow targets (build, test, lint, release, docker, …)
- Looking for a reusable recipe for a specific language or tool
- Applying consistent conventions across multiple Makefiles in a mono-repo

## Instructions

### Environment file loading

Load a `.env` file when present so secrets stay out of the Makefile:

```makefile
-include .env
export
```

### Versioning from Git

```makefile
VERSION     ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT_SHA  ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE  ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
```

### Guard / require variable pattern

```makefile
require-%:
	@[ -n "$($*)" ] || (echo "ERROR: $* is required"; exit 1)

deploy: require-ENV require-VERSION
	./deploy.sh $(ENV) $(VERSION)
```

### Recursive repo-root detection

```makefile
REPO_TOP := $(shell git rev-parse --show-toplevel)
```

### Directory creation helper

```makefile
$(OBJDIR) $(BINDIR):
	mkdir -p $@
```

### Clean pattern

```makefile
.PHONY: clean
clean: ## Remove build artefacts
	rm -rf $(BINDIR) $(OBJDIR) dist/ *.out *.log
```

### Watch / live-reload target

```makefile
.PHONY: watch
watch: ## Watch source files and re-run on changes (requires entr)
	find . -name '*.go' | entr -r $(MAKE) build
```

### Parallel targets

```makefile
.PHONY: ci
ci: ## Run all checks in parallel
	$(MAKE) -j4 lint test build
```

### Multi-platform Docker build

```makefile
REGISTRY   ?= ghcr.io
IMAGE_NAME ?= $(REGISTRY)/$(shell basename $(CURDIR))
PLATFORMS  ?= linux/amd64,linux/arm64

.PHONY: docker-build-push
docker-build-push: ## Build and push multi-platform image
	docker buildx build \
	  --platform $(PLATFORMS) \
	  --tag $(IMAGE_NAME):$(VERSION) \
	  --push .
```

### Semantic-version bump helpers

```makefile
SEMVER_BUMP ?= patch  # patch | minor | major

.PHONY: release
release: ## Tag a new semver release (SEMVER_BUMP=patch|minor|major)
	@current=$$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0"); \
	 next=$$(npx semver -i $(SEMVER_BUMP) $$current); \
	 git tag -a "v$$next" -m "Release v$$next"; \
	 git push origin "v$$next"
```

### Mono-repo include pattern

In a mono-repo, keep shared targets in `common/mk/*.mk` and include them:

```makefile
REPO_TOP := $(shell git rev-parse --show-toplevel)
-include $(REPO_TOP)/common/mk/core.mk
-include $(REPO_TOP)/common/mk/docker.mk
```

### Conditional OS detection

```makefile
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
  OPEN_CMD := xdg-open
endif
ifeq ($(UNAME_S),Darwin)
  OPEN_CMD := open
endif
```

### Colorised output helper

```makefile
RESET  := \033[0m
BOLD   := \033[1m
GREEN  := \033[32m
YELLOW := \033[33m
CYAN   := \033[36m

define log
  @printf "$(BOLD)$(CYAN)▶ %s$(RESET)\n" "$(1)"
endef
```
