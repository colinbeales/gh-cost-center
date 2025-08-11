#!/usr/bin/env bash
# Team resolution and member retrieval

# Global variables
TEAM_SLUG=""

# Resolve team by name or slug
resolve_team() {
    local team_input="$1"
    local teams_json

    vlog "Resolving team: $team_input"

    if [[ -n "${ORG:-}" ]]; then
        vlog "Fetching organization teams from: $ORG"
        teams_json="$(list_org_teams "$ORG")" || die "Failed to fetch organization teams"
    else
        vlog "Fetching enterprise teams from: $ENTERPRISE"
        teams_json="$(list_enterprise_teams "$ENTERPRISE")" || die "Failed to fetch enterprise teams"
    fi

    # Try to resolve team slug using priority order:
    # 1. Exact slug match
    # 2. Exact name match
    # 3. Case-insensitive name match
    TEAM_SLUG="$(
        printf '%s' "$teams_json" | jq -r --arg input "$team_input" '
            [.[] | {slug, name}] |
            (
                map(select(.slug == $input)) +
                map(select(.name == $input)) +
                map(select((.name | ascii_downcase) == ($input | ascii_downcase)))
            ) |
            .[0].slug // empty
        '
    )"

    # Fallback to using input as slug directly
    if [[ -z "$TEAM_SLUG" ]]; then
        warn "Team '$team_input' not found in team list, trying as direct slug"
        TEAM_SLUG="$team_input"
    else
        vlog "Resolved team '$team_input' to slug: $TEAM_SLUG"
    fi

    export TEAM_SLUG
}

# Get team members
get_team_members() {
    local members_json

    if [[ -n "${ORG:-}" ]]; then
        vlog "Fetching organization team members: $ORG/$TEAM_SLUG"
        members_json="$(get_org_team_members "$ORG" "$TEAM_SLUG")" || {
            die "Failed to fetch organization team members. Check that team '$TEAM_SLUG' exists in organization '$ORG'"
        }
    else
        vlog "Fetching enterprise team members: $ENTERPRISE/$TEAM_SLUG"
        members_json="$(get_enterprise_team_members "$ENTERPRISE" "$TEAM_SLUG")" || {
            die "Failed to fetch enterprise team members. Check that team '$TEAM_SLUG' exists in enterprise '$ENTERPRISE'"
        }
    fi

    # Extract usernames from the response
    printf '%s' "$members_json" | collect_usernames
}

# Validate team exists and get basic info
validate_team() {
    local team_details

    if [[ -n "${ORG:-}" ]]; then
        vlog "Validating organization team: $ORG/$TEAM_SLUG"
        team_details="$(get_org_team_details "$ORG" "$TEAM_SLUG" 2>/dev/null)" || {
            die "Team '$TEAM_SLUG' not found in organization '$ORG'"
        }
    else
        vlog "Validating enterprise team: $ENTERPRISE/$TEAM_SLUG"
        # For enterprise teams, get details from the teams list since individual team endpoint doesn't exist
        local teams_json
        teams_json="$(list_enterprise_teams "$ENTERPRISE" 2>/dev/null)" || {
            die "Failed to fetch enterprise teams from '$ENTERPRISE'"
        }
        team_details="$(printf '%s' "$teams_json" | jq -r --arg slug "$TEAM_SLUG" '.[] | select(.slug == $slug)')" || {
            die "Team '$TEAM_SLUG' not found in enterprise '$ENTERPRISE'"
        }
        if [[ -z "$team_details" || "$team_details" == "null" ]]; then
            die "Team '$TEAM_SLUG' not found in enterprise '$ENTERPRISE'"
        fi
    fi

    local team_name
    team_name="$(printf '%s' "$team_details" | json_field_or_empty '.name')"

    if [[ -n "$team_name" ]]; then
        log "Found team: $team_name (slug: $TEAM_SLUG)"
    else
        warn "Team found but name not available"
    fi
}
