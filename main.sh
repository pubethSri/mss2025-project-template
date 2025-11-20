echo "push status start ..."

CPU_ALL=$(df -h / | tail -n 1 | awk '{print $2}')
CPU_USAGE=$(df -h / | tail -n 1 | awk '{print $3}')
echo $CPU_ALL
echo $CPU_USAGE
