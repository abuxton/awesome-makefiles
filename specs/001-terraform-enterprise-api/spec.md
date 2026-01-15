# Feature Specification: Terraform Enterprise API Makefile

**Feature Branch**: `001-terraform-enterprise-api-makefile`
**Created**: 2026-01-15
**Status**: Draft
**Input**: Create a Makefile implementation for Terraform Enterprise/HCP Terraform API interactions using curl

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Validate API Connection (Priority: P1)

As a DevOps engineer, I need to quickly validate my TFE/HCP Terraform API credentials and organization access before performing any operations.

**Why this priority**: Without authentication validation, all subsequent operations will fail. This is the foundational capability that enables everything else.

**Independent Test**: Can be fully tested by setting TFE_TOKEN and TFE_ORG environment variables, running `make auth-check`, and verifying successful connection to the organization.

**Acceptance Scenarios**:

1. **Given** I have valid TFE_TOKEN and TFE_ORG set, **When** I run `make auth-check`, **Then** the system confirms successful authentication and displays organization details
2. **Given** I have an invalid token, **When** I run `make auth-check`, **Then** the system displays a clear error message indicating authentication failure
3. **Given** TFE_TOKEN is not set, **When** I run any API target, **Then** the system displays an error message indicating the required environment variable with setup instructions

---

### User Story 2 - List and Query Workspaces (Priority: P1)

As a DevOps engineer, I need to list all workspaces in my organization and retrieve details about specific workspaces to understand my infrastructure landscape.

**Why this priority**: Workspace discovery is essential for all workspace-related operations. Users need to find workspace IDs before performing any workspace-specific actions.

**Independent Test**: Can be tested by running `make workspace-list` to see all workspaces, then using a workspace ID with `make workspace-get WORKSPACE_ID=ws-xxx` to retrieve details.

**Acceptance Scenarios**:

1. **Given** I have access to an organization, **When** I run `make workspace-list`, **Then** I see a formatted list of all workspaces with their IDs and names
2. **Given** I have a workspace ID, **When** I run `make workspace-get WORKSPACE_ID=ws-xxx`, **Then** I see detailed workspace configuration including VCS settings, Terraform version, and execution mode
3. **Given** I want to search workspaces, **When** I run `make workspace-list` with pagination, **Then** I can navigate through pages of workspaces
4. **Given** I need raw output for scripting, **When** I run `make workspace-list-raw`, **Then** I receive unformatted JSON for pipeline processing

---

### User Story 3 - Manage Workspace Runs (Priority: P2)

As a DevOps engineer, I need to trigger Terraform runs, monitor their status, and apply approved plans programmatically as part of my CI/CD pipeline.

**Why this priority**: Run management is the core automation workflow for Terraform operations. This enables automated infrastructure deployments.

**Independent Test**: Can be tested by creating a run with `make run-create WORKSPACE_ID=ws-xxx`, then checking its status with `make run-get RUN_ID=run-xxx`, and applying it with `make run-apply RUN_ID=run-xxx`.

**Acceptance Scenarios**:

1. **Given** I have a workspace ID, **When** I run `make run-create WORKSPACE_ID=ws-xxx MESSAGE="Deploy v1.2.3"`, **Then** a new Terraform run is queued and I receive the run ID
2. **Given** I have a run ID, **When** I run `make run-get RUN_ID=run-xxx`, **Then** I see the current run status, plan summary, and any policy check results
3. **Given** I have a run in "planned" state, **When** I run `make run-apply RUN_ID=run-xxx`, **Then** the run is applied and I can monitor progress
4. **Given** I need to stop a run, **When** I run `make run-cancel RUN_ID=run-xxx`, **Then** the run is cancelled if possible
5. **Given** I want to see all runs for a workspace, **When** I run `make run-list WORKSPACE_ID=ws-xxx`, **Then** I see a list of recent runs with their statuses

---

### User Story 4 - Manage Workspace Variables (Priority: P2)

As a DevOps engineer, I need to create, update, list, and delete workspace variables to manage configuration without modifying Terraform code.

**Why this priority**: Variable management is essential for environment-specific configuration and secrets management. This enables configuration as code workflows.

**Independent Test**: Can be tested by listing variables with `make var-list WORKSPACE_ID=ws-xxx`, creating a new variable with `make var-create`, updating it with `make var-update`, and deleting it with `make var-delete`.

**Acceptance Scenarios**:

1. **Given** I have a workspace ID, **When** I run `make var-list WORKSPACE_ID=ws-xxx`, **Then** I see all Terraform and environment variables with their values (non-sensitive) and properties
2. **Given** I need to add a variable, **When** I run `make var-create WORKSPACE_ID=ws-xxx KEY=region VALUE=us-west-2`, **Then** a new Terraform variable is created
3. **Given** I need to create a sensitive variable, **When** I run `make var-create WORKSPACE_ID=ws-xxx KEY=api_key VALUE=secret123 SENSITIVE=true`, **Then** a sensitive variable is created and the value is write-only
4. **Given** I have a variable ID, **When** I run `make var-update VAR_ID=var-xxx VALUE=new-value`, **Then** the variable is updated with the new value
5. **Given** I have a variable ID, **When** I run `make var-delete VAR_ID=var-xxx`, **Then** the variable is deleted from the workspace
6. **Given** I need an HCL variable, **When** I run `make var-create WORKSPACE_ID=ws-xxx KEY=tags VALUE='{"env"="prod"}' HCL=true`, **Then** a variable with HCL parsing is created

---

### User Story 5 - Access State Versions (Priority: P3)

As a DevOps engineer, I need to list state versions and download current state to audit infrastructure or perform state operations.

**Why this priority**: State access is important for debugging and auditing but less critical than workspace and run operations. Most teams access state less frequently.

**Independent Test**: Can be tested by listing state versions with `make state-list WORKSPACE_ID=ws-xxx` and downloading current state with `make state-download WORKSPACE_ID=ws-xxx`.

**Acceptance Scenarios**:

1. **Given** I have a workspace ID, **When** I run `make state-list WORKSPACE_ID=ws-xxx`, **Then** I see a list of state versions with timestamps and who created them
2. **Given** I have a workspace ID, **When** I run `make state-download WORKSPACE_ID=ws-xxx`, **Then** the current state file is downloaded to a local file
3. **Given** I need a specific state version, **When** I run `make state-get STATE_ID=sv-xxx`, **Then** I retrieve that specific state version's metadata and download URL

---

### User Story 6 - Create and Manage Workspaces (Priority: P3)

As a DevOps engineer, I need to create new workspaces, update workspace settings, and delete workspaces programmatically to automate workspace lifecycle management.

**Why this priority**: While important for automation, workspace creation/deletion happens less frequently than querying and running operations. Most users work with existing workspaces.

**Independent Test**: Can be tested by creating a workspace with `make workspace-create`, updating settings with `make workspace-update`, and cleaning up with `make workspace-delete`.

**Acceptance Scenarios**:

1. **Given** I have organization access, **When** I run `make workspace-create NAME=my-app-prod`, **Then** a new workspace is created with default settings
2. **Given** I need VCS integration, **When** I run `make workspace-create NAME=my-app OAUTH_TOKEN_ID=ot-xxx REPO=org/repo`, **Then** a VCS-connected workspace is created
3. **Given** I have a workspace ID, **When** I run `make workspace-update WORKSPACE_ID=ws-xxx TF_VERSION=1.6.0`, **Then** the workspace Terraform version is updated
4. **Given** I need to enable auto-apply, **When** I run `make workspace-update WORKSPACE_ID=ws-xxx AUTO_APPLY=true`, **Then** the workspace is configured for automatic applies
5. **Given** I have a workspace ID, **When** I run `make workspace-delete WORKSPACE_ID=ws-xxx`, **Then** the workspace is deleted after confirmation

---

## Requirements & Constraints

### Functional Requirements

**Authentication & Authorization**:
- Support TFE_TOKEN environment variable for authentication
- Support TFE_ORG environment variable for organization context
- Support TFE_ADDR for custom Terraform Enterprise installations (default: https://app.terraform.io)
- Validate credentials before making API calls
- Provide clear error messages for authentication failures

**API Operations**:
- Implement REST API calls using curl with proper headers
- Follow JSON API specification for request/response structure
- Handle API rate limits gracefully (30 req/s)
- Support pagination for list operations
- Parse JSON responses with jq

**Error Handling**:
- Validate required environment variables before execution
- Check for required commands (curl, jq) at runtime
- Provide actionable error messages with context
- Exit with appropriate status codes
- Handle HTTP errors (401, 404, 429) specifically

**Output Formats**:
- Default: Pretty-printed JSON via jq
- Raw mode: Unformatted JSON for pipeline integration
- Support both modes for all GET operations

### Non-Functional Requirements

**Security**:
- Never hardcode tokens or secrets
- Use environment variables exclusively for credentials
- Provide .env.example template
- Warn users not to commit .env files
- Treat blob storage URLs as secrets

**Performance**:
- Minimize API calls (no unnecessary requests)
- Use appropriate HTTP methods (GET for reads, POST for writes)
- Respect API rate limits
- Cache organization details when possible

**Usability**:
- Self-documenting help system (`make help`)
- Clear target names with resource prefixes
- Optional parameters documented in help text
- Examples in README
- Consistent UX across all targets

**Maintainability**:
- Follow awesome-makefiles patterns (REPO_TOP, core.mk, BIN_DIR)
- Extract common patterns to helper scripts
- Modular design (can add new endpoints easily)
- Clear comments for complex logic
- Consistent code style

**Compatibility**:
- Work with HCP Terraform (app.terraform.io)
- Work with Terraform Enterprise (custom domain)
- Support both JSON API and legacy endpoints where needed
- Compatible with GNU Make 3.81+

### Technical Constraints

**Dependencies** (MUST check):
- curl (required for API calls)
- jq (required for JSON processing)
- git (required for REPO_TOP detection)
- bash (required for shell script execution)

**API Constraints**:
- JSON API specification compliance
- Rate limit: 30 requests/second per user
- Blob storage URLs expire after 25 hours
- Pagination max page size: 100 items

**Project Constraints**:
- Must follow awesome-makefiles constitution v1.0.0
- Must integrate with existing common/mk/core.mk patterns
- Must provide .env.example template
- Must include comprehensive README.md

### Known Limitations

- Cannot bypass Terraform Enterprise access controls
- Rate limiting may affect bulk operations
- State file downloads require workspace access
- Some operations require specific organization entitlements
- Blob storage URLs are time-limited (25 hours)

## Success Metrics

**Feature Complete When**:
- All P1 user stories implemented and tested
- Constitution compliance checklist passes 100%
- README.md with setup and examples complete
- .env.example template provided
- Help system shows all targets
- Error handling covers common failure cases

**Quality Indicators**:
- No hardcoded secrets in any files
- All targets self-documented
- Error messages include resolution steps
- Works with both HCP Terraform and Terraform Enterprise
- Can be extended with new endpoints without structural changes

## Out of Scope

The following are explicitly NOT included in this feature:

- Graphical user interface or web dashboard
- Real-time run monitoring with polling loops
- Automated retry logic for failed API calls
- Configuration file upload/management (future enhancement)
- Team management operations (future enhancement)
- Policy set management (future enhancement)
- Notification configuration (future enhancement)
- Cost estimation access (future enhancement)
- Run tasks integration (future enhancement)
- Agent pool management (future enhancement)

These may be added in future iterations based on user demand.

## Dependencies

**Internal Dependencies**:
- awesome-makefiles constitution v1.0.0
- common/mk/core.mk pattern library
- common/bin/ helper scripts directory

**External Dependencies**:
- Terraform Enterprise or HCP Terraform account
- API token with appropriate permissions
- Network access to TFE/HCP endpoint

**Documentation Dependencies**:
- Terraform Enterprise API docs: https://developer.hashicorp.com/terraform/enterprise/api-docs
- JSON API specification: https://jsonapi.org/

## Timeline & Phases

**Phase 1 - Core Authentication & Workspace Discovery** (P1):
- Implement auth-check target
- Implement workspace-list and workspace-get targets
- Establish helper script patterns
- Complete error handling framework

**Phase 2 - Run Management** (P2):
- Implement run-create, run-get, run-list targets
- Implement run-apply and run-cancel targets
- Add run status monitoring

**Phase 3 - Variable Management** (P2):
- Implement var-list, var-create, var-update, var-delete targets
- Support sensitive variables
- Support HCL variables

**Phase 4 - State & Workspace Management** (P3):
- Implement state-list and state-download targets
- Implement workspace-create and workspace-update targets
- Implement workspace-delete with safeguards

**Phase 5 - Documentation & Polish**:
- Complete README.md with examples
- Create .env.example template
- Add usage examples for common workflows
- Validate constitution compliance

## Future Enhancements

Potential future additions (not in scope for v1):

- Configuration version upload
- Policy set evaluation
- Team and organization management
- Notification webhooks
- Cost estimation access
- Run task integration
- Agent pool management
- Advanced filtering and search
- Bulk operations (multiple workspaces)
- Watch mode for run monitoring
