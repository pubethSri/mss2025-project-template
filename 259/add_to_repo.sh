#!/bin/bash

REPO_DIR="/home/harley2zaza/mss2025-project-template/259"
GITHUB_USERNAME="Harley2zazaa"
GITHUB_PAT=$(cat /home/harley2zaza/mss2025-project-template/259/.pat)

cd "$REPO_DIR" || exit 1

git add .

git diff-index --quiet HEAD || git commit -m "Automated commit from cron 234 time:$TIME"

git push "https://${GITHUB_USERNAME}:${GITHUB_PAT}@github.com/Harley2zazaa/mss2025-project-template.git" new_harley


