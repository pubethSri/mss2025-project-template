#!/bin/bash

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
MEMORY_USED=$(free -h | awk '/^Mem:/ {print $3}' | sed 's/[A-Za-z]//g') 
MEMORY_TOTAL=$(free -h | awk '/^Mem:/ {print $2}' | sed 's/[A-Za-z]//g') 
MEMORY_PERCENT=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2 * 100}')
STORAGE_USED=$(df -h / | awk 'NR==2 {print $3}')
STORAGE_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
STORAGE_PERCENT=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
TIMESTAMP=$(date +"%H:%M:%S")
UPTIME=$(uptime -p | sed 's/up //')
SYSTEM_STATUS="Very Good"

# ดึงรายการโปรเซสที่กำลังทำงาน (PID และชื่อโปรเซส)
PROCESS_LIST=$(ps -eo pid,comm --sort=pid | grep -v "PID" | head -n 10 | awk '{print "<li class=\"process-item\">" $1 " - " $2 "</li>"}')

# สร้างไฟล์ HTML
cat > index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>System Status Dashboard</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
body { background-color: #0d1117; color: #c9d1d9; font-family: 'Segoe UI', sans-serif; padding: 20px; }
.dashboard-card { background-color: #161b22; border: 1px solid #30363d; border-radius: 8px; padding: 20px; margin-bottom: 20px; }
.card-header { color: #58a6ff; font-size: 1.1rem; font-weight: 600; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px solid #30363d; }
.metric-value { font-size: 2rem; font-weight: 700; color: #58a6ff; }
.metric-label { color: #8b949e; font-size: 0.9rem; margin-top: 5px; }
.progress { height: 8px; border-radius: 4px; margin-top: 10px; background-color: #21262d; }
.progress-bar { background-color: #58a6ff; }
h1 { color: #58a6ff; text-align: center; margin-bottom: 30px; }
.process-list { list-style: none; padding: 0; margin: 0; }
.process-item { padding: 8px 0; border-bottom: 1px solid #30363d; color: #c9d1d9; }
.process-item:last-child { border-bottom: none; }
</style>
</head>
<body>
<div class="container-fluid">
  <h1>System Status Dashboard</h1>
  <div class="row">
    <div class="col-md-6">
      <div class="dashboard-card">
        <div class="card-header">💻 CPU Usage</div>
        <div class="metric-value">${CPU_USAGE}%</div>
        <div class="progress">
          <div class="progress-bar" style="width: ${CPU_USAGE}%"></div>
        </div>
      </div>
    </div>
    <div class="col-md-6">
      <div class="dashboard-card">
        <div class="card-header">🧠 Memory Usage</div>
        <div class="metric-value">${MEMORY_USED}Mb</div>
        <div class="metric-label">of ${MEMORY_TOTAL}Gb Used</div>
        <div class="progress">
          <div class="progress-bar" style="width: ${MEMORY_PERCENT}%"></div>
        </div>
      </div>
    </div>
    <div class="col-md-6">
      <div class="dashboard-card">
        <div class="card-header">💾 Storage Usage</div>
        <div class="metric-value">${STORAGE_USED}</div>
        <div class="metric-label">of ${STORAGE_TOTAL} Used</div>
        <div class="progress">
          <div class="progress-bar" style="width: ${STORAGE_PERCENT}%"></div>
        </div>
      </div>
    </div>
    <div class="col-md-6">
      <div class="dashboard-card">
        <div class="card-header">🕐 Last Update</div>
        <div class="metric-value">${TIMESTAMP}</div>
        <div class="metric-label">System Time</div>
      </div>
    </div>
    <div class="col-md-6">
      <div class="dashboard-card">
        <div class="card-header">📋 Current Processes</div>
        <ul class="process-list">
          ${PROCESS_LIST}
        </ul>
      </div>
    </div>
    <div class="col-md-6">
      <div class="dashboard-card">
        <div class="card-header">✅ System Status</div>
        <div class="metric-value" style="font-size: 1.2rem;">${SYSTEM_STATUS}</div>
        <div class="metric-label">Uptime: ${UPTIME}</div>
      </div>
    </div>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
EOF

