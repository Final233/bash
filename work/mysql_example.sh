#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-11-26
#FileName：             mysql_example.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************
#vim /mysql/{3306,3307,3308}/bin/mysqld
#cat /mysq/3306/bin/mysqld
port=3306
mysql_user="root"
mysql_pwd="" #数据库默认密码为空，安全加固后输入密码
cmd_path="/usr/bin" #注意mysqld_safe路径
mysql_basedir="/mysql"
mysql_sock="${mysql_basedir}/${port}/socket/mysql.sock"

function_start_mysql(){
    if [ ! -e "$mysql_sock" ];then
        printf "Starting MySQL...\n"
        ${cmd_path}/mysqld_safe --defaults-file=${mysql_basedir}/${port}/etc/my.cnf &> /dev/null &
    else
        printf "MySQL is running...\n"
        exit
    fi
}

function_stop_mysql(){
    if [ ! -e "$mysql_sock" ];then
        printf "MySQL is stopped...\n"
        exit
    else
        printf "Stoping MySQL...\n"
        ${cmd_path}/mysqladmin -u ${mysql_user} -p${mysql_pwd} -S ${mysql_sock} shutdown
    fi
}

function_restart_mysql(){
    printf "Restarting MySQL...\n"
    function_stop_mysql
    sleep 2
    function_start_mysql
}

case $1 in
    start)
    function_start_mysql
    ;;
    stop)
    function_stop_mysql
    ;;
    restart)
    function_restart_mysql
    ;;
    *)
    printf "Usage: ${mysql_basedir}/${port}/bin/mysqld {start|stop|restart}\n"
esac

