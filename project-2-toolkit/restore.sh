#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/backup.log"
STAGING_DIR="/tmp/restore-staging"
TARGET_DIR="/opt/project_files"

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

CONFIRM=false

if [[ "${1:-}" == "--confirm" ]]; then
    CONFIRM=true
    shift
fi

ARCHIVE="${1:-}"

log "START restore"
log "Archive: $ARCHIVE"

if [[ -z "$ARCHIVE" ]]; then
    echo "Usage: restore.sh [--confirm] ARCHIVE"
    exit 1
fi

if [[ ! -f "$ARCHIVE" ]]; then
    echo "ERROR: archive not found: $ARCHIVE"
    log "ERROR: archive not found: $ARCHIVE"
    exit 1
fi

CHECKSUM_FILE="${ARCHIVE}.sha256"

if [[ ! -f "$CHECKSUM_FILE" ]]; then
    echo "ERROR: checksum file not found: $CHECKSUM_FILE"
    log "ERROR: checksum file not found: $CHECKSUM_FILE"
    exit 1
fi

echo "Verifying checksum..."

if ! sha256sum -c "$CHECKSUM_FILE"; then
    echo "ERROR: checksum verification failed."
    log "ERROR: checksum verification failed"
    exit 1
fi

echo "Checksum verified successfully."
log "Checksum verified successfully"

rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

echo "Extracting archive to staging directory..."

tar -xzf "$ARCHIVE" -C "$STAGING_DIR"

echo "Staging extraction complete."
echo "Files that would be restored:"

find "$STAGING_DIR" -type f -print

log "Archive extracted to staging: $STAGING_DIR"

if [[ "$CONFIRM" != true ]]; then
    echo
    echo "Preview only. Nothing was changed."
    echo "Run with --confirm to perform the restore."
    log "RESULT: PREVIEW ONLY"
    exit 0
fi

echo
echo "Starting restore..."

rm -rf "${TARGET_DIR:?}"/*
cp -a "$STAGING_DIR/project_files/." "$TARGET_DIR/"

echo "Restore completed successfully."

log "Restored files to: $TARGET_DIR"
log "RESULT: SUCCESS"

exit 0
