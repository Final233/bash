#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2021-01-07
#FileName：             nginx_make_install.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2021 All rights reserved
#********************************************************************

. /etc/init.d/functions
APPDIR="/apps/nginx"
PKGNAME="nginx-1.18.0"
CPU_NUM=$(lscpu | awk -F: '/socket/{print $2}')
MAKE_OPT="./configure --prefix=${APPDIR} \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_realip_module \
--with-http_stub_status_module \
--with-http_gzip_static_module \
--with-pcre \
--with-stream \
--with-stream_ssl_module \
--with-stream_realip_module"

_nginx_make_install(){
    if [ ! -f ${PKGNAME}.tar.gz ];then
        #wget -c http://nginx.org/download/nginx-1.18.0.tar.gz 
        action "mariadb source pkg not exist" false 
        echo "wget -c http://nginx.org/download/${PKGNAME}.tar.gz"
        #echo "yum install bison bison-devel zlib-devel libcurl-devel libarchive-devel boost-devel gcc gcc-c++ cmake ncurses-devel gnutls-devel libxml2-devel openssl-devel libevent-devel libaio-devel -y"
        echo "yum install -y vim lrzsz tree screen psmisc lsof tcpdump wget ntpdategcc gcc-c++ glibc glibc-devel pcre pcre-devel openssl openssl-devel systemd-develnet-tools iotop bc zip unzip zlib-devel bash-completion nfs-utils automake libxml2libxml2-devel libxslt libxslt-devel perl perl-ExtUtils-Embed"
        exit
    else
        getent passwd nginx |awk -F: '{print $3}'|grep 6000 -q || (userdel nginx && useradd -s /sbin/nologin -u 6000)
        tar xf ${PKGNAME}.tar.gz -C /usr/local/src
        cd /usr/local/src/${PKGNAME} && ${MAKE_OPT} && make -j${CPU_NUM} && make install

    fi
}

_nginx_make_uninstall(){
    killall nginx
    rm -rf ${APPDIR}
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
    _nginx_make_install
    ;;
    uninstall|u)
    _nginx_make_uninstall
    ;;
    *)
    _help
    ;;
esac 
