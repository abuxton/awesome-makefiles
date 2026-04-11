SHELL := /bin/bash
.DEFAULT_GOAL := help

# -------------------------------------------------
# Variables
# -------------------------------------------------
MODULE      := $(shell go list -m 2>/dev/null || echo "unknown")
BINARY      ?= $(notdir $(CURDIR))
BUILD_DIR   ?= bin
GO          ?= go
VERSION     ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT_SHA  ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "none")
BUILD_DATE  ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
LDFLAGS     := -s -w \
               -X main.version=$(VERSION) \
               -X main.commit=$(COMMIT_SHA) \
               -X main.date=$(BUILD_DATE)
PLATFORMS   ?= linux/amd64 linux/arm64 darwin/amd64 darwin/arm64

# -------------------------------------------------
# Core targets
# -------------------------------------------------
.PHONY: build build-debug build-all test test-coverage lint fmt vet deps tidy clean ci

build: ## Build release binary
	$(GO) build -ldflags "$(LDFLAGS)" -o $(BUILD_DIR)/$(BINARY) ./...

build-debug: ## Build debug binary (race detector)
	$(GO) build -race -o $(BUILD_DIR)/$(BINARY)-debug ./...

build-all: ## Cross-compile for all platforms
	@for platform in $(PLATFORMS); do \
	  GOOS=$$(echo $$platform | cut -d/ -f1); \
	  GOARCH=$$(echo $$platform | cut -d/ -f2); \
	  ext=""; [ "$$GOOS" = "windows" ] && ext=".exe"; \
	  echo "building $$GOOS/$$GOARCH"; \
	  GOOS=$$GOOS GOARCH=$$GOARCH \
	    $(GO) build -ldflags "$(LDFLAGS)" \
	    -o $(BUILD_DIR)/$(BINARY)-$$GOOS-$$GOARCH$$ext ./...; \
	done

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

ci: deps fmt vet lint test build ## Full CI pipeline

# -------------------------------------------------
# Help
# -------------------------------------------------
.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$$$' $(MAKEFILE_LIST) | sort \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$$$1, $$$$2}'
