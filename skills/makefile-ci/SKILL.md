---
name: makefile-ci
description: Integrating Makefiles with CI/CD pipelines (GitHub Actions, GitLab CI, Jenkins, etc.)
---

# Makefile CI/CD Integration

Patterns for using Makefiles as the single entrypoint for CI/CD pipelines.

## When to use

Use this skill when:
- Wiring Makefile targets into a CI/CD workflow
- Ensuring the same commands run locally and in CI
- Adding targets that produce artefacts or reports for pipeline consumption

## Instructions

### CI-safe defaults

```makefile
# Disable interactive prompts and colour when running in CI
CI ?= false
ifeq ($(CI),true)
  DOCKER_FLAGS += --no-cache
  NPM_FLAGS    += --ci --no-progress
endif
```

### Standard target contract

Define these targets in every repo so pipelines can call them without knowing the stack:

| Target | Purpose |
|--------|---------|
| `make deps` | Install / download all dependencies |
| `make lint` | Static analysis / style check |
| `make test` | Run the test suite |
| `make build` | Compile / package the application |
| `make ci` | Run `deps lint test build` in sequence |
| `make clean` | Remove all generated artefacts |

### GitHub Actions integration

```yaml
# .github/workflows/ci.yml
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install deps
        run: make deps
      - name: Lint
        run: make lint
      - name: Test
        run: make test
      - name: Build
        run: make build
```

### Caching in CI

Pass the cache directory as a variable so CI can persist it:

```makefile
CACHE_DIR ?= .cache

deps: $(CACHE_DIR)/.deps-stamp
$(CACHE_DIR)/.deps-stamp:
	mkdir -p $(CACHE_DIR)
	npm ci --cache $(CACHE_DIR)/npm
	touch $@
```

### Reporting artefacts

```makefile
COVERAGE_DIR ?= coverage
TEST_RESULTS  ?= test-results.xml

.PHONY: test
test: ## Run tests and write coverage + JUnit report
	go test ./... \
	  -coverprofile=$(COVERAGE_DIR)/coverage.out \
	  -v 2>&1 | tee $(TEST_RESULTS)
```

### Docker layer caching in CI

```makefile
CACHE_FROM ?= type=gha
CACHE_TO   ?= type=gha,mode=max

.PHONY: docker-build
docker-build: ## Build image (CI-aware layer caching)
	docker buildx build \
	  --cache-from=$(CACHE_FROM) \
	  --cache-to=$(CACHE_TO) \
	  --tag $(IMAGE):$(VERSION) .
```

### Secrets / environment hygiene

- Never hard-code secrets in a Makefile; read them from environment variables.
- Document required env vars in a `.env.example` file.
- In CI, inject via the platform secret store (e.g. GitHub Actions `secrets`).

```makefile
ifndef REGISTRY_TOKEN
  $(error REGISTRY_TOKEN must be set for docker-push)
endif
```

### Idempotency

Targets should be safe to run multiple times. Use `.stamp` files or `$(shell test …)` guards:

```makefile
.cache/.install-stamp: package.json
	npm ci
	mkdir -p .cache && touch $@
```
