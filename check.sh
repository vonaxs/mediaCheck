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
    # 初始化计数器
    netflix_count=0

    # 循环检测3次
    for ((i = 0; i < 3; i++)); do
	    sudo sh -c "echo \$(date)：正在检测IP是否可以解锁媒体... >> $log_file"
	    # 访问此网址，如果无法观看非自制剧，会返回"Netflix"
	    title=$(curl -s https://www.netflix.com/tw/title/70143836 | grep -oP '<title>\K[^<]*')
	    if [[ $title == 'Netflix' ]]; then
	        sudo sh -c "echo \$(date)：当前IP无法解锁Netflix >> $log_file"
	        echo "当前IP无法解锁Netflix"
	        netflix_count=$((netflix_count + 1))         # 如果Netflix出现，增加计数器
	 	echo "$netflix_count"
	    else
	        sudo sh -c "echo \$(date)：当前IP可以解锁Netflix，无需更换IP... >> $log_file"
	        echo "当前IP可以解锁Netflix，无需更换IP..."
	 	break
	    fi
	    sleep 30
    done
	
    # 检查计数器是否达到3次
    if [ $netflix_count -eq 3 ]; then
        sudo sh -c "echo \$(date)：当前IP无法解锁Netflix，连续出现3次，准备更换IP... >> $log_file"
        echo "当前IP无法解锁Netflix，连续出现3次，准备更换IP..."
        changeIP
    fi
}

# 主函数
random_number=$((RANDOM % 20))
# 随机检测，避免Netflix识别在定时检测
if [ "$random_number" -eq 0 ]; then
    echo "正在检测IP是否可以解锁媒体..."
    sleep $((10 * random_number))
    checkIP
fi

