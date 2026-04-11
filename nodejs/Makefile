SHELL := /bin/bash
.DEFAULT_GOAL := help

# -------------------------------------------------
# Variables
# -------------------------------------------------
PKG_MANAGER  ?= npm
INSTALL_CMD  ?= $(PKG_MANAGER) ci
BUILD_DIR    ?= dist
NODE_MODULES := node_modules/.package-lock.json

VERSION  ?= $(shell node -p "require('./package.json').version" 2>/dev/null || echo "dev")

# -------------------------------------------------
# Dependency installation (stamp-file pattern)
# -------------------------------------------------
$(NODE_MODULES): package.json package-lock.json
	$(INSTALL_CMD)
	touch $@

.PHONY: install
install: $(NODE_MODULES) ## Install npm dependencies

# -------------------------------------------------
# Core targets
# -------------------------------------------------
.PHONY: build test lint fmt type-check clean ci

build: install ## Compile / bundle the project
	$(PKG_MANAGER) run build

test: install ## Run the test suite
	$(PKG_MANAGER) run test

lint: install ## Lint the source code
	$(PKG_MANAGER) run lint

fmt: install ## Auto-format source files
	$(PKG_MANAGER) run format

type-check: install ## TypeScript type-check (no emit)
	$(PKG_MANAGER) exec tsc --noEmit

clean: ## Remove build artefacts
	rm -rf $(BUILD_DIR)/ node_modules/

ci: install lint type-check test build ## Full CI pipeline

# -------------------------------------------------
# Help
# -------------------------------------------------
.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
