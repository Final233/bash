#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-12-14
#FileName：             httpd_make_install.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************

. /etc/init.d/functions
DATE=$(date +%Y%m%d-%H%M%S)
Cpu_Core=$(lscpu | awk -F: '/socket/{print $2}')
Httpd_Ver="httpd-2.4.46"
Apr_Ver="apr-1.7.0"
Apr_util_Ver="apr-util-1.6.1"
BasePath=$(cd `dirname $0`; pwd)
App_Dir="/app/httpd24"
Httpd_User="apache"

_httpd_install(){
    if [ ! -f ${Httpd_Ver}.tar.gz ];then
        action "httpd pkg not exist" false
        echo "wget https://mirror.bit.edu.cn/apache/httpd/${Httpd_Ver}.tar.gz"
        echo "wget https://mirrors.tuna.tsinghua.edu.cn/apache/apr/${Apr_Ver}.tar.gz"
        echo "wget https://mirrors.tuna.tsinghua.edu.cn/apache/apr/${Apr_util_Ver}.tar.gz"
        echo "yum install bison bison-devel zlib-devel libcurl-devel libarchive-devel boost-devel gcc gcc-c++ cmake ncurses-devel gnutls-devel libxml2-devel openssl-devel libevent-devel libaio-devel expat-devel -y"
    else
        id apache &> /dev/null || useradd -s /sbin/nologin -r apache

        tar xf ${Httpd_Ver}.tar.gz
        tar xf ${Apr_Ver}.tar.gz -C ${Httpd_Ver}/srclib/
        tar xf ${Apr_util_Ver}.tar.gz -C ${Httpd_Ver}/srclib/
        cd ${Httpd_Ver}/srclib
        mv ${Apr_Ver} apr
        mv ${Apr_util_Ver} apr-util
        cd .. && ./configure --prefix="${App_Dir}" --enable-so --enable-ssl --enable-cgi --enable-rewrite --with-zlib --with-pcre --enable-modules=most --enable-mpms-shared=all --with-mpm=prefork --with-included-apr
        make -j${Cpu_Core} && make install

        export PATH=${App_Dir}/bin:$PATH
        echo "PATH=${App_Dir}/bin:\$PATH" > /etc/profile.d/httpd.sh
        
        sed -i "/^User/s/daemon/${Httpd_User}/" ${App_Dir}/conf/httpd.conf
        sed -i "/^Group/s/daemon/${Httpd_User}/" ${App_Dir}/conf/httpd.conf

        #sed -i '/^#ServerName/s/#//' ${App_Dir}/conf/httpd.conf
        #httpd -t
        #apachectl restart
    fi
}

_httpd_uninstall(){
    [ -d ${App_Dir}/htdocs ] && tar zcf /tmp/httpd_bak_${DATE}.tar.gz ${App_Dir}/htdocs/
    rm -f /etc/profile.d/httpd.sh
    rm -rf ${App_Dir}
    id apache && userdel apache
}

_httpd_conf(){
    grep -q "^Include conf/conf\.d/\*\.conf" ${App_Dir}/conf/httpd.conf || echo "Include conf/conf.d/*.conf" >> ${App_Dir}/conf/httpd.conf
    grep -q "index.php" ${App_Dir}/conf/httpd.conf || sed -ri '/index.html/s/(.* DirectoryIndex).*/\1 index.php index.html/' ${App_Dir}/conf/httpd.conf

    [ ! -d /app/httpd24/conf/conf.d ] && mkdir ${App_Dir}/conf/conf.d/
    if [ "$2" == "port" ];then
		#端口模式
		#ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/app/httpd24/htdocs/$1
        cat > ${App_Dir}/conf/conf.d/php.conf <<- EOF
		LoadModule proxy_module modules/mod_proxy.so
		LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so

		AddType application/x-httpd-php .php
		AddType application/x-httpd-php-source .phps
		ProxyRequests Off
		ProxyPassMatch "^/(.*\.php)$" "fcgi://127.0.0.1:9000/app/httpd24/htdocs/\$1"
		EOF
    elif [ "$2" == "socket" ];then
		#socket模式
        cat > ${App_Dir}/conf/conf.d/php.conf <<- EOF
		LoadModule proxy_module modules/mod_proxy.so
		LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so

		AddType application/x-httpd-php .php
		AddType application/x-httpd-php-source .phps
		ProxyRequests Off
		#ProxyPassMatch "^/(.*\.php)$" "unix:/var/run/php-fpm.sock|fcgi://localhost/app/httpd24/htdocs/" 
		EOF
    else
        echo "bash $0 conf port/socket"
    fi
}

_help(){
    echo "Usage: bash command [options] [args]"
    echo ""
    echo "Commands are:"
    echo "    参数1：install/i; uninstall/u ; conf/c"
    echo "=============================================================================="
    echo ""
    echo "执行命令示例："
    echo "        bash $0 install"
    echo ""
}

case $1 in
    install|i)
    _httpd_install
    ;;
    uninstall|u)
    _httpd_uninstall
    ;;
    conf|c)
    _httpd_conf "$@"
    ;;
    *)
    _help 
    ;;
esac
