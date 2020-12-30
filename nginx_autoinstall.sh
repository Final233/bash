#!/bin/bash

CPUNUM=`grep "processor" /proc/cpuinfo |wc -l`
NGINX_VER="1.14.0"
NGINX_DIR="/usr/local/nginx"
NGINX_ARGS="--prefix=/usr/local/nginx --conf-path=/etc/nginx/nginx.conf --user=nginx --group=nginx --error-log-path=/var/log/nginx/error_log --http-log-path=/var/log/nginx/access_log --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock --with-http_ssl_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_flv_module --with-http_mp4_module"
NGINX_YUM="pcre-devel openssl-devel make gcc gcc-c++"
NGINX_CONFTD="/root"
NAME="nginx"

yum install -y ${NGINX_YUM} &>/dev/null
tar xf ${NAME}-${NGINX_VER}.tar.gz
cd ${NGINX_CONFTD}/${NAME}-${NGINX_VER}
#.${NGINX_CONFTD}/${NAME}-${NGINX_VER}/configure ${NGINX_ARGS}
./configure ${NGINX_ARGS} &>/dev/null
make -j${CPUNUM} &>/dev/null && make install &>/dev/null 

cp /etc/${NAME}/${NAME}.conf{,.bak}
ln -s ${NGINX_DIR}/sbin/${NAME} /sbin/${NAME}
cp ${NGINX_CONFTD}/${NAME}.conf /etc/${NAME}/${NAME}.conf -rf
cp ${NGINX_CONFTD}/${NAME} /etc/init.d/ -rf
setenforce 0
systemctl stop firewalld
systemctl disable firewalld
/etc/init.d/${NAME} restart
ss -tnl
echo 'nginx install succeful'
