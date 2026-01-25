#!/bin/sh
# Logging library for WireGuard Mesh Manager

# Log levels
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARN=2
LOG_LEVEL_ERROR=3

# Default settings
: "${LOG_LEVEL:=info}"
: "${LOG_FILE:=/var/log/wg-mesh.log}"
: "${LOG_TO_STDOUT:=true}"

# Convert log level string to number
get_log_level_num() {
    case "$1" in
        debug) echo $LOG_LEVEL_DEBUG ;;
        info)  echo $LOG_LEVEL_INFO ;;
        warn)  echo $LOG_LEVEL_WARN ;;
        error) echo $LOG_LEVEL_ERROR ;;
        *)     echo $LOG_LEVEL_INFO ;;
    esac
}

# Core logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    local level_num
    local current_level_num

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    level_num=$(get_log_level_num "$level")
    current_level_num=$(get_log_level_num "$LOG_LEVEL")

    # Check if we should log this level
    if [ "$level_num" -lt "$current_level_num" ]; then
        return 0
    fi

    local formatted="[$timestamp] [${level}] $message"

    # Log to file if specified
    if [ -n "$LOG_FILE" ] && [ "$LOG_FILE" != "/dev/null" ]; then
        echo "$formatted" >> "$LOG_FILE" 2>/dev/null || true
    fi

    # Log to stdout if enabled
    if [ "$LOG_TO_STDOUT" = "true" ]; then
        case "$level" in
            error) echo "$formatted" >&2 ;;
            warn)  echo "$formatted" >&2 ;;
            *)     echo "$formatted" ;;
        esac
    fi
}

# Convenience functions
log_debug() {
    log_message "debug" "$1"
}

log_info() {
    log_message "info" "$1"
}

log_warn() {
    log_message "warn" "$1"
}

log_error() {
    log_message "error" "$1"
}

# Initialize logging
init_logging() {
    local log_dir
    log_dir=$(dirname "$LOG_FILE")

    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir" 2>/dev/null || true
    fi

    log_debug "Logging initialized: level=$LOG_LEVEL file=$LOG_FILE"
}
