#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-10-15
#FileName：             systeminfo.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************

clear
echo -e "-------------------------------System Information----------------------------"
echo -e "Hostname:\t\t"`hostname`
echo -e "uptime:\t\t\t"`uptime |sed 's/^ //'`
#echo -e "uptime:\t\t\t"`uptime | awk '{print $3,$4}' | sed 's/,//'`
echo -e "Manufacturer:\t\t"`cat /sys/class/dmi/id/chassis_vendor`
echo -e "Product Name:\t\t"`cat /sys/class/dmi/id/product_name`
echo -e "Version:\t\t"`cat /sys/class/dmi/id/product_version`
echo -e "Serial Number:\t\t"`cat /sys/class/dmi/id/product_serial`
echo -e "Machine Type:\t\t"`vserver=$(lscpu | grep Hypervisor | wc -l); if [ $vserver -gt 0 ]; then echo "VM"; else echo "Physical"; fi`
echo -e "Operating System:\t"`cat /etc/redhat-release`
#echo -e "Operating System:\t"`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
echo -e "Kernel:\t\t\t"`uname -r`
echo -e "Architecture:\t\t"`arch`
echo -e "Processor Name:\t\t"`sed -rn '/model name/s/(.*: )(,*)/\2/p ' /proc/cpuinfo |uniq`
echo -e "（物理CPU个数）physical id is :\t\t"`grep "physical id" /proc/cpuinfo |sort -u |wc -l`
echo -e "（逻辑CPU个数）processor is :\t\t"`grep "processor" /proc/cpuinfo |wc -l`
echo -e "（CPU内核数）cpu cores is :\t\t"`grep "cpu cores" /proc/cpuinfo |uniq |awk '{print $NF}'`
echo -e "（单个物理CPU的逻辑CPU数）siblings is :\t\t"`grep "sibings" /proc/cpuinfo |uniq`
#逻辑 CPU > 物理 CPU x CPU 核数 #开启超线程
#逻辑 CPU = 物理 CPU x CPU 核数 #没有开启超线程或不支持超线程


echo -e "Active User:\t\t"`w | cut -d ' ' -f1 | grep -v USER | xargs -n1`
echo -e "System Main IP:\t\t"`hostname -I`
ping -c 2 g.cn &>/dev/null && echo -e "Internet:\t\tConnected" || echo -e "Internet:\t\tDisconnected"
echo -e "Check External IP:\t\t"`curl -s http://ipecho.net/plain`
echo -e "Check DNS:\t\t"`grep -E "\<nameserver[ ]+" /etc/resolv.conf | awk '{print $NF}'`

awk -F. '{run_days=$1 / 86400;run_hour=($1 % 86400)/3600;run_minute=($1 % 3600)/60;run_second=$1 % 60;printf("系统已运行：%d天%d时%d分%d秒",run_days,run_hour,run_minute,run_second)}' /proc/uptime
echo ""

echo -e "-------------------------------CPU/Memory Usage------------------------------"
echo -e "Memory Usage:\t"`free | awk '/Mem/{printf("%.2f%"), $3/$2*100}'`
echo -e "Swap Usage:\t"`free | awk '/Swap/{printf("%.2f%"), $3/$2*100}'`
echo -e "CPU Usage:\t"`cat /proc/stat | awk '/cpu/{printf("%.2f%\n"), ($2+$4)*100/($2+$4+$5)}' | awk '{print $0}' | head -1`

echo -e "磁盘IO"`iostat -dxk`
echo -e "网络IO"`sar -n DEV 1 1`

echo ""
echo -e "\033[32m占用 CPU 资源最多的前 10 个进程\033[0m"
ps -auxf | sort -nr -k 3 | head -10
echo -e "\033[32m占用内存资源最多的前 10 个进程\033[0m"
ps -auxf | sort -nr -k 4 | head -10
echo -e "-------------------------------Disk Usage >80%-------------------------------"
df -Ph | sed s/%//g | awk '{ if($5 > 80) print $0;}'
echo ""

echo -e "-------------------------------For WWN Details-------------------------------"
vserver=$(lscpu | grep Hypervisor | wc -l)
if [ $vserver -gt 0 ];then
    echo "$(hostname)"
else
    cat /sys/class/fc_host/host?/port_name
fi
echo ""

echo -e "---------------------------Network Interface Status--------------------------"
for i in $(ls /sys/class/net/);do
    STATUS=$(cat /sys/class/net/"$i"/operstate)
    echo "$i" "$STATUS"
done
echo ""
