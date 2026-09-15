#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/auth.log"

FAILED_COUNT="$(grep -a -c "Failed password" "$LOG_FILE")"

echo "===== Authentication Log Report ====="
echo
echo "Failed login attempts: $FAILED_COUNT"

echo
echo "Top 5 failed login IP addresses:"

grep -a "Failed password" "$LOG_FILE" \
    | awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -5

echo
echo "Most recent successful login for each user:"

grep -a "Accepted password" "$LOG_FILE" \
    | awk '{user=""; for(i=1;i<=NF;i++) if($i=="for") user=$(i+1); if(user!="") last[user]=$0} END {for(user in last) print last[user]}'


