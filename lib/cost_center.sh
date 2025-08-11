#!/usr/bin/env bash
# Cost center management

# Global variables
RESOLVED_COST_CENTER_ID=""

# Resolve cost center by name or use provided ID
resolve_cost_center() {
    if [[ -n "$COST_CENTER_ID" ]]; then
        vlog "Using provided cost center ID: $COST_CENTER_ID"
        RESOLVED_COST_CENTER_ID="$COST_CENTER_ID"

        # Validate the cost center exists
        if ! get_cost_center_details "$ENTERPRISE" "$RESOLVED_COST_CENTER_ID" >/dev/null 2>&1; then
            die "Cost center with ID '$RESOLVED_COST_CENTER_ID' not found"
        fi

        export RESOLVED_COST_CENTER_ID
        return
    fi

    vlog "Resolving cost center by name: $COST_CENTER_NAME"

    local all_cost_centers
    all_cost_centers="$(list_cost_centers "$ENTERPRISE")" || die "Failed to fetch cost centers"

    local found_id
    found_id="$(
        printf '%s' "$all_cost_centers" | jq -r --arg name "$COST_CENTER_NAME" '
            .costCenters[]? | select(.name == $name) | .id
        ' | head -n1
    )"

    if [[ -n "$found_id" ]]; then
        RESOLVED_COST_CENTER_ID="$found_id"
        log "Found cost center: $COST_CENTER_NAME (ID: $RESOLVED_COST_CENTER_ID)"
        export RESOLVED_COST_CENTER_ID
        return
    fi

    # Cost center not found
    if [[ -z "${CREATE_COST_CENTER:-}" ]]; then
        die "Cost center '$COST_CENTER_NAME' not found. Use --create-cost-center to create it automatically"
    fi

    # Create cost center
    create_cost_center_if_needed
}

# Create cost center if it doesn't exist
create_cost_center_if_needed() {
    if [[ -n "${DRY_RUN:-}" ]]; then
        dry_run_log "Would create cost center: $COST_CENTER_NAME"
        RESOLVED_COST_CENTER_ID="dry-run-id"
        export RESOLVED_COST_CENTER_ID
        return
    fi

    if [[ -z "${FORCE:-}" ]] && ! confirm "Create cost center '$COST_CENTER_NAME'?"; then
        die "Cost center creation cancelled"
    fi

    log "Creating cost center: $COST_CENTER_NAME"

    local creation_response
    creation_response="$(create_cost_center "$ENTERPRISE" "$COST_CENTER_NAME")" || {
        die "Failed to create cost center '$COST_CENTER_NAME'"
    }

    RESOLVED_COST_CENTER_ID="$(printf '%s' "$creation_response" | json_field_or_empty '.id')"

    if [[ -z "$RESOLVED_COST_CENTER_ID" ]]; then
        die "Created cost center but failed to get ID from response"
    fi

    log "Created cost center: $COST_CENTER_NAME (ID: $RESOLVED_COST_CENTER_ID)"
    export RESOLVED_COST_CENTER_ID
}

# Get current cost center users
get_current_cost_center_users() {
    vlog "Fetching current cost center users"

    # Always fetch users for comparison, even in dry-run mode
    get_cost_center_users "$ENTERPRISE" "$RESOLVED_COST_CENTER_ID"
}

# Add users to cost center
add_users_to_cost_center_batch() {
    local -a users=("$@")

    if [[ ${#users[@]} -eq 0 ]]; then
        vlog "No users to add to cost center"
        return 0
    fi

    if [[ -n "${DRY_RUN:-}" ]]; then
        dry_run_log "Would add ${#users[@]} users to cost center: ${users[*]}"
        return 0
    fi

    log "Adding ${#users[@]} users to cost center..."
    vlog "Users to add: ${users[*]}"

    local payload
    payload="$(create_user_payload "${users[@]}")"

    if ! printf '%s' "$payload" | add_users_to_cost_center "$ENTERPRISE" "$RESOLVED_COST_CENTER_ID" >/dev/null; then
        die "Failed to add users to cost center"
    fi

    log "Successfully added ${#users[@]} users to cost center"
}

# Remove users from cost center
remove_users_from_cost_center_batch() {
    local -a users=("$@")

    if [[ ${#users[@]} -eq 0 ]]; then
        vlog "No users to remove from cost center"
        return 0
    fi

    if [[ -n "${DRY_RUN:-}" ]]; then
        dry_run_log "Would remove ${#users[@]} users from cost center: ${users[*]}"
        return 0
    fi

    # Confirmation for removal (unless force mode)
    if [[ -z "${FORCE:-}" ]] && ! confirm "Remove ${#users[@]} users from cost center?"; then
        log "User removal cancelled"
        return 0
    fi

    log "Removing ${#users[@]} users from cost center..."
    vlog "Users to remove: ${users[*]}"

    local payload
    payload="$(create_user_payload "${users[@]}")"

    if ! printf '%s' "$payload" | remove_users_from_cost_center "$ENTERPRISE" "$RESOLVED_COST_CENTER_ID" >/dev/null; then
        die "Failed to remove users from cost center"
    fi

    log "Successfully removed ${#users[@]} users from cost center"
}
