#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-11-18
#FileName：             mysql_binary_install.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************

. /etc/init.d/functions

DATADIR="/data/mysql"
APPDIR="/usr/local/mysql"
PKGNAME="mariadb-10.5.8-linux-systemd-x86_64"

_mysql_binary_install(){
    #wget -c https://mirrors.ustc.edu.cn/mariadb/mariadb-10.5.8/bintar-linux-systemd-x86_64/mariadb-10.5.8-linux-systemd-x86_64.tar.gz
    if [ ! -f ${PKGNAME}.tar.gz ];then
        action "mariadb pkg not exist" false 
        echo "wget -c https://mirrors.ustc.edu.cn/mariadb/mariadb-10.5.8/bintar-linux-systemd-x86_64/mariadb-10.5.8-linux-systemd-x86_64.tar.gz"
        exit
    else
        id mysql &> /dev/null || useradd -s /sbin/nologin -r mysql

        tar xf ${PKGNAME}.tar.gz -C /usr/local/
        ln -sv /usr/local/${PKGNAME} ${APPDIR}
        chown root.root ${APPDIR} -R

        echo "PATH=${APPDIR}/bin:\$PATH" > /etc/profile.d/mysql.sh
        # source /etc/profile

        mkdir ${DATADIR} -pv
        chown mysql.mysql ${DATADIR}
        chmod o=rx `dirname ${DATADIR}`
        cd ${APPDIR}/ && ./scripts/mysql_install_db --datadir=${DATADIR} --user=mysql
        mkdir /etc/mysql && cp ${APPDIR}/support-files/wsrep.cnf /etc/mysql/my.cnf

        if grep datadir /etc/mysql/my.cnf;then
            sed -ri "/datadir=/s@(datadir=).*@\1${DATADIR}@" /etc/mysql/my.cnf
        else
            sed "/\[mysqld\]/adatadir=${DATADIR}" /etc/mysql/my.cnf -i
        fi

        cp ${APPDIR}/support-files/mysql.server /etc/init.d/mysqld 
        chkconfig -add mysqld &> /dev/null
        systemctl daemon-reload
        systemctl status mysqld
        #/etc/init.d/mysqld status
    fi
}

_mysql_binary_uninstall(){
    if [ -f "${PKGNAME}" ];then 
        rm -rf /etc/mysql /etc/profile.d/mysql.sh /etc/init.d/mysqld /usr/local/${PKGNAME} &> /dev/null
        rm -f /usr/local/mysql
        #注意清理数据目录先确认是否要备份!!!
        rm -rf ${DATADIR} &>/dev/null
        #tar zcf mysql-`data +%F`.tar.gz /etc/mysql/ /etc/profile.d/mysql.sh /etc/init.d/mysqld /usr/local/${PKGNAME} 
        #tar zcf mysql-`data +%F`.tar.gz ${DATADIR} 
    fi
}

#_mysql_binary_uninstall
_mysql_binary_install
