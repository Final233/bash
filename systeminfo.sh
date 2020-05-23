#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-05-16
#FileName：             systeminfo.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************
#查看系统信息
#$HOSTNAME || hostname
IPV4=$(ifconfig |sed -rn '/broadcast/s/(.*inet )(.*)netmask(.*)/\2/p')
OSVER=$(cat /etc/redhat-release)
KERNELVER=$(uname -r)
#CPU=$(grep 'model name'  /proc/cpuinfo |uniq|awk -F: '{print $2}'|sed 's/^ //')
CPU=$(sed -rn '/model name/s/(.*: )(,*)/\2/p ' /proc/cpuinfo |uniq)
MEM=$(free -h| awk '/Mem/{print $2}')
DISK=$(lsblk |awk '/^.d./{print $4}')

echo -e "主机名: \t$HOSTNAME"
echo -e "IP地址: \t$IPV4"
echo -e "系统版本: \t$OSVER"
echo -e "内核版本: \t$KERNELVER"
echo -e "CPU型号: \t$CPU"
echo -e "内存大小: \t$MEM"
echo -e "硬盘容量: \t$DISK"
