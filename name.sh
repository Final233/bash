#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-05-23
#FileName：             name.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************

_name(){
NAME=`basename $0`
if [ "$NAME" = "test.sh" ];then
    echo file name is test.sh
elif [ "$NAME" = "test1.sh" ];then
    echo file name is test1.sh
else 
    echo other
fi
}

_name
