#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-10-14
#FileName：             user.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************

. /etc/init.d/functions

USER=$1
_useradd(){
    if id $USER &> /dev/null ;then
        action "$USER already exist."
    else
        useradd $USER;
        echo $USER | passwd --stdin $USER;
        action "USER is create completed."
    fi
}

_useradd "$@"
