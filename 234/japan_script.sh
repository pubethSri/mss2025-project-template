#!/bin/bash

# Get CPU usage (average over 1 second)
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}'| xargs)

# Get memory usage
MEM=$(free | awk '/Mem:/ {printf("%.1f%%", $3/$2 * 100)}'| xargs)

# Get disk usage (root partition)
DISK=$(df -h / | awk 'NR==2 {print $3 " / " $2}' | xargs)

# Get current time
TIME=$(date +"%Y-%m-%d %H:%M:%S" | xargs)

# Firewall rules (try ufw first, fallback to iptables)
if command -v ufw &> /dev/null; then
  FIREWALL=$(ufw status | sed 's/$/<br>/')
elif command -v iptables &> /dev/null; then
  FIREWALL=$(iptables -L | head -n 10 | sed 's/$/<br>/')
else
  FIREWALL="Firewall tool not found<br>"
fi

# Open ports (using ss)
PORTS=$(ss -tuln | awk 'NR>1 {print $1, $5}' | sed 's/$/<br>')

echo "
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Server Stats Dashboard</title>
  <style>
    body {
      font-family: sans-serif;
      background: #f0f0f0;
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      padding: 20px;
    }
    .card {
      background: white;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
      margin: 10px;
      padding: 20px;
      width: 250px;
      text-align: center;
    }
    .label {
      font-size: 1.2em;
      color: #555;
    }
    .value {
      font-size: 2em;
      color: #222;
      margin-top: 10px;
    }
  </style>
</head>
<body>

  <div class="card">
    <div class="label">CPU Usage</div>
    <div class="value">$CPU</div>
  </div>

  <div class="card">
    <div class="label">Memory Usage</div>
    <div class="value">$MEM</div>
  </div>

  <div class="card">
    <div class="label">Storage Used</div>
    <div class="value">$DISK</div>
  </div>

  <div class="card">
    <div class="label">Last Updated</div>
    <div class="value">$TIME</div>
  </div>
  <div class="card">
    <div class="label">Firewall Rules</div>
    <div class="value" style="font-size: 0.9em; white-space: pre-wrap;">{{FIREWALL}}</div>
  </div>

  <div class="card">
    <div class="label">Open Ports</div>
    <div class="value" style="font-size: 0.9em; white-space: pre-wrap;">{{PORTS}}</div>
  </div>

</body>
</html>
" > japan.html
# Define your repository path and PAT

REPO_DIR="/home/japansg/git/mss2025-project-template/" # e.g., /home/user/my-project
GITHUB_USERNAME="japanSG"
GITHUB_PAT=$(cat /home/japansg/git/mss2025-project-template/234/.pat) # Ensure this PAT has repo write permissions

# Navigate to the repository directory
cd "$REPO_DIR" || exit 1

# Add all changes to staging
git add .

# Commit changes (only if there are changes)
git diff-index --quiet HEAD || git commit -m "Automated commit from cron 234 time:$TIME"

# Push to GitHub using the PAT for authentication
git push "https://${GITHUB_USERNAME}:${GITHUB_PAT}@github.com/Harley2zazaa/mss2025-project-template.git" JapanSG
echo "https://${GITHUB_USERNAME}:${GITHUB_PAT}@github.com/Harley2zazaa/mss2025-project-template.git"
