---
name: makefile-nodejs
description: Makefile targets for Node.js / npm / pnpm projects — install, build, test, lint, and release
---

# Makefile Node.js Targets

Standard Makefile targets for Node.js projects.

## When to use

Use this skill when:
- Adding a Makefile to a Node.js, TypeScript, or frontend project
- Standardising workflows across npm / yarn / pnpm workspaces
- Providing a consistent `make ci` entrypoint regardless of the JS toolchain

## Instructions

### Core variables

```makefile
NODE        ?= node
NPM         ?= npm
# Swap to 'yarn' or 'pnpm' as needed
PKG_MANAGER ?= npm
INSTALL_CMD ?= $(PKG_MANAGER) ci
BUILD_DIR   ?= dist
NODE_MODULES := node_modules/.package-lock.json
```

### Dependency installation stamp

```makefile
$(NODE_MODULES): package.json package-lock.json
	$(INSTALL_CMD)
	touch $@

.PHONY: install
install: $(NODE_MODULES) ## Install npm dependencies (cached via stamp file)
```

### Standard targets

```makefile
.PHONY: build test lint fmt type-check clean

build: install ## Compile / bundle the project
	$(PKG_MANAGER) run build

test: install ## Run the test suite
	$(PKG_MANAGER) run test

lint: install ## Run ESLint / biome / oxc
	$(PKG_MANAGER) run lint

fmt: install ## Auto-format with prettier / biome
	$(PKG_MANAGER) run format

type-check: install ## Run TypeScript type checking
	$(PKG_MANAGER) exec tsc --noEmit

clean: ## Remove build artefacts
	rm -rf $(BUILD_DIR)/ node_modules/
```

### Version bump and release

```makefile
SEMVER_BUMP ?= patch  # patch | minor | major

.PHONY: release
release: ## Bump version, tag, and push (SEMVER_BUMP=patch|minor|major)
	$(PKG_MANAGER) version $(SEMVER_BUMP) --no-git-tag-version
	git add package.json package-lock.json
	git commit -m "chore: release v$$(node -p "require('./package.json').version")"
	git tag "v$$(node -p "require('./package.json').version")"
	git push && git push --tags
```

### Docker build for Node app

```makefile
IMAGE_NAME ?= $(notdir $(CURDIR))
VERSION    ?= $(shell node -p "require('./package.json').version" 2>/dev/null || echo "dev")

.PHONY: docker-build
docker-build: ## Build Docker image for this Node app
	docker build --build-arg NODE_VERSION=$(shell node --version | tr -d 'v') \
	  --tag $(IMAGE_NAME):$(VERSION) .
```

### npm workspace helpers

```makefile
.PHONY: ws-build ws-test
ws-build: ## Build all workspace packages
	$(PKG_MANAGER) run --workspaces build

ws-test: ## Test all workspace packages
	$(PKG_MANAGER) run --workspaces test
```

### Full CI gate

```makefile
.PHONY: ci
ci: install lint type-check test build ## Full CI pipeline
```

### Best practices

- Commit `package-lock.json` (npm) or `pnpm-lock.yaml` and use `ci` install commands in CI.
- Use the stamp-file pattern (`node_modules/.package-lock.json`) to avoid re-installing when lock file unchanged.
- Run `tsc --noEmit` and `eslint` as separate steps so failures are clearly attributed.
- Cache `node_modules` in CI keyed on the lock-file hash.
