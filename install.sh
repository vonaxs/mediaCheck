#!/bin/bash
set -e

# 主函数
# 检查是否已经安装了curl
if ! command -v curl &> /dev/null; then
    echo "curl 未安装，正在安装..."
    # 安装sudo
    apt-get update
    apt-get install -y curl
else
    echo "curl 已经安装。"
fi

# 创建储存日志，API等数据的文件
sudo touch /root/mediaCheck/change.log
sudo touch /root/mediaCheck/api.txt
sudo touch /root/mediaCheck/isIPChanged.txt
sudo touch /root/mediaCheck/checkTime.txt

# 输入API
api=$(cat /root/mediaCheck/api.txt)
if [ -z "$api" ]; then
    # 输入API
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
fi

# 储存API
echo "$api" | sudo tee /root/mediaCheck/api.txt > /dev/null

# 下载检测IP是否改变的脚本
wget https://github.com/vonaxs/mediaCheck/raw/main/isIPChanged.sh -O /root/mediaCheck/isIPChanged.sh
chmod +x /root/mediaCheck/isIPChanged.sh

# 下载定时更换IP的脚本
wget https://github.com/vonaxs/mediaCheck/raw/main/change.sh -O /root/mediaCheck/change.sh
chmod +x /root/mediaCheck/change.sh

# 下载定时检测IP的脚本
wget https://github.com/vonaxs/mediaCheck/raw/main/check.sh -O /root/mediaCheck/check.sh
chmod +x /root/mediaCheck/check.sh

# 创建定时任务
# 如果定时任务为空，直接创建，否则追加
# 如果任务不存在，则创建
random_number=$((RANDOM % 60))
if [ -z "$(crontab -l)" ]; then
    (echo "$random_number */6 * * * /root/mediaCheck/change.sh") | crontab -
else
    if ! crontab -l | grep -q "/root/mediaCheck/change.sh"; then
        (crontab -l ; echo "$random_number */6 * * * /root/mediaCheck/change.sh") | crontab -
    fi
fi
# if ! crontab -l | grep -q "/root/mediaCheck/isIPChanged.sh"; then
#     (crontab -l ; echo "*/5 * * * * /root/mediaCheck/isIPChanged.sh") | crontab -
# fi
# 每5分钟检测一次，但不是真的5分钟检测一次，只是可能检测一次，避免Netflix识别在定时检测
# if ! crontab -l | grep -q "/root/mediaCheck/check.sh"; then
#    (crontab -l ; echo "*/5 * * * * /root/mediaCheck/check.sh") | crontab -
# fi

echo "安装完成"





