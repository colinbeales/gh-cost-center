# Changelog

All notable changes to the gh-cost-center extension will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2025-08-11

### Added
- **Organization Teams support** with `--org` parameter for using GitHub organization teams instead of enterprise teams
- New API endpoints integration for GitHub Teams API (`/orgs/{org}/teams` and `/orgs/{org}/teams/{team_slug}/members`)
- `resolve_org_team()` function to find organization teams by name or slug
- `get_org_team_members()` function to fetch organization team members
- `resolve_enterprise_team()` and `get_enterprise_team_members()` functions to refactor existing enterprise team logic
- Enhanced team type detection in summary output showing "[org team]" vs "[enterprise team]"
- Updated help text and examples for both enterprise and organization team usage
- Updated documentation with organization teams examples and requirements

### Changed
- Refactored team resolution logic into separate functions for enterprise and organization teams
- Enhanced error messages to differentiate between enterprise and organization team failures
- Updated usage examples to show both enterprise and organization team workflows
- Improved requirements documentation to clarify permissions needed for each team type

### Technical Details
- Organization teams use standard GitHub REST API endpoints (no early access required)
- Maintains backward compatibility with existing enterprise team functionality
- Uses same cost center management logic for both team types

## [1.2.0] - 2025-08-08

### Added
- **Sync functionality** with `--sync` flag for bidirectional team-cost center synchronization
- `remove_users_from_cost_center()` function with batch processing support
- Comprehensive sync logic that removes cost center users not in the enterprise team
- Safety confirmations for user removal operations (respects `--force` mode)
- Verbose logging for sync operations
- `example-sync.sh` demonstrating sync functionality
- Updated API documentation to include DELETE endpoint for user removal

### Changed
- Enhanced help text to include sync functionality
- Updated README with comprehensive sync documentation section
- Improved "How It Works" section to include synchronization step
- Updated limitations section to reflect user removal capabilities

### Fixed
- Variable naming inconsistency between `SYNC_MODE`/`FORCE_MODE` and `SYNC`/`FORCE`
- Resolved "unbound variable" error when using `--sync` flag

### Technical Details
- Sync ensures cost center membership exactly matches enterprise team membership
- Supports dry-run mode for sync operations preview
- Batch processing handles up to 50 user removals per API request
- Maintains all existing safety features (confirmations, force mode, verbose logging)

## [1.1.0] - 2025-08-07

### Added
- **Cost center auto-creation** with `--create-cost-center` flag
- **Force mode** with `--force` flag for full automation
- Enhanced error handling with helpful suggestions
- Improved dry-run mode with cost center creation preview
- Automation and CI/CD documentation
- Better confirmation handling and user experience

### Changed
- Force mode automatically enables cost center creation and skips confirmations
- Enhanced verbose logging throughout the application
- Improved error messages with actionable suggestions

### Fixed
- Better handling of cost center name resolution
- Improved API error reporting
- Enhanced cross-shell compatibility

## [1.0.0] - 2025-08-06

### Added
- Initial release of gh-cost-center extension
- Add enterprise team members to cost centers
- Dry-run mode for previewing changes
- Batch processing for efficient API usage
- Comprehensive error handling
- Support for team names and slugs
- Cost center name and ID resolution
- Verbose logging option
- Enterprise admin permission validation

### Technical Features
- GitHub Enterprise Teams API integration (Early Access)
- GitHub Enterprise Billing API integration
- Batch processing up to 50 users per request
- Cross-platform shell compatibility
- JSON processing with jq
