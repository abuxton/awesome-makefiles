# Terraform Enterprise API Makefile
# API Documentation: https://developer.hashicorp.com/terraform/enterprise/api-docs
# Constitution: Follows awesome-makefiles constitution v1.0.0

-include .env
REPO_TOP=$(shell git rev-parse --show-toplevel)
BIN_DIR=${REPO_TOP}/common/bin

# Default values
TFE_ADDR ?= https://app.terraform.io
TFE_API_VERSION := v2
TFE_BASE_URL := ${TFE_ADDR}/api/${TFE_API_VERSION}

# Required environment variables
REQUIRED_VARS := TFE_TOKEN TFE_ORG
REQUIRED_CMDS := curl jq git

.PHONY: all
all: help

.PHONY: help
help: ## Show help messages for make targets
	@echo "Terraform Enterprise API Makefile"
	@echo "=================================="
	@echo ""
	@echo "Configuration:"
	@echo "  TFE_ADDR:  ${TFE_ADDR}"
	@echo "  TFE_ORG:   ${TFE_ORG}"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Setup:"
	@echo "  1. Copy .env.example to .env"
	@echo "  2. Set TFE_TOKEN and TFE_ORG in .env"
	@echo "  3. Run 'make check-deps' to verify dependencies"
	@echo "  4. Run 'make auth-check' to validate credentials"

.PHONY: check-deps
check-deps: ## Verify required dependencies (curl, jq, git)
	@echo "Checking required dependencies..."
	@for cmd in $(REQUIRED_CMDS); do \
		if ! command -v $$cmd >/dev/null 2>&1; then \
			echo "❌ Error: $$cmd is not installed"; \
			echo "   Please install $$cmd to continue"; \
			exit 1; \
		else \
			echo "✅ $$cmd found: $$(command -v $$cmd)"; \
		fi; \
	done
	@echo "All dependencies satisfied!"

.PHONY: check-env
check-env: ## Validate required environment variables
	@for var in $(REQUIRED_VARS); do \
		if [ -z "$$(eval echo \$$$$var)" ]; then \
			echo "❌ Error: $$var is not set"; \
			echo "   Set it in .env file or export it: export $$var=your-value"; \
			exit 1; \
		fi; \
	done

# =============================================================================
# Authentication
# =============================================================================

.PHONY: auth-check
auth-check: check-env check-deps ## Validate API credentials and organization access
	@echo "Validating credentials for organization: ${TFE_ORG}..."
	@curl --fail --silent --show-error \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		"${TFE_BASE_URL}/organizations/${TFE_ORG}" | jq '.'
	@echo ""
	@echo "✅ Authentication successful!"

# =============================================================================
# Workspace Operations
# =============================================================================

.PHONY: workspace-list
workspace-list: check-env check-deps ## List all workspaces in organization
	@echo "Listing workspaces for organization: ${TFE_ORG}..."
	@PAGE_NUM=$${PAGE:-1}; \
	PAGE_SIZE_VAL=$${PAGE_SIZE:-20}; \
	curl --fail --silent --show-error \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		"${TFE_BASE_URL}/organizations/${TFE_ORG}/workspaces?page%5Bnumber%5D=$$PAGE_NUM&page%5Bsize%5D=$$PAGE_SIZE_VAL" \
		| jq '.data[] | {id: .id, name: .attributes.name, terraform_version: .attributes["terraform-version"], auto_apply: .attributes["auto-apply"]}'

.PHONY: workspace-list-raw
workspace-list-raw: check-env check-deps ## List workspaces (raw JSON for scripting)
	@PAGE_NUM=$${PAGE:-1}; \
	PAGE_SIZE_VAL=$${PAGE_SIZE:-20}; \
	curl --fail --silent --show-error \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		"${TFE_BASE_URL}/organizations/${TFE_ORG}/workspaces?page%5Bnumber%5D=$$PAGE_NUM&page%5Bsize%5D=$$PAGE_SIZE_VAL"

.PHONY: workspace-get
workspace-get: check-env check-deps ## Get workspace details (requires WORKSPACE_ID)
	@test -n "$(WORKSPACE_ID)" || (echo "❌ Error: WORKSPACE_ID required. Usage: make workspace-get WORKSPACE_ID=ws-xxx"; exit 1)
	@echo "Fetching workspace: $(WORKSPACE_ID)..."
	@INCLUDE_PARAM=$${INCLUDE:+?include=$$INCLUDE}; \
	curl --fail --silent --show-error \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		"${TFE_BASE_URL}/workspaces/$(WORKSPACE_ID)$$INCLUDE_PARAM" | jq '.'

.PHONY: workspace-create
workspace-create: check-env check-deps ## Create workspace (requires NAME, optional: TF_VERSION, AUTO_APPLY, VCS settings)
	@test -n "$(NAME)" || (echo "❌ Error: NAME required. Usage: make workspace-create NAME=my-workspace"; exit 1)
	@echo "Creating workspace: $(NAME)..."
	@TF_VER=$${TF_VERSION:-1.6.0}; \
	AUTO_APPLY_VAL=$${AUTO_APPLY:-false}; \
	WORKING_DIR_VAL=$${WORKING_DIR:-}; \
	PAYLOAD=$$(cat <<-EOF \
	{ \
	  "data": { \
	    "type": "workspaces", \
	    "attributes": { \
	      "name": "$(NAME)", \
	      "terraform-version": "$$TF_VER", \
	      "auto-apply": $$AUTO_APPLY_VAL \
	    } \
	  } \
	} \
	EOF \
	); \
	curl --fail --silent --show-error \
		-X POST \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		-d "$$PAYLOAD" \
		"${TFE_BASE_URL}/organizations/${TFE_ORG}/workspaces" | jq '.'

.PHONY: workspace-update
workspace-update: check-env check-deps ## Update workspace (requires WORKSPACE_ID, optional: TF_VERSION, AUTO_APPLY, etc.)
	@test -n "$(WORKSPACE_ID)" || (echo "❌ Error: WORKSPACE_ID required. Usage: make workspace-update WORKSPACE_ID=ws-xxx TF_VERSION=1.6.0"; exit 1)
	@echo "Updating workspace: $(WORKSPACE_ID)..."
	@ATTRS="{}"; \
	if [ -n "$${TF_VERSION}" ]; then ATTRS=$$(echo "$$ATTRS" | jq '. + {"terraform-version": "'$$TF_VERSION'"}'); fi; \
	if [ -n "$${AUTO_APPLY}" ]; then ATTRS=$$(echo "$$ATTRS" | jq '. + {"auto-apply": '$$AUTO_APPLY'}'); fi; \
	if [ -n "$${WORKING_DIR}" ]; then ATTRS=$$(echo "$$ATTRS" | jq '. + {"working-directory": "'$$WORKING_DIR'"}'); fi; \
	PAYLOAD=$$(jq -n --argjson attrs "$$ATTRS" '{"data": {"type": "workspaces", "attributes": $$attrs}}'); \
	curl --fail --silent --show-error \
		-X PATCH \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		-d "$$PAYLOAD" \
		"${TFE_BASE_URL}/workspaces/$(WORKSPACE_ID)" | jq '.'

.PHONY: workspace-delete
workspace-delete: check-env check-deps ## Delete workspace (requires WORKSPACE_ID, optional: FORCE=yes)
	@test -n "$(WORKSPACE_ID)" || (echo "❌ Error: WORKSPACE_ID required. Usage: make workspace-delete WORKSPACE_ID=ws-xxx"; exit 1)
	@if [ "$${FORCE}" != "yes" ]; then \
		echo "⚠️  WARNING: This will delete workspace $(WORKSPACE_ID)"; \
		echo "   To confirm, run: make workspace-delete WORKSPACE_ID=$(WORKSPACE_ID) FORCE=yes"; \
		exit 1; \
	fi
	@echo "Deleting workspace: $(WORKSPACE_ID)..."
	@curl --fail --silent --show-error \
		-X DELETE \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		"${TFE_BASE_URL}/workspaces/$(WORKSPACE_ID)"
	@echo "✅ Workspace deleted"

# =============================================================================
# Run Operations
# =============================================================================

.PHONY: run-list
run-list: check-env check-deps ## List runs for workspace (requires WORKSPACE_ID)
	@test -n "$(WORKSPACE_ID)" || (echo "❌ Error: WORKSPACE_ID required. Usage: make run-list WORKSPACE_ID=ws-xxx"; exit 1)
	@echo "Listing runs for workspace: $(WORKSPACE_ID)..."
	@PAGE_NUM=$${PAGE:-1}; \
	PAGE_SIZE_VAL=$${PAGE_SIZE:-20}; \
	curl --fail --silent --show-error \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		"${TFE_BASE_URL}/workspaces/$(WORKSPACE_ID)/runs?page%5Bnumber%5D=$$PAGE_NUM&page%5Bsize%5D=$$PAGE_SIZE_VAL" \
		| jq '.data[] | {id: .id, status: .attributes.status, message: .attributes.message, created_at: .attributes["created-at"]}'

.PHONY: run-get
run-get: check-env check-deps ## Get run details (requires RUN_ID)
	@test -n "$(RUN_ID)" || (echo "❌ Error: RUN_ID required. Usage: make run-get RUN_ID=run-xxx"; exit 1)
	@echo "Fetching run: $(RUN_ID)..."
	@curl --fail --silent --show-error \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		"${TFE_BASE_URL}/runs/$(RUN_ID)" | jq '.'

.PHONY: run-create
run-create: check-env check-deps ## Create run (requires WORKSPACE_ID, optional: MESSAGE, AUTO_APPLY)
	@test -n "$(WORKSPACE_ID)" || (echo "❌ Error: WORKSPACE_ID required. Usage: make run-create WORKSPACE_ID=ws-xxx"; exit 1)
	@echo "Creating run for workspace: $(WORKSPACE_ID)..."
	@MESSAGE=$${MESSAGE:-"Triggered via Makefile"}; \
	AUTO_APPLY_VAL=$${AUTO_APPLY:-false}; \
	PAYLOAD=$$(cat <<-EOF \
	{ \
	  "data": { \
	    "type": "runs", \
	    "attributes": { \
	      "message": "$$MESSAGE", \
	      "auto-apply": $$AUTO_APPLY_VAL \
	    }, \
	    "relationships": { \
	      "workspace": { \
	        "data": { \
	          "type": "workspaces", \
	          "id": "$(WORKSPACE_ID)" \
	        } \
	      } \
	    } \
	  } \
	} \
	EOF \
	); \
	curl --fail --silent --show-error \
		-X POST \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		-d "$$PAYLOAD" \
		"${TFE_BASE_URL}/runs" | jq '.data | {id: .id, status: .attributes.status, message: .attributes.message}'

.PHONY: run-apply
run-apply: check-env check-deps ## Apply run (requires RUN_ID, optional: COMMENT)
	@test -n "$(RUN_ID)" || (echo "❌ Error: RUN_ID required. Usage: make run-apply RUN_ID=run-xxx"; exit 1)
	@echo "Applying run: $(RUN_ID)..."
	@COMMENT_VAL=$${COMMENT:-"Applied via Makefile"}; \
	PAYLOAD=$$(cat <<-EOF \
	{ \
	  "comment": "$$COMMENT_VAL" \
	} \
	EOF \
	); \
	curl --fail --silent --show-error \
		-X POST \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		-d "$$PAYLOAD" \
		"${TFE_BASE_URL}/runs/$(RUN_ID)/actions/apply" | jq '.'
	@echo "✅ Run apply requested"

.PHONY: run-cancel
run-cancel: check-env check-deps ## Cancel run (requires RUN_ID, optional: COMMENT)
	@test -n "$(RUN_ID)" || (echo "❌ Error: RUN_ID required. Usage: make run-cancel RUN_ID=run-xxx"; exit 1)
	@echo "Cancelling run: $(RUN_ID)..."
	@COMMENT_VAL=$${COMMENT:-"Cancelled via Makefile"}; \
	PAYLOAD=$$(cat <<-EOF \
	{ \
	  "comment": "$$COMMENT_VAL" \
	} \
	EOF \
	); \
	curl --fail --silent --show-error \
		-X POST \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		-d "$$PAYLOAD" \
		"${TFE_BASE_URL}/runs/$(RUN_ID)/actions/cancel" | jq '.'
	@echo "✅ Run cancellation requested"

# =============================================================================
# Variable Operations
# =============================================================================

.PHONY: var-list
var-list: check-env check-deps ## List variables for workspace (requires WORKSPACE_ID)
	@test -n "$(WORKSPACE_ID)" || (echo "❌ Error: WORKSPACE_ID required. Usage: make var-list WORKSPACE_ID=ws-xxx"; exit 1)
	@echo "Listing variables for workspace: $(WORKSPACE_ID)..."
	@curl --fail --silent --show-error \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		"${TFE_BASE_URL}/workspaces/$(WORKSPACE_ID)/vars" \
		| jq '.data[] | {id: .id, key: .attributes.key, value: .attributes.value, category: .attributes.category, hcl: .attributes.hcl, sensitive: .attributes.sensitive}'

.PHONY: var-create
var-create: check-env check-deps ## Create variable (requires KEY, VALUE, WORKSPACE_ID, optional: CATEGORY, HCL, SENSITIVE)
	@test -n "$(KEY)" || (echo "❌ Error: KEY required. Usage: make var-create KEY=myvar VALUE=myvalue WORKSPACE_ID=ws-xxx"; exit 1)
	@test -n "$(VALUE)" || (echo "❌ Error: VALUE required"; exit 1)
	@test -n "$(WORKSPACE_ID)" || (echo "❌ Error: WORKSPACE_ID required"; exit 1)
	@echo "Creating variable: $(KEY)..."
	@CATEGORY_VAL=$${CATEGORY:-terraform}; \
	HCL_VAL=$${HCL:-false}; \
	SENSITIVE_VAL=$${SENSITIVE:-false}; \
	PAYLOAD=$$(cat <<-EOF \
	{ \
	  "data": { \
	    "type": "vars", \
	    "attributes": { \
	      "key": "$(KEY)", \
	      "value": "$(VALUE)", \
	      "category": "$$CATEGORY_VAL", \
	      "hcl": $$HCL_VAL, \
	      "sensitive": $$SENSITIVE_VAL \
	    }, \
	    "relationships": { \
	      "workspace": { \
	        "data": { \
	          "type": "workspaces", \
	          "id": "$(WORKSPACE_ID)" \
	        } \
	      } \
	    } \
	  } \
	} \
	EOF \
	); \
	curl --fail --silent --show-error \
		-X POST \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		-d "$$PAYLOAD" \
		"${TFE_BASE_URL}/vars" | jq '.'

.PHONY: var-update
var-update: check-env check-deps ## Update variable (requires VAR_ID, optional: VALUE, CATEGORY, HCL, SENSITIVE)
	@test -n "$(VAR_ID)" || (echo "❌ Error: VAR_ID required. Usage: make var-update VAR_ID=var-xxx VALUE=newvalue"; exit 1)
	@echo "Updating variable: $(VAR_ID)..."
	@ATTRS="{}"; \
	if [ -n "$${VALUE}" ]; then ATTRS=$$(echo "$$ATTRS" | jq '. + {"value": "'$$VALUE'"}'); fi; \
	if [ -n "$${CATEGORY}" ]; then ATTRS=$$(echo "$$ATTRS" | jq '. + {"category": "'$$CATEGORY'"}'); fi; \
	if [ -n "$${HCL}" ]; then ATTRS=$$(echo "$$ATTRS" | jq '. + {"hcl": '$$HCL'}'); fi; \
	if [ -n "$${SENSITIVE}" ]; then ATTRS=$$(echo "$$ATTRS" | jq '. + {"sensitive": '$$SENSITIVE'}'); fi; \
	PAYLOAD=$$(jq -n --argjson attrs "$$ATTRS" '{"data": {"type": "vars", "attributes": $$attrs}}'); \
	curl --fail --silent --show-error \
		-X PATCH \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		-d "$$PAYLOAD" \
		"${TFE_BASE_URL}/vars/$(VAR_ID)" | jq '.'

.PHONY: var-delete
var-delete: check-env check-deps ## Delete variable (requires VAR_ID)
	@test -n "$(VAR_ID)" || (echo "❌ Error: VAR_ID required. Usage: make var-delete VAR_ID=var-xxx"; exit 1)
	@echo "Deleting variable: $(VAR_ID)..."
	@curl --fail --silent --show-error \
		-X DELETE \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		"${TFE_BASE_URL}/vars/$(VAR_ID)"
	@echo "✅ Variable deleted"

# =============================================================================
# State Operations
# =============================================================================

.PHONY: state-list
state-list: check-env check-deps ## List state versions for workspace (requires WORKSPACE_ID)
	@test -n "$(WORKSPACE_ID)" || (echo "❌ Error: WORKSPACE_ID required. Usage: make state-list WORKSPACE_ID=ws-xxx"; exit 1)
	@echo "Listing state versions for workspace: $(WORKSPACE_ID)..."
	@curl --fail --silent --show-error \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		"${TFE_BASE_URL}/state-versions?filter%5Bworkspace%5D%5Bid%5D=$(WORKSPACE_ID)" \
		| jq '.data[] | {id: .id, serial: .attributes.serial, created_at: .attributes["created-at"]}'

.PHONY: state-get
state-get: check-env check-deps ## Get state version details (requires STATE_ID)
	@test -n "$(STATE_ID)" || (echo "❌ Error: STATE_ID required. Usage: make state-get STATE_ID=sv-xxx"; exit 1)
	@echo "Fetching state version: $(STATE_ID)..."
	@curl --fail --silent --show-error \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		"${TFE_BASE_URL}/state-versions/$(STATE_ID)" | jq '.'

.PHONY: state-download
state-download: check-env check-deps ## Download current state (requires WORKSPACE_ID, optional: OUTPUT_FILE)
	@test -n "$(WORKSPACE_ID)" || (echo "❌ Error: WORKSPACE_ID required. Usage: make state-download WORKSPACE_ID=ws-xxx"; exit 1)
	@echo "Downloading current state for workspace: $(WORKSPACE_ID)..."
	@OUTPUT=$${OUTPUT_FILE:-$(WORKSPACE_ID)-state.json}; \
	DOWNLOAD_URL=$$(curl --fail --silent --show-error \
		-H "Authorization: Bearer ${TFE_TOKEN}" \
		-H "Content-Type: application/vnd.api+json" \
		"${TFE_BASE_URL}/workspaces/$(WORKSPACE_ID)/current-state-version" \
		| jq -r '.data.attributes["hosted-state-download-url"]'); \
	if [ "$$DOWNLOAD_URL" = "null" ] || [ -z "$$DOWNLOAD_URL" ]; then \
		echo "❌ Error: No state version available for this workspace"; \
		exit 1; \
	fi; \
	echo "Downloading state to: $$OUTPUT"; \
	curl --fail --silent --show-error "$$DOWNLOAD_URL" -o "$$OUTPUT"; \
	echo "✅ State downloaded to $$OUTPUT"; \
	echo "⚠️  Note: Download URLs expire after 25 hours"
