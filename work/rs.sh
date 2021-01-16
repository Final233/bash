#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2021-01-16
#FileName：             rs.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2021 All rights reserved
#********************************************************************
. /etc/rc.d/init.d/functions

LVS_VIP="192.168.10.200"
DEV="lo:0"
MASK="255.255.255.255"

case $1 in
    start)
    ifconfig $DEV $LVS_VIP netmask $MASK broadcast $LVS_VIP
    #route add -host $LVS_VIP dev $DEV
    echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
    echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
    echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
    echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce
    action "RealServer is open"
    ;;
    stop)
    ifconfig $DEV down
    route del $LVS_VIP &> /dev/null
    echo 0 > /proc/sys/net/ipv4/conf/all/arp_ignore
    echo 0 > /proc/sys/net/ipv4/conf/lo/arp_ignore
    echo 0 > /proc/sys/net/ipv4/conf/all/arp_announce
    echo 0 > /proc/sys/net/ipv4/conf/lo/arp_announce
    action "RealServer is close"
    ;;
    *)
    echo "Usage: $(basename $0) start|stop" 
    exit 1
esac
