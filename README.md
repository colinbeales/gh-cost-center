# gh-cost-center

A GitHub CLI extension to manage Enterprise Cost Centers and Team membership.

## Overview

This extension allows you to add members of GitHub Enterprise Teams to Cost Centers automatically. It's designed for GitHub Enterprise Cloud customers who use both Enterprise Teams and Cost Centers for billing management.

## Features

- ✅ Add all members of an Enterprise Team to a Cost Center
- ✅ Automatic team and cost center resolution by name
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
- GitHub Enterprise Cloud account
- Access to Enterprise Teams (Early Access feature)
- Access to Cost Centers (Enhanced billing platform)
- Enterprise admin permissions
- GitHub CLI authenticated with appropriate permissions

### Authentication
Your GitHub CLI must be authenticated with a token that has:
- `manage_billing:enterprise` scope
- Enterprise admin permissions

```bash
# Check authentication status
gh auth status

# Login if needed
gh auth login
```

## Usage

### Basic Usage

Add all members of an enterprise team to a cost center:

```bash
gh cost-center add-team -e myenterprise -t "Engineering Team" -c "Engineering Cost Center"
```

### Options

```bash
gh cost-center add-team [options]

Required:
  -e, --enterprise     Enterprise slug
  -t, --team          Enterprise team name or slug
  -c, --cost-center   Cost center name
      --cost-center-id Cost center ID (alternative to --cost-center)

Optional:
      --dry-run       Show what would be changed without making changes
  -y, --yes          Skip confirmation prompts
      --verbose      Enable detailed logging
  -h, --help         Show help message
```

### Examples

```bash
# Basic usage with team and cost center names
gh cost-center add-team -e myenterprise -t "Engineering Team" -c "Engineering Budget"

# Using team slug instead of name
gh cost-center add-team -e myenterprise -t engineering-team -c "Engineering Budget"

# Preview changes without applying them
gh cost-center add-team -e myenterprise -t "DevOps Team" -c "Infrastructure Budget" --dry-run

# Skip confirmation prompts (useful for automation)
gh cost-center add-team -e myenterprise -t "QA Team" -c "Quality Assurance Budget" -y

# Use cost center ID instead of name (more precise)
gh cost-center add-team -e myenterprise -t "Data Team" --cost-center-id "abc123-def456"

# Enable verbose logging for troubleshooting
gh cost-center add-team -e myenterprise -t "Security Team" -c "Security Budget" --verbose
```

## How It Works

1. **Team Resolution**: Finds the enterprise team by name or slug
2. **Member Retrieval**: Gets all members of the specified team
3. **Cost Center Resolution**: Finds the cost center by name or uses provided ID
4. **Duplicate Check**: Identifies team members not already in the cost center
5. **Batch Addition**: Adds new users to the cost center in batches (up to 50 per request)
6. **Result Summary**: Reports success/failure counts

## API Endpoints Used

This extension uses the following GitHub Enterprise APIs:

### Enterprise Teams API (Early Access)
- `GET /enterprises/{enterprise}/teams` - List enterprise teams
- `GET /enterprises/{enterprise}/teams/{team_slug}` - Get team details
- `GET /enterprises/{enterprise}/teams/{team_slug}/memberships` - List team members

### Enterprise Billing API
- `GET /enterprises/{enterprise}/settings/billing/cost-centers` - List cost centers
- `GET /enterprises/{enterprise}/settings/billing/cost-centers/{id}` - Get cost center details
- `POST /enterprises/{enterprise}/settings/billing/cost-centers/{id}/resource` - Add users to cost center

## Error Handling

The extension includes comprehensive error handling for common scenarios:

- **Authentication errors**: Checks if `gh` is authenticated
- **Permission errors**: Validates enterprise admin access
- **Team not found**: Clear error when team name/slug is invalid
- **Cost center not found**: Clear error when cost center name is invalid
- **API failures**: Graceful handling of network/API issues
- **Partial failures**: Reports which users were successfully added vs failed

## Limitations

- Maximum 50 users can be added per API request (automatically handled with batching)
- Requires GitHub Enterprise Cloud with Enhanced Billing Platform
- Enterprise Teams API is currently in Early Access
- Only supports adding users (not removing)

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

### Getting Help

For issues with this extension:
1. Check the troubleshooting section above
2. Run with `--verbose` for detailed logging
3. Verify your GitHub Enterprise setup supports the required features

For GitHub Enterprise Teams or Billing API issues:
- Contact GitHub Enterprise Support
- Check the GitHub Enterprise documentation

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Changelog

### v1.0.0
- Initial release
- Add enterprise team members to cost centers
- Dry-run mode
- Batch processing
- Comprehensive error handling
