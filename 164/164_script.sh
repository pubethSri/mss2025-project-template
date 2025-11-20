#!/bin/bash

while true; 
do
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8 "%"}')
    MEMORY_USED=$(free -m | awk '/Mem/ {print $3}')
    MEMORY_TOTAL=$(free -m | awk '/Mem/ {print $2}')
    STORAGE_USED=$(df -h / | awk 'NR==2 {print $3}')
    STORAGE_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
    OS=$(lsb_release -d | awk -F"\t" '{print $2}')
    LAST_UPDATED=$(date '+%Y-%m-%d %H:%M:%S')
    echo
    "{
        \"cpu_usage\": \"$CPU_USAGE\",
        \"memory_usage\": \"$MEMORY_USED MB / $MEMORY_TOTAL MB\",
        \"storage_usage\": \"$STORAGE_USED / $STORAGE_TOTAL\",
        \"os\": \"$OS\",
        \"last_updated\": \"$LAST_UPDATED\"
    }" > system_status.json
    sleep 1
done
