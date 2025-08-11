#!/usr/bin/env bash
# GitHub API abstraction layer

# API configuration
API_VERSION="2022-11-28"
API_HEADERS=(-H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: ${API_VERSION}")

# Core API wrappers
gh_get() {
    local endpoint="$1"
    shift
    gh api "${API_HEADERS[@]}" "$endpoint" "$@"
}

gh_post_json() {
    local endpoint="$1"
    gh api "${API_HEADERS[@]}" --method POST "$endpoint" --input -
}

gh_put_json() {
    local endpoint="$1"
    gh api "${API_HEADERS[@]}" --method PUT "$endpoint" --input -
}

gh_delete_json() {
    local endpoint="$1"
    gh api "${API_HEADERS[@]}" --method DELETE "$endpoint" --input -
}

gh_delete() {
    local endpoint="$1"
    gh api "${API_HEADERS[@]}" --method DELETE "$endpoint"
}

# Organization Teams API
list_org_teams() {
    local org="$1"
    gh_get "/orgs/${org}/teams" --paginate
}

get_org_team_details() {
    local org="$1"
    local team_slug="$2"
    gh_get "/orgs/${org}/teams/${team_slug}"
}

get_org_team_members() {
    local org="$1"
    local team_slug="$2"
    gh_get "/orgs/${org}/teams/${team_slug}/members" --paginate
}

# Enterprise Teams API
list_enterprise_teams() {
    local enterprise="$1"
    gh_get "/enterprises/${enterprise}/teams" --paginate
}

get_enterprise_team_details() {
    local enterprise="$1"
    local team_slug="$2"
    gh_get "/enterprises/${enterprise}/teams/${team_slug}"
}

get_enterprise_team_members() {
    local enterprise="$1"
    local team_slug="$2"
    gh_get "/enterprises/${enterprise}/teams/${team_slug}/memberships" --paginate
}

# Enterprise Billing API
list_cost_centers() {
    local enterprise="$1"
    gh_get "/enterprises/${enterprise}/settings/billing/cost-centers" --paginate
}

get_cost_center_details() {
    local enterprise="$1"
    local cost_center_id="$2"
    gh_get "/enterprises/${enterprise}/settings/billing/cost-centers/${cost_center_id}"
}

get_cost_center_users() {
    local enterprise="$1"
    local cost_center_id="$2"
    # Get cost center details and extract users from resources
    gh_get "/enterprises/${enterprise}/settings/billing/cost-centers/${cost_center_id}" |
        jq -r '.resources[]? | select(.type=="User") | .name // empty'
}

create_cost_center() {
    local enterprise="$1"
    local cost_center_name="$2"
    jq -nc --arg name "$cost_center_name" '{name: $name}' |
        gh_post_json "/enterprises/${enterprise}/settings/billing/cost-centers"
}

add_users_to_cost_center() {
    local enterprise="$1"
    local cost_center_id="$2"
    # Expects JSON payload from stdin
    gh_post_json "/enterprises/${enterprise}/settings/billing/cost-centers/${cost_center_id}/resource"
}

remove_users_from_cost_center() {
    local enterprise="$1"
    local cost_center_id="$2"
    # Expects JSON payload from stdin
    gh_delete_json "/enterprises/${enterprise}/settings/billing/cost-centers/${cost_center_id}/resource"
}
