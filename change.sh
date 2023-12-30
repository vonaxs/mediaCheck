#!/bin/bash
set -e

log_file="/root/mediaCheck/change.log"
isIPChanged_file="/root/mediaCheck/isIPChanged.txt"
threshold=100	# 如果行数超过阈值，覆盖文件

# 更换IP
changeIP() {
    sudo sh -c "echo \$(date)：正在更换IP... >> $log_file"
    api=$(cat /root/mediaCheck/.api)
    for ((i = 0; i < 5; i++)); do
        sudo sh -c "echo 1" > $isIPChanged_file
        result=$(curl -s "$api")
        if ! echo "$result" | grep -q '"ok":true'; then
            sudo sh -c "echo -n > $isIPChanged_file"  # 清空文件
            sudo sh -c "echo \$(date): 更换失败，等待 120 秒后重试... $result" >> $log_file
            sleep 120
        fi
    done
}

# 检测日志是否太大，如果太大，则清空
clearLog() {
    if [ -e "$log_file" ]; then
        line_count=$(wc -l < "$log_file")		# 获取文件行数
        if [ "$line_count" -gt "$threshold" ]; then
            sudo sh -c "echo -n > $log_file"  # 清空文件
        fi
    else
        sudo touch "$log_file"
    fi
}

# 主函数
echo "执行更换任务，准备更换IP..."
clearLog
changeIP
