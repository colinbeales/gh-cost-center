#!/usr/bin/env bash
# Example with validation and error handling

set -euo pipefail

# Configuration - UPDATE THESE VALUES
ENTERPRISE="your-enterprise-slug"
TEAM_NAME="Engineering Team"
COST_CENTER_NAME="Engineering Budget"

echo "Validation and error handling example"
echo "===================================="
echo ""

# Function to check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: $1 is not installed or not in PATH" >&2
        exit 1
    fi
}

# Function to validate inputs
validate_inputs() {
    if [[ -z "$ENTERPRISE" || "$ENTERPRISE" == "your-enterprise-slug" ]]; then
        echo "Error: Please update ENTERPRISE variable with your actual enterprise slug" >&2
        exit 1
    fi
    
    if [[ -z "$TEAM_NAME" || "$TEAM_NAME" == "Engineering Team" ]]; then
        echo "Warning: Using default team name. Update TEAM_NAME variable if needed" >&2
    fi
    
    if [[ -z "$COST_CENTER_NAME" || "$COST_CENTER_NAME" == "Engineering Budget" ]]; then
        echo "Warning: Using default cost center name. Update COST_CENTER_NAME variable if needed" >&2
    fi
}

# Step 1: Check prerequisites
echo "Step 1: Checking prerequisites"
echo "------------------------------"

check_command "gh"
check_command "jq"

echo "✓ Required commands are available"

# Check if gh is authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "Error: GitHub CLI is not authenticated. Run 'gh auth login' first." >&2
    exit 1
fi

echo "✓ GitHub CLI is authenticated"
echo ""

# Step 2: Validate inputs
echo "Step 2: Validating inputs"
echo "-------------------------"

validate_inputs

echo "✓ Configuration looks good"
echo "  Enterprise: $ENTERPRISE"
echo "  Team: $TEAM_NAME"
echo "  Cost Center: $COST_CENTER_NAME"
echo ""

# Step 3: Test API access with dry run
echo "Step 3: Testing API access"
echo "--------------------------"

echo "Running dry-run to validate API access..."

if gh cost-center add-team \
    -e "$ENTERPRISE" \
    -t "$TEAM_NAME" \
    -c "$COST_CENTER_NAME" \
    --dry-run \
    --verbose; then
    echo "✓ API access validation successful"
else
    echo "✗ API access validation failed"
    echo ""
    echo "Common causes:"
    echo "1. Enterprise slug is incorrect"
    echo "2. Team name/slug is incorrect"
    echo "3. Cost center name is incorrect"
    echo "4. Insufficient permissions (need enterprise admin)"
    echo "5. Enterprise Teams or Cost Centers not enabled"
    exit 1
fi

echo ""

# Step 4: Confirmation and execution
echo "Step 4: Final confirmation"
echo "-------------------------"

echo "Ready to add team members to cost center."
echo ""

read -p "Proceed with the operation? [y/N]: " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Executing operation..."
    
    if gh cost-center add-team \
        -e "$ENTERPRISE" \
        -t "$TEAM_NAME" \
        -c "$COST_CENTER_NAME" \
        --verbose; then
        echo ""
        echo "🎉 Operation completed successfully!"
    else
        echo ""
        echo "❌ Operation failed. Check the error messages above."
        exit 1
    fi
else
    echo "Operation cancelled by user."
fi
