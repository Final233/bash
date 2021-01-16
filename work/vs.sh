#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2021-01-16
#FileName：             vs.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2021 All rights reserved
#********************************************************************
VIP="192.168.10.200"
DEV="lo:1"
MASK="255.255.255.255"
PORT="80"
RS1="192.168.10.3"
RS2="192.168.10.4"
SCHEDULER="rr"
TYPE="-g"

case $1 in
    start)
    ifconfig $DEV $VIP netmask $MASK broadcast $VIP up
    iptables -F
    ipvsadm -A -t $VIP:$PORT -s $SCHEDULER
    ipvsadm -a -t $VIP:$PORT -r $RS1 $TYPE -w 1
    ipvsadm -a -t $VIP:$PORT -r $RS2 $TYPE -w 1
    ;;
    stop)
    ipvsadm -C
    ifconfig $DEV down
    ;;
    *)
    echo "Usage $(basename $0) start|stop"
    exit 1
esac
