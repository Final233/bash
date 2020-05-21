#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-05-21
#FileName：             num.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************
#判断用户输入是否为数字
_num(){
NUM=$1
[[ $NUM =~ ^[1-9][0-9]*$ ]] || { echo "echo Input false" ; exit; }
}
