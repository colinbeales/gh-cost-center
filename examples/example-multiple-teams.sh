#!/usr/bin/env bash
# Example: Adding multiple teams to different cost centers

set -euo pipefail

# Configuration - UPDATE THESE VALUES
ENTERPRISE="your-enterprise-slug"

# Array of team to cost-center mappings
declare -A TEAM_MAPPINGS=(
    ["Engineering Team"]="Engineering Budget"
    ["DevOps Team"]="Infrastructure Budget"
    ["QA Team"]="Quality Assurance Budget"
    ["Data Team"]="Analytics Budget"
)

echo "Multiple teams to cost centers example"
echo "====================================="
echo ""

echo "This will add the following teams to their respective cost centers:"
for team in "${!TEAM_MAPPINGS[@]}"; do
    echo "  • $team → ${TEAM_MAPPINGS[$team]}"
done
echo ""

# Ask for confirmation
read -p "Do you want to proceed? [y/N]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo ""
echo "Processing teams..."
echo ""

# Process each team
for team in "${!TEAM_MAPPINGS[@]}"; do
    cost_center="${TEAM_MAPPINGS[$team]}"
    
    echo "----------------------------------------"
    echo "Processing: $team → $cost_center"
    echo "----------------------------------------"
    
    if gh cost-center add-team \
        -e "$ENTERPRISE" \
        -t "$team" \
        -c "$cost_center" \
        --yes \
        --verbose; then
        echo "✓ Successfully processed $team"
    else
        echo "✗ Failed to process $team"
    fi
    
    echo ""
done

echo "All teams processed!"
