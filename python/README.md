# Makefiles for Python projects

This Makefile provides a standard set of targets for Python projects using a
virtual environment managed by `venv`, with `ruff` for linting/formatting and
`mypy` for type-checking.

## Usage

```shell
make install       # create .venv and install dependencies
make test          # run pytest with coverage
make lint          # lint with ruff
make fmt           # format with ruff
make type-check    # type-check with mypy
make build         # build wheel + sdist
make ci            # full CI pipeline
```

## Requirements

- Python 3.10+
- A `pyproject.toml` with an optional `[dev]` extra (or a `requirements-dev.txt`)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PYTHON` | `python3` | Python interpreter |
| `VENV` | `.venv` | Virtual environment directory |
| `SRC` | `src` | Source package directory |
| `BUILD_DIR` | `dist` | Build output directory |
