---
name: makefile-debugging
description: Techniques for debugging, tracing, and troubleshooting GNU Makefiles
---

# Makefile Debugging

Techniques for diagnosing and fixing problems in GNU Makefiles.

## When to use

Use this skill when:
- A target is not executing when expected, or executes too often
- Variables have unexpected values
- Recipes fail silently or with cryptic errors
- You need to understand the dependency graph `make` is building

## Instructions

### Print variable values

Use the built-in `$(info ...)` or `$(warning ...)` functions to inspect variables at
parse time, or add a dedicated `debug` target:

```makefile
.PHONY: debug-vars
debug-vars:
	@echo "CC       = $(CC)"
	@echo "CFLAGS   = $(CFLAGS)"
	@echo "SOURCES  = $(SOURCES)"
	@echo "OBJECTS  = $(OBJECTS)"
	$(info  VERSION is: $(VERSION))
```

### `--dry-run` / `-n`

Run `make -n` (or `make --dry-run`) to print the commands that would be executed
without actually running them. Combine with `-B` to force all targets:

```shell
make -nB target
```

### `--print-data-base` / `-p`

Dump the entire Makefile database (all variables, rules, and defaults):

```shell
make -p 2>&1 | grep -A2 'CFLAGS'
```

### `--trace` (GNU Make ≥ 4.0)

Print the reason each target is being rebuilt:

```shell
make --trace target
```

### `--debug`

Verbose dependency and rule matching info:

```shell
make --debug=all target 2>&1 | less
```

Levels: `basic`, `verbose`, `implicit`, `jobs`, `all`.

### Disable silent mode temporarily

Remove `@` prefixes or pass the flag:

```shell
make --no-silent target
```

Or override in the Makefile temporarily:

```makefile
# Uncomment to show all recipe lines during debugging
# SHELL := bash -x
```

### Check if a file is seen as up to date

```shell
make --question target; echo "exit=$?"
# exit=0 → up to date; exit=1 → would rebuild; exit=2 → error
```

### Common pitfalls

| Symptom | Likely cause |
|---------|-------------|
| `*** missing separator` | Recipe indented with spaces, not a tab |
| Variable expands empty | Wrong expansion flavour (`=` vs `:=`) or typo in name |
| Target always rebuilds | Prerequisite file never created / `.PHONY` not declared |
| Target never rebuilds | Stale timestamp; use `touch` or `make -B` to force |
| `No rule to make target` | Missing prerequisite, wrong path, or missing pattern rule |
| Recursive variable loop | Use `:=` instead of `=` to break the cycle |
| Commands from wrong shell | Missing `SHELL := /bin/bash` for bash-specific syntax |

### Debugging included Makefiles

Use `$(MAKEFILE_LIST)` to see which files have been included so far:

```makefile
$(info Included files: $(MAKEFILE_LIST))
```

### Checking for circular dependencies

GNU Make will report `Circular X <- Y dependency dropped.` — search for that string
in verbose output and trace backwards to which rule introduces the cycle.
