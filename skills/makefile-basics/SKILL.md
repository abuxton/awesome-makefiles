---
name: makefile-basics
description: Core GNU Make concepts, syntax, and best practices for writing effective Makefiles
---

# Makefile Basics

Instructions for writing and reviewing GNU Make Makefiles following best practices.

## When to use

Use this skill when:
- Writing a new Makefile from scratch
- Reviewing or refactoring an existing Makefile
- Explaining Makefile syntax and concepts
- Helping users understand how `make` resolves targets

## Instructions

### Structure

1. Always declare phony targets to avoid conflicts with files of the same name:
   ```makefile
   .PHONY: build test clean help
   ```

2. Set a sensible default goal (usually `all` or `help`):
   ```makefile
   .DEFAULT_GOAL := help
   ```

3. Use `SHELL := /bin/bash` at the top to ensure consistent shell behaviour.

4. Group variables at the top, targets in logical sections below.

### Variables

- Use `?=` for overridable defaults (caller can override via environment or CLI).
- Use `:=` for immediate (simple) expansion to avoid repeated evaluation.
- Use `=` only when deferred (recursive) expansion is intentional.
- Prefer uppercase names for variables set at the Makefile level.

### Targets

- Every target recipe line must begin with a **tab** character (not spaces).
- Prefix recipe lines with `@` to suppress echoing, or omit `@` when the command itself is informative.
- Use `$(MAKE)` (not `make`) to invoke sub-makes so flags and variables propagate.

### Self-documenting help target

Add `## comment` after each target declaration and generate a help screen:

```makefile
.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
```

### Error handling

- Use `$(error ...)` to abort with a message when required variables are missing.
- Use `$(warning ...)` for non-fatal notices.
- Example guard:
  ```makefile
  ifndef REQUIRED_VAR
    $(error REQUIRED_VAR is not set)
  endif
  ```

### Including other Makefiles

- Use `-include file.mk` (with dash) to silently ignore missing includes.
- Use `include file.mk` when the file is mandatory.

### Pattern rules

Prefer static pattern rules over implicit rules for clarity:
```makefile
$(OBJECTS): $(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<
```

### Automatic variables

| Variable | Meaning |
|----------|---------|
| `$@` | Target name |
| `$<` | First prerequisite |
| `$^` | All prerequisites (deduplicated) |
| `$*` | Stem matched by `%` in a pattern rule |
| `$(@D)` | Directory part of `$@` |

### Portability

- Test with both GNU Make 3.x and 4.x where possible.
- Avoid GNU-specific extensions when targeting BSD/macOS unless `gmake` is guaranteed.
- Use `$(shell ...)` sparingly; cache the result in a variable.
