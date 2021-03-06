#!/usr/bin/env bash
#使用文件方式传参
while read ip user password;do
expect <<EOF
set timeout 20
spawn ssh $user@$ip
expect {
    "yes/no" { send "yes\n"; exp_continue }
    "password" { send "$password\n" }
}
expect "]#" { send "useradd user1\n" }
expect "]#" { send "echo password123 | passwd --stdin user1\n" }
expect "]#" { send "exit\n" }
expect eof
EOF
done < user.txt
