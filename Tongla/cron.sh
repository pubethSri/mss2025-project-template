#!/bin/bash


cd /home/ubuntu/mss2025-project-template/Tongla
./Tongla.sh
git switch bureerak
git add .
git commit -m "Auto Update $(date '+%Y-%m-%d %H:%M:%S')"
git push origin bureerak
