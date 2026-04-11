# Makefile

This repository is intended to create and manage collected Makefiles and the like (task, rake etc) and related useful resources [![Awesome](https://awesome.re/badge.svg)](https://awesome.re)

It also ships a set of **AI skills** for [GitHub Copilot](https://github.com/features/copilot) coding agents and a **dev container** so you can open the repo in a fully-configured Codespace.

## Open in a Codespace

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/abuxton/awesome-makefiles)

The dev container includes: `make`, `git`, `gh`, Node.js LTS, Python 3.12, Go latest, Rust latest, Docker-in-Docker, and VS Code extensions for Makefile Tools, Copilot, ShellCheck, and language-specific tooling.

## Makefile collection

| Directory | Description |
|-----------|-------------|
| `makefile` | Root repo-management Makefile |
| `ansible/` | Ansible workflow (paulRbr/ansible-makefile) |
| `common/mk/` | Shared `.mk` fragments for mono-repo includes |
| `cpp/` | C/C++ build with `gcc`, pattern rules, deps |
| `docker/` | Docker image build/push/scan + Compose lifecycle |
| `go-lang/` | Go module: build, test, lint, cross-compile |
| `hashicorp/terraform/` | Terraform plan/apply workflow |
| `nodejs/` | Node.js/TypeScript: install stamp, build, test |
| `python/` | Python venv bootstrap, pytest, ruff, mypy |
| `rust/` | Cargo: build, test, clippy, fmt, doc, install |

## AI Skills (GitHub Copilot)

The `skills/` directory contains [SKILL.md](https://skills.sh) packages that teach Copilot coding agents how to work with Makefiles. Install them with [`npx skills`](https://www.npmjs.com/package/skills):

```shell
npx skills experimental_install   # restore from skills-lock.json
```

| Skill | Description |
|-------|-------------|
| `makefile-basics` | Core syntax, variables, `.PHONY`, automatic variables |
| `makefile-patterns` | Common reusable patterns and idioms |
| `makefile-debugging` | `make -n`, `--trace`, `--debug`, pitfall table |
| `makefile-ci` | CI/CD integration (GitHub Actions, caching, artefacts) |
| `makefile-docker` | Docker build/push/scan and Compose targets |
| `makefile-golang` | Go module targets and cross-compilation |
| `makefile-python` | Python venv, pytest, ruff, mypy targets |
| `makefile-nodejs` | npm/pnpm stamp install, build, test, type-check |

## References

* <https://opensource.com/article/18/8/what-how-makefile>
  * <https://makefiletutorial.com/>
  * <https://github.com/krisnova/Makefile/blob/main/Makefile>
  * <https://github.com/michaelfromyeg/makefiles>
  * <https://github.com/amjadmajid/Makefile>
* <https://taskfile.dev/>
* <https://ruby.github.io/rake/doc/rakefile_rdoc.html>

The root Makefile is to help with management of this repo for fun and profit.

## Usage

``` shell

# git clone this repo or download a file directly
wget https://raw.githubusercontent.com/abuxton/awesome-makefiles/main/makefile

curl -O https://raw.githubusercontent.com/abuxton/awesome-makefiles/main/makefile

```

## tools && helpers

- <https://crates.io/crates/make-makefile>

