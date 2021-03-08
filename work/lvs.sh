#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2021-01-14
#FileName：             lvs.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2021 All rights reserved
#********************************************************************
#!/bin/bash
VIP="192.168.10.250"
MASK='255.255.255.255'
DEV="lo:1"
PORT='80'
RS1='192.168.10.3'
RS2='192.168.10.4'
SCHEDULER='wrr'
TYPE='-g'

case $1 in
vs_start)
    ifconfig ${DEV} ${VIP} netmask ${MASK} #broadcast $VIP up
    iptables -F
    ipvsadm -A -t ${VIP}:${PORT} -s $SCHEDULER
    ipvsadm -a -t ${VIP}:${PORT} -r ${RS1} $TYPE -w 1
    ipvsadm -a -t ${VIP}:${PORT} -r ${RS2} $TYPE -w 1
    ;;
vs_stop)
    ipvsadm -C
    ifconfig $DEV down
    ;;
rs_start)
    echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
    echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
    echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
    echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce
    ifconfig $DEV $VIP netmask $MASK #broadcast $VIP up
    #route add -host $VIP dev $DEV
    ;;
rs_stop)
    ifconfig $DEV down
    echo 0 > /proc/sys/net/ipv4/conf/all/arp_ignore
    echo 0 > /proc/sys/net/ipv4/conf/lo/arp_ignore
    echo 0 > /proc/sys/net/ipv4/conf/all/arp_announce
    echo 0 > /proc/sys/net/ipv4/conf/lo/arp_announce
    ;;
*)
    echo "Usage: bash $(basename $0) vs_start|vs_stop|rs_start|rs_stop"
    exit 1
    ;;
esac
