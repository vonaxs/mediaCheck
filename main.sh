#!/bin/bash
set -e

# 更换IP
changeIP() {
    api=$(cat /root/changeIP/.api)
    for ((i = 0; i < 5; i++)); do
        result=$(curl -s "$api")
        if echo "$result" | grep -q '"ok":true'; then  # 修正这行，正确使用grep
            echo "更换成功: $result"
            sudo sh -c "echo \$(date): 更换成功 >> /root/changeIP/change.log"
            break  # 更换IP成功
        else
            echo "更换失败，等待10S进行下次尝试...: $result"
            sudo sh -c "echo \$(date): 更换失败 >> /root/changeIP/change.log"
            sleep 10  # 在重试前等待一段时间
        fi
    done
}

if [[ "$1" == "check" ]]; then
    # 访问此网址，如果无法观看非自制剧，会返回"Netflix"
    title=$(curl -s https://www.netflix.com/tw/title/70143836 | grep -oP '<title>\K[^<]*')
    if [[ $title == 'Netflix' ]]; then
        echo "当前IP无法解锁Netflix，准备更换IP..."
        changeIP
    fi
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
    sudo mkdir -p /root/changeIP
    sudo touch /root/changeIP/change.log
    sudo touch /root/changeIP/.api
    echo "$api" | sudo tee /root/changeIP/.api > /dev/null
	echo "API已经保存，安装完成"
else
    echo "脚本参数不正确，退出脚本。"
fi
