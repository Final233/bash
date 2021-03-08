#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-12-10
#FileName：             cobbler.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************

. /etc/init.d/functions
DATE=$(date +%Y%m%d-%H%M%S)

PASS=$(openssl passwd -1 'pass123')
IP="192.168.10.233"
Network_Segment="${IP%.*}."
Route="192.168.10.254"

_cobbler_install(){
    if [ rpm -qa epel-release &> /dev/null && rpm -qa cobbler &> /dev/null ];then
        true
    else
        yum install epel-release cobbler -y &> /dev/null 
    fi

    systemctl restart httpd
    systemctl restart cobblerd
    systemctl start rsyncd
    systemctl enable rsyncd
    systemctl restart tftp

    cp /etc/cobbler/settings{,.bak}

    ping g.cn -c 3 &> /dev/null && cobbler get-loaders || echo "internet is not woring"

    sed -ri "s/(^server:).*/\1 ${IP}/" /etc/cobbler/settings
    sed -ri "s/(^next_server:).*/\1 ${IP}/" /etc/cobbler/settings

    yum install debmirror fence-agents -y &> /dev/null
    sed -i '/^@dists/s/^/#/' /etc/debmirror.conf
    sed -i '/^@arches/s/^/#/' /etc/debmirror.conf  

    sed -i '/manage_dhcp/s/0/1/' /etc/cobbler/settings 
    sed -ri "/default_password_crypted/s/(.*:).*/\1 ${PASS}/" /etc/cobbler/settings

    yum install dhcp -y &> /dev/null
    cp /etc/cobbler/dhcp.template{,.bak}
    #设置网段
    sed -ri "/subnet/s/(^subnet ).*(netmask.*)/\1 ${Network_Segment}0 \2/" /etc/cobbler/dhcp.template
    #设置路由
    sed -ri "/option routers/s/(.*option routers).*[:digit:]+.*/\1 ${Route}\;/" /etc/cobbler/dhcp.template
    #设置DNS地址
    sed -ri "/option domain-name-servers/s/(.*option domain-name-servers).*/\1 119.29.29.29\;/" /etc/cobbler/dhcp.template
    #设置DHCP网段
    sed -ri "/range dynamic-bootp/s/(.*range dynamic-bootp).*/\1        ${Network_Segment}100 ${Network_Segment}254\; /" /etc/cobbler/dhcp.template

    sed '/timeout/s/0/60/' /etc/cobbler/pxe/efidefault.template -i
    cobbler check
    systemctl restart cobblerd
    cobbler sync
}

_cobbler_web_install(){
    yum install cobbler-web -y &> /dev/null
    systemctl restart httpd
}

_cobbler_uninstall(){
    systemctl stop cobblerd
    systemctl stop httpd
    systemctl stop rsyncd
    systemctl stop tftp
    yum remove -y cobbler cobbler-web &> /dev/null
}

_help(){
    echo "Usage: bash command [options] [args]"
    echo ""
    echo "Commands are:"
    echo "    参数1：install/i 安装; web/w cobbler web管理页面; uninstall/u 卸载"
    echo "=============================================================================="
    echo ""
    echo "执行命令例如："
    echo "        bash $0 install"
    echo ""
    echo "手工挂载并导入镜像源到 cobbler"
    echo "cobbler import --name=centos-7.6-x86_64 --path=/mnt --arch=x86_64"
    echo "cobbler profile add --name=centos-7.6 --distro=centos-7.6-x86_64 --kickstart=/var/lib/cobbler/kickstarts/centos7.6.cfg && cobbler profile list"
    echo "使用浏览器登录 https://$IP/cobbler_web"
    echo "用户/密码 cobbler/cobbler"
}

case $1 in
    install|i)
    _cobbler_install
    ;;
    web|w)
    _cobbler_web_install
    ;;
    uninstall|u)
    _cobbler_uninstsall
    ;;
    *)
    _help
    ;;
esac 

