#!/bin/bash

./diddy_script.sh

# Define your repository path and PAT
REPO_DIR="/home/sarin/mss2025-project-template/"
GITHUB_USERNAME="Sarin-Z"
GITHUB_PAT=$(cat /home/sarin/mss2025-project-template/183/.pat) # Ensure this PAT has repo write permissions
# Navigate to the repository directory
cd "$REPO_DIR" || exit 1

# Add all changes to staging
git add .

# Commit changes (only if there are changes)
git diff-index --quiet HEAD || git commit -m "Automated commit from cron sarin time:$TIME"

# Push to GitHub using the PAT for authentication
git push "https://${GITHUB_USERNAME}:${GITHUB_PAT}@github.com/Harley2zazaa/mss2025-project-template.git" sarin2 
