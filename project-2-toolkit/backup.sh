#!/usr/bin/env bash

set -euo pipefail


if [[ "${1:-}" == "--help" ]]; then
    echo "Usage: backup.sh [SOURCE] [DESTINATION]"
    echo
    echo "Create a compressed backup of SOURCE in DESTINATION."
    echo
    echo "Defaults:"
    echo "  SOURCE       /opt/project_files"
    echo "  DESTINATION  /opt/backups"
    exit 0
fi
SOURCE="${1:-/opt/project_files}"
DESTINATION="${2:-/opt/backups}"

if [[ ! -d "$SOURCE" ]]; then
    echo "ERROR: source directory does not exist: $SOURCE"
    exit 1
fi

LOG_FILE="/var/log/backup.log"

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

# shellcheck disable=SC2317
handle_error() {
    local exit_code=$?
    log "ERROR: backup failed with exit code $exit_code"
    log "RESULT: FAILED"
    exit "$exit_code"
}

trap handle_error ERR


log "START backup"
log "Source: $SOURCE"
log "Destination: $DESTINATION"


LOCK_FILE="/var/run/backup.lock"

exec 200>"$LOCK_FILE"

if ! flock -n 200; then
    log "ERROR: another backup is already running"
    exit 1
fi


MIN_FREE_MB=100

AVAILABLE_MB="$(df -Pm "$DESTINATION" | awk 'NR==2 {print $4}')"

if (( AVAILABLE_MB < MIN_FREE_MB )); then
    log "ERROR: not enough free disk space. Available: ${AVAILABLE_MB}MB, Required: ${MIN_FREE_MB}MB"
    exit 1
fi

log "Free disk space: ${AVAILABLE_MB}MB"


TIMESTAMP="$(date '+%Y-%m-%d-%H%M')"
ARCHIVE="$DESTINATION/project_files-$TIMESTAMP.tar.gz"

log "Creating archive: $ARCHIVE"

tar -czf "$ARCHIVE" \
    -C "$(dirname "$SOURCE")" \
    "$(basename "$SOURCE")"

log "Archive created: $ARCHIVE"


CHECKSUM_FILE="${ARCHIVE}.sha256"

log "Creating checksum: $CHECKSUM_FILE"

sha256sum "$ARCHIVE" > "$CHECKSUM_FILE"

log "Checksum created: $CHECKSUM_FILE"


mapfile -t ARCHIVES < <(find "$DESTINATION" -maxdepth 1 -type f -name 'project_files-*.tar.gz' -printf '%f\n' | sort)

if (( ${#ARCHIVES[@]} > 7 )); then
    DELETE_COUNT=$((${#ARCHIVES[@]} - 7))

    for (( i=0; i<DELETE_COUNT; i++ )); do
        OLD_ARCHIVE="$DESTINATION/${ARCHIVES[$i]}"
        OLD_CHECKSUM="${OLD_ARCHIVE}.sha256"

        log "Deleting old archive: $OLD_ARCHIVE"
        rm -f -- "$OLD_ARCHIVE"

        if [[ -f "$OLD_CHECKSUM" ]]; then
            log "Deleting old checksum: $OLD_CHECKSUM"
            rm -f -- "$OLD_CHECKSUM"
        fi
    done
fi


log "FINISH backup"
log "RESULT: SUCCESS"

exit 0
