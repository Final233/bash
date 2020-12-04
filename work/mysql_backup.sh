#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-12-03
#FileName：             mysql_backup.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************

#mysql -uroot -e'show databases' | grep -Ev 'Database|information_schema|performance_schema'
#for i in `mysql -uroot -e'show databases' | grep -Ev 'Database|information_schema|performance_schema'`;do mysqldump -B $i | gzip > ${i}_bak_`date +%F`.sql;done
#mysql -uroot -e'show databases' | grep -Ev 'Database|information_schema|performance_schema' |sed -r 's/(.*)/mysqldump -B \1 | gzip > \1.bak.sql.gz/'

. /etc/init.d/functions
DATE=$(date +%Y%m%d-%H%M%S)
DB_USER="root"
DB_PASS=""
DBNAME=$(mysql -e 'show databases' | grep -Ev 'Database|information_schema|performance_schema|test')
BASEPATH=$(cd `dirname $0`; pwd)

_mysql_backup(){
    #备份所有的数据库
    #mysqldump -B -F -E -R --single-transaction --master-data=1 --flush-privileges --triggers --default-character-set=utf8 --hex-blob | gzip > all_bak_$DATE.sql;
    #备份指定的数据库
    for i in $DBNAME;do
        mysqldump -B -F -E -R --single-transaction --master-data=1 --flush-privileges --triggers --default-character-set=utf8 --hex-blob $i | gzip > ${i}_bak_${DATE}.sql.gz
        action "${i}_bak_$DATE.sql.gz"
    done
}

_mysql_recovery(){
    if test -z $2;then 
        echo "file is not exist"
    else
        FILE=$2
        if [ -f $FILE ];then
            gzip -d $FILE
            FILE=${FILE/.gz/}
            DB=$(echo $FILE | sed -r 's/(.*)_bak.*/\1/')
            cd $BASEPATH
            systemctl stop mariadb &> /dev/null
            #注意启动服务时，禁止用户远程访问
            systemctl start mariadb &> /dev/null && mysql -e "set sql_log_bin=off;drop database $DB;source $FILE;" && action "mysql is recovery succ"
        fi
    fi
}

case "$1" in
    backup|b)
        _mysql_backup
        ;;
    recovery|r)
        _mysql_recovery "$@"
        ;;
    *)
        echo "Usage: bash command [options] [args]"
        echo ""
        echo "Commands are:"
        echo "    参数1：bakcup|b; recovery|r file.sql.gz"
        echo "=============================================================================="
        echo ""
        echo "执行命令例如："
        echo "        bash $0 backup | bash $0 recovery file.sql.gz"
        echo ""
esac
