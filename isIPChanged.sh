#!/bin/bash
set -e

log_file="/root/mediaCheck/change.log"
isIPChanged_file="/root/mediaCheck/isIPChanged.txt"
threshold=100	# 如果行数超过阈值，覆盖文件

# 更换IP
changeIP() {
    sudo sh -c "echo \$(date)：正在更换IP... >> $log_file"
    api=$(cat /root/mediaCheck/api.txt)
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

# 检测IP是否可以解锁媒体
checkIP() {
	sudo sh -c "echo \$(date)：正在检测IP是否可以解锁媒体... >> $log_file"
	# 访问此网址，如果无法观看非自制剧，会返回"Netflix"

	# 执行命令并将输出保存到变量中
	output=$(echo 1 | bash <(curl -L -s check.unlock.media) -M 4)
	echo $output
 
	# 分析输出结果是否包含 "Netflix:				Yes"
	if [[ $output == *"Netflix:				Yes"* ]]; then
		sudo sh -c "echo \$(date)：当前IP可以解锁Netflix，无需更换IP... >> $log_file"
		echo "当前IP可以解锁Netflix，无需更换IP"
		break
	else
		sudo sh -c "echo \$(date)：当前IP无法解锁Netflix，准备更换IP... >> $log_file"
		echo "当前IP无法解锁Netflix，准备更换IP..."
		changeIP
	fi
}

# 检测IP是否更换，如果IP发生了改变，检测新的IP是否可以解锁媒体
isIPChanged() {
    isIPChanged=$(cat $isIPChanged_file)
    if [[ -n $isIPChanged ]]; then
	if [[ $isIPChanged == 1 ]]; then
            sudo sh -c "echo -n > $isIPChanged_file"  # 清空文件
            sudo sh -c "echo \$(date)：IP发生了改变，检测新的IP是否可以解锁媒体... >> $log_file"
            checkIP
	fi
    fi
}

# 主函数
echo "正在检测IP是否发生了改变..."
isIPChanged
