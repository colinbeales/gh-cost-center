# gh-cost-center

[![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)](CHANGELOG.md)

A GitHub CLI extension to manage Enterprise Cost Centers and Team membership.

## Overview

This extension allows you to add members of GitHub Teams (both Enterprise Teams and Organization Teams) to Cost Centers automatically. It's designed for GitHub Enterprise Cloud customers who use Cost Centers for billing management.

## Features

- ✅ Add all members of an **Enterprise Team** to a Cost Center
- ✅ Add all members of an **Organization Team** to a Cost Center (new in v1.3.0)
- ✅ **Sync functionality** removes users from cost center who are not in the team (with `--sync`)
- ✅ Automatic team and cost center resolution by name
- ✅ **Auto-create cost centers** when they don't exist (with `--create-cost-center`)
- ✅ **Force mode** for automation with `--force` flag (auto-creates + skips confirmations)
- ✅ Dry-run mode to preview changes
- ✅ Idempotent operations (won't duplicate existing users)
- ✅ Batch processing for large teams
- ✅ Detailed logging and error handling

## Installation

```bash
# Install the extension
gh extension install <your-username>/gh-cost-center

# Or install locally for development
cd gh-cost-center
gh extension install .
```

## Prerequisites

### Requirements
- GitHub Enterprise Cloud with Cost Centers enabled
- For **Enterprise Teams**: Enterprise admin permissions and early access to Enterprise Teams API
- For **Organization Teams**: Organization member permissions with `read:org` scope
- Personal access token with `manage_billing:enterprise` scope
- GitHub CLI authenticated with appropriate permissions

### Authentication
Your GitHub CLI must be authenticated with a token that has:
- `manage_billing:enterprise` scope (required for cost center management)
- For Enterprise Teams: Enterprise admin permissions
- For Organization Teams: `read:org` scope

```bash
# Check authentication status
gh auth status

# Login if needed
gh auth login
```

## Usage

### Basic Usage

Add all members of a team to a cost center:

```bash
gh cost-center add-team -e myenterprise -t "Engineering Team" -c "Engineering Cost Center"
```

Add all members of an organization team to a cost center:

```bash
gh cost-center add-team -e myenterprise --org myorg -t "engineering" -c "Engineering Cost Center"
```

### Options

```bash
gh cost-center add-team [options]

Required:
  -e, --enterprise         Enterprise slug
  -t, --team              Enterprise Team name or Org Team Name (if used with --org)
  -c, --cost-center       Cost center name
      --cost-center-id    Cost center ID (alternative to --cost-center)

Optional:
      --org               Organization name (use org teams instead of enterprise teams)
      --create-cost-center Automatically create cost center if it doesn't exist
      --sync              Remove users from cost center who are not in the team
      --force             Force mode: auto-create cost centers and skip all confirmations
      --dry-run           Show what would be changed without making changes
  -y, --yes              Skip confirmation prompts
      --verbose          Enable detailed logging
  -h, --help             Show help message
```

### Examples

#### Enterprise Teams
```bash
# Basic usage with team and cost center names
gh cost-center add-team -e myenterprise -t "Engineering Team" -c "Engineering Budget"

# Using team slug instead of name
gh cost-center add-team -e myenterprise -t engineering-team -c "Engineering Budget"

# Preview changes without applying them
gh cost-center add-team -e myenterprise -t "DevOps Team" -c "Infrastructure Budget" --dry-run

# Create cost center if it doesn't exist (with confirmation)
gh cost-center add-team -e myenterprise -t "New Team" -c "New Cost Center" --create-cost-center

# Force mode: Auto-create cost center and skip all confirmations (perfect for automation)
gh cost-center add-team -e myenterprise -t "Data Team" -c "Analytics Budget" --force --verbose

# Skip confirmation prompts (useful for automation)
gh cost-center add-team -e myenterprise -t "QA Team" -c "Quality Assurance Budget" -y

# Use cost center ID instead of name (more precise)
gh cost-center add-team -e myenterprise -t "Data Team" --cost-center-id "abc123-def456"

# Synchronize cost center membership with team (removes users not in team)
gh cost-center add-team -e myenterprise -t "DevOps Team" -c "Infrastructure Budget" --sync

# Enable verbose logging for troubleshooting
gh cost-center add-team -e myenterprise -t "Security Team" -c "Security Budget" --verbose
```

#### Organization Teams
```bash
# Basic usage with organization team
gh cost-center add-team -e myenterprise --org myorg -t "engineering" -c "Engineering Budget"

# Organization team with sync functionality
gh cost-center add-team -e myenterprise --org myorg -t "data-science" -c "Analytics Budget" --sync

# Force mode with organization team
gh cost-center add-team -e myenterprise --org myorg -t "devops" -c "Infrastructure Budget" --force

# Dry run with organization team
gh cost-center add-team -e myenterprise --org myorg -t "security" -c "Security Budget" --dry-run --verbose
```

## How It Works

1. **Team Resolution**: Finds the team by name or slug (enterprise team or organization team)
2. **Member Retrieval**: Gets all members of the specified team using appropriate API
3. **Cost Center Resolution**: Finds the cost center by name or uses provided ID
4. **Cost Center Creation**: Optionally creates cost center if it doesn't exist (with `--create-cost-center` or `--force`)
5. **Duplicate Check**: Identifies team members not already in the cost center
6. **Batch Addition**: Adds new users to the cost center in batches (up to 50 per request)
7. **Synchronization**: Optionally removes users from cost center who are not in the team (with `--sync`)
8. **Result Summary**: Reports success/failure counts

## Sync Functionality

The `--sync` flag provides bidirectional synchronization between teams and cost centers:

### What Sync Does
- **Adds missing users**: Team members not in the cost center are added
- **Removes extra users**: Cost center users not in the team are removed
- **Maintains alignment**: Ensures cost center membership exactly matches team membership

### When to Use Sync
- **Team changes**: When team membership has changed and you want cost centers to reflect current membership
- **Clean-up**: Remove former team members from cost center budgets
- **Compliance**: Ensure only current team members have access to cost center resources
- **Automation**: Regular sync jobs to maintain alignment

### Sync Safety Features
- **Confirmation prompts**: Shows exactly which users will be removed (unless `--force` is used)
- **Dry run support**: Use `--dry-run` to preview sync actions
- **Verbose logging**: Use `--verbose` to see detailed sync operations
- **Batch operations**: Handles large user lists efficiently

```bash
# Preview sync changes
gh cost-center add-team -e myenterprise -t "DevOps Team" -c "Infrastructure" --sync --dry-run

# Sync with confirmation
gh cost-center add-team -e myenterprise -t "DevOps Team" -c "Infrastructure" --sync

# Automated sync (no prompts)
gh cost-center add-team -e myenterprise -t "DevOps Team" -c "Infrastructure" --sync --force
```

## API Endpoints Used

This extension uses the following GitHub APIs:

### Enterprise Teams API (Early Access)
- `GET /enterprises/{enterprise}/teams` - List enterprise teams
- `GET /enterprises/{enterprise}/teams/{team_slug}` - Get enterprise team details
- `GET /enterprises/{enterprise}/teams/{team_slug}/memberships` - List enterprise team members

### Organization Teams API (Standard)
- `GET /orgs/{org}/teams` - List organization teams
- `GET /orgs/{org}/teams/{team_slug}` - Get organization team details  
- `GET /orgs/{org}/teams/{team_slug}/members` - List organization team members

### Enterprise Billing API
- `GET /enterprises/{enterprise}/settings/billing/cost-centers` - List cost centers
- `GET /enterprises/{enterprise}/settings/billing/cost-centers/{id}` - Get cost center details
- `GET /enterprises/{enterprise}/settings/billing/cost-centers/{id}/resource` - Get cost center users
- `POST /enterprises/{enterprise}/settings/billing/cost-centers` - Create cost center
- `POST /enterprises/{enterprise}/settings/billing/cost-centers/{id}/resource` - Add users to cost center
- `DELETE /enterprises/{enterprise}/settings/billing/cost-centers/{id}/resource` - Remove users from cost center
- `DELETE /enterprises/{enterprise}/settings/billing/cost-centers/{id}/resource` - Remove users from cost center

## Error Handling

The extension includes comprehensive error handling for common scenarios:

- **Authentication errors**: Checks if `gh` is authenticated
- **Permission errors**: Validates enterprise admin access
- **Team not found**: Clear error when team name/slug is invalid
- **Cost center not found**: Clear error when cost center name is invalid
- **API failures**: Graceful handling of network/API issues
- **Partial failures**: Reports which users were successfully added vs failed

## Limitations

- Maximum 50 users can be added/removed per API request (automatically handled with batching)
- Requires GitHub Enterprise Cloud with Enhanced Billing Platform
- Enterprise Teams API is currently in Early Access
- User removal only available via sync functionality (--sync flag)

## Development

### Local Testing

```bash
# Install locally
cd gh-cost-center
gh extension install .

# Test the extension
gh cost-center add-team --help

# Uninstall
gh extension remove cost-center
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Troubleshooting

### Common Issues

**"Not authenticated with GitHub"**
- Run `gh auth login` and ensure your token has enterprise permissions

**"Failed to fetch teams"**
- Verify you have enterprise admin permissions
- Check if Enterprise Teams early access is enabled for your enterprise

**"Failed to fetch cost centers"**
- Verify your enterprise uses the Enhanced Billing Platform
- Check if cost centers are enabled for your enterprise

**"Team not found"**
- Try using the team slug instead of the display name
- Use `--verbose` to see available teams

**"Cost center not found"**
- Use the exact cost center name as it appears in billing settings
- Consider using `--cost-center-id` instead
- Use `--create-cost-center` or `--force` to create it automatically

### Getting Help

For issues with this extension:
1. Check the troubleshooting section above
2. Run with `--verbose` for detailed logging
3. Verify your GitHub Enterprise setup supports the required features

For GitHub Enterprise Teams or Billing API issues:
- Contact GitHub Enterprise Support
- Check the GitHub Enterprise documentation

## Automation & CI/CD

The extension is designed for automation scenarios:

### GitHub Actions Example
```yaml
- name: Add team to cost center
  run: |
    gh extension install <username>/gh-cost-center
    gh cost-center add-team \
      -e "${{ vars.ENTERPRISE }}" \
      -t "${{ vars.TEAM_NAME }}" \
      -c "${{ vars.COST_CENTER }}" \
      --force --verbose
  env:
    GH_TOKEN: ${{ secrets.ENTERPRISE_TOKEN }}
```

### Automation Best Practices
- Use `--force` for fully automated runs (creates cost centers and skips confirmations)
- Use `--dry-run` first to validate configuration
- Use `--verbose` for detailed logging in CI/CD
- Store enterprise details in environment variables or secrets
- Use dedicated service accounts with minimal required permissions

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Changelog

### v1.3.0
- **Added GitHub Organization Teams support** with `--org` parameter
- Support for both Enterprise Teams and Organization Teams
- New Organization Teams API integration
- Enhanced team resolution logic for dual team type support
- Updated documentation and examples for organization teams
- Improved error handling for different team types

### v1.2.0
- **Added sync functionality** with `--sync` flag for bidirectional synchronization
- Remove cost center users who are not in the team
- Enhanced safety features with removal confirmations
- Comprehensive sync documentation and examples
- Fixed variable naming inconsistencies

### v1.1.0
- **Added cost center auto-creation** with `--create-cost-center` flag
- **Added force mode** with `--force` flag for full automation
- Enhanced error handling with helpful suggestions
- Improved dry-run mode with cost center creation preview
- Added automation and CI/CD documentation
- Better confirmation handling and user experience

### v1.0.0
- Initial release
- Add team members to cost centers
- Dry-run mode
- Batch processing
- Comprehensive error handling
