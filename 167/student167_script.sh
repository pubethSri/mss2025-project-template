#!/bin/bash

cpu_idle=$(top -b -n 2 -d 0.01 | grep 'Cpu(s)' | tail -1 | grep -E -o '[0-9]+\.[0-9]+ id' | grep -E -o '[0-9]+\.[0-9]+')
cpu_usage=$(bc <<< "scale=2; 100-$cpu_idle")

memory=$(free -m | awk 'NR==2{print $2, $3 }')
memory_total=$(echo $memory | awk '{print $1}')
memory_used=$(echo $memory | awk '{print $2}')
memory_usage=$(bc <<< "scale=2; 100 * $memory_used/$memory_total")
memory_total=$(echo "scale=2; $memory_total/1024" | bc | sed 's/^\./0./')
memory_used=$(echo "scale=2; $memory_used/1024" | bc | sed 's/^\./0./')

storage_data=$(df -h | grep '/dev/sda[0-9]' | awk '{print $2, $3}' | grep -o -E '[0-9]+(.[0-9]+)?')
storage_total=$(echo $storage_data | awk '{print $1}')
storage_used=$(echo $storage_data | awk '{print $2}')
storage_usage=$(bc <<< "scale=2; 100 * $storage_used/$storage_total")

last_update=$(date +'%0H:%0M:%0S %0d/%0m/%0Y')

cat << EOF > /home/it67070167/mss2025-project-template/167/167.html
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Monitoring Dashboard</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #0a0e1a;
            color: #e2e8f0;
            padding: 20px;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
        }

        .header {
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h1 {
            font-size: 32px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .server-status {
            display: flex;
            align-items: center;
            gap: 12px;
            background: #1e293b;
            padding: 12px 24px;
            border-radius: 12px;
            border: 1px solid #334155;
        }

        .status-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: #10b981;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        .last-update {
            color: #94a3b8;
            font-size: 14px;
        }

        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 24px;
            margin-bottom: 30px;
        }

        .metric-card {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            padding: 28px;
            border-radius: 16px;
            border: 1px solid #334155;
            position: relative;
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .metric-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
        }

        .metric-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
        }

        .metric-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .metric-title {
            font-size: 16px;
            color: #94a3b8;
            font-weight: 500;
        }

        .metric-value {
            font-size: 48px;
            font-weight: bold;
            margin-bottom: 16px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .progress-bar {
            width: 100%;
            height: 12px;
            background: #0f172a;
            border-radius: 6px;
            overflow: hidden;
            margin-bottom: 12px;
            border: 1px solid #334155;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            border-radius: 6px;
            transition: width 1s ease;
            position: relative;
            overflow: hidden;
        }

        .progress-fill::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            bottom: 0;
            right: 0;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            animation: shimmer 2s infinite;
        }

        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }

        .metric-info {
            display: flex;
            justify-content: space-between;
            color: #94a3b8;
            font-size: 14px;
        }

        .warning {
            border-color: #f59e0b !important;
        }

        .warning .progress-fill {
            background: linear-gradient(90deg, #f59e0b 0%, #ef4444 100%);
        }

        .warning::before {
            background: linear-gradient(90deg, #f59e0b 0%, #ef4444 100%);
        }

        .critical {
            border-color: #ef4444 !important;
        }

        .critical .progress-fill {
            background: linear-gradient(90deg, #ef4444 0%, #dc2626 100%);
        }

        .critical::before {
            background: linear-gradient(90deg, #ef4444 0%, #dc2626 100%);
        }

        .chart-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 24px;
            color: #e2e8f0;
        }

        .server-info {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            padding: 28px;
            border-radius: 16px;
            border: 1px solid #334155;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .info-item {
            padding: 16px;
            background: #0f172a;
            border-radius: 8px;
            border: 1px solid #334155;
        }

        .info-label {
            color: #94a3b8;
            font-size: 14px;
            margin-bottom: 8px;
        }

        .info-value {
            font-size: 18px;
            font-weight: 600;
            color: #e2e8f0;
        }

        @media (max-width: 768px) {
            .metrics-grid {
                grid-template-columns: 1fr;
            }

            .charts-section {
                grid-template-columns: 1fr;
            }

            .header h1 {
                font-size: 24px;
            }

            .metric-value {
                font-size: 36px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>
               Server Status
            </h1>
            <div class="server-status">
                <div class="status-dot"></div>
                <div>
                    <div style="font-weight: 600; font-size: 14px;">Server Online</div>
                    <div class="last-update" id="lastUpdate">Last updated: $last_update</div>
                </div>
            </div>
        </div>

        <div class="metrics-grid">
            <div class="metric-card" id="cpuCard">
                <div class="metric-header">
                    <span class="metric-title">CPU Usage</span>
                    <div class="metric-value" id="cpuValue">$cpu_usage%</div>
                </div>

                <div class="progress-bar">
                    <div class="progress-fill" id="cpuProgress" style="width: $cpu_usage%"></div>
                </div>
            </div>

            <div class="metric-card" id="memoryCard">
                <div class="metric-header">
                    <span class="metric-title">Memory Usage</span>
                <div class="metric-value" id="memoryValue">$memory_usage%</div>
                </div>

                <div class="progress-bar">
                    <div class="progress-fill" id="memoryProgress" style="width: $memory_usage%"></div>
                </div>
                <div class="metric-info">
                    <span id="memoryUsed">$memory_used GB</span>
                    <span id="memoryTotal">/ $memory_total GB</span>
                </div>
            </div>

            <div class="metric-card" id="storageCard">
                <div class="metric-header">
                    <span class="metric-title">Storage Usage</span>
                    <div class="metric-value" id="storageValue">$storage_usage%</div>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" id="storageProgress" style="width: $storage_usage%"></div>
                </div>
                <div class="metric-info">
                    <span id="storageUsed">$storage_used GB</span>
                    <span id="storageTotal">/ $storage_total GB</span>
                </div>
            </div>
        </div>

        <div class="server-info">
            <div class="chart-title">Server Information</div>
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-label">Hostname</div>
		    <div class="info-value">$(hostname)</div>
                </div>
                <div class="info-item">
                    <div class="info-label">IP Address</div>
		    <div class="info-value">$(ip a | grep 'inet\b' | tail -1 | grep -o -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'| head -1)</div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF


# Define your repository path and PAT
 15
 14 REPO_DIR="/home/it67070167/mss2025-project-template/" # e.g., /home/user/my-project
 13 GITHUB_USERNAME="WissanupongChanliem"
 12 GITHUB_PAT=$(cat /home/it67070167/mss2025-project-template/167/.pat) # Ensure this PAT has repo write permissions
 11
 10 # Navigate to the repository directory
  9 cd "$REPO_DIR" || exit 1
  8
  7 # Add all changes to staging
  6 git add .
  5
  4 # Commit changes (only if there are changes)
  3 git diff-index --quiet HEAD || git commit -m "Automated commit from cron 167 time:$last_update"
  2
  1 # Push to GitHub using the PAT for authentication
  0 git push "https://${GITHUB_USERNAME}:${GITHUB_PAT}@github.com/Harley2zazaa/mss2025-project-template.git" Wissanupong
