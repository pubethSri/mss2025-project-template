#!/bin/bash

# Get CPU usage (average over 1 second)
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}'| xargs)

# Get memory usage
MEM=$(free | awk '/Mem:/ {printf("%.1f%%", $3/$2 * 100)}'| xargs)

# Get disk usage (root partition)
DISK=$(df -h / | awk 'NR==2 {print $3 " / " $2}' | xargs)

# Get current time
TIME=$(date +"%Y-%m-%d %H:%M:%S" | xargs)

# Hostname
HOSTNAME=$(hostname)

# Home directory tree (first 2 levels)
HOMEDIR=$(tree /home)


echo "
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Server Stats Dashboard</title>
  <style>
    body .container{
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
    .tree {
      background: white;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
      margin: 10px;
      padding: 20px;
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
  <div class="container">
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
    <div class="label">Hostname</div>
    <div class="value">$HOSTNAME</div>
  </div>
</div>
<div class="container">
  <div class="tree" style="width: auto\; max-width: 90vw\; overflow-x: auto\; padding: 10px\;">
    <div class="label">Home Directory Tree</div>
    <div class="value" style="font-size: 0.75em\; text-align: left\; white-space: pre\;">
      $HOMEDIR
    </div>
  </div>
</div>
</body>
</html>
" > /home/japansg/git/mss2025-project-template/234/japan.html
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
