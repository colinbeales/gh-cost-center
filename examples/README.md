# Example Usage Scripts

This directory contains example scripts showing how to use the gh-cost-center extension.

## Prerequisites

Before running these examples:

1. Install the extension:
   ```bash
   gh extension install <your-username>/gh-cost-center
   ```

2. Authenticate with GitHub:
   ```bash
   gh auth login
   ```

3. Ensure your token has `manage_billing:enterprise` scope and enterprise admin permissions.

## Examples

### example-basic.sh
Basic usage example that adds a team to a cost center.

### example-multiple-teams.sh
Advanced example that adds multiple teams to different cost centers.

### example-with-validation.sh
Example with validation checks and error handling.

### example-sync.sh
Synchronization example that ensures cost center membership matches team membership exactly.

### example-org-teams.sh
Organization teams example showing how to use GitHub organization teams instead of enterprise teams.

## Running Examples

Make the scripts executable and run them:

```bash
chmod +x examples/*.sh
./examples/example-basic.sh
```

**Important**: Update the placeholder values (enterprise, team names, cost center names) with your actual values before running.
