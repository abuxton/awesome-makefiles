<!--
SYNC IMPACT REPORT
==================
Version Change: Initial → 1.0.0
Action: Initial constitution creation for awesome-makefiles project

Principles Defined:
- Pattern Consistency: Established repository-wide structural conventions
- Self-Documentation: Mandatory help system and inline documentation
- Security by Default: Environment variable management and secrets handling
- Error Handling First: Prerequisite validation and graceful failures
- API Compliance: JSON API spec adherence for external integrations

Templates Status:
✅ plan-template.md - Aligned with constitution checks
✅ spec-template.md - User story prioritization matches principles
✅ tasks-template.md - Task organization reflects principle-driven development
✅ All command templates - Compatible with defined principles

Dependencies Validated:
- curl, jq, git, bash (standard tooling)
- No hardcoded credentials
- Environment variable patterns established

Rationale: MAJOR version 1.0.0 for initial constitution establishment. This is the baseline
governance document for the awesome-makefiles project, codifying existing patterns and
establishing clear principles for Terraform Enterprise API Makefile development.
-->

# Awesome Makefiles Constitution

## Core Principles

### I. Pattern Consistency

**MUST**: Follow established repository structural conventions across all Makefiles.

All Makefiles within this repository MUST adhere to the following non-negotiable patterns:
- Use `REPO_TOP=$(shell git rev-parse --show-toplevel)` for repository root detection
- Include core patterns via `-include ${REPO_TOP}/common/mk/core.mk`
- Support local environment configuration via `-include .env`
- Reference shared utilities via `BIN_DIR=${REPO_TOP}/common/bin`
- Maintain consistent directory structure: `language/Makefile`, `language/bin/`, `language/mk/`

**Rationale**: Pattern consistency enables developers to navigate unfamiliar Makefiles instantly, reduces cognitive load, and ensures that improvements to core patterns propagate automatically across all projects. It transforms the repository from a collection of scripts into a cohesive ecosystem.

### II. Self-Documentation (NON-NEGOTIABLE)

**MUST**: Every target MUST include inline documentation accessible via `make help`.

Requirements:
- Every `.PHONY` target MUST have a `## comment` immediately following the target declaration
- Help generation MUST use: `@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk ...`
- Targets MUST be logically grouped by functional area with clear section comments
- Default target MUST be either `help` or `all: help`
- Complex targets MUST include parameter documentation in the help text (e.g., "requires VAR_NAME")

**Rationale**: Self-documentation eliminates the need for external documentation to fall out of sync. When help is always one `make help` away, adoption increases and maintenance burden decreases. This principle is non-negotiable because undocumented automation is technical debt.

### III. Security by Default

**MUST**: No secrets, tokens, or sensitive data in Makefiles, scripts, or version control.

Security requirements:
- Authentication tokens MUST be read from environment variables only
- Use `.env` files for local development (`.env` MUST be in `.gitignore`)
- Provide `.env.example` templates with placeholder values and documentation
- Validate required environment variables before executing sensitive operations
- Log operations without exposing sensitive values
- Treat all URLs containing secrets (e.g., blob storage URLs) as confidential

**Default secure patterns**:
```makefile
TFE_TOKEN ?= ${TFE_TOKEN}  # Read from environment
TFE_ORG ?= ${TFE_ORG}      # Read from environment
TFE_ADDR ?= https://app.terraform.io  # Safe default
```

**Rationale**: Security breaches from committed secrets are preventable and catastrophic. This principle protects users, organizations, and the repository's integrity. Security cannot be optional or conditional.

### IV. Error Handling First

**MUST**: Validate prerequisites before execution and provide actionable error messages.

Requirements:
- Check for required environment variables with descriptive error messages
- Check for required commands (curl, jq, git) before use
- Use curl with `--fail --silent --show-error` for API calls
- Provide context in error messages: what failed, why it matters, how to fix
- Exit with non-zero status codes on failure
- Implement `check-env` target pattern:

```makefile
.PHONY: check-env
check-env: ## Validate required environment variables
	@for var in $(REQUIRED_VARS); do \
		if [ -z "$${!var}" ]; then \
			echo "Error: $$var is not set. Set it in .env or export it."; \
			exit 1; \
		fi; \
	done
```

**Rationale**: Silent failures waste hours of debugging time. Clear error messages transform confusion into action. Error handling is not defensive programming—it's respectful UX design for CLI tools.

### V. API Compliance & Standards

**MUST**: External API integrations MUST follow the API specification exactly.

For REST APIs (e.g., Terraform Enterprise):
- Use correct HTTP methods (GET, POST, PATCH, DELETE)
- Include all required headers (Content-Type, Authorization)
- Follow API specification for request/response structure (JSON API spec for TFE)
- Handle pagination when dealing with lists
- Respect rate limits with appropriate retry logic or warnings
- Parse responses with `jq` for clean output
- Support both pretty-printed and raw output modes

**JSON API Requirements** (for Terraform Enterprise):
```makefile
-H "Content-Type: application/vnd.api+json" \
-H "Authorization: Bearer ${TFE_TOKEN}"
```

**Rationale**: API specifications exist for a reason. Deviation causes integration failures, silent errors, and maintenance nightmares. Compliance ensures reliability and future compatibility.

### VI. Modularity & Reusability

**MUST**: Common functionality MUST be extracted to shared modules, not duplicated.

Modularity requirements:
- Common shell logic MUST go in `common/bin/` as executable scripts
- Common Makefile patterns MUST go in `common/mk/*.mk` as includable modules
- Language-specific patterns MUST go in `language/bin/` or `language/mk/`
- Scripts MUST have clear single responsibilities
- Scripts MUST accept parameters via arguments or environment variables
- Scripts MUST be independently testable

**Extraction threshold**: If logic appears in >2 Makefiles, extract it.

**Rationale**: DRY (Don't Repeat Yourself) is more critical in automation than in application code. Duplicated automation means bugs get fixed in one place and persist in others. Shared modules create a force multiplier for improvements.

## Technical Standards

### Dependency Management

**Required dependencies** (MUST check availability):
- `git` - Repository operations
- `make` - GNU Make 3.81+
- `bash` - Shell script execution

**Optional dependencies** (SHOULD check and warn):
- `curl` - API interactions
- `jq` - JSON processing
- `terraform` - Terraform operations
- Language-specific tools (go, rust, python, etc.)

**Pattern for checking**:
```makefile
.PHONY: check-deps
check-deps: ## Verify required dependencies
	@command -v git >/dev/null || (echo "Error: git not found"; exit 1)
	@command -v curl >/dev/null || (echo "Error: curl not found"; exit 1)
```

### Target Naming Conventions

**MUST** follow these conventions:
- Use kebab-case: `workspace-list`, `run-create`, `state-download`
- Prefix with resource type for clarity: `workspace-`, `run-`, `state-`, `var-`
- Use standard verbs: `list`, `get`, `create`, `update`, `delete`, `apply`, `cancel`
- Helper targets (non-user-facing): prefix with underscore `_helper-target`

**Examples**:
- ✅ Good: `workspace-list`, `run-create`, `state-download`
- ❌ Bad: `listWorkspaces`, `create_run`, `downloadState`

### Documentation Requirements

Each Makefile directory MUST include:
1. **README.md** - Setup, usage examples, environment variables
2. **.env.example** - Template with all required/optional variables documented
3. **Inline comments** - For complex logic or non-obvious workarounds

Documentation MUST answer:
- What does this Makefile do?
- What environment variables are required?
- What are common workflows? (with examples)
- Where can I find more information?

## Development Workflow

### Feature Development Process

When adding new Makefile functionality:

1. **Research Phase**: Understand the API/tool/workflow being automated
2. **Spec Phase**: Document user scenarios and acceptance criteria in `/specs/`
3. **Plan Phase**: Design the Makefile structure, identify reusable components
4. **Implementation Phase**: Write targets following all principles
5. **Documentation Phase**: Update README.md, create .env.example, add examples
6. **Validation Phase**: Test with missing env vars, invalid inputs, edge cases

### Constitution Compliance Checklist

Before merging any Makefile changes, verify:

- [ ] **Pattern Consistency**: Uses REPO_TOP, includes core.mk, follows directory structure
- [ ] **Self-Documentation**: All targets have ## comments, help target works
- [ ] **Security**: No hardcoded secrets, uses environment variables, .env.example provided
- [ ] **Error Handling**: Validates prerequisites, provides clear error messages
- [ ] **API Compliance**: Follows API spec, includes required headers, handles responses correctly
- [ ] **Modularity**: Common logic extracted to bin/ or mk/, no duplication
- [ ] **Dependencies**: Checks for required tools, warns on missing optional tools
- [ ] **Naming**: Targets use kebab-case with resource prefixes
- [ ] **Documentation**: README.md updated, examples provided, usage clear

### Quality Gates

**GATE 1 - Functional**: Does it work?
- Targets execute successfully with valid inputs
- Error cases handled gracefully
- Help system displays correctly

**GATE 2 - Secure**: Is it safe?
- No secrets in code or version control
- Environment variables validated
- Sensitive data not logged

**GATE 3 - Maintainable**: Can others use/modify it?
- Documentation complete and accurate
- Follows established patterns
- Code is clear and commented where necessary

## Governance

### Amendment Process

To amend this constitution:

1. **Proposal**: Document the proposed change with rationale in an issue
2. **Impact Analysis**: Identify affected Makefiles, templates, and scripts
3. **Version Decision**: Determine MAJOR/MINOR/PATCH based on semantic versioning:
   - **MAJOR**: Removes/changes principles, breaks existing contracts
   - **MINOR**: Adds principles, expands guidance materially
   - **PATCH**: Clarifications, typo fixes, non-semantic refinements
4. **Approval**: Discuss and approve the change
5. **Implementation**: Update constitution and propagate changes to templates
6. **Migration**: Update existing Makefiles to comply with new principles (if needed)

### Semantic Versioning Rules

Constitution versions follow MAJOR.MINOR.PATCH:
- **MAJOR (X.0.0)**: Backward-incompatible principle changes, removals, or redefinitions
- **MINOR (0.X.0)**: New principles added, sections expanded with new requirements
- **PATCH (0.0.X)**: Clarifications, wording improvements, typo fixes

### Conflict Resolution

When principles conflict:
1. Security by Default takes precedence over all other principles
2. Error Handling First takes precedence over convenience
3. Self-Documentation is non-negotiable
4. When unclear, prefer explicit over implicit

### Compliance Enforcement

- All pull requests MUST reference this constitution in review
- Violations MUST be corrected before merge
- Exceptions MUST be documented with clear justification
- Templates MUST stay synchronized with principles

This constitution supersedes all prior informal practices and conventions. When in doubt, refer to these principles.

**Version**: 1.0.0 | **Ratified**: 2026-01-15 | **Last Amended**: 2026-01-15
