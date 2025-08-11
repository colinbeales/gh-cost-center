#!/usr/bin/env bats

# Test argument parsing and validation

load "test_helper"

setup() {
    # Source the args module
    source "$BATS_TEST_DIRNAME/../lib/log.sh"
    source "$BATS_TEST_DIRNAME/../lib/args.sh"
}

@test "parse_args handles basic required flags" {
    parse_args add-team -e myenterprise -t myteam -c mycostcenter
    
    [[ "$ENTERPRISE" == "myenterprise" ]]
    [[ "$TEAM_INPUT" == "myteam" ]]
    [[ "$COST_CENTER_NAME" == "mycostcenter" ]]
}

@test "parse_args handles org flag" {
    parse_args add-team -e myenterprise --org myorg -t myteam -c mycostcenter
    
    [[ "$ENTERPRISE" == "myenterprise" ]]
    [[ "$ORG" == "myorg" ]]
    [[ "$TEAM_INPUT" == "myteam" ]]
    [[ "$COST_CENTER_NAME" == "mycostcenter" ]]
}

@test "parse_args handles boolean flags" {
    parse_args add-team -e myenterprise -t myteam -c mycostcenter --sync --dry-run --verbose
    
    [[ -n "$SYNC" ]]
    [[ -n "$DRY_RUN" ]]
    [[ -n "$VERBOSE" ]]
}

@test "parse_args handles force mode" {
    parse_args add-team -e myenterprise -t myteam -c mycostcenter --force
    
    [[ -n "$FORCE" ]]
    [[ -n "$YES" ]]  # Force mode should set YES
}

@test "parse_args handles cost-center-id instead of cost-center" {
    parse_args add-team -e myenterprise -t myteam --cost-center-id abc123
    
    [[ "$COST_CENTER_ID" == "abc123" ]]
    [[ -z "$COST_CENTER_NAME" ]]
}

@test "validate_args fails with missing enterprise" {
    ENTERPRISE=""
    TEAM_INPUT="myteam"
    COST_CENTER_NAME="mycostcenter"
    
    run validate_args
    [[ "$status" -eq 1 ]]
    [[ "$output" =~ "Missing required flag: --enterprise" ]]
}

@test "validate_args fails with missing team" {
    ENTERPRISE="myenterprise"
    TEAM_INPUT=""
    COST_CENTER_NAME="mycostcenter"
    
    run validate_args
    [[ "$status" -eq 1 ]]
    [[ "$output" =~ "Missing required flag: --team" ]]
}

@test "validate_args fails with missing cost center identification" {
    ENTERPRISE="myenterprise"
    TEAM_INPUT="myteam"
    COST_CENTER_NAME=""
    COST_CENTER_ID=""
    
    run validate_args
    [[ "$status" -eq 1 ]]
    [[ "$output" =~ "Must provide either --cost-center or --cost-center-id" ]]
}

@test "validate_args fails with both cost center name and ID" {
    ENTERPRISE="myenterprise"
    TEAM_INPUT="myteam"
    COST_CENTER_NAME="mycostcenter"
    COST_CENTER_ID="abc123"
    
    run validate_args
    [[ "$status" -eq 1 ]]
    [[ "$output" =~ "Cannot use both --cost-center and --cost-center-id" ]]
}

@test "validate_args passes with valid enterprise team config" {
    ENTERPRISE="myenterprise"
    TEAM_INPUT="myteam"
    COST_CENTER_NAME="mycostcenter"
    ORG=""
    COST_CENTER_ID=""
    
    run validate_args
    [[ "$status" -eq 0 ]]
}

@test "validate_args passes with valid org team config" {
    ENTERPRISE="myenterprise"
    ORG="myorg"
    TEAM_INPUT="myteam"
    COST_CENTER_NAME="mycostcenter"
    COST_CENTER_ID=""
    
    run validate_args
    [[ "$status" -eq 0 ]]
}
