#!/usr/bin/env bash
#使用文件交互的方式 $1 $2 $3 IP 用户 密码
#做免密登陆，做将公钥发给各主机
while read ip user password;do
expect <<EOF
set timeout 20
spawn ssh $user@$ip
expect {
    "yes/no" { send "yes\n"; exp_continue }
    "password" { send "$password\n" }
}
expect eof
EOF
done < user.txt
#cat user.txt
#127.0.0.1 root password123
#192.168.10.233 root password123
