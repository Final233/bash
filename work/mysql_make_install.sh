#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-11-24
#FileName：             mysql_make_install.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************

	

DATADIR="/data/mysql"
APPDIR="/usr/local/mysql"
PKGNAME="mariadb-10.5.8"
CPU_NUM=$(lscpu | awk -F: '/socket/{print $2}')
MYSQL_SOCKET="/data/mysql/mysql.sock" 
MYSQL_CONF="/etc/mysql"
MAKE_OPT="cmake . \
-DCMAKE_INSTALL_PREFIX="${APPDIR}" \
-DMYSQL_DATADIR="${DATADIR}" \
-DSYSCONFDIR="${MYSQL_CONF}" \
-DMYSQL_USER=mysql \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITHOUT_MROONGA_STORAGE_ENGINE=1 \
-DWITH_DEBUG=0 \
-DWITH_READLINE=1 \
-DWITH_SSL=system \
-DWITH_ZLIB=system \
-DWITH_LIBWRAP=0 \
-DENABLED_LOCAL_INFILE=1 \
-DMYSQL_UNIX_ADDR="${MYSQL_SOCKET}" \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci"

_mysql_make_install(){
    if [ ! -f ${PKGNAME}.tar.gz ];then
        #wget -c https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-10.5.8/source/mariadb-10.5.8.tar.gz
        action "mariadb source pkg not exist" false 
        echo "wget -c https://mirrors.tuna.tsinghua.edu.cn/mariadb/${PKGNAME}/source/${PKGNAME}.tar.gz"
        echo "yum install bison bison-devel zlib-devel libcurl-devel libarchive-devel boost-devel gcc gcc-c++ cmake ncurses-devel gnutls-devel libxml2-devel openssl-devel libevent-devel libaio-devel -y"
        exit
    else
        id mysql &> /dev/null || useradd -s /sbin/nologin -r mysql
        if [ ! -d /var/log/mariadb ];then
            mkdir /var/log/mariadb && chown mysql.mysql /var/log/mariadb
        fi

        mkdir -pv ${DATADIR}
        chown mysql.mysql ${DATADIR}

        tar xf ${PKGNAME}.tar.gz -C /usr/local/src
        cd /usr/local/src/${PKGNAME}
        rm -f CMakeCache.txt &> /dev/null
        ${MAKE_OPT} && make -j${CPU_NUM} && make install || ( action "make instll error.." false && exit )

        echo "PATH=${APPDIR}/bin:\$PATH" > /etc/profile.d/mysql.sh
        source /etc/profile

        chmod o=rx `dirname ${DATADIR}`
        cd ${APPDIR}/ && ./scripts/mysql_install_db --datadir=${DATADIR} --user=mysql
        mkdir /etc/mysql && cp ${APPDIR}/support-files/wsrep.cnf ${MYSQL_CONF}/my.cnf

        if grep datadir ${MYSQL_CONF}/my.cnf;then
            sed -ri "/datadir=/s@(datadir=).*@\1${DATADIR}@" ${MYSQL_CONF}/my.cnf
        else
            sed "/\[mysqld\]/adatadir=${DATADIR}" ${MYSQL_CONF}/my.cnf -i
        fi

        if grep ^socket ${MYSQL_CONF}/my.cnf;then
            sed -ri "/socket/s@(socket=).*@\1/data/mysql/mysql.sock@" ${MYSQL_CONF}/my.cnf 
        else
            sed "/\[mysqld\]/asocket=/data/mysql/mysql.sock" ${MYSQL_CONF}/my.cnf -i
        fi
        

        cp ${APPDIR}/support-files/mysql.server /etc/init.d/mysqld 
        chkconfig -add mysqld &> /dev/null
        systemctl daemon-reload
        systemctl status mysqld
        #/etc/init.d/mysqld status
        echo ". /etc/profile"
    fi
}

_mysql_make_uninstall(){
    if [ -f "${APPDIR}" ];then 
        systemctl stop mysqld
        rm -rf /etc/mysql /etc/profile.d/mysql.sh /etc/init.d/mysqld /usr/local/src/${PKGNAME} /usr/local/mysql &> /dev/null
        rm -f /usr/local/mysql
        #注意清理数据目录先确认是否要备份!!!
        rm -rf ${DATADIR} &>/dev/null
        #tar zcf mysql-`data +%F`.tar.gz /etc/mysql/ /etc/profile.d/mysql.sh /etc/init.d/mysqld /usr/local/${PKGNAME} 
        #tar zcf mysql-`data +%F`.tar.gz ${DATADIR} 
    fi
}


_help(){
    echo "Usage: bash command [options] [args]"
    echo ""
    echo "Commands are:"
    echo "    参数1：install/i 安装; uninstall/u 卸载"
    echo "=============================================================================="
    echo ""
    echo "执行命令例如："
    echo "        bash $0 install"
    echo ""
}

case $1 in
    install|i)
    _mysql_make_install
    ;;
    uninstall|u)
    _mysql_make_uninstall
    ;;
    *)
    _help
    ;;
esac 
