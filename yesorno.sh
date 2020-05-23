#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-05-16
#FileName：             yesorno.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************
#判断用户是否输入yes or no
read -p "please input YES or NO : " ANS
#[[ $ANS =~ [Yy]|[Yy][Ee][Ss]|[Nn]|[Nn][No] ]] || { echo "please input right options" && exit 1;}

YES="^[Yy]([Ee][Ss])?$"
NO="^[Nn]([No])?$"
if [[ $ANS =~ $YES ]];then
	echo yes
	exit
elif [[ $ANS =~ $NO ]];then
	echo no
else
	echo "please input right options" && exit 1
fi
