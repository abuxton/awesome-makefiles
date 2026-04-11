---
name: makefile-golang
description: Makefile targets for Go projects — build, test, lint, cross-compile, and release
---

# Makefile Go (golang) Targets

Standard Makefile targets for Go projects.

## When to use

Use this skill when:
- Creating or improving a Makefile for a Go module or workspace
- Adding CI targets for a Go project
- Cross-compiling Go binaries for multiple platforms

## Instructions

### Core variables

```makefile
MODULE      := $(shell go list -m 2>/dev/null || echo "unknown")
BINARY      ?= $(notdir $(CURDIR))
BUILD_DIR   ?= bin
GO          ?= go
GOFLAGS     ?=
VERSION     ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT_SHA  ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "none")
BUILD_DATE  ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
LDFLAGS     := -s -w \
               -X main.version=$(VERSION) \
               -X main.commit=$(COMMIT_SHA) \
               -X main.date=$(BUILD_DATE)
```

### Standard targets

```makefile
.PHONY: build build-debug test lint fmt vet clean deps tidy

build: ## Build release binary
	$(GO) build $(GOFLAGS) -ldflags "$(LDFLAGS)" -o $(BUILD_DIR)/$(BINARY) ./...

build-debug: ## Build debug binary (race detector)
	$(GO) build -race -o $(BUILD_DIR)/$(BINARY)-debug ./...

test: ## Run unit tests with coverage
	$(GO) test -v -race -coverprofile=coverage.out -covermode=atomic ./...

test-coverage: test ## Open HTML coverage report
	$(GO) tool cover -html=coverage.out

lint: ## Run golangci-lint
	golangci-lint run ./...

fmt: ## Format all Go files
	$(GO) fmt ./...

vet: ## Run go vet
	$(GO) vet ./...

deps: ## Download module dependencies
	$(GO) mod download

tidy: ## Tidy and verify module graph
	$(GO) mod tidy
	$(GO) mod verify

clean: ## Remove build artefacts
	rm -rf $(BUILD_DIR)/ coverage.out
```

### Cross-compilation

```makefile
PLATFORMS ?= linux/amd64 linux/arm64 darwin/amd64 darwin/arm64 windows/amd64

.PHONY: build-all
build-all: ## Cross-compile for all target platforms
	@for platform in $(PLATFORMS); do \
	  GOOS=$$(echo $$platform | cut -d/ -f1); \
	  GOARCH=$$(echo $$platform | cut -d/ -f2); \
	  ext=""; [ "$$GOOS" = "windows" ] && ext=".exe"; \
	  echo "Building $$GOOS/$$GOARCH"; \
	  GOOS=$$GOOS GOARCH=$$GOARCH \
	    $(GO) build -ldflags "$(LDFLAGS)" \
	    -o $(BUILD_DIR)/$(BINARY)-$$GOOS-$$GOARCH$$ext ./...; \
	done
```

### Generate and mock

```makefile
.PHONY: generate
generate: ## Run go generate across the module
	$(GO) generate ./...
```

### Benchmarks

```makefile
.PHONY: bench
bench: ## Run benchmarks
	$(GO) test -bench=. -benchmem ./...
```

### Full CI gate

```makefile
.PHONY: ci
ci: deps fmt vet lint test build ## Full CI pipeline
```

### Best practices

- Set `CGO_ENABLED=0` when building container images to produce a statically linked binary.
- Use `go mod tidy` in CI and fail if `go.sum` changes.
- Run `go vet` and `staticcheck` (or `golangci-lint`) before merging.
- Store coverage reports as CI artefacts for trend tracking.
