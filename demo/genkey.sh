#!/usr/bin/env bash
#生成密钥文件
#ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
#echo n |ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
#echo |ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
_genkey(){
expect <<EOF
set timeout 20
spawn ssh-keygen -t rsa -P "" 
expect "id_rsa" { send "\n" }
expect "y/n" { send "\n" }
EOF
}
_genkey
