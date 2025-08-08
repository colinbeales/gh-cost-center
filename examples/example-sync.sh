#!/bin/bash

# Example: Synchronizing team membership with cost center
# This example demonstrates how to use the --sync flag to ensure the cost center
# only contains users who are currently in the enterprise team.

# Configuration
ENTERPRISE="myenterprise"
TEAM="DevOps Team"
COST_CENTER="Infrastructure Budget"

echo "=== Synchronizing Team with Cost Center ==="
echo "Enterprise: $ENTERPRISE"
echo "Team: $TEAM"
echo "Cost Center: $COST_CENTER"
echo

# This command will:
# 1. Add any team members who are not in the cost center
# 2. Remove any cost center users who are not in the team
# 3. Ensure perfect synchronization between team and cost center membership

gh cost-center add-team \
  --enterprise "$ENTERPRISE" \
  --team "$TEAM" \
  --cost-center "$COST_CENTER" \
  --sync \
  --verbose

echo
echo "Synchronization complete!"
echo "The cost center now contains exactly the same users as the enterprise team."
