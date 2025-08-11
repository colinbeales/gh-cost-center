#!/usr/bin/env bash

# Test helper functions and setup

# Mock the 'die' function to avoid exiting during tests
die() {
    echo "ERROR: $*"
    return 1
}

# Mock the 'usage' function 
usage() {
    echo "USAGE CALLED"
}

# Reset global variables before each test
reset_globals() {
    ENTERPRISE=""
    ORG=""
    TEAM_INPUT=""
    COST_CENTER_NAME=""
    COST_CENTER_ID=""
    CREATE_COST_CENTER=""
    SYNC=""
    FORCE=""
    DRY_RUN=""
    YES=""
    VERBOSE=""
}

# Setup function called before each test
setup_test_env() {
    reset_globals
}
