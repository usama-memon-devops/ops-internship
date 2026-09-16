#!/bin/bash

LOG="/var/log/nginx/access.log"

echo "=== Nginx Log Report ==="

echo

echo "Top 10 Requested Paths:"

awk '{print $7}' "$LOG" | sort | uniq -c | sort -nr | head -n 10

echo

echo "HTTP Status Code Counts:"

awk '{print $9}' "$LOG" | sort | uniq -c | sort -nr

echo

echo "Busiest Client IP:"

awk '{print $1}' "$LOG" | sort | uniq -c | sort -nr | head -n 1

echo

echo "Report generated on: $(date)"


