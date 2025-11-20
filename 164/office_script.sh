#!/bin/bash

while true; 
do
    CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | tr -d ,) # Use tr -d , to handle locales with commas
    CPU_USAGE=$(echo "100 - $CPU_IDLE" | bc)
    MEMORY_USED=$(free -m | awk 'NR==2{print $3}')
    MEMORY_TOTAL=$(free -m | awk 'NR==2{print $2}')
    STORAGE_USED_PERCENT=$(df -h / | awk 'NR==2{print $5}')
    STORAGE_TOTAL=$(df -h / | awk 'NR==2{print $2}')
    OS_NAME="$(uname -o)"
    OS_VERSION="$(uname -r)"
    LAST_UPDATED=$(uptime -s)
    cat << EOF > system_status.json
{
    "timestamp": "$(date +%Y-%m-%dT%H:%M:%S%z)",
    "cpu_usage": "$CPU_USAGE%",
    "memory_usage": "$MEMORY_USED MB",
    "memory_total": "$MEMORY_TOTAL MB",
    "storage_used": "$STORAGE_USED_PERCENT",
    "storage_total": "$STORAGE_TOTAL",
    "os_name": "$OS_NAME",
    "os_version": "$OS_VERSION",
    "system_boot_time": "$LAST_UPDATED"
}
EOF
    sleep 1
done
