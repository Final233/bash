#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-05-19
#FileName：             status.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************
#显示状态
_status(){
#echo -e "\033[31m FALIED \033[0m"
#echo -e "\033[32m OK \033[0m"

. /etc/init.d/functions
action "FAILED" false
action "OK" true
}

_status

