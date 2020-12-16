#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-12-14
#FileName：             php_make_install.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************

. /etc/init.d/functions

Cpu_Core=$(lscpu | awk -F: '/socket/{print $2}')
Php_Ver="php-7.3.25"
App_Dir="/app/php"

_php_install(){
    if [ ! -f ${Php_Ver}.tar.xz ];then
        echo "wget https://www.php.net/distributions/${Php_Ver}.tar.xz"
        action "libmcrypt-devel is EPEL yum !!!!!!" false
        echo "yum install bison bison-devel zlib-devel libcurl-devel libarchive-devel boost-devel gcc gcc-c++ cmake ncurses-devel gnutls-devel libxml2-devel openssl-devel libevent-devel libaio-devel expat-devel glibc  pcre-devel bzip2-devel libmcrypt-devel"
    else
        tar xf ${Php_Ver}.tar.xz
        cd ${Php_Ver} && ./configure --prefix=${App_Dir} --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-openssl --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --enable-mbstring --enable-xml --enable-sockets --enable-fpm --enable-maintainer-zts --disable-fileinfo
        make -j${Cpu_Core} && make install

        cp php.ini-production /etc/php.ini
        cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm && chmod +x /etc/init.d/php-fpm && chkconfig --add php-fpm

        cd ${App_Dir}/etc
        cp php-fpm.conf.default php-fpm.conf
        cp php-fpm.d/www.conf.default php-fpm.d/www.conf

        systemctl restart php-fpm
    fi
}

_php_uninstall(){
    rm -rf ${App_Dir}
    chkconfig --del php-fpm
    rm -f /etc/php.ini /etc/init.d/php-fpm
}

_php_conf(){
    Php_Conf="${App_Dir}/etc/php-fpm.d/www.conf"
    sed -ri '/^user/s/(.*)=.*/\1= apache/' ${Php_Conf}
    sed -ri '/^group/s/(.*)=.*/\1= apache/' ${Php_Conf}
    #端口模式
    if [ "$2" == "port" ];then
        sed -ri '/^listen/s/(.*)=.*/\1= 9000/' ${Php_Conf}
        #sed -ri '/^listen/s/(.*)=.*/\1= 127.0.0.1:9000/' ${Php_Conf}
        sed -i '/^listen.mode/s/^/;/' ${Php_Conf}
    #socket模式
    elif [ "$2" == "socket" ];then
        sed -ri '/^listen/s@(.*)=.*@\1= /var/run/php-fpm.sock@' ${Php_Conf}
        sed -ri '/listen.mode/s@\;(listen.mode).*@\1 = 0666@' ${Php_Conf}
    else
        echo "bash $0 conf /port/socket"
    fi
}

_help(){
    echo "Usage: bash command [options] [args]"
    echo ""
    echo "Commands are:"
    echo "    参数1：install/i 安装 ; uninstall/u 卸载; conf/c 配置"
    echo "=============================================================================="
    echo ""
    echo "执行命令例如："
    echo "        bash $0 install"
    echo ""
}

case $1 in
    install|i)
    _php_install
    ;;
    uninstall|u)
    _php_uninstall
    ;;
    conf|c)
    _php_conf "$@"
    ;;
    *)
    _help 
    ;;
esac

