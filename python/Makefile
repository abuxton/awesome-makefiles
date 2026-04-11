SHELL := /bin/bash
.DEFAULT_GOAL := help

# -------------------------------------------------
# Variables
# -------------------------------------------------
PYTHON      ?= python3
VENV        ?= .venv
PIP         ?= $(VENV)/bin/pip
PYTEST      ?= $(VENV)/bin/pytest
RUFF        ?= $(VENV)/bin/ruff
MYPY        ?= $(VENV)/bin/mypy
BUILD_DIR   ?= dist
SRC         ?= src

VERSION     ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")

# -------------------------------------------------
# Virtualenv bootstrap (stamp-file pattern)
# -------------------------------------------------
$(VENV)/.stamp: pyproject.toml
	$(PYTHON) -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -e ".[dev]"
	touch $@

.PHONY: venv
venv: $(VENV)/.stamp ## Create / update virtual environment

# -------------------------------------------------
# Core targets
# -------------------------------------------------
.PHONY: install test lint fmt type-check clean build publish ci

install: venv ## Install project and dev dependencies

test: venv ## Run pytest with coverage
	$(PYTEST) --cov=$(SRC) --cov-report=term-missing --cov-report=xml -v

lint: venv ## Lint with ruff
	$(RUFF) check $(SRC) tests/

fmt: venv ## Format source files with ruff
	$(RUFF) format $(SRC) tests/

type-check: venv ## Type-check with mypy
	$(MYPY) $(SRC)

clean: ## Remove build artefacts and caches
	rm -rf $(BUILD_DIR)/ .eggs/ *.egg-info/ .pytest_cache/ .mypy_cache/ \
	       .ruff_cache/ htmlcov/ .coverage coverage.xml $(VENV)/

build: venv ## Build wheel and sdist
	$(VENV)/bin/python -m build

publish: build ## Upload to PyPI (requires TWINE_USERNAME / TWINE_PASSWORD)
	$(VENV)/bin/twine upload $(BUILD_DIR)/*

ci: install lint type-check test build ## Full CI pipeline

# -------------------------------------------------
# Help
# -------------------------------------------------
.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
