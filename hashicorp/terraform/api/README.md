# Terraform Enterprise API Makefile

A comprehensive Makefile-based CLI for Terraform Enterprise and HCP Terraform API operations. Automate workspace management, run orchestration, variable configuration, and state access using simple `make` commands.

## Features

- ✅ **Self-Documenting**: Run `make help` to see all available commands
- 🔒 **Security First**: No hardcoded secrets, environment variable-based configuration
- 🛡️ **Error Handling**: Clear, actionable error messages with validation
- 📋 **JSON API Compliant**: Follows Terraform Enterprise API specifications
- 🚀 **Easy to Use**: Simple, consistent command patterns
- 🔧 **Extensible**: Easy to add new endpoints and operations

## Quick Start

### Prerequisites

- `curl` - For API requests
- `jq` - For JSON processing
- `git` - For repository operations
- `make` - GNU Make 3.81+

### Installation

1. **Clone or download this Makefile**:
   ```bash
   cd hashicorp/terraform/api/
   ```

2. **Set up your environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your TFE_TOKEN and TFE_ORG
   ```

3. **Verify dependencies**:
   ```bash
   make check-deps
   ```

4. **Test your credentials**:
   ```bash
   make auth-check
   ```

5. **Start using the API**:
   ```bash
   make workspace-list
   ```

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `TFE_TOKEN` | ✅ Yes | - | Your TFE/HCP Terraform API token |
| `TFE_ORG` | ✅ Yes | - | Your organization name |
| `TFE_ADDR` | ❌ No | `https://app.terraform.io` | API endpoint (use custom for Terraform Enterprise) |

### Getting Your API Token

**HCP Terraform (SaaS)**:
1. Go to https://app.terraform.io/app/settings/tokens
2. Create a new API token
3. Copy it to your `.env` file

**Terraform Enterprise (Self-Hosted)**:
1. Go to `https://your-tfe-instance.com/app/settings/tokens`
2. Create a new API token
3. Set `TFE_ADDR=https://your-tfe-instance.com` in `.env`

## Usage

### Help & Discovery

```bash
# Show all available commands
make help

# Verify dependencies
make check-deps

# Validate credentials
make auth-check
```

### Workspace Operations

```bash
# List all workspaces
make workspace-list

# List workspaces (raw JSON for scripting)
make workspace-list-raw

# Get workspace details
make workspace-get WORKSPACE_ID=ws-xxxxx

# Get workspace with related resources
make workspace-get WORKSPACE_ID=ws-xxxxx INCLUDE=organization,current-run

# Create a new workspace
make workspace-create NAME=my-app-prod

# Create workspace with custom settings
make workspace-create NAME=my-app TF_VERSION=1.6.0 AUTO_APPLY=true

# Update workspace settings
make workspace-update WORKSPACE_ID=ws-xxxxx TF_VERSION=1.6.0

# Enable auto-apply for workspace
make workspace-update WORKSPACE_ID=ws-xxxxx AUTO_APPLY=true

# Delete a workspace (requires confirmation)
make workspace-delete WORKSPACE_ID=ws-xxxxx FORCE=yes
```

### Run Operations

```bash
# List runs for a workspace
make run-list WORKSPACE_ID=ws-xxxxx

# Get run details
make run-get RUN_ID=run-xxxxx

# Create a new run
make run-create WORKSPACE_ID=ws-xxxxx

# Create a run with custom message
make run-create WORKSPACE_ID=ws-xxxxx MESSAGE="Deploy v1.2.3"

# Create a run with auto-apply
make run-create WORKSPACE_ID=ws-xxxxx AUTO_APPLY=true

# Apply a planned run
make run-apply RUN_ID=run-xxxxx

# Apply with a comment
make run-apply RUN_ID=run-xxxxx COMMENT="Approved by ops team"

# Cancel a run
make run-cancel RUN_ID=run-xxxxx
```

### Variable Operations

```bash
# List all variables for a workspace
make var-list WORKSPACE_ID=ws-xxxxx

# Create a Terraform variable
make var-create KEY=region VALUE=us-west-2 WORKSPACE_ID=ws-xxxxx

# Create an environment variable
make var-create KEY=AWS_PROFILE VALUE=prod WORKSPACE_ID=ws-xxxxx CATEGORY=env

# Create a sensitive variable
make var-create KEY=api_key VALUE=secret123 WORKSPACE_ID=ws-xxxxx SENSITIVE=true

# Create an HCL variable
make var-create KEY=tags VALUE='{"env"="prod"}' WORKSPACE_ID=ws-xxxxx HCL=true

# Update a variable
make var-update VAR_ID=var-xxxxx VALUE=new-value

# Delete a variable
make var-delete VAR_ID=var-xxxxx
```

### State Operations

```bash
# List state versions for a workspace
make state-list WORKSPACE_ID=ws-xxxxx

# Get state version details
make state-get STATE_ID=sv-xxxxx

# Download current state
make state-download WORKSPACE_ID=ws-xxxxx

# Download state to specific file
make state-download WORKSPACE_ID=ws-xxxxx OUTPUT_FILE=my-state.json
```

## Common Workflows

### Deploy Infrastructure

```bash
# 1. Verify credentials
make auth-check

# 2. Find your workspace
make workspace-list | grep my-app

# 3. Create a run
make run-create WORKSPACE_ID=ws-xxxxx MESSAGE="Deploy production"

# 4. Monitor the run
make run-get RUN_ID=run-xxxxx

# 5. Apply if plan looks good
make run-apply RUN_ID=run-xxxxx
```

### Configure Workspace

```bash
# 1. List current variables
make var-list WORKSPACE_ID=ws-xxxxx

# 2. Add environment-specific variables
make var-create KEY=environment VALUE=production WORKSPACE_ID=ws-xxxxx
make var-create KEY=region VALUE=us-east-1 WORKSPACE_ID=ws-xxxxx

# 3. Add sensitive credentials
make var-create KEY=db_password VALUE=secret WORKSPACE_ID=ws-xxxxx SENSITIVE=true CATEGORY=env

# 4. Verify configuration
make var-list WORKSPACE_ID=ws-xxxxx
```

### Audit and Compliance

```bash
# 1. Get workspace configuration
make workspace-get WORKSPACE_ID=ws-xxxxx > workspace-config.json

# 2. Check recent runs
make run-list WORKSPACE_ID=ws-xxxxx

# 3. Download current state for review
make state-download WORKSPACE_ID=ws-xxxxx OUTPUT_FILE=audit-state.json

# 4. Review variables (including sensitive flags)
make var-list WORKSPACE_ID=ws-xxxxx
```

### Workspace Lifecycle

```bash
# 1. Create new workspace for feature branch
make workspace-create NAME=my-app-feature-x TF_VERSION=1.6.0

# 2. Configure variables
make var-create KEY=environment VALUE=staging WORKSPACE_ID=ws-xxxxx

# 3. Run infrastructure
make run-create WORKSPACE_ID=ws-xxxxx MESSAGE="Feature X testing"

# 4. Clean up when done
make workspace-delete WORKSPACE_ID=ws-xxxxx FORCE=yes
```

## Pagination

Many list operations support pagination:

```bash
# Get first page (default)
make workspace-list

# Get specific page
make workspace-list PAGE=2

# Change page size (max 100)
make workspace-list PAGE=1 PAGE_SIZE=50

# Pagination works for:
make workspace-list PAGE=2 PAGE_SIZE=20
make run-list WORKSPACE_ID=ws-xxxxx PAGE=2 PAGE_SIZE=10
```

## Error Handling

The Makefile includes comprehensive error handling:

- **Missing Environment Variables**: Clear message with setup instructions
- **Missing Dependencies**: Identifies which tool is missing
- **Missing Parameters**: Shows correct usage example
- **API Errors**: Displays HTTP status and error details
- **Invalid Credentials**: Identifies authentication failures

Example error:
```bash
$ make workspace-get
❌ Error: WORKSPACE_ID required. Usage: make workspace-get WORKSPACE_ID=ws-xxx
```

## Advanced Usage

### Raw Output for Scripting

Most GET operations have `-raw` variants for scripting:

```bash
# Get structured data for processing
WORKSPACE_ID=$(make workspace-list-raw | jq -r '.data[0].id')
make workspace-get WORKSPACE_ID=$WORKSPACE_ID
```

### Include Related Resources

Use the `INCLUDE` parameter to fetch related data:

```bash
make workspace-get WORKSPACE_ID=ws-xxxxx INCLUDE=current-run,organization
```

### Custom Terraform Enterprise Instance

```bash
# Set in .env:
TFE_ADDR=https://terraform.example.com

# Or export for single command:
TFE_ADDR=https://terraform.example.com make workspace-list
```

## Troubleshooting

### "curl: command not found"

Install curl:
```bash
# macOS
brew install curl

# Ubuntu/Debian
sudo apt-get install curl

# RHEL/CentOS
sudo yum install curl
```

### "jq: command not found"

Install jq:
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# RHEL/CentOS
sudo yum install jq
```

### "Error: TFE_TOKEN is not set"

1. Copy `.env.example` to `.env`
2. Add your token to `.env`
3. Make sure you're in the correct directory

### "401 Unauthorized"

Your token is invalid or expired:
1. Generate a new token
2. Update `.env` with the new token
3. Run `make auth-check` to verify

### "404 Not Found"

Either the resource doesn't exist, or you don't have access:
- Verify the ID is correct
- Check your organization membership
- Verify token permissions

### State download fails

- Ensure the workspace has state
- Check that you have read access
- Note: Download URLs expire after 25 hours

## Security Best Practices

1. **Never commit .env**: Already in `.gitignore`, but double-check
2. **Use team tokens for CI/CD**: More secure than personal tokens
3. **Rotate tokens regularly**: Generate new tokens periodically
4. **Limit token scope**: Use the minimum permissions needed
5. **Audit token usage**: Monitor API activity in Terraform Enterprise

## API Documentation

This Makefile implements the Terraform Enterprise API v2:
- **Official Docs**: https://developer.hashicorp.com/terraform/enterprise/api-docs
- **JSON API Spec**: https://jsonapi.org/
- **Rate Limit**: 30 requests/second per user

## Contributing

This Makefile follows the [awesome-makefiles constitution](../../../.specify/memory/constitution.md):
- All targets must have `##` documentation
- No hardcoded secrets
- Comprehensive error handling
- Consistent naming (kebab-case)
- Modular and reusable

## License

This Makefile is part of the awesome-makefiles project. See the repository LICENSE for details.

## Support

- **Issues**: Open an issue in the awesome-makefiles repository
- **API Questions**: See official Terraform Enterprise API documentation
- **Token Issues**: Contact your Terraform Enterprise administrator

---

**Made with ❤️ following [awesome-makefiles constitution v1.0.0](../../../.specify/memory/constitution.md)**
