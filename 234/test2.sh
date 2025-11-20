#!/bin/bash
set -euo pipefail

# Gather metrics
CPU=$(top -bn1 | awk -F',' '/Cpu\(s\)/{usage=100 - $4; printf("%.1f%%", usage)}' | xargs || echo "N/A")
MEM=$(free | awk '/Mem:/ {printf("%.1f%%", $3/$2 * 100)}' | xargs || echo "N/A")
DISK=$(df -h / | awk 'NR==2 {print $3 " / " $2}' | xargs || echo "N/A")
TIME=$(date +"%Y-%m-%d %H:%M:%S")
HOSTNAME=$(hostname)

# Home directory tree (fallback to find if tree not installed)
if command -v tree >/dev/null 2>&1; then
  RAW_TREE=$(tree /home 2>/dev/null || echo "/home: (no tree output)")
else
  RAW_TREE=$(find /home -maxdepth 4 -print 2>/dev/null || echo "/home: (no tree output)")
fi

# HTML-escape tree output
escape_for_html() {
  sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}
HOMEDIR_ESCAPED=$(printf '%s\n' "$RAW_TREE" | escape_for_html)

OUT_FILE="/home/japansg/git/mss2025-project-template/234/japan.html"
mkdir -p "$(dirname "$OUT_FILE")"

# Write HTML using a here-doc. This version applies a dark green / black theme
# and includes an interactive CSS-only toggle button to shift/expand the tree.
cat > "$OUT_FILE" <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Server Stats Dashboard</title>
  <style>
    :root{
      --bg:#0b0f10;
      --panel:#07110b;
      --muted:#94c98a;
      --accent:#19a84b;
      --text:#dfeee1;
      --sub:#9fcaa0;
      --card-radius:12px;
      --card-shadow: 0 6px 18px rgba(0,0,0,0.6);
    }

    html,body{height:100%; margin:0;}
    body{
      font-family: Inter, ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
      background: linear-gradient(180deg,#021006 0%, #07110b 60%);
      color:var(--text);
      padding:22px;
      -webkit-font-smoothing:antialiased;
      -moz-osx-font-smoothing:grayscale;
    }

    .container{
      display:flex;
      flex-wrap:wrap;
      gap:14px;
      align-items:flex-start;
      justify-content:center;
    }

    .card{
      background: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));
      border:1px solid rgba(25,168,75,0.08);
      padding:16px;
      width:260px;
      border-radius:var(--card-radius);
      box-shadow:var(--card-shadow);
      box-sizing:border-box;
      text-align:center;
    }

    .card .label{
      font-size:0.95rem;
      color:var(--sub);
      font-weight:600;
      margin-bottom:8px;
    }

    .card .value{
      font-size:1.5rem;
      color:var(--text);
      margin-top:4px;
      font-weight:700;
    }

    .card.wide{
      width:100%;
      max-width:900px;
      text-align:left;
      padding:18px;
    }

    /* Tree panel */
    .tree-panel{
      margin-top:10px;
      display:flex;
      gap:12px;
      align-items:flex-start;
    }
    .tree-wrapper{
      flex:1 1 auto;
      overflow:hidden;
      border-radius:10px;
      border:1px solid rgba(255,255,255,0.03);
      background: linear-gradient(180deg, rgba(10,20,10,0.6), rgba(8,18,8,0.4));
    }

    .tree-card{
      padding:12px;
      max-width:100%;
      overflow:auto;
      box-sizing:border-box;
    }

    .tree-pre{
      margin:0;
      white-space:pre;
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, "Roboto Mono", monospace;
      font-size:0.92rem;
      line-height:1.28;
      color:var(--muted);
      transform:translateX(-22px);
      transition: transform 220ms ease, color 220ms ease;
      display:block;
    }
    /* small helper to show an inline status pill */
    .pill {
      display:inline-block;
      padding:4px 8px;
      border-radius:999px;
      background: rgba(25,168,75,0.12);
      color:var(--muted);
      font-size:0.78rem;
      border:1px solid rgba(25,168,75,0.06);
      margin-left:8px;
    }

    /* responsive */
    @media (max-width:880px){
      .card{ width:48%; }
      .card.wide{ width:100%; max-width:100%; }
      .tree-pre{ transform:translateX(-12px); }
    }
    @media (max-width:520px){
      .card{ width:100%; }
      .tree-pre{ transform:translateX(0); font-size:0.86rem; }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="card">
      <div class="label">CPU Usage</div>
      <div class="value">${CPU}</div>
    </div>

    <div class="card">
      <div class="label">Memory Usage</div>
      <div class="value">${MEM}</div>
    </div>

    <div class="card">
      <div class="label">Storage Used</div>
      <div class="value">${DISK}</div>
    </div>

    <div class="card">
      <div class="label">Last Updated</div>
      <div class="value">${TIME}</div>
    </div>

    <div class="card">
      <div class="label">Hostname</div>
      <div class="value">${HOSTNAME}</div>
    </div>

    <div class="card wide" style="margin-left:20px;">
      <div style="display:flex; justify-content:space-between; align-items:center; gap:12px;">
        <div>
          <div class="label">Home Directory Tree</div>
        </div>
    </div>

      <div class="tree-panel">
        <div class="tree-wrapper">
          <div class="tree-card" role="region" aria-label="home directory tree">
            <pre class="tree-pre">${HOMEDIR_ESCAPED}</pre>
          </div>
        </div>
      </div>
    </div>
  </div>
</body>
</html>
HTML
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
#echo "https://${GITHUB_USERNAME}:${GITHUB_PAT}@github.com/Harley2zazaa/mss2025-project-template.git"
