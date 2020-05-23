#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-05-23
#FileName：             ddos.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************
#连接数超过 10 放入到添加到 iptables 拒绝
_ddos(){
WARNING=10
ss -nt|sed -rn '/ESTAB/s/.* (.*):.*/\1/p'|sort|uniq -c|while read LINE;do
    TIME=`echo $LINE |cut -d" " -f1`
    IP=`echo $LINE |cut -d" " -f2`
    if [ $TIME -ge $WARNING ];then
        echo iptables -A INPUT -s $IP -j DROP
    fi
done
}
