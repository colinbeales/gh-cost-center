#!/usr/bin/env bash
# Argument parsing and validation

# Global variables for parsed arguments
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

# Parse command line arguments
parse_args() {
    local subcommand=""

    # Handle subcommand
    if [[ $# -gt 0 && "$1" != -* ]]; then
        subcommand="$1"
        shift
    fi

    # Validate subcommand
    case "$subcommand" in
    add-team | "")
        # add-team is the main/default command
        ;;
    *)
        die "Unknown subcommand: $subcommand. Use 'add-team' or see --help"
        ;;
    esac

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
        -e | --enterprise)
            [[ -n "${2:-}" ]] || die "Flag $1 requires a value"
            ENTERPRISE="$2"
            shift 2
            ;;
        --org)
            [[ -n "${2:-}" ]] || die "Flag $1 requires a value"
            ORG="$2"
            shift 2
            ;;
        -t | --team)
            [[ -n "${2:-}" ]] || die "Flag $1 requires a value"
            TEAM_INPUT="$2"
            shift 2
            ;;
        -c | --cost-center)
            [[ -n "${2:-}" ]] || die "Flag $1 requires a value"
            COST_CENTER_NAME="$2"
            shift 2
            ;;
        --cost-center-id)
            [[ -n "${2:-}" ]] || die "Flag $1 requires a value"
            COST_CENTER_ID="$2"
            shift 2
            ;;
        --create-cost-center)
            CREATE_COST_CENTER="1"
            shift
            ;;
        --sync)
            SYNC="1"
            shift
            ;;
        --force)
            FORCE="1"
            YES="1" # Force mode implies yes
            shift
            ;;
        --dry-run)
            DRY_RUN="1"
            shift
            ;;
        -y | --yes)
            YES="1"
            shift
            ;;
        --verbose)
            VERBOSE="1"
            shift
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            die "Unknown flag: $1. Use --help for usage information"
            ;;
        esac
    done
}

# Validate parsed arguments
validate_args() {
    local errors=()

    # Require enterprise
    [[ -z "$ENTERPRISE" ]] && errors+=("Missing required flag: --enterprise")

    # Require team
    [[ -z "$TEAM_INPUT" ]] && errors+=("Missing required flag: --team")

    # Require cost center identification
    if [[ -z "$COST_CENTER_NAME" && -z "$COST_CENTER_ID" ]]; then
        errors+=("Must provide either --cost-center or --cost-center-id")
    fi

    # Mutually exclusive cost center identification
    if [[ -n "$COST_CENTER_NAME" && -n "$COST_CENTER_ID" ]]; then
        errors+=("Cannot use both --cost-center and --cost-center-id")
    fi

    # Report validation errors
    if [[ ${#errors[@]} -gt 0 ]]; then
        for error in "${errors[@]}"; do
            error "$error"
        done
        echo
        usage
        exit 1
    fi

    # Validation passed - now we can safely do verbose logging
    if [[ -n "$ORG" ]]; then
        vlog "Using organization teams from org: $ORG"
    else
        vlog "Using enterprise teams from enterprise: $ENTERPRISE"
    fi

    # Force mode implies create-cost-center
    if [[ -n "$FORCE" && -n "$COST_CENTER_NAME" ]]; then
        CREATE_COST_CENTER="1"
        vlog "Force mode: auto-enabling --create-cost-center"
    fi

    # Export validated variables for modules
    export ENTERPRISE ORG TEAM_INPUT COST_CENTER_NAME COST_CENTER_ID
    export CREATE_COST_CENTER SYNC FORCE DRY_RUN YES VERBOSE
}

# Show usage information
usage() {
    cat <<'EOF'
Usage:
  gh cost-center add-team -e <enterprise> -t <team> -c <cost-center> [OPTIONS]
  gh cost-center add-team -e <enterprise> --org <organization> -t <team> -c <cost-center> [OPTIONS]

Description:
  Add members of a Team to a Cost Center. This command will:
  1. Find the specified team by name (Enterprise Team or Organization Team)
  2. Get all members of that team  
  3. Find the specified cost center by name (or create it if it doesn't exist)
  4. Optionally remove users from cost center who are not in the team (--sync)
  5. Add the team members to the cost center

Flags:
  -e, --enterprise         Enterprise slug (required)
      --org                Organization name (use org teams instead of enterprise teams)
  -t, --team               Team name or slug (required)
  -c, --cost-center        Cost center name (required unless using --cost-center-id)
      --cost-center-id     Cost center ID (overrides --cost-center)
      --create-cost-center Automatically create cost center if it doesn't exist
      --sync               Remove users from cost center who are not in the team
      --force              Force mode: auto-create cost centers and skip all confirmations
      --dry-run            Show actions without applying changes
  -y, --yes                Skip confirmation prompts
      --verbose            Extra logging output
  -h, --help               Show this help message

Examples:
  # Enterprise Teams
  gh cost-center add-team -e myenterprise -t "Engineering Team" -c "Engineering Cost Center"
  gh cost-center add-team -e myenterprise -t engineering-team -c "Engineering Cost Center" --dry-run
  gh cost-center add-team -e myenterprise -t engineering-team --cost-center-id abc123 -y
  gh cost-center add-team -e myenterprise -t "New Team" -c "New Cost Center" --create-cost-center
  gh cost-center add-team -e myenterprise -t "Data Team" -c "Analytics Budget" --force --verbose
  gh cost-center add-team -e myenterprise -t "DevOps Team" -c "Infrastructure Budget" --sync

  # Organization Teams  
  gh cost-center add-team -e myenterprise --org myorg -t "engineering" -c "Engineering Cost Center"
  gh cost-center add-team -e myenterprise --org myorg -t "frontend" -c "UI Cost Center" --sync --verbose

Version: 1.3.0
EOF
}
