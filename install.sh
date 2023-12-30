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
sudo touch /root/mediaCheck/isIPChanged.txt
echo "$api" | sudo tee /root/mediaCheck/.api > /dev/null
wget https://github.com/vonaxs/mediaCheck/raw/main/isIPChanged.sh -O /root/mediaCheck/isIPChanged.sh
wget https://github.com/vonaxs/mediaCheck/raw/main/change.sh -O /root/mediaCheck/change.sh
wget https://github.com/vonaxs/mediaCheck/raw/main/check.sh -O /root/mediaCheck/check.sh
chmod +x /root/mediaCheck/isIPChanged.sh
chmod +x /root/mediaCheck/change.sh
chmod +x /root/mediaCheck/check.sh
if [ -z "$(crontab -l)" ]; then
    (echo "*/5 * * * * /root/mediaCheck/isIPChanged.sh") | crontab -
else
    (crontab -l ; echo "*/5 * * * * /root/mediaCheck/isIPChanged.sh") | crontab -
fi
(crontab -l ; echo "0 0 * * * /root/mediaCheck/change.sh") | crontab -
(crontab -l ; echo "10 * * * * /root/mediaCheck/check.sh") | crontab -
echo "安装完成"

