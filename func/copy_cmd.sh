#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-05-20
#FileName：             copy_cmd.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************
_copycmd(){
#LIBFILE=`ldd `which --skip-alias ls` | egrep -o "/lib64.* "`
G1="\\033[32m"
G2="\\033[0m"
_copyfile(){
ldd `which --skip-alias ${LINE}` |awk '{print $3}'|grep ^/ | while read i;do
    DESTDIR=/mnt/sysroot
    [ ! -d $DESTDIR ] && mkdir -p ${DESTDIR}
    DIRNAME=`dirname $i`
    [ ! -d ${DESTDIR}${DIRNAME} ] && mkdir -p ${DESTDIR}${DIRNAME}
    cp -rfl $i $DESTDIR$i
    echo -e "copy file $i ==> $DESTDIR$i ${G1}finished $G2"
done 
}

while read  -p "Please Input Command: " LINE ;do
QUIT="^[Qq]([Uu][Ii][Tt])?$"
    if which --skip-alias $LINE &> /dev/null ;then
        _copyfile
    elif [[ $LINE =~ $QUIT ]];then
        break
    else
        echo no
    fi
done
}

#_copycmd
