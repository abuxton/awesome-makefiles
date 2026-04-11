---
name: makefile-python
description: Makefile targets for Python projects — virtualenv, testing, linting, packaging, and publishing
---

# Makefile Python Targets

Standard Makefile targets for Python projects.

## When to use

Use this skill when:
- Adding a Makefile to a Python project (library or application)
- Standardising dev workflows (virtual env, testing, linting, publishing)
- Onboarding contributors with a single `make help` entry point

## Instructions

### Core variables

```makefile
PYTHON      ?= python3
VENV        ?= .venv
PIP         ?= $(VENV)/bin/pip
PYTEST      ?= $(VENV)/bin/pytest
RUFF        ?= $(VENV)/bin/ruff
MYPY        ?= $(VENV)/bin/mypy
BUILD_DIR   ?= dist
SRC         ?= src
```

### Virtualenv bootstrap

```makefile
$(VENV)/.stamp: requirements*.txt pyproject.toml
	$(PYTHON) -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -e ".[dev]"
	touch $@

.PHONY: venv
venv: $(VENV)/.stamp ## Create / update virtual environment
```

### Standard targets

```makefile
.PHONY: install test lint fmt type-check clean build publish

install: venv ## Install project and dev dependencies

test: venv ## Run pytest with coverage
	$(PYTEST) --cov=$(SRC) --cov-report=term-missing --cov-report=xml -v

lint: venv ## Lint with ruff
	$(RUFF) check $(SRC) tests/

fmt: venv ## Format with ruff
	$(RUFF) format $(SRC) tests/

type-check: venv ## Type-check with mypy
	$(MYPY) $(SRC)

clean: ## Remove build artefacts and caches
	rm -rf $(BUILD_DIR)/ .eggs/ *.egg-info/ .pytest_cache/ .mypy_cache/ \
	       .ruff_cache/ htmlcov/ .coverage coverage.xml

build: venv ## Build wheel and sdist
	$(VENV)/bin/python -m build

publish: build ## Upload to PyPI (requires TWINE_USERNAME / TWINE_PASSWORD)
	$(VENV)/bin/twine upload $(BUILD_DIR)/*
```

### Pre-commit integration

```makefile
.PHONY: pre-commit-install pre-commit
pre-commit-install: venv ## Install pre-commit hooks
	$(VENV)/bin/pre-commit install

pre-commit: venv ## Run all pre-commit hooks
	$(VENV)/bin/pre-commit run --all-files
```

### Full CI gate

```makefile
.PHONY: ci
ci: install lint type-check test build ## Full CI pipeline
```

### Best practices

- Commit `requirements.txt` (pinned) for reproducible installs; keep `pyproject.toml` for package metadata.
- Use `pip-compile` (from `pip-tools`) to regenerate pinned requirements from abstract dependencies.
- Run `ruff format --check` (not `--fix`) in CI to fail on unformatted code without modifying files.
- Cache `$(VENV)` in CI using the hash of `requirements*.txt` as the cache key.
