#!/bin/bash
set -e

log_file="/root/mediaCheck/change.log"
ip_file="/root/mediaCheck/ip.txt"
threshold=100	# 如果行数超过阈值，覆盖文件
oldIP=$(curl ip.sb)

# 更换IP
changeIP() {
    sudo sh -c "echo \$(date)：正在更换IP... >> $log_file"
    api=$(cat /root/mediaCheck/.api)
    for ((i = 0; i < 5; i++)); do
        result=$(curl -s "$api")
        if ! echo "$result" | grep -q '"ok":true'; then
            sudo sh -c "echo \$(date): 更换失败，等待 60 秒后重试... \$result" >> $log_file
            sleep 60 
        fi
    done
}

# 检测IP是否可以解锁媒体
checkIP() {
    sudo sh -c "echo \$(date)：正在检测IP是否可以解锁媒体... >> $log_file"
    # 访问此网址，如果无法观看非自制剧，会返回"Netflix"
    title=$(curl -s https://www.netflix.com/tw/title/70143836 | grep -oP '<title>\K[^<]*')
    if [[ $title == 'Netflix' ]]; then
	sudo sh -c "echo \$(date)：当前IP无法解锁Netflix，准备更换IP... >> $log_file"
        echo "当前IP无法解锁Netflix，准备更换IP..."
        changeIP
    else
	sudo sh -c "echo \$(date)：当前IP可以解锁Netflix，无需更换IP... >> $log_file"
        echo "当前IP可以解锁Netflix，无需更换IP..."
    fi
}

# 检测IP是否更换，如果IP发生了改变，检测新的IP是否可以解锁媒体
isIPChanged() {
    oidIP=$(cat /root/mediaCheck/ip.txt)
    newIP=$(curl ip.sb)
    if [[ -n $oidIP ]]; then
	if [[ $oidIP != $newIP ]]; then
            sudo sh -c "echo $newIP > $ip_file"
            sudo sh -c "echo \$(date)：IP发生了改变，检测新的IP是否可以解锁媒体... >> $log_file"
            checkIP
	fi
    else
	sudo sh -c "echo $newIP > $ip_file"
    fi
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

if [[ "$1" == "isIPChanged" ]]; then
    echo "正在检测IP是否发生了改变..."
    isIPChanged
elif [[ "$1" == "check" ]]; then
    echo "正在检测IP是否可以解锁媒体..."
    checkIP
elif [[ "$1" == "change" ]]; then
    echo "执行更换任务，准备更换IP..."
	clearLog
    changeIP
elif [[ "$1" == "install" ]]; then
    # 检查是否已经安装了curl
    if ! command -v curl &> /dev/null; then
        echo "curl 未安装，正在安装..."
        # 安装sudo
        apt-get update
        apt-get install -y curl
    else
        echo "curl 已经安装。"
    fi

    while true; do
        read -p "请输入更换IP的API：" api

        if [[ $api =~ ^http ]]; then
            break  # 输入有效，跳出循环
        elif [[ -z $api ]]; then
            exit 1 # 退出脚本，返回非零状态码
        else
            echo "输入无效，请重新输入。"
        fi
    done
    sudo touch /root/mediaCheck/change.log
    sudo touch /root/mediaCheck/.api
    sudo touch /root/mediaCheck/ip.txt
    echo "$api" | sudo tee /root/mediaCheck/.api > /dev/null
    if [ -z "$(crontab -l)" ]; then
        (echo "*/5 * * * * /root/mediaCheck/main.sh 'isIPChanged'") | crontab -
    else
        (crontab -l ; echo "*/5 * * * * /root/mediaCheck/main.sh 'isIPChanged'") | crontab -
    fi
	(crontab -l ; echo "0 0 * * * /root/mediaCheck/main.sh 'change'") | crontab -
	(crontab -l ; echo "0 * * * * /root/mediaCheck/main.sh 'check'") | crontab -
    echo "安装完成"
else
    echo "脚本参数不正确，退出脚本。"
fi
