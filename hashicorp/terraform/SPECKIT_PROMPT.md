# Speckit Prompt: Terraform Enterprise API Makefile Implementation

## Project Context

**Repository**: awesome-makefiles
**Purpose**: Collection of reusable, well-structured Makefiles for various development workflows
**Target**: Create a Makefile implementation for Terraform Enterprise/HCP Terraform API interactions using curl

## Project Principles

### 1. **Consistency with Existing Patterns**
- Follow the established structure in `awesome-makefiles`
- Use `REPO_TOP=$(shell git rev-parse --show-toplevel)` for repository root detection
- Include core.mk patterns: `-include ${REPO_TOP}/common/mk/core.mk`
- Support `.env` file inclusion for environment variables: `-include .env`
- Use `BIN_DIR` for helper scripts location

### 2. **Self-Documenting Code**
- Every target MUST have a `## comment` for automatic help generation
- Help target should use: `@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)`
- Targets should be organized by functional area (authentication, workspaces, runs, etc.)

### 3. **Security Best Practices**
- NEVER hardcode tokens or sensitive data in Makefiles
- Use environment variables for authentication: `TFE_TOKEN`, `TFE_ORG`, `TFE_ADDR`
- Support `.env` file for local development
- Treat all API URLs as secrets (especially blob storage URLs with 25-hour validity)
- Default `TFE_ADDR` to `https://app.terraform.io` for HCP Terraform

### 4. **Error Handling & Validation**
- Check for required environment variables before making API calls
- Provide helpful error messages when prerequisites are missing
- Use curl's `--fail` flag to catch HTTP errors
- Include `--show-error` and `--silent` for clean error reporting

### 5. **JSON API Compliance**
- All requests must include: `Content-Type: application/vnd.api+json`
- All requests must include: `Authorization: Bearer ${TFE_TOKEN}`
- Use proper JSON API document structure with `data.type`, `data.attributes`, `data.relationships`
- Handle pagination with `page[number]` and `page[size]` query parameters
- Support `include` parameter for related resources

## Terraform Enterprise API Characteristics

### Authentication
```bash
-H "Authorization: Bearer ${TFE_TOKEN}" \
-H "Content-Type: application/vnd.api+json"
```

### Base URL Structure
- API v2: `/api/v2` prefix for all endpoints
- Example: `${TFE_ADDR}/api/v2/organizations/${TFE_ORG}/workspaces`

### Rate Limits
- 30 requests/second per user
- Special limits for sensitive endpoints
- HTTP 429 response when throttled

### Common Response Codes
- 200: Success
- 401: Invalid/missing authentication
- 404: Not found OR no access (security by obscurity)
- 429: Rate limit exceeded

## Implementation Requirements

### Core Functionality Categories

#### 1. **Authentication & Validation**
- Validate token and connection
- Check organization access
- List available entitlements

#### 2. **Workspace Operations**
- List workspaces in an organization
- Get workspace details
- Create workspace
- Update workspace settings
- Delete workspace

#### 3. **Run Management**
- List runs for a workspace
- Create a new run
- Get run details
- Apply a run
- Cancel a run

#### 4. **State Management**
- List state versions
- Get current state
- Download state (handle blob storage URLs)

#### 5. **Variable Management**
- List variables for a workspace
- Create variable
- Update variable
- Delete variable

#### 6. **Configuration Versions**
- Create configuration version
- Upload configuration

### Makefile Structure

```makefile
# Terraform Enterprise API Makefile
# API Documentation: https://developer.hashicorp.com/terraform/enterprise/api-docs

-include .env
REPO_TOP=$(shell git rev-parse --show-toplevel)
BIN_DIR=${REPO_TOP}/common/bin

# Default values
TFE_ADDR ?= https://app.terraform.io
TFE_API_VERSION := v2
TFE_BASE_URL := ${TFE_ADDR}/api/${TFE_API_VERSION}

# Required environment variables
REQUIRED_VARS := TFE_TOKEN TFE_ORG

.PHONY: all
all: help

.PHONY: check-env
check-env: ## Validate required environment variables
	@for var in $(REQUIRED_VARS); do \
		if [ -z "$${!var}" ]; then \
			echo "Error: $$var is not set"; \
			exit 1; \
		fi; \
	done

# ... targets organized by category ...
```

### Helper Script Considerations

Create helper scripts in `${BIN_DIR}` for:
- JSON formatting and jq processing
- Error handling wrappers
- Common API call patterns

### Target Naming Conventions

- Use kebab-case: `workspace-list`, `run-create`
- Prefix with resource type for clarity
- Use verbs: list, get, create, update, delete, apply, cancel

### Examples of Well-Formed Targets

```makefile
.PHONY: workspace-list
workspace-list: check-env ## List all workspaces in organization
	@curl --fail --silent --show-error \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		"${TFE_BASE_URL}/organizations/${TFE_ORG}/workspaces" | jq '.'

.PHONY: workspace-get
workspace-get: check-env ## Get workspace details (requires WORKSPACE_ID)
	@test -n "$(WORKSPACE_ID)" || (echo "Error: WORKSPACE_ID required"; exit 1)
	@curl --fail --silent --show-error \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		"${TFE_BASE_URL}/workspaces/$(WORKSPACE_ID)" | jq '.'

.PHONY: run-create
run-create: check-env ## Create a new run (requires WORKSPACE_ID, optional: MESSAGE)
	@test -n "$(WORKSPACE_ID)" || (echo "Error: WORKSPACE_ID required"; exit 1)
	@MESSAGE="${MESSAGE:-Triggered via Makefile}"; \
	curl --fail --silent --show-error \
		-X POST \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		-d @- "${TFE_BASE_URL}/runs" <<-EOF | jq '.'
		{
		  "data": {
		    "type": "runs",
		    "attributes": {
		      "message": "$$MESSAGE"
		    },
		    "relationships": {
		      "workspace": {
		        "data": {
		          "type": "workspaces",
		          "id": "$(WORKSPACE_ID)"
		        }
		      }
		    }
		  }
		}
		EOF
```

## Technical Requirements

### Dependencies
- curl (required)
- jq (required for JSON processing)
- git (for repo detection)
- bash (for shell scripts)

### Optional Enhancements
- Support for pagination with `PAGE` and `PAGE_SIZE` variables
- Include related resources with `INCLUDE` variable
- Filtering support where API provides it
- Pretty-printed output with jq
- RAW output option for piping to other tools

## Testing & Validation

Each target should be testable with:
1. Required environment variables set
2. Optional parameters provided
3. Error cases (missing vars, invalid tokens, etc.)

## Documentation

Include in README.md:
1. Required environment variables
2. Optional configuration
3. Example workflows
4. Common use cases
5. Links to API documentation

## Deliverables

1. **Makefile** (`hashicorp/terraform/api/Makefile`)
   - All API operation targets
   - Help system integrated
   - Error checking
   - JSON API compliant requests

2. **README.md** (`hashicorp/terraform/api/README.md`)
   - Setup instructions
   - Usage examples
   - Environment variable reference
   - Common workflows

3. **Helper Scripts** (if needed in `common/bin/`)
   - API call wrappers
   - JSON processors
   - Response formatters

4. **.env.example**
   - Template for required variables
   - Documentation for each variable

## Success Criteria

- [ ] All targets follow existing project patterns
- [ ] Self-documenting with help system
- [ ] Secure (no hardcoded secrets)
- [ ] JSON API compliant
- [ ] Error handling for common failure cases
- [ ] Organized by functional area
- [ ] Uses curl efficiently
- [ ] jq for clean JSON output
- [ ] Works with both HCP Terraform and Terraform Enterprise
- [ ] Easy to extend with new API endpoints

## References

- API Docs: https://developer.hashicorp.com/terraform/enterprise/api-docs
- JSON API Spec: https://jsonapi.org/
- Existing patterns: `awesome-makefiles/common/mk/core.mk`
- go-tfe (reference): https://github.com/hashicorp/go-tfe

---

**Note**: Focus on the most commonly used endpoints first (workspaces, runs, variables), then expand to cover more specialized operations (agents, policies, etc.) based on usage patterns.
