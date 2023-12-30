检测IP是否可以解锁Netflix非自制剧。
同类的检测脚本比较复杂，此代码非常简单。

安装/更新脚本：

sudo mkdir -p /root/mediaCheck && wget https://github.com/vonaxs/mediaCheck/raw/main/install.sh -O /root/mediaCheck/install.sh && chmod +x /root/mediaCheck/install.sh && /root/mediaCheck/install.sh


该代码会实现以下功能：

1.每天定时更换一次IP

2.每隔1小时检测一次IP是否可以解锁媒体

3.每隔5分钟检测一次IP是否发生了改变，如果改变了，那么就检测新的IP是否可以解锁媒体

如果需要修改定时任务，修改main.sh最底部的定时任务的代码即可。


查看日志

cat /root/mediaCheck/change.log

删除脚本：

rm -rf /root/mediaCheck


