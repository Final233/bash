#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2021-01-25
#FileName：             notify.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2021 All rights reserved
#********************************************************************

CONTACT="438803792@qq.com"

_notify(){
    MAIL_SUBBECT="$(hostname) to be $1,VIP 转移"
    MAIL_BODY="$(date +'%F %T'): VRRP transition,$(hostname) changed to be $1"
    echo "$MAIL_BODY" | mail -s "$MAIL_SUBBECT" $CONTACT
}

case $1 in
master)
    _notify master
    ;;
    backup)
    _notify backup
    ;;
    fault)
    _notify fault
    ;;
    *)
    echo "Usage: $(basename $0) {master|backup|fault}"
    ;;
esac
