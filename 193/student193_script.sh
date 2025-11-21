#!/bin/bash
# ต้องตรวจสอบให้แน่ใจว่าได้ติดตั้ง 'bc' แล้ว (สำหรับคำนวณทศนิยม)

# --- 1. ดึงและคำนวณ CPU Usage ---
cpu_idle=$(top -b -n 2 -d 0.01 | grep "Cpu(s)" | tail -1 | grep -E -o '[0-9]+\.[0-9]+ id' | grep -E -o '[0-9]+\.[0-9]+')
cpu_usage=$(bc <<< "scale=2; 100 - $cpu_idle")

# --- 2. ดึงและคำนวณ Memory Usage ---
mem_stats=$(free -m | awk 'NR==2{print $2, $3}')
total_mem_mb=$(echo $mem_stats | awk '{print $1}')
used_mem_mb=$(echo $mem_stats | awk '{print $2}')
mem_usage=$(echo "scale=2; 100 * $used_mem_mb / $total_mem_mb" | bc)

# แปลงหน่วย MB เป็น G (หาร 1024) และใช้ sed เพื่อบังคับให้มี 0 นำหน้าเสมอ
total_mem_g=$(echo "scale=2; $total_mem_mb / 1024" | bc | sed 's/^\./0./')
used_mem_g=$(echo "scale=2; $used_mem_mb / 1024" | bc | sed 's/^\./0./')

# --- 3. ดึงและคำนวณ Storage Usage (Root Filesystem /) ---
storage_stats_k=$(df -P | grep -E '\/$' | head -1 | awk '{print $2, $3, $5}')
storage_total_k=$(echo $storage_stats_k | awk '{print $1}')
storage_used_k=$(echo $storage_stats_k | awk '{print $2}')
storage_usage=$(echo $storage_stats_k | awk '{print $3}' | tr -d '%')

# แปลงหน่วย 1K-blocks เป็น GigaByte และใช้ sed เพื่อบังคับให้มี 0 นำหน้าเสมอ
storage_total_g=$(echo "scale=2; $storage_total_k / 1024 / 1024" | bc | sed 's/^\./0./')
used_storage_g=$(echo "scale=2; $storage_used_k / 1024 / 1024" | bc | sed 's/^\./0./')

# --- 4. ดึง System Uptime (เวลาเปิดใช้งาน) ---
# ใช้ uptime -p เพื่อให้ได้รูปแบบที่อ่านง่าย เช่น "up 1 day, 5 hours" และลบคำว่า "up " ออกไป
system_uptime=$(uptime -p | sed 's/^up //')

# --- 5. ดึง IP Address ของ Server ---
# ดึง IP Address แรกของ Server (ส่วนใหญ่จะเป็น IP หลัก)
server_ip=$(hostname -I | awk '{print $1}')

# --- 6. เวลาอัปเดตล่าสุด ---
last_update=$(date +'%H:%M:%S %d/%m/%Y')

# --- 7. สร้างไฟล์ index.html (ไม่มีช่องว่างนำหน้าหรือตามหลัง EOF) ---
cat > /home/atikan/mss2025-project-template/student193/index.html << EOF
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #000000;
            color: #e0e0e0;
            min-height: 100vh;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .dashboard {
            max-width: 1200px;
            width: 100%;
        }

        .header {
            text-align: center;
            margin-bottom: 40px;
        }

        .header h1 {
            font-size: 2.5em;
            color: #64ffda;
            margin-bottom: 10px;
            text-shadow: 0 0 20px rgba(100, 255, 218, 0.3);
        }

        .last-updated {
            color: #888;
            font-size: 0.9em;
            margin-top: 10px;
        }

        .metrics-grid {
            /* FIX: กำหนดให้มี 3 คอลัมน์สำหรับ Desktop */
            display: grid;
            grid-template-columns: repeat(3, 1fr); 
            gap: 25px;
            margin-bottom: 30px;
        }

        .metric-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 30px;
            border: 1px solid rgba(100, 255, 218, 0.1);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        
        /* NEW: สำหรับ Server Info Card ที่ต้องการให้กินพื้นที่เต็มแถว */
        .full-width-card {
            grid-column: span 3;
        }

        .metric-card:hover {
            transform: translateY(-5px);
            border-color: rgba(100, 255, 218, 0.3);
            box-shadow: 0 10px 30px rgba(100, 255, 218, 0.2);
        }

        .metric-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, #64ffda, #4db8ff);
        }

        .metric-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .metric-title {
            font-size: 1.5em;
            color: #64ffda;
            font-weight: 600;
        }

        .metric-value {
            font-size: 3em;
            font-weight: bold;
            color: #fff;
            margin-bottom: 5px;
        }

        .metric-detail {
            color: #aaa;
            font-size: 1em;
            margin-bottom: 15px;
        }

        .metric-label {
            color: #888;
            font-size: 0.9em;
        }

        .progress-bar {
            width: 100%;
            height: 8px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            overflow: hidden;
            margin-top: 15px;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #64ffda, #4db8ff);
            border-radius: 10px;
            transition: width 0.5s ease;
        }

        /* --- STYLES FOR COMBINED SERVER INFO CARD --- */
        .server-info-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .server-info-item:last-child {
            border-bottom: none;
        }

        .info-label {
            font-size: 1.2em;
            color: #64ffda;
            font-weight: 500;
            flex-shrink: 0;
            margin-right: 15px;
        }

        .info-value-text {
            background: rgba(100, 255, 218, 0.1); 
            padding: 8px 15px;
            border-radius: 8px;
            font-size: 1.1em; 
            font-weight: 600;
            color: #fff;
            border: 1px solid #64ffda; 
            text-align: right;
            word-break: break-all;
        }
        /* --- END SERVER INFO STYLES --- */


        @media (max-width: 900px) { /* NEW: ปรับ breakpoint ให้กว้างขึ้นเพื่อรองรับ Full Width */
            .metrics-grid {
                /* บนหน้าจอขนาดเล็ก กลับไปใช้ auto-fit เพื่อจัดวางให้เหมาะสม */
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            }
            .full-width-card {
                /* บนหน้าจอขนาดเล็ก ให้ Card กลับไปกินพื้นที่ 1 คอลัมน์ปกติ */
                grid-column: span 1;
            }
            .header h1 {
                font-size: 2em;
            }
            
            .metric-value {
                font-size: 2.5em;
            }
            .info-value-text {
                font-size: 1em; 
            }
        }
    </style>
</head>
<body>
    <div class="dashboard">
        <div class="header">
            <h1>Atikan's Server Resource Usage</h1>
            <div class="last-updated" id="lastUpdated">Last updated: ${last_update}</div>
        </div>

        <div class="metrics-grid">
            <div class="metric-card">
                <div class="metric-header">
                    <div class="metric-title">CPU Usage</div>
                </div>
                <div class="metric-value" id="cpuValue">${cpu_usage}%</div>
                <div class="metric-detail">Processor Load</div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: ${cpu_usage}%"></div>
                </div>
            </div>

            <div class="metric-card">
                <div class="metric-header">
                    <div class="metric-title">Memory Usage</div>
                </div>
                <div class="metric-value" id="memoryValue">${mem_usage}%</div>
                <div class="metric-detail">${used_mem_g} G used / ${total_mem_g} G total</div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: ${mem_usage}%"></div>
                </div>
            </div>

            <div class="metric-card">
                <div class="metric-header">
                    <div class="metric-title">Storage Usage (Root /)</div>
                </div>
                <div class="metric-value" id="storageValue">${storage_usage}%</div>
                <div class="metric-detail">${used_storage_g} G used / ${total_mem_g} G total</div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: ${storage_usage}%"></div>
                </div>
            </div>
            
            <!-- *** NEW SERVER INFO COMBINED CARD - ใช้คลาส full-width-card ให้กินพื้นที่ 3 คอลัมน์ *** -->
            <div class="metric-card full-width-card">
                <div class="metric-header">
                    <div class="metric-title">Server Info</div>
                </div>
                
                <!-- Uptime -->
                <div class="server-info-item">
                    <div class="info-label">System Uptime</div>
                    <div class="info-value-text" id="uptimeValue">${system_uptime}</div>
                </div>

                <!-- Server IP -->
                <div class="server-info-item">
                    <div class="info-label">IP Address</div>
                    <div class="info-value-text" id="serverIpValue">${server_ip}</div>
                </div>

                <div class="metric-detail" style="margin-top: 20px;">Overall status, running time, and primary network address.</div>
            </div>
            <!-- *** END NEW CARD *** -->
            
        </div>
    </div>
</body>
</html>
EOF

# Define your repository path and PAT

REPO_DIR="/home/atikan/mss2025-project-template/student193" # e.g., /home/user/my-project
GITHUB_USERNAME="D37un"
GITHUB_PAT=$(cat /home/atikan/mss2025-project-template/student193/67070193.pat) # Ensure this PAT has repo write permissions
# Navigate to the repository directory
cd "$REPO_DIR" || exit 1
# Add all changes to staging
git add .
# Commit changes (only if there are changes)
git diff-index --quiet HEAD || git commit -m "Automated commit from cron 234 time:$last_update"
# Push to GitHub using the PAT for authentication
git push "https://${GITHUB_USERNAME}:${GITHUB_PAT}@github.com/Harley2zazaa/mss2025-project-template.git" Atikan


