# Makefile AI Skills

This directory contains [SKILL.md](https://skills.sh) packages for GitHub Copilot coding agents.
Each skill instructs the agent on a specific aspect of working with GNU Makefiles.

## Skills inventory

| Skill | File | Description |
|-------|------|-------------|
| `makefile-basics` | [SKILL.md](makefile-basics/SKILL.md) | Core syntax, variables, `.PHONY`, automatic variables, portability |
| `makefile-patterns` | [SKILL.md](makefile-patterns/SKILL.md) | Common reusable patterns (`.env` loading, versioning, guards, watch, release) |
| `makefile-debugging` | [SKILL.md](makefile-debugging/SKILL.md) | `make -n`, `--trace`, `--debug`, pitfall table, circular dependency detection |
| `makefile-ci` | [SKILL.md](makefile-ci/SKILL.md) | CI/CD integration (GitHub Actions, caching, artefacts, idempotency) |
| `makefile-docker` | [SKILL.md](makefile-docker/SKILL.md) | Docker build/push/scan, multi-arch buildx, Compose lifecycle |
| `makefile-golang` | [SKILL.md](makefile-golang/SKILL.md) | Go module targets, ldflags, cross-compilation, CI gate |
| `makefile-python` | [SKILL.md](makefile-python/SKILL.md) | Python venv stamp, pytest, ruff, mypy, build, publish |
| `makefile-nodejs` | [SKILL.md](makefile-nodejs/SKILL.md) | npm/pnpm stamp install, build, test, type-check, workspace helpers |

## Usage with `npx skills`

```shell
# Restore all skills from the lock file (project-level)
npx skills experimental_install

# List installed skills
npx skills list

# Browse the skills registry for more skills
npx skills find makefile
```

## Skill format

Each skill is a directory containing a `SKILL.md` file with YAML frontmatter:

```markdown
---
name: skill-name
description: Brief description of what the skill does
---

# Skill Name

## When to use
...

## Instructions
...
```

## Search results from `npx skills find make`

The public skills registry currently returns **no results** for the queries
`make` or `makefile`. The skills in this directory were authored specifically for
this repository to fill that gap. They follow the SKILL.md format defined by
[skills.sh](https://skills.sh/) and can be published to the registry by pushing
this repo and running `npx skills add abuxton/awesome-makefiles`.
