#!/usr/bin/env bash
#
#********************************************************************

#Author:                Final
#QQ:                    438803792
#Date:                  2020-05-23
#FileName：             color.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************

_color(){
#echo -e "\033[字背景颜色；文字颜色m字符串\033[0m"

#echo -e "\033[30m 黑色字 \033[0m"
#echo -e "\033[31m 红色字 \033[0m"
#echo -e "\033[32m 绿色字 \033[0m"
#echo -e "\033[33m 黄色字 \033[0m"
#echo -e "\033[34m 蓝色字 \033[0m"
#echo -e "\033[35m 紫色字 \033[0m"
#echo -e "\033[36m 天蓝字 \033[0m"
#echo -e "\033[37m 白色字 \033[0m"

#echo -e "\033[40;37m 黑底白字 \033[0m"
#echo -e "\033[41;37m 红底白字 \033[0m"
#echo -e "\033[42;37m 绿底白字 \033[0m"
#echo -e "\033[43;37m 黄底白字 \033[0m"
#echo -e "\033[44;37m 蓝底白字 \033[0m"
#echo -e "\033[45;37m 紫底白字 \033[0m"
#echo -e "\033[46;37m 天蓝底白字 \033[0m"
#echo -e "\033[47;30m 白底黑字 \033[0m"
#black="\033[30m"
#red="\033[31m"
#green="\033[32m"
#yellow="\033[33m"
#blue="\033[34m"
#purple="\033[35m"
#skyblue="\033[36m"
#white="\033[37m"
black="echo -e \033[30m"
red="echo -e \033[31m"
green="echo -e \033[32m"
yellow="echo -e \033[33m"
blue="echo -e \033[34m"
purple="echo -e \033[35m"
skyblue="echo -e \033[36m"
white="echo -e \033[37m"
end="\033[0m"
}

_colortest(){
#间接变量引用 eval tempvar=\$$variable1 或者 tempvar=${!variable1}
for i in black red green yellow blue purple skyblue white;do
#    echo -e "${!i}test${end}"
    ${!i}test${end}
done
}
