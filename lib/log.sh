#!/usr/bin/env bash
# Logging and user interaction utilities

# Global variables for logging behavior
VERBOSE=${VERBOSE:-}
YES=${YES:-}
DRY_RUN=${DRY_RUN:-}

# Standard logging functions
log() {
    printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >&2
}

vlog() {
    [[ -n "${VERBOSE:-}" ]] && log "VERBOSE: $*"
}

warn() {
    printf '[%s] WARN: %s\n' "$(date +%H:%M:%S)" "$*" >&2
}

error() {
    printf '[%s] ERROR: %s\n' "$(date +%H:%M:%S)" "$*" >&2
}

die() {
    error "$*"
    exit 1
}

# User confirmation with force mode support
confirm() {
    local prompt="$1"
    [[ -n "${YES:-}" ]] && return 0
    [[ -n "${FORCE:-}" ]] && return 0

    local response
    read -r -p "$prompt [y/N]: " response
    case "$response" in
    [Yy] | [Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
    esac
}

# Dry run logging
dry_run_log() {
    [[ -n "${DRY_RUN:-}" ]] && log "[DRY-RUN] $*"
}
