#!/usr/bin/env bash
# JSON parsing utilities

# Safe JSON field extraction
json_field_or_empty() {
    local jq_expression="$1"
    jq -r "$jq_expression // empty" 2>/dev/null || true
}

# Extract JSON to lines safely
json_to_lines() {
    local jq_expression="$1"
    jq -r "$jq_expression // empty" 2>/dev/null || true
}

# Collect usernames from various JSON response formats
collect_usernames() {
    jq -r '
        if type == "array" then
            .[] | (.login // .username // empty)
        else
            .login // .username // empty
        end
    ' 2>/dev/null | grep -v '^$' | sort -u || true
}

# Extract team names and slugs from team list responses
extract_teams() {
    jq -r '.[] | {name, slug} | @json' 2>/dev/null || true
}

# Create JSON payload for user list
create_user_payload() {
    local -a users=("$@")
    if [[ ${#users[@]} -eq 0 ]]; then
        echo '{}'
        return
    fi

    printf '%s\n' "${users[@]}" | jq -R . | jq -s '{users: .}'
}

# Validate JSON response
is_valid_json() {
    local input="$1"
    echo "$input" | jq empty 2>/dev/null
}
