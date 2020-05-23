#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-05-18
#FileName：             checkdisk.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************
#检查硬盘容量是否超过80%
_checkdisk(){
WARNING=80
df|sed -n '/^\/dev\/.d./p'| while read LINE;do
    USED=`echo $LINE|sed -rn 's/([^[:space:]]+).* ([0-9]+)%.*/\2/p'`
    PAPT=`echo $LINE|sed -rn 's/([^[:space:]]+).* ([0-9]+)%.*/\1/p'`
    if [ $USED -ge $WARNING ];then
        echo "$PAPT 硬盘容量超过80%,目前使用情况:$USED%"
    fi
done
}
