#!/bin/bash

# Get system information
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
MEMORY=$(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2 }')
MEMORY_USED=$(free -h | awk 'NR==2{print $3}')
MEMORY_TOTAL=$(free -h | awk 'NR==2{print $2}')
DISK=$(df -h / | awk 'NR==2{print $5}')
DISK_USED=$(df -h / | awk 'NR==2{print $3}')
DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
UPTIME=$(uptime -p | sed 's/up //')
LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)
HOSTNAME=$(hostname)
PROCESSES=$(ps aux | wc -l)

# Create or update index.html
cat > diddy.html << EOF
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="refresh" content="5">
    <title>System Monitor</title>
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        .header {
            text-align: center;
            color: white;
            margin-bottom: 30px;
        }
        .header h1 {
            margin: 0;
            font-size: 42px;
        }
        .header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        .card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .card h2 {
            margin: 0 0 15px 0;
            font-size: 16px;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .value {
            font-size: 36px;
            font-weight: bold;
            color: #333;
            margin: 10px 0;
        }
        .detail {
            color: #888;
            font-size: 14px;
        }
        .progress-bar {
            width: 100%;
            height: 8px;
            background: #e0e0e0;
            border-radius: 4px;
            margin-top: 15px;
            overflow: hidden;
        }
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            transition: width 0.3s ease;
        }
        .info-card {
            grid-column: 1 / -1;
        }
        .footer {
            text-align: center;
            color: white;
            margin-top: 20px;
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>⚡ System Monitor</h1>
            <p>$HOSTNAME</p>
        </div>
        
        <div class="grid">
            <div class="card">
                <h2>CPU Usage</h2>
                <div class="value">$CPU_USAGE</div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: $CPU_USAGE"></div>
                </div>
            </div>
            
            <div class="card">
                <h2>Memory</h2>
                <div class="value">$MEMORY</div>
                <div class="detail">$MEMORY_USED / $MEMORY_TOTAL</div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: $MEMORY"></div>
                </div>
            </div>
            
            <div class="card">
                <h2>Disk Usage</h2>
                <div class="value">$DISK</div>
                <div class="detail">$DISK_USED / $DISK_TOTAL</div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: $DISK"></div>
                </div>
            </div>
            
            <div class="card">
                <h2>Processes</h2>
                <div class="value">$PROCESSES</div>
                <div class="detail">Running processes</div>
            </div>
            
            <div class="card info-card">
                <h2>System Info</h2>
                <div class="detail" style="font-size: 16px; line-height: 1.8;">
                    <strong>Uptime:</strong> $UPTIME<br>
                    <strong>Load Average:</strong> $LOAD
                </div>
            </div>
        </div>
        
        <div class="footer">
            Last updated: $(date '+%Y-%m-%d %H:%M:%S')
        </div>
    </div>
</body>
</html>
EOF

echo "System monitor updated at $(date '+%H:%M:%S')"
