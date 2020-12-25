#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-12-16
#FileName：             mysql_semi_sync.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************


rpm -ql mariadb-server |grep "semisync.*so$"

_mysql_master_semisync(){
    mysql -e "install plugin  rpl_semi_sync_master soname 'semisync_master.so';"
    mysql -e "set global rpl_semi_sync_master_enabled=1; set global rpl_semi_sync_master_timeout = 1000;"
    mysql -e "show variables like '%semi%';"
    mysql -e "show global status like '%semi%';"
    grep -q "rpl_semi_sync_master_enabled" /etc/my.cnf || sed "/\[mysqld\]/arpl_semi_sync_master_enabled = 1" /etc/my.cnf -i
    grep -q "rpl_semi_sync_master_timeout" /etc/my.cnf || sed "/\[mysqld\]/arpl_semi_sync_master_timeout = 1000" /etc/my.cnf -i
}

_mysql_slave_semisync(){
    mysql -e "install plugin rpl_semi_sync_slave soname 'semisync_slave.so';"
    mysql -e "set global rpl_semi_sync_slave_enabled=1;
    mysql -e "mysql -e "show status like '%semi%';"
    grep -q "rpl_semi_sync_slave_enabled" /etc/my.cnf || sed "/\[mysqld\]/arpl_semi_sync_slave_enabled = 1" /etc/my.cnf -i
}

_help(){
    echo "Usage: bash command [options] [args]"
    echo ""
    echo "Commands are:"
    echo "    参数1：master/m ; slave/s"
    echo "=============================================================================="
    echo ""
    echo "执行命令例如："
    echo "        bash $0 master"
    echo ""
}

case $1 in
    master|m)
    _mysql_master_semisync
    ;;
    slave|s)
    _mysql_slave_semisync
    ;;
    *)
   _help
esac 
