检测IP是否可以解锁Netflix非自制剧。
同类的检测脚本比较复杂，此代码非常简单。

首次安装：

sudo mkdir -p /root/mediaCheck && wget https://github.com/vonaxs/mediaCheck/raw/main/main.sh -O /root/mediaCheck/main.sh && chmod +x /root/mediaCheck/main.sh && /root/mediaCheck/main.sh "install"

每隔1小时检测一次IP是否可以解锁Netflix，如果无法解锁Netflix，则会自动更换IP：

0 * * * * /root/mediaCheck/mediaCheck.sh "check"

每天自动更换IP：

0 0 * * * /root/mediaCheck/mediaCheck.sh "change"

检测IP是否更换，如果IP发生了改变，检测新的IP是否可以解锁媒体

*/5 * * * * /root/mediaCheck/mediaCheck.sh "change"
