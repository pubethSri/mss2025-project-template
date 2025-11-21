#!/bin/bash

REPO_DIR="/home/opto/mss2025-project-template"
WORK_DIR="/home/opto/mss2025-project-template/115"
GITHUB_USERNAME="PPchayutt"
BRANCH_NAME="opto"

GITHUB_PAT=$(cat $WORK_DIR/.pat)

NOW=$(date "+%d %B %Y - %H:%M:%S")
CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
MEM_USED=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
MEM_TEXT=$(free -h | awk 'NR==2{printf "%s / %s", $3, $2 }')
DISK_USED=$(df -h / | awk '$NF=="/"{print $5}')
DISK_TEXT=$(df -h / | awk '$NF=="/"{printf "%s / %s", $3, $2}')
UPTIME=$(uptime -p | sed 's/up //')
OS_INFO=$(lsb_release -d | cut -f2)
LOAD_AVG=$(cat /proc/loadavg | awk '{print $1}')

TEMPLATE_FILE="$WORK_DIR/115.html"
OUTPUT_FILE="$WORK_DIR/index.html"

sed -e "s|{{USERNAME}}|opto|g" \
    -e "s|{{NOW}}|$NOW|g" \
    -e "s|{{CPU_LOAD}}|$CPU_LOAD|g" \
    -e "s|{{MEM_USED}}|$MEM_USED|g" \
    -e "s|{{MEM_TEXT}}|$MEM_TEXT|g" \
    -e "s|{{DISK_USED}}|$DISK_USED|g" \
    -e "s|{{DISK_TEXT}}|$DISK_TEXT|g" \
    -e "s|{{UPTIME}}|$UPTIME|g" \
    -e "s|{{OS_INFO}}|$OS_INFO|g" \
    -e "s|{{LOAD_AVG}}|$LOAD_AVG|g" \
    $TEMPLATE_FILE > $OUTPUT_FILE

cd "$REPO_DIR" || exit 1

git add .

if ! git diff-index --quiet HEAD; then
    
    git commit -m "Automated commit from cron 115 time:$NOW"
    
    git push "https://${GITHUB_USERNAME}:${GITHUB_PAT}@github.com/Harley2zazaa/mss2025-project-template.git" $BRANCH_NAME

else
    echo "No changes to commit"
fi
