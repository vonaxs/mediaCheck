#!/bin/bash
set -e

log_file="/root/mediaCheck/change.log"
threshold=100	# 如果行数超过阈值，覆盖文件
oldIP=$(curl ip.sb)
sudo sh -c "echo \$(date): $oldIP >> $log_file"

# 更换IP
changeIP() {
    api=$(cat /root/mediaCheck/.api)
    for ((i = 0; i < 5; i++)); do
        result=$(curl -s "$api")
        if echo "$result" | grep -q '"ok":true'; then
			echo "更换成功: $result"
		
			# 获取文件行数
			line_count=$(wc -l < "$log_file")
		
			# 如果行数超过阈值，覆盖文件
			if [ "$line_count" -gt "$threshold" ]; then
				echo "行数超过 $threshold，文件将被覆盖。"
				sudo sh -c "echo \$(date): 更换成功 > $log_file"
			else
				sudo sh -c "echo \$(date): 更换成功 >> $log_file"
			fi
			
			#输出当前的IP
			newIP=$(curl ip.sb)
			sudo sh -c "echo \$(date): $newIP >> $log_file"

			if [[ "$oldIP" != "$newIP" ]]; then
				if [[ $(checkIP) == 0 ]]; then
					break  # 更换IP成功
				else
					echo "IP无法解锁，再次尝试更换...: $result"
					sleep 60  # 在重试前等待一段时间
				fi
			fi
        else
            echo "更换失败，等待下次尝试...: $result"
            sudo sh -c "echo \$(date): 更换失败 >> /root/mediaCheck/change.log"
            sleep 60  # 在重试前等待一段时间
        fi
    done
}

# 检测IP是否可以解锁媒体
checkIP() {
    # 访问此网址，如果无法观看非自制剧，会返回"Netflix"
    title=$(curl -s https://www.netflix.com/tw/title/70143836 | grep -oP '<title>\K[^<]*')
    if [[ $title == 'Netflix' ]]; then
        echo "当前IP无法解锁Netflix，准备更换IP..."
        changeIP
        return 0  # 返回成功
    else
        echo "当前IP可以解锁Netflix，无需更换IP..."
        return 1  # 返回失败
    fi
}

if [[ "$1" == "check" ]]; then
    echo "正在检测IP是否可以解锁媒体..."
    checkIP
elif [[ "$1" == "change" ]]; then
    echo "执行更换任务，准备更换IP..."
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
    echo "$api" | sudo tee /root/mediaCheck/.api > /dev/null
	echo "API已经保存，安装完成"
else
    echo "脚本参数不正确，退出脚本。"
fi
