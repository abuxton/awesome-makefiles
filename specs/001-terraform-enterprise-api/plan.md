# Implementation Plan: Terraform Enterprise API Makefile

**Branch**: `001-terraform-enterprise-api-makefile` | **Date**: 2026-01-15 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-terraform-enterprise-api/spec.md`

## Summary

Create a comprehensive Makefile-based CLI for Terraform Enterprise/HCP Terraform API operations. This implementation provides curl-based API interactions following JSON API specification, with self-documenting targets, robust error handling, and security-first design. Core capabilities include workspace management, run orchestration, variable management, and state access—enabling DevOps teams to automate Terraform workflows without custom tooling.

## Technical Context

**Language/Version**: GNU Make 3.81+, Bash 4.0+  
**Primary Dependencies**: curl (REST API client), jq (JSON processor), git (repository operations)  
**Storage**: N/A (stateless API client)  
**Testing**: Manual testing with real TFE/HCP account, shellcheck for script validation  
**Target Platform**: macOS, Linux (any POSIX-compliant system with bash)  
**Project Type**: Single Makefile with helper scripts  
**Performance Goals**: <500ms per API call (network dependent), respect 30 req/s rate limit  
**Constraints**: JSON API spec compliance, no secrets in code, environment variable-based config  
**Scale/Scope**: ~30 Makefile targets covering 6 user stories, support for unlimited workspaces/runs

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

All Makefile implementations must comply with the awesome-makefiles constitution principles:

- [x] **Pattern Consistency**: Uses `REPO_TOP=$(shell git rev-parse --show-toplevel)`, includes `core.mk`, follows directory structure
- [x] **Self-Documentation**: All targets have `## comments`, help system implemented
- [x] **Security by Default**: No hardcoded secrets, uses environment variables, `.env.example` provided
- [x] **Error Handling First**: Validates prerequisites, provides actionable error messages
- [x] **API Compliance**: Follows API specifications, includes required headers (JSON API spec)
- [x] **Modularity & Reusability**: Common logic extracted to `bin/` or `mk/`, no duplication
- [x] **Dependencies**: Checks required tools (git, make, bash, curl, jq)
- [x] **Naming Conventions**: Targets use kebab-case with resource prefixes (workspace-, run-, var-, state-)
- [x] **Documentation**: README.md complete, examples provided, usage clear

## Project Structure

### Documentation (this feature)

```text
specs/001-terraform-enterprise-api/
├── plan.md              # This file
├── spec.md              # User stories and requirements
├── research.md          # API research and patterns (to be created)
├── data-model.md        # API object models (to be created)
├── contracts/           # API endpoint contracts (to be created)
│   ├── authentication.md
│   ├── workspaces.md
│   ├── runs.md
│   ├── variables.md
│   └── state-versions.md
└── tasks.md             # Implementation task list (to be created)
```

### Source Code (repository root)

```text
hashicorp/terraform/api/
├── Makefile             # Main API Makefile
├── README.md            # Setup, usage, examples
├── .env.example         # Environment variable template
└── bin/                 # Helper scripts (if needed)
    ├── tfe-api-call     # Common API call wrapper
    └── tfe-format       # Response formatting utilities

common/
├── bin/                 # Shared utilities
│   └── (existing scripts)
└── mk/
    └── core.mk          # Shared patterns (existing)
```

## Phase 0: Research & Discovery

**Goal**: Understand TFE API structure, authentication, and response patterns

### Research Tasks

1. **API Authentication Patterns**
   - Review bearer token authentication
   - Document header requirements
   - Test token validation endpoint
   - Identify error response structures

2. **Workspace API Endpoints**
   - List workspaces: GET `/api/v2/organizations/:org/workspaces`
   - Get workspace: GET `/api/v2/workspaces/:id`
   - Create workspace: POST `/api/v2/organizations/:org/workspaces`
   - Update workspace: PATCH `/api/v2/workspaces/:id`
   - Delete workspace: DELETE `/api/v2/workspaces/:id`
   - Document pagination patterns
   - Document include parameter options

3. **Run API Endpoints**
   - List runs: GET `/api/v2/workspaces/:id/runs`
   - Get run: GET `/api/v2/runs/:id`
   - Create run: POST `/api/v2/runs`
   - Apply run: POST `/api/v2/runs/:id/actions/apply`
   - Cancel run: POST `/api/v2/runs/:id/actions/cancel`
   - Document run status transitions

4. **Variable API Endpoints**
   - List variables: GET `/api/v2/workspaces/:id/vars`
   - Get variable: GET `/api/v2/vars/:id`
   - Create variable: POST `/api/v2/vars`
   - Update variable: PATCH `/api/v2/vars/:id`
   - Delete variable: DELETE `/api/v2/vars/:id`
   - Document HCL and sensitive variable handling

5. **State Version API Endpoints**
   - List state versions: GET `/api/v2/state-versions`
   - Get state version: GET `/api/v2/state-versions/:id`
   - Download state: Follow hosted-state-download-url
   - Document blob storage URL expiration (25 hours)

6. **Error Handling Patterns**
   - Test 401 (unauthorized) responses
   - Test 404 (not found/no access) responses
   - Test 429 (rate limit) responses
   - Document JSON API error object structure

**Deliverables**:
- `research.md` with API endpoint documentation
- `contracts/` directory with endpoint specifications
- Test curl commands for each endpoint
- Error response examples

## Phase 1: Design & Architecture

**Goal**: Design Makefile structure, helper scripts, and shared patterns

### Design Tasks

1. **Makefile Structure Design**
   - Define variable structure (TFE_TOKEN, TFE_ORG, TFE_ADDR)
   - Design check-env pattern for validation
   - Design check-deps pattern for tool verification
   - Establish help system integration
   - Plan target organization by resource type

2. **Helper Script Design**
   - Decide: inline curl vs helper script wrapper
   - Design common API call function if needed
   - Design response formatting utilities
   - Plan error message formatting

3. **Data Model Documentation**
   - Document Workspace object structure
   - Document Run object structure
   - Document Variable object structure
   - Document StateVersion object structure
   - Document relationships between objects

4. **Contract Specifications**
   - Write endpoint contracts for each operation
   - Document required parameters
   - Document optional parameters
   - Document response structures
   - Include example requests/responses

5. **Testing Strategy**
   - Plan manual test scenarios
   - Design validation checklist
   - Plan error case testing
   - Consider shellcheck for script validation

**Deliverables**:
- `data-model.md` with API object schemas
- Complete `contracts/` directory
- Architecture decision documentation
- Quickstart guide draft

## Phase 2: Core Implementation

**Goal**: Implement P1 user stories (authentication, workspace discovery)

### Implementation Tasks

**Infrastructure Setup**:
1. Create `hashicorp/terraform/api/` directory
2. Create base Makefile with constitution-compliant structure
3. Implement REPO_TOP, core.mk include, .env include
4. Implement check-env target with TFE_TOKEN, TFE_ORG, TFE_ADDR validation
5. Implement check-deps target with curl, jq, git verification
6. Implement help target with grep-based documentation

**Authentication Implementation**:
7. Implement auth-check target (validate token + organization access)
8. Test with valid credentials
9. Test with invalid credentials
10. Test with missing credentials

**Workspace Discovery Implementation**:
11. Implement workspace-list target with pagination support
12. Implement workspace-list-raw target for pipeline use
13. Implement workspace-get target with WORKSPACE_ID parameter
14. Add include parameter support for related resources
15. Test workspace operations with real data

**Documentation**:
16. Create .env.example with all variables documented
17. Start README.md with setup instructions
18. Add authentication examples to README

**Validation**:
19. Verify constitution compliance checklist
20. Test all error cases
21. Verify help system output

## Phase 3: Run Management Implementation

**Goal**: Implement P2 run management user story

### Implementation Tasks

**Run Creation**:
1. Implement run-create target with WORKSPACE_ID and MESSAGE parameters
2. Support optional AUTO_APPLY parameter
3. Handle JSON API request structure
4. Parse and display created run ID

**Run Querying**:
5. Implement run-list target for workspace runs
6. Implement run-get target with RUN_ID parameter
7. Add pagination support to run-list
8. Format run status output clearly

**Run Actions**:
9. Implement run-apply target with RUN_ID parameter
10. Implement run-cancel target with RUN_ID parameter
11. Add confirmation prompts for destructive operations
12. Handle run status transition errors

**Documentation**:
13. Add run management examples to README
14. Document run status lifecycle
15. Add common workflow examples (create → monitor → apply)

**Validation**:
16. Test run creation with various messages
17. Test run apply on planned runs
18. Test run cancel on in-progress runs
19. Test error cases (wrong status, invalid ID)

## Phase 4: Variable Management Implementation

**Goal**: Implement P2 variable management user story

### Implementation Tasks

**Variable Listing**:
1. Implement var-list target with WORKSPACE_ID parameter
2. Format output to show key, value, category, HCL, sensitive flags
3. Handle sensitive variables (value not displayed)

**Variable Creation**:
4. Implement var-create target with KEY, VALUE, WORKSPACE_ID parameters
5. Support CATEGORY parameter (terraform/env, default: terraform)
6. Support HCL parameter (true/false, default: false)
7. Support SENSITIVE parameter (true/false, default: false)
8. Build correct JSON API structure

**Variable Updates**:
9. Implement var-update target with VAR_ID parameter
10. Support VALUE, CATEGORY, HCL, SENSITIVE parameter updates
11. Handle partial updates correctly

**Variable Deletion**:
12. Implement var-delete target with VAR_ID parameter
13. Add confirmation prompt (optional FORCE parameter)

**Documentation**:
14. Add variable management examples to README
15. Document sensitive variable behavior
16. Add HCL variable examples

**Validation**:
17. Test creating Terraform variables
18. Test creating environment variables
19. Test creating sensitive variables
20. Test creating HCL variables
21. Test update operations
22. Test delete operations

## Phase 5: State & Workspace Management

**Goal**: Implement P3 user stories (state access, workspace CRUD)

### Implementation Tasks

**State Access**:
1. Implement state-list target with WORKSPACE_ID parameter
2. Implement state-get target with STATE_ID parameter
3. Implement state-download target with WORKSPACE_ID parameter
4. Handle blob storage URL extraction and download
5. Save state to local file with appropriate naming

**Workspace Creation**:
6. Implement workspace-create target with NAME parameter
7. Support TF_VERSION, WORKING_DIR, AUTO_APPLY parameters
8. Support VCS integration parameters (OAUTH_TOKEN_ID, REPO)
9. Build correct JSON API structure

**Workspace Updates**:
10. Implement workspace-update target with WORKSPACE_ID parameter
11. Support TF_VERSION, AUTO_APPLY, WORKING_DIR updates
12. Handle partial updates correctly

**Workspace Deletion**:
13. Implement workspace-delete target with WORKSPACE_ID parameter
14. Add confirmation prompt with workspace name display
15. Require CONFIRM parameter or interactive confirmation

**Documentation**:
16. Add state access examples to README
17. Add workspace creation examples
18. Add workspace update examples
19. Document VCS integration setup

**Validation**:
20. Test state listing and download
21. Test workspace creation (basic and VCS)
22. Test workspace updates
23. Test workspace deletion with safeguards

## Phase 6: Documentation & Polish

**Goal**: Complete documentation, validate compliance, prepare for merge

### Tasks

**Documentation Completion**:
1. Complete README.md with all sections:
   - Overview and purpose
   - Installation/setup
   - Environment variables reference
   - Target reference (all commands)
   - Common workflow examples
   - Troubleshooting guide
   - Links to official API docs

2. Finalize .env.example:
   - Document all variables
   - Provide example values
   - Include comments for optional vs required
   - Add links to token creation docs

3. Create QUICKSTART.md:
   - 5-minute getting started guide
   - Most common use cases
   - Copy-paste examples

**Code Quality**:
4. Review all targets for consistency
5. Add comments for complex operations
6. Run shellcheck on any helper scripts
7. Verify error messages are actionable
8. Check for common pitfalls (set -e, quoting, etc.)

**Constitution Compliance**:
9. Review Pattern Consistency checklist
10. Review Self-Documentation checklist
11. Review Security by Default checklist
12. Review Error Handling First checklist
13. Review API Compliance checklist
14. Review Modularity & Reusability checklist
15. Review Dependencies checklist
16. Review Naming Conventions checklist
17. Review Documentation checklist

**Testing**:
18. Test with HCP Terraform (app.terraform.io)
19. Test with Terraform Enterprise (custom domain)
20. Test all error cases systematically
21. Verify help output is complete and clear
22. Test from fresh environment (no assumptions)

**Final Validation**:
23. Ensure no secrets in any files
24. Verify .gitignore includes .env
25. Check for TODOs or placeholder comments
26. Verify all spec requirements met
27. Run full workflow end-to-end test

## Testing Strategy

### Unit Testing (per target)
- Test with valid inputs
- Test with missing required parameters
- Test with invalid credentials
- Test with malformed inputs
- Verify error messages are clear

### Integration Testing (workflows)
- **Workspace Discovery Workflow**: auth-check → workspace-list → workspace-get
- **Run Execution Workflow**: workspace-get → run-create → run-get → run-apply
- **Variable Management Workflow**: var-list → var-create → var-update → var-delete
- **State Access Workflow**: workspace-get → state-list → state-download
- **Workspace Lifecycle**: workspace-create → workspace-update → workspace-delete

### Error Scenario Testing
- Missing TFE_TOKEN
- Missing TFE_ORG
- Invalid TFE_TOKEN
- Missing required parameters
- Invalid workspace/run/variable IDs
- Rate limit responses (if reachable)
- Network errors
- Missing dependencies (curl, jq)

### Platform Testing
- macOS with bash 3.x and 4.x
- Linux with bash 4.x+
- Verify GNU Make compatibility

## Risks & Mitigations

### Risk: API rate limits during testing
**Mitigation**: Space out tests, use dedicated test organization, implement backoff logic in future version

### Risk: Breaking API changes by HashiCorp
**Mitigation**: Pin to v2 API, document API version, monitor changelog, add versioning to Makefile

### Risk: Token exposure in shell history
**Mitigation**: Document environment variable best practices, never prompt for tokens interactively, use .env files

### Risk: Incompatibility with older Make versions
**Mitigation**: Test with Make 3.81 (common baseline), document minimum version, avoid advanced features

### Risk: Complex JSON construction prone to errors
**Mitigation**: Use heredoc syntax for clarity, validate against API docs, test with various inputs

### Risk: Blob storage URLs expiring
**Mitigation**: Document 25-hour limitation, recommend immediate download, consider caching strategies

## Definition of Done

- [ ] All P1 and P2 user stories implemented and tested
- [ ] All P3 user stories implemented and tested (or explicitly deferred)
- [ ] Constitution compliance checklist 100% complete
- [ ] README.md complete with examples
- [ ] .env.example complete with documentation
- [ ] Help system shows all targets with descriptions
- [ ] Error handling covers all common failure modes
- [ ] No hardcoded secrets in any file
- [ ] All targets follow naming conventions
- [ ] Works on macOS and Linux
- [ ] Works with HCP Terraform and Terraform Enterprise
- [ ] No shellcheck warnings
- [ ] Successfully tested end-to-end workflows
- [ ] Documentation reviewed for accuracy
- [ ] Ready for PR and merge to main

## Future Enhancements (Out of Scope)

- Configuration version upload and management
- Team and organization management operations
- Policy set management (Sentinel)
- Notification configuration
- Cost estimation access
- Run tasks integration
- Agent pool management
- Advanced filtering and search capabilities
- Bulk operations (multiple workspaces)
- Watch mode for real-time run monitoring
- Retry logic with exponential backoff
- Response caching for repeated queries
- Interactive mode with prompts
- Bash completion script
- ZSH completion script

These will be considered for future iterations based on user feedback and demand.
