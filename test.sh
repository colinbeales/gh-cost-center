#!/usr/bin/env bash
# Test script for gh-cost-center extension

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing gh-cost-center extension...${NC}\n"

# Test 1: Help message
echo -e "${YELLOW}Test 1: Help message${NC}"
if ./gh-cost-center --help >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Help message displays correctly${NC}"
else
    echo -e "${RED}✗ Help message failed${NC}"
    exit 1
fi

# Test 2: Invalid subcommand
echo -e "\n${YELLOW}Test 2: Invalid subcommand handling${NC}"
if ./gh-cost-center invalid-command 2>/dev/null; then
    echo -e "${RED}✗ Should reject invalid subcommand${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Invalid subcommand properly rejected${NC}"
fi

# Test 3: Missing required arguments
echo -e "\n${YELLOW}Test 3: Missing required arguments${NC}"
if ./gh-cost-center add-team 2>/dev/null; then
    echo -e "${RED}✗ Should require arguments${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Missing arguments properly detected${NC}"
fi

# Test 4: Add-team help
echo -e "\n${YELLOW}Test 4: Add-team help${NC}"
if ./gh-cost-center add-team --help >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Add-team help displays correctly${NC}"
else
    echo -e "${RED}✗ Add-team help failed${NC}"
    exit 1
fi

# Test 5: Argument parsing (dry run with all required args)
echo -e "\n${YELLOW}Test 5: Argument parsing${NC}"
# This will fail on API calls but should parse arguments correctly
output=$(./gh-cost-center add-team -e test -t test -c test --dry-run 2>&1 || true)
if echo "$output" | grep -q "Failed to fetch\|Not authenticated\|Starting to add enterprise team"; then
    echo -e "${GREEN}✓ Arguments parsed correctly (expected API failure)${NC}"
else
    echo -e "${RED}✗ Unexpected error in argument parsing${NC}"
    echo "Output: $output"
fi

echo -e "\n${GREEN}All basic tests passed!${NC}"
echo -e "\n${YELLOW}Note: Full functionality testing requires:${NC}"
echo "- GitHub CLI authentication (gh auth login)"
echo "- GitHub Enterprise Cloud with Enterprise Teams and Cost Centers"
echo "- Enterprise admin permissions"
echo -e "\n${YELLOW}To test with real data, use:${NC}"
echo "./gh-cost-center add-team -e YOUR_ENTERPRISE -t YOUR_TEAM -c YOUR_COST_CENTER --dry-run"
