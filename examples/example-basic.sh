#!/usr/bin/env bash
# Basic example of using gh-cost-center extension

set -euo pipefail

# Configuration - UPDATE THESE VALUES
ENTERPRISE="your-enterprise-slug"
TEAM_NAME="Engineering Team"
COST_CENTER_NAME="Engineering Budget"

echo "Basic gh-cost-center usage example"
echo "=================================="
echo ""

# First, let's do a dry run to see what would happen
echo "Step 1: Dry run to preview changes"
echo "Command: gh cost-center add-team -e '$ENTERPRISE' -t '$TEAM_NAME' -c '$COST_CENTER_NAME' --dry-run"
echo ""

gh cost-center add-team \
  -e "$ENTERPRISE" \
  -t "$TEAM_NAME" \
  -c "$COST_CENTER_NAME" \
  --dry-run

echo ""
echo "Dry run completed. Review the output above."
echo ""

# Ask user if they want to proceed
read -p "Do you want to proceed with the actual changes? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Step 2: Adding team members to cost center"
    echo ""
    
    gh cost-center add-team \
      -e "$ENTERPRISE" \
      -t "$TEAM_NAME" \
      -c "$COST_CENTER_NAME" \
      --verbose
    
    echo ""
    echo "✓ Operation completed!"
else
    echo "Operation cancelled."
fi
