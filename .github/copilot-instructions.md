# GitHub Copilot Instructions — awesome-makefiles

This repository is a curated collection of **Makefiles, .mk fragments, and AI skills** for common developer workflows. It is also the reference implementation for a GitHub Copilot Coding Space focused on Makefile expertise.

## Repository structure

| Path | Contents |
|------|----------|
| `makefile` | Root repo-management Makefile |
| `common/mk/` | Shared `.mk` fragments (include from any sub-Makefile) |
| `common/bin/` | Helper scripts called by Make targets |
| `ansible/` | Ansible workflow Makefile |
| `cpp/` | C/C++ build Makefile |
| `docker/` | Docker & Compose Makefile |
| `go-lang/` | Go project Makefile |
| `hashicorp/terraform/` | Terraform workflow Makefile |
| `nodejs/` | Node.js / npm Makefile |
| `python/` | Python virtualenv Makefile |
| `rust/` | Rust / Cargo Makefile + `.mk` fragment |
| `skills/` | AI skill packages (SKILL.md) for Copilot agents |

## Coding conventions

- **Tabs only** — recipe lines must use a real tab character, never spaces.
- **`.PHONY`** — declare every non-file target as `.PHONY`.
- **`.DEFAULT_GOAL := help`** — every Makefile should have a self-documenting `help` target.
- **Self-doc pattern** — annotate targets with `## description` and generate help via `grep + awk`.
- **Variable overrides** — use `?=` for user-overridable variables; document them near the top.
- **`-include .env`** — load `.env` when present; never commit secrets.
- **`$(MAKE)`** — use `$(MAKE)` for recursive invocations, never bare `make`.
- **Portability** — avoid GNU Make 4-only features when targeting macOS (which ships Make 3.x).

## Skills

The `skills/` directory contains SKILL.md files that teach Copilot agents how to work with Makefiles. When a user asks for help with a Makefile topic, apply the relevant skill:

- `makefile-basics` — syntax, variables, `.PHONY`, automatic variables
- `makefile-patterns` — common recipes and idioms
- `makefile-debugging` — `make -n`, `--trace`, `--debug`, pitfall table
- `makefile-ci` — CI/CD integration patterns
- `makefile-docker` — Docker image and Compose targets
- `makefile-golang` — Go module targets, cross-compilation
- `makefile-python` — Python virtualenv, pytest, ruff, mypy
- `makefile-nodejs` — npm/pnpm install stamp, build, test, type-check

## When helping with Makefiles

1. Always check whether a relevant skill exists in `skills/` first.
2. Follow the conventions above when generating new Makefiles.
3. Use the `help` target pattern so users can discover all targets.
4. Suggest `-include .env` for projects that need environment variables.
5. Recommend `.PHONY` for every target that isn't an actual file.
6. Prefer `$(MAKE)` over bare `make` in recipes.
7. When writing multi-line shell in a recipe, always use `&&` to chain or `;` with proper error propagation.
