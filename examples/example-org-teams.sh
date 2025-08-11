#!/bin/bash

# Example: Using Organization Teams with gh-cost-center
# This example demonstrates how to use organization teams instead of enterprise teams

set -e

ENTERPRISE="myenterprise"
ORG="myorg"
COST_CENTER="Development Costs"

echo "=== Organization Teams Examples ==="
echo ""

echo "1. Basic organization team to cost center assignment:"
echo "   gh cost-center add-team -e $ENTERPRISE --org $ORG -t \"frontend\" -c \"$COST_CENTER\""
echo ""

echo "2. Preview changes with dry-run:"
echo "   gh cost-center add-team -e $ENTERPRISE --org $ORG -t \"backend\" -c \"$COST_CENTER\" --dry-run"
echo ""

echo "3. Synchronize cost center with team membership (removes extra users):"
echo "   gh cost-center add-team -e $ENTERPRISE --org $ORG -t \"devops\" -c \"$COST_CENTER\" --sync"
echo ""

echo "4. Force mode for automation (auto-create cost center, skip confirmations):"
echo "   gh cost-center add-team -e $ENTERPRISE --org $ORG -t \"data-science\" -c \"Analytics Budget\" --force"
echo ""

echo "5. Using team slug with verbose logging:"
echo "   gh cost-center add-team -e $ENTERPRISE --org $ORG -t \"security-team\" -c \"Security Budget\" --verbose"
echo ""

# Uncomment to run actual examples:

# echo "Running example 1: Add frontend team to cost center"
# gh cost-center add-team -e "$ENTERPRISE" --org "$ORG" -t "frontend" -c "$COST_CENTER" --dry-run

# echo "Running example 2: Sync backend team"
# gh cost-center add-team -e "$ENTERPRISE" --org "$ORG" -t "backend" -c "$COST_CENTER" --sync --dry-run

echo "=== Key Differences from Enterprise Teams ==="
echo ""
echo "✓ Use --org parameter to specify organization"
echo "✓ Team names/slugs are from organization teams (not enterprise teams)"
echo "✓ Requires read:org permissions instead of enterprise admin"
echo "✓ Uses standard GitHub REST API (no early access required)"
echo "✓ Cost center management still requires enterprise admin permissions"
echo ""

echo "=== Prerequisites for Organization Teams ==="
echo ""
echo "• GitHub CLI authenticated with read:org scope"
echo "• Member of the organization specified with --org"
echo "• Enterprise admin permissions for cost center management"
echo "• Enterprise billing enabled with cost centers feature"
echo ""
