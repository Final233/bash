#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-05-23
#FileName：             deny_crack.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************
#如果此 IP 登录密码输错 10 次则在 iptables 拒绝
_deny_crack(){
WARNING=10
lastb |sed -rn 's/.* (([0-9]{1,3}\.){3}[0-9]{1,3}).*/\1/p'|sort|uniq -c|while read LINE;do
    TIME=`echo $LINE |cut -d" " -f1`
    IP=`echo $LINE |cut -d" " -f2`
    if [ $TIME -ge $WARNING ];then
        echo iptables -A INPUT -s $IP -j DROP 
    fi
done
}
