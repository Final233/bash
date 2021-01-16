#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-05-19
#FileName：             testsrv.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************
#服务脚本测试
#chkconfig:- 96 07
#description
#[ -f /etc/init.d/$0 ] && chkconfig --add $0 || echo "$0 no such file"
. /etc/init.d/functions 

_start(){
if [ -f /var/lock/subsys/$0 ];then
    echo "$0 is running"
else
    touch /var/lock/subsys/$0
    action "service start"
fi
}

_stop(){
if [ -f /var/lock/subsys/$0 ];then
    rm -f /var/lock/subsys/$0
    action "service stop"
else
    echo "$0 is stopped"
fi
}

_restart(){
if [ ! -f /var/lock/subsys/$0 ];then
   _start
else
    _stop
    _start
fi
}

_status(){
if [ -f /var/lock/subsys/$0 ];then
    echo "$0 is running"
else
    echo "$0 is stopped"
fi
}
case $1 in
start)
    _start
;;
stop)
    _stop
;;
restart)
    _restart
;;
status)
    _status
;;
*)
echo "Usage: $0 {start|stop|restart|status}"
esac
