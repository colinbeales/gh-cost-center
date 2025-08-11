#!/usr/bin/env bats

# Test JSON utilities

load "test_helper"

setup() {
    source "$BATS_TEST_DIRNAME/../lib/json.sh"
}

@test "collect_usernames handles array format" {
    local json='[{"login": "user1"}, {"login": "user2"}, {"login": "user3"}]'
    
    run bash -c "source '$BATS_TEST_DIRNAME/../lib/json.sh'; echo '$json' | collect_usernames"
    [[ "$status" -eq 0 ]]
    [[ "$output" =~ "user1" ]]
    [[ "$output" =~ "user2" ]]
    [[ "$output" =~ "user3" ]]
}

@test "collect_usernames handles single object format" {
    local json='{"login": "singleuser"}'
    
    run bash -c "source '$BATS_TEST_DIRNAME/../lib/json.sh'; echo '$json' | collect_usernames"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "singleuser" ]]
}

@test "collect_usernames handles username field" {
    local json='[{"username": "user1"}, {"username": "user2"}]'
    
    run bash -c "source '$BATS_TEST_DIRNAME/../lib/json.sh'; echo '$json' | collect_usernames"
    [[ "$status" -eq 0 ]]
    [[ "$output" =~ "user1" ]]
    [[ "$output" =~ "user2" ]]
}

@test "collect_usernames removes duplicates and sorts" {
    local json='[{"login": "zebra"}, {"login": "alpha"}, {"login": "zebra"}]'
    
    run bash -c "source '$BATS_TEST_DIRNAME/../lib/json.sh'; echo '$json' | collect_usernames"
    [[ "$status" -eq 0 ]]
    # Should be sorted and deduplicated
    [[ "$(echo "$output" | head -n1)" == "alpha" ]]
    [[ "$(echo "$output" | tail -n1)" == "zebra" ]]
    [[ "$(echo "$output" | wc -l | tr -d ' ')" == "2" ]]
}

@test "collect_usernames handles empty array" {
    local json='[]'
    
    run bash -c "source '$BATS_TEST_DIRNAME/../lib/json.sh'; echo '$json' | collect_usernames"
    [[ "$status" -eq 0 ]]
    [[ -z "$output" ]]
}

@test "collect_usernames handles malformed JSON gracefully" {
    local json='{"invalid": json}'
    
    run bash -c "source '$BATS_TEST_DIRNAME/../lib/json.sh'; echo '$json' | collect_usernames"
    [[ "$status" -eq 0 ]]
    [[ -z "$output" ]]
}

@test "create_user_payload creates valid JSON" {
    source "$BATS_TEST_DIRNAME/../lib/json.sh"
    run create_user_payload "user1" "user2" "user3"
    [[ "$status" -eq 0 ]]
    
    # Validate it's valid JSON
    run bash -c "echo '$output' | jq -e '.users | length'"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "3" ]]
}

@test "create_user_payload handles empty input" {
    source "$BATS_TEST_DIRNAME/../lib/json.sh"
    run create_user_payload
    [[ "$status" -eq 0 ]]
    [[ "$output" == "{}" ]]
}

@test "json_field_or_empty extracts field safely" {
    local json='{"name": "test", "id": 123}'
    
    run bash -c "source '$BATS_TEST_DIRNAME/../lib/json.sh'; echo '$json' | json_field_or_empty '.name'"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "test" ]]
    
    run bash -c "source '$BATS_TEST_DIRNAME/../lib/json.sh'; echo '$json' | json_field_or_empty '.nonexistent'"
    [[ "$status" -eq 0 ]]
    [[ -z "$output" ]]
}

@test "is_valid_json validates JSON correctly" {
    source "$BATS_TEST_DIRNAME/../lib/json.sh"
    run is_valid_json '{"valid": "json"}'
    [[ "$status" -eq 0 ]]
    
    run is_valid_json '{"invalid": json}'
    [[ "$status" -ne 0 ]]
}
