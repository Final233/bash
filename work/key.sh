#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-10-14
#FileName：             key.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************

. /etc/init.d/functions
rpm -q expect &> /dev/null || yum install -q -y expect || action "expect is Package not installed" false || exit

#生成密钥文件
_sshkeygen(){
    expect <<-EOF
    set timeout 20
    spawn ssh-keygen -t rsa -P "" 
    expect "id_rsa" { send "\n" }
    expect "y/n" { send "\n" }
	EOF
    action "Generate private key"
}

#做免密登陆，做将公钥发给各主机
_copyid(){
    if [ -f ip.txt ];then
        while read ip user password;do
        expect <<-EOF
        set timeout 20
        spawn ssh-copy-id $user@$ip
        expect {
            "yes/no" { send "yes\n"; exp_continue }
            "password" { send "$password\n" }
        }
        expect eof
		EOF
        done < ip.txt
        #127.0.0.1 user password
        #127.0.0.1 oesuser oesuser
        #127.0.0.1 mdsuser mdsuser
        #127.0.0.1 monuser monuser
        action "Distribute public key"
    else
        action "ip.txt file does not exist" false
    fi
}

_copyid2(){
    if [ $# -ge 4 ];then
        ip=$2
        user=$3
        password=$4
        expect <<-EOF
        set timeout 20
        spawn ssh-copy-id $user@$ip
        expect {
            "yes/no" { send "yes\n"; exp_continue }
            "password" { send "$password\n" }
        }
        expect eof
		EOF
    else
        action "127.0.0.1 user password" false
    fi

}

_help(){
    echo "Usage: bash command [options] [args]"
    echo ""
    echo "Commands are:"
    echo "    参数1：set1 ssh-keygen ssh-copy-id"
    echo "    参数2：set2 ssh-keygen"
    echo "    参数3：set3 ssh-copy-id"
    echo "    参数4：set4 127.0.0.1 user password"
    echo "=============================================================================="
    echo ""
    echo "执行命令例如："
    echo "        bash $0 set2"
    echo ""
}

_execute(){
case "$1" in
    set1)
    _sshkeygen
    _copyid
    ;;
    set2)
    _sshkeygen
    ;;
    set3)
    _copyid
    ;;
    set4)
    _copyid2 "$@"
    ;;
    *)
    _help
esac
}

_execute "$@"
