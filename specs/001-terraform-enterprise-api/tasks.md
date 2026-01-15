# Tasks: Terraform Enterprise API Makefile

**Input**: Design documents from `/specs/001-terraform-enterprise-api/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md (in progress), data-model.md (pending), contracts/ (pending)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

This project follows: `hashicorp/terraform/api/` for Makefile and scripts

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create `hashicorp/terraform/api/` directory structure
- [ ] T002 [P] Create `.env.example` template with TFE_TOKEN, TFE_ORG, TFE_ADDR documented
- [ ] T003 [P] Create initial `hashicorp/terraform/api/README.md` with placeholder sections
- [ ] T004 [P] Update `hashicorp/terraform/api/.gitignore` to include `.env`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T005 Create `hashicorp/terraform/api/Makefile` with constitution-compliant structure
- [ ] T006 Add `REPO_TOP=$(shell git rev-parse --show-toplevel)` to Makefile
- [ ] T007 Add `-include .env` to Makefile for environment variables
- [ ] T008 Add `-include ${REPO_TOP}/common/mk/core.mk` to Makefile
- [ ] T009 Define TFE_ADDR, TFE_API_VERSION, TFE_BASE_URL variables with defaults
- [ ] T010 Define REQUIRED_VARS list (TFE_TOKEN, TFE_ORG)
- [ ] T011 Implement `check-deps` target to verify curl, jq, git availability
- [ ] T012 Implement `check-env` target to validate required environment variables
- [ ] T013 Implement `help` target with grep-based documentation system
- [ ] T014 Set default target to `all: help`
- [ ] T015 Test help system displays correctly
- [ ] T016 Test check-deps with missing curl, jq (validate error messages)
- [ ] T017 Test check-env with missing TFE_TOKEN, TFE_ORG (validate error messages)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Validate API Connection (Priority: P1) 🎯 MVP

**Goal**: Enable users to validate their TFE credentials and organization access

**Independent Test**: Set TFE_TOKEN and TFE_ORG, run `make auth-check`, verify success

### Authentication Implementation

- [ ] T018 [US1] Implement `auth-check` target in `hashicorp/terraform/api/Makefile`
- [ ] T019 [US1] Add dependency on `check-env` to `auth-check` target
- [ ] T020 [US1] Build curl command with Authorization and Content-Type headers
- [ ] T021 [US1] Call GET `/api/v2/organizations/${TFE_ORG}` endpoint
- [ ] T022 [US1] Pipe response through `jq '.'` for pretty printing
- [ ] T023 [US1] Add `## Validate API credentials and organization access` help text

### Testing & Validation

- [ ] T024 [US1] Test auth-check with valid TFE_TOKEN and TFE_ORG
- [ ] T025 [US1] Test auth-check with invalid TFE_TOKEN (expect 401 error)
- [ ] T026 [US1] Test auth-check with invalid TFE_ORG (expect 404 error)
- [ ] T027 [US1] Test auth-check with missing TFE_TOKEN (expect check-env error)
- [ ] T028 [US1] Verify error messages are actionable

### Documentation

- [ ] T029 [US1] Add authentication section to README.md
- [ ] T030 [US1] Document how to obtain TFE_TOKEN in README.md
- [ ] T031 [US1] Add auth-check example to README.md

**Deliverable**: Users can validate credentials before performing operations

---

## Phase 4: User Story 2 - List and Query Workspaces (Priority: P1) 🎯 MVP

**Goal**: Enable workspace discovery and detailed inspection

**Independent Test**: Run `make workspace-list`, get workspace ID, run `make workspace-get WORKSPACE_ID=ws-xxx`

### Workspace List Implementation

- [ ] T032 [US2] Implement `workspace-list` target in Makefile
- [ ] T033 [US2] Add dependency on `check-env` to `workspace-list`
- [ ] T034 [US2] Build curl GET to `/api/v2/organizations/${TFE_ORG}/workspaces`
- [ ] T035 [US2] Add support for PAGE and PAGE_SIZE parameters (optional)
- [ ] T036 [US2] Pipe through `jq '.data[] | {id, type, name: .attributes.name}'` for clean output
- [ ] T037 [US2] Add `## List all workspaces in organization` help text
- [ ] T038 [US2] Implement `workspace-list-raw` target for unformatted JSON output

### Workspace Get Implementation

- [ ] T039 [US2] Implement `workspace-get` target in Makefile
- [ ] T040 [US2] Add dependency on `check-env` to `workspace-get`
- [ ] T041 [US2] Add validation check for WORKSPACE_ID parameter
- [ ] T042 [US2] Build curl GET to `/api/v2/workspaces/$(WORKSPACE_ID)`
- [ ] T043 [US2] Add support for optional INCLUDE parameter for related resources
- [ ] T044 [US2] Pipe through `jq '.'` for pretty output
- [ ] T045 [US2] Add `## Get workspace details (requires WORKSPACE_ID)` help text

### Testing & Validation

- [ ] T046 [US2] Test workspace-list with valid credentials
- [ ] T047 [US2] Test workspace-list with pagination (PAGE=2, PAGE_SIZE=10)
- [ ] T048 [US2] Test workspace-list-raw outputs valid JSON
- [ ] T049 [US2] Test workspace-get with valid WORKSPACE_ID
- [ ] T050 [US2] Test workspace-get with invalid WORKSPACE_ID (expect 404)
- [ ] T051 [US2] Test workspace-get with missing WORKSPACE_ID parameter (expect error)
- [ ] T052 [US2] Test workspace-get with INCLUDE parameter

### Documentation

- [ ] T053 [US2] Add workspace discovery section to README.md
- [ ] T054 [US2] Add workspace-list and workspace-get examples to README.md
- [ ] T055 [US2] Document pagination usage in README.md

**Deliverable**: Users can discover and inspect workspaces

---

## Phase 5: User Story 3 - Manage Workspace Runs (Priority: P2)

**Goal**: Enable run creation, monitoring, and execution

**Independent Test**: Create run with `make run-create`, monitor with `make run-get`, apply with `make run-apply`

### Run List Implementation

- [ ] T056 [US3] Implement `run-list` target in Makefile
- [ ] T057 [US3] Add dependency on `check-env` to `run-list`
- [ ] T058 [US3] Add validation for WORKSPACE_ID parameter
- [ ] T059 [US3] Build curl GET to `/api/v2/workspaces/$(WORKSPACE_ID)/runs`
- [ ] T060 [US3] Add pagination support (PAGE, PAGE_SIZE)
- [ ] T061 [US3] Format output with jq to show run ID, status, message
- [ ] T062 [US3] Add `## List runs for workspace (requires WORKSPACE_ID)` help text

### Run Get Implementation

- [ ] T063 [US3] Implement `run-get` target in Makefile
- [ ] T064 [US3] Add dependency on `check-env` to `run-get`
- [ ] T065 [US3] Add validation for RUN_ID parameter
- [ ] T066 [US3] Build curl GET to `/api/v2/runs/$(RUN_ID)`
- [ ] T067 [US3] Format output with jq to highlight status, plan summary
- [ ] T068 [US3] Add `## Get run details (requires RUN_ID)` help text

### Run Create Implementation

- [ ] T069 [US3] Implement `run-create` target in Makefile
- [ ] T070 [US3] Add dependency on `check-env` to `run-create`
- [ ] T071 [US3] Add validation for WORKSPACE_ID parameter
- [ ] T072 [US3] Support MESSAGE parameter with default "Triggered via Makefile"
- [ ] T073 [US3] Support optional AUTO_APPLY parameter (true/false)
- [ ] T074 [US3] Build JSON API request with data.type="runs"
- [ ] T075 [US3] Add data.attributes.message from MESSAGE parameter
- [ ] T076 [US3] Add data.relationships.workspace with WORKSPACE_ID
- [ ] T077 [US3] Build curl POST to `/api/v2/runs` with JSON payload
- [ ] T078 [US3] Format response to display created run ID and status
- [ ] T079 [US3] Add `## Create run (requires WORKSPACE_ID, optional: MESSAGE, AUTO_APPLY)` help text

### Run Apply Implementation

- [ ] T080 [US3] Implement `run-apply` target in Makefile
- [ ] T081 [US3] Add dependency on `check-env` to `run-apply`
- [ ] T082 [US3] Add validation for RUN_ID parameter
- [ ] T083 [US3] Build curl POST to `/api/v2/runs/$(RUN_ID)/actions/apply`
- [ ] T084 [US3] Add optional COMMENT parameter for apply comment
- [ ] T085 [US3] Format response to show apply status
- [ ] T086 [US3] Add `## Apply run (requires RUN_ID, optional: COMMENT)` help text

### Run Cancel Implementation

- [ ] T087 [US3] Implement `run-cancel` target in Makefile
- [ ] T088 [US3] Add dependency on `check-env` to `run-cancel`
- [ ] T089 [US3] Add validation for RUN_ID parameter
- [ ] T090 [US3] Build curl POST to `/api/v2/runs/$(RUN_ID)/actions/cancel`
- [ ] T091 [US3] Add optional COMMENT parameter for cancel reason
- [ ] T092 [US3] Format response to show cancellation status
- [ ] T093 [US3] Add `## Cancel run (requires RUN_ID, optional: COMMENT)` help text

### Testing & Validation

- [ ] T094 [US3] Test run-list with valid WORKSPACE_ID
- [ ] T095 [US3] Test run-get with valid RUN_ID
- [ ] T096 [US3] Test run-create with WORKSPACE_ID and custom MESSAGE
- [ ] T097 [US3] Test run-create with AUTO_APPLY=true
- [ ] T098 [US3] Test run-apply with planned run (requires real run)
- [ ] T099 [US3] Test run-cancel with in-progress run (if available)
- [ ] T100 [US3] Test error cases for missing parameters
- [ ] T101 [US3] Test error cases for invalid RUN_ID/WORKSPACE_ID

### Documentation

- [ ] T102 [US3] Add run management section to README.md
- [ ] T103 [US3] Add run workflow examples (create → monitor → apply) to README.md
- [ ] T104 [US3] Document run status transitions in README.md

**Deliverable**: Users can manage run lifecycle programmatically

---

## Phase 6: User Story 4 - Manage Workspace Variables (Priority: P2)

**Goal**: Enable variable CRUD operations for workspace configuration

**Independent Test**: List vars with `make var-list`, create with `make var-create`, update, delete

### Variable List Implementation

- [ ] T105 [US4] Implement `var-list` target in Makefile
- [ ] T106 [US4] Add dependency on `check-env` to `var-list`
- [ ] T107 [US4] Add validation for WORKSPACE_ID parameter
- [ ] T108 [US4] Build curl GET to `/api/v2/workspaces/$(WORKSPACE_ID)/vars`
- [ ] T109 [US4] Format with jq to show id, key, value, category, hcl, sensitive
- [ ] T110 [US4] Handle sensitive variables (value hidden)
- [ ] T111 [US4] Add `## List variables for workspace (requires WORKSPACE_ID)` help text

### Variable Create Implementation

- [ ] T112 [US4] Implement `var-create` target in Makefile
- [ ] T113 [US4] Add dependency on `check-env` to `var-create`
- [ ] T114 [US4] Add validation for KEY, VALUE, WORKSPACE_ID parameters
- [ ] T115 [US4] Support CATEGORY parameter (terraform|env, default: terraform)
- [ ] T116 [US4] Support HCL parameter (true|false, default: false)
- [ ] T117 [US4] Support SENSITIVE parameter (true|false, default: false)
- [ ] T118 [US4] Build JSON API request with data.type="vars"
- [ ] T119 [US4] Add data.attributes with key, value, category, hcl, sensitive
- [ ] T120 [US4] Add data.relationships.workspace with WORKSPACE_ID
- [ ] T121 [US4] Build curl POST to `/api/v2/vars` with JSON payload
- [ ] T122 [US4] Format response to show created variable details
- [ ] T123 [US4] Add `## Create variable (requires KEY, VALUE, WORKSPACE_ID, optional: CATEGORY, HCL, SENSITIVE)` help text

### Variable Update Implementation

- [ ] T124 [US4] Implement `var-update` target in Makefile
- [ ] T125 [US4] Add dependency on `check-env` to `var-update`
- [ ] T126 [US4] Add validation for VAR_ID parameter
- [ ] T127 [US4] Support VALUE, CATEGORY, HCL, SENSITIVE parameters (all optional)
- [ ] T128 [US4] Build JSON API PATCH request with updated attributes
- [ ] T129 [US4] Build curl PATCH to `/api/v2/vars/$(VAR_ID)`
- [ ] T130 [US4] Format response to show updated variable
- [ ] T131 [US4] Add `## Update variable (requires VAR_ID, optional: VALUE, CATEGORY, HCL, SENSITIVE)` help text

### Variable Delete Implementation

- [ ] T132 [US4] Implement `var-delete` target in Makefile
- [ ] T133 [US4] Add dependency on `check-env` to `var-delete`
- [ ] T134 [US4] Add validation for VAR_ID parameter
- [ ] T135 [US4] Build curl DELETE to `/api/v2/vars/$(VAR_ID)`
- [ ] T136 [US4] Display confirmation message
- [ ] T137 [US4] Add `## Delete variable (requires VAR_ID)` help text

### Testing & Validation

- [ ] T138 [US4] Test var-list with valid WORKSPACE_ID
- [ ] T139 [US4] Test var-create with Terraform variable
- [ ] T140 [US4] Test var-create with environment variable (CATEGORY=env)
- [ ] T141 [US4] Test var-create with HCL variable (HCL=true)
- [ ] T142 [US4] Test var-create with sensitive variable (SENSITIVE=true)
- [ ] T143 [US4] Test var-update changing VALUE
- [ ] T144 [US4] Test var-update changing SENSITIVE flag
- [ ] T145 [US4] Test var-delete with valid VAR_ID
- [ ] T146 [US4] Test error cases for missing parameters
- [ ] T147 [US4] Test error cases for invalid VAR_ID/WORKSPACE_ID

### Documentation

- [ ] T148 [US4] Add variable management section to README.md
- [ ] T149 [US4] Add examples for each variable operation to README.md
- [ ] T150 [US4] Document sensitive variable behavior in README.md
- [ ] T151 [US4] Add HCL variable examples to README.md

**Deliverable**: Users can manage workspace variables programmatically

---

## Phase 7: User Story 5 - Access State Versions (Priority: P3)

**Goal**: Enable state version listing and download

**Independent Test**: List states with `make state-list`, download with `make state-download`

### State List Implementation

- [ ] T152 [US5] Implement `state-list` target in Makefile
- [ ] T153 [US5] Add dependency on `check-env` to `state-list`
- [ ] T154 [US5] Add validation for WORKSPACE_ID parameter
- [ ] T155 [US5] Build curl GET to `/api/v2/state-versions?filter[workspace][name]=${WORKSPACE_NAME}` or use workspace relationship
- [ ] T156 [US5] Format with jq to show state version ID, created-at, serial
- [ ] T157 [US5] Add `## List state versions for workspace (requires WORKSPACE_ID)` help text

### State Get Implementation

- [ ] T158 [US5] Implement `state-get` target in Makefile
- [ ] T159 [US5] Add dependency on `check-env` to `state-get`
- [ ] T160 [US5] Add validation for STATE_ID parameter
- [ ] T161 [US5] Build curl GET to `/api/v2/state-versions/$(STATE_ID)`
- [ ] T162 [US5] Format with jq to show state details and download URL
- [ ] T163 [US5] Add `## Get state version details (requires STATE_ID)` help text

### State Download Implementation

- [ ] T164 [US5] Implement `state-download` target in Makefile
- [ ] T165 [US5] Add dependency on `check-env` to `state-download`
- [ ] T166 [US5] Add validation for WORKSPACE_ID parameter
- [ ] T167 [US5] Get current state version for workspace
- [ ] T168 [US5] Extract hosted-state-download-url from response
- [ ] T169 [US5] Download state file using curl (no auth header needed for blob storage)
- [ ] T170 [US5] Save to file named `${WORKSPACE_ID}-state.json` or OUTPUT_FILE if provided
- [ ] T171 [US5] Add warning about 25-hour URL expiration
- [ ] T172 [US5] Add `## Download current state (requires WORKSPACE_ID, optional: OUTPUT_FILE)` help text

### Testing & Validation

- [ ] T173 [US5] Test state-list with valid WORKSPACE_ID
- [ ] T174 [US5] Test state-get with valid STATE_ID
- [ ] T175 [US5] Test state-download with valid WORKSPACE_ID
- [ ] T176 [US5] Verify downloaded state file is valid JSON
- [ ] T177 [US5] Test error cases for missing parameters
- [ ] T178 [US5] Test error cases for workspaces with no state

### Documentation

- [ ] T179 [US5] Add state access section to README.md
- [ ] T180 [US5] Add state download examples to README.md
- [ ] T181 [US5] Document blob storage URL expiration in README.md

**Deliverable**: Users can access and download state versions

---

## Phase 8: User Story 6 - Create and Manage Workspaces (Priority: P3)

**Goal**: Enable workspace lifecycle management (create, update, delete)

**Independent Test**: Create workspace with `make workspace-create`, update with `make workspace-update`, delete with `make workspace-delete`

### Workspace Create Implementation

- [ ] T182 [US6] Implement `workspace-create` target in Makefile
- [ ] T183 [US6] Add dependency on `check-env` to `workspace-create`
- [ ] T184 [US6] Add validation for NAME parameter
- [ ] T185 [US6] Support optional TF_VERSION, WORKING_DIR, AUTO_APPLY parameters
- [ ] T186 [US6] Support optional VCS parameters (OAUTH_TOKEN_ID, REPO, BRANCH)
- [ ] T187 [US6] Build JSON API request with data.type="workspaces"
- [ ] T188 [US6] Add data.attributes with name and optional settings
- [ ] T189 [US6] Add data.relationships for VCS if provided
- [ ] T190 [US6] Build curl POST to `/api/v2/organizations/${TFE_ORG}/workspaces`
- [ ] T191 [US6] Format response to show created workspace ID and details
- [ ] T192 [US6] Add `## Create workspace (requires NAME, optional: TF_VERSION, AUTO_APPLY, VCS settings)` help text

### Workspace Update Implementation

- [ ] T193 [US6] Implement `workspace-update` target in Makefile
- [ ] T194 [US6] Add dependency on `check-env` to `workspace-update`
- [ ] T195 [US6] Add validation for WORKSPACE_ID parameter
- [ ] T196 [US6] Support optional TF_VERSION, AUTO_APPLY, WORKING_DIR parameters
- [ ] T197 [US6] Build JSON API PATCH request with updated attributes
- [ ] T198 [US6] Build curl PATCH to `/api/v2/workspaces/$(WORKSPACE_ID)`
- [ ] T199 [US6] Format response to show updated workspace
- [ ] T200 [US6] Add `## Update workspace (requires WORKSPACE_ID, optional: TF_VERSION, AUTO_APPLY, etc.)` help text

### Workspace Delete Implementation

- [ ] T201 [US6] Implement `workspace-delete` target in Makefile
- [ ] T202 [US6] Add dependency on `check-env` to `workspace-delete`
- [ ] T203 [US6] Add validation for WORKSPACE_ID parameter
- [ ] T204 [US6] Fetch workspace details to display name for confirmation
- [ ] T205 [US6] Add confirmation prompt unless FORCE=yes
- [ ] T206 [US6] Build curl DELETE to `/api/v2/workspaces/$(WORKSPACE_ID)`
- [ ] T207 [US6] Display confirmation message
- [ ] T208 [US6] Add `## Delete workspace (requires WORKSPACE_ID, optional: FORCE=yes)` help text

### Testing & Validation

- [ ] T209 [US6] Test workspace-create with basic parameters
- [ ] T210 [US6] Test workspace-create with VCS integration
- [ ] T211 [US6] Test workspace-create with AUTO_APPLY=true
- [ ] T212 [US6] Test workspace-update changing TF_VERSION
- [ ] T213 [US6] Test workspace-update changing AUTO_APPLY
- [ ] T214 [US6] Test workspace-delete with confirmation
- [ ] T215 [US6] Test workspace-delete with FORCE=yes
- [ ] T216 [US6] Test error cases for missing parameters
- [ ] T217 [US6] Test error cases for duplicate workspace names

### Documentation

- [ ] T218 [US6] Add workspace lifecycle section to README.md
- [ ] T219 [US6] Add workspace creation examples to README.md
- [ ] T220 [US6] Add workspace update examples to README.md
- [ ] T221 [US6] Document VCS integration setup in README.md

**Deliverable**: Users can manage workspace lifecycle programmatically

---

## Phase 9: Documentation & Polish

**Purpose**: Complete documentation, validate compliance, prepare for merge

### Documentation Completion

- [ ] T222 Complete README.md with all sections (overview, setup, usage, examples, troubleshooting)
- [ ] T223 Add environment variables reference table to README.md
- [ ] T224 Add target reference section with all commands to README.md
- [ ] T225 Add common workflow examples to README.md
- [ ] T226 Add troubleshooting section to README.md (common errors and solutions)
- [ ] T227 Add links to official TFE API docs in README.md
- [ ] T228 Finalize .env.example with all variables documented
- [ ] T229 Add comments to .env.example for required vs optional variables
- [ ] T230 Add links to token creation docs in .env.example

### Code Quality & Polish

- [ ] T231 Review all targets for consistent formatting
- [ ] T232 Add comments for complex curl commands
- [ ] T233 Verify all error messages are actionable
- [ ] T234 Check for code duplication, extract if needed
- [ ] T235 Run shellcheck on any helper scripts (if created)
- [ ] T236 Verify all targets use consistent parameter patterns
- [ ] T237 Check for TODOs or placeholder comments, resolve them

### Constitution Compliance Validation

- [ ] T238 ✅ Pattern Consistency: REPO_TOP, core.mk, directory structure
- [ ] T239 ✅ Self-Documentation: All targets have ## comments
- [ ] T240 ✅ Security by Default: No secrets, environment variables only
- [ ] T241 ✅ Error Handling First: Prerequisites validated, clear errors
- [ ] T242 ✅ API Compliance: JSON API spec followed, proper headers
- [ ] T243 ✅ Modularity: No duplication, common logic extracted
- [ ] T244 ✅ Dependencies: curl, jq, git checked
- [ ] T245 ✅ Naming Conventions: kebab-case with prefixes
- [ ] T246 ✅ Documentation: README complete, examples provided

### Comprehensive Testing

- [ ] T247 Test with HCP Terraform (app.terraform.io)
- [ ] T248 Test with Terraform Enterprise (custom domain, if available)
- [ ] T249 Test all error cases systematically (missing vars, invalid IDs, auth failures)
- [ ] T250 Verify help output is complete and formatted correctly
- [ ] T251 Test from fresh shell environment (no assumptions about variables)
- [ ] T252 Test all user story workflows end-to-end
- [ ] T253 Verify .gitignore includes .env
- [ ] T254 Verify no secrets in any committed files

### Final Validation

- [ ] T255 Run complete workflow: auth → workspace discovery → run management
- [ ] T256 Verify all P1 and P2 user stories fully functional
- [ ] T257 Verify all P3 user stories fully functional (or documented as deferred)
- [ ] T258 Check for any remaining TODOs or FIXMEs
- [ ] T259 Verify all spec requirements met
- [ ] T260 Prepare commit message for final merge
- [ ] T261 Create pull request with complete description
- [ ] T262 Self-review all changes before requesting review

---

## Total Tasks: 262

**By Priority**:
- P1 (MVP): 61 tasks (T001-T055 + foundation)
- P2: 146 tasks (T056-T151)
- P3: 70 tasks (T152-T221)
- Polish: 41 tasks (T222-T262)

**Estimated Effort**: 3-5 days for complete implementation and testing

**Success Criteria**: All tasks complete, constitution compliant, fully documented, ready to merge
