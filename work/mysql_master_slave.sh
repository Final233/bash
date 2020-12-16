#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-11-26
#FileName：             mysql_master_slave.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************

MYSQL_CONF=/etc/my.cnf
SERVER_ID=1
IP="'192.168.10.%'"
USER="'repluser'"
PASS="'pass123'"
MASTER_BINLOG_FILE="'mariadb-bin.000001'"
#新部署默认是245开始，可以show master logs查看下二进制位置
MASTER_BINLOG_SITE="245"

_mysql_master(){
    grep log_bin ${MYSQL_CONF} || sed -i "/\[mysqld\]/alog_bin" ${MYSQL_CONF}
    grep server_id ${MYSQL_CONF} &&  sed -ri "/server_id=/s/(server_id=).*/\1${SERVER_ID}/" ${MYSQL_CONF} || sed -i "/\[mysqld\]/aserver_id=${SERVER_ID}" ${MYSQL_CONF} 
    systemctl restart mariadb
    #reset master;

    mysql -e "grant replication slave on *.* to "$USER"@"$IP"  identified by "$PASS";"
    mysql -e "select host,user,password from mysql.user;show processlist;"
}

_mysql_slave(){
SERVER_ID=2
MASTER_IP="'192.168.10.5'"
USER="'repluser'"
PASS="'pass123'"

    grep read_only ${MYSQL_CONF} && sed -ri "/read_only=/s/(read_only=).*/\1ON/" ${MYSQL_CONF} || sed -i "/\[mysqld\]/aread_only=ON" ${MYSQL_CONF}
    grep server_id ${MYSQL_CONF} && sed -ri "/server_id=/s/(server_id=).*/\1${SERVER_ID}/" ${MYSQL_CONF} || sed -i "/\[mysqld\]/aserver_id=${SERVER_ID}" ${MYSQL_CONF} 
    systemctl restart mariadb

    mysql -e "stop slave;" &> /dev/null
    mysql -e "RESET SLAVE ALL;"
    mysql -e "CHANGE MASTER TO MASTER_HOST="$MASTER_IP", MASTER_USER="$USER", MASTER_PASSWORD="$PASS", MASTER_PORT=3306, MASTER_LOG_FILE="$MASTER_BINLOG_FILE", MASTER_LOG_POS=${MASTER_BINLOG_SITE};"
    mysql -e "start slave;"
    mysql -e "show slave status\G;"
    mysql -e "show processlist;"
}

_help(){
	echo "Usage: bash command [options] [args]"
    echo ""
    echo "Commands are:"
    echo "    参数1：master/m 部署主节点，slave/s 部署从节点"
    echo "=============================================================================="
    echo ""
    echo "执行命令例如："
    echo "        bash $0 master"
    echo ""
	}
	
case "$1" in 
    master|m)
    _mysql_master
    ;;
    slave|s)
    _mysql_slave
    ;;
    *)
    _help()
	;;
esac
