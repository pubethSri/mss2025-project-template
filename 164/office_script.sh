#!/bin/bash

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
MEMORY_USED=$(free -m | awk '/^Mem:/ {print $3}')
MEMORY_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
STORAGE_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
OS=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
SYSTEM_UPTIME=$(uptime -p)
LAST_UPDATED=$(uptime -s)
cat << EOF > /home/office/mss2025-project-template/164/system_status.json
{
    "cpu_usage": "$CPU_USAGE",
    "memory_used": "$MEMORY_USED",
    "memory_total": "$MEMORY_TOTAL",
    "storage_usage": "$STORAGE_USAGE",
    "os": "$OS",
    "system_uptime": "$SYSTEM_UPTIME",
    "last_updated": "$LAST_UPDATED"
}
EOF

REPO_DIR="/home/office/mss2025-project-template/"
GITHUB_USERNAME="GEOFFCHARGE"
GITHUB_PAT=$(cat /home/office/token)
cd "$REPO_DIR" || exit 1
git add .
git diff-index --quiet HEAD || git commit -m "Automated commit from cron 164 time:$LAST_UPDATED"
git push "https://${GITHUB_USERNAME}:${GITHUB_PAT}@github.com/Harley2zazaa/mss2025-project-template.git" office
