#!/bin/bash
source centos.conf

echo \*\*\*\* 开始自动配置安全基线

# 关闭selinux
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config

# 新建用户给最高权限 限制root远程登录
echo
echo \*\*\*\* 新建用户给最高权限 限制root远程登录
userdel -r ctuser
groupdel ctuser
useradd -u 0 -o -g root -G root -m ctuser
echo '1qaz@WSX' | passwd --stdin ctuser

# 设置口令长度最小值和密码复杂度策略
echo
echo \*\*\*\* 设置口令长度最小值和密码复杂度策略
# 大写字母、小写字母、数字、特殊字符 4选3，可自行配置
# 配置system-auth
cp /etc/pam.d/system-auth /etc/pam.d/'system-auth-'`date +%Y%m%d`.bak
egrep -q "^\s*password\s*(requisite|required)\s*pam_cracklib.so.*$" /etc/pam.d/system-auth  && sed -ri "s/^\s*password\s*(requisite|required)\s*pam_cracklib.so.*$/\password    requisite     pam_cracklib.so try_first_pass retry=3 minlen=$minlen dcredit=-1 ocredit=-1 lcredit=-1/" /etc/pam.d/system-auth || echo "password    requisite     pam_cracklib.so try_first_pass retry=3 minlen=$minlen dcredit=-1 ocredit=-1 lcredit=-1" >> /etc/pam.d/system-auth
# 配置password-auth
cp /etc/pam.d/password-auth /etc/pam.d/'password-auth-'`date +%Y%m%d`.bak
egrep -q "^\s*password\s*(requisite|required)\s*pam_cracklib.so.*$" /etc/pam.d/password-auth && sed -ri "s/^\s*password\s*(requisite|required)\s*pam_cracklib.so.*$/\password    requisite     pam_cracklib.so try_first_pass retry=3 minlen=$minlen dcredit=-1 ocredit=-1 lcredit=-1/" /etc/pam.d/password-auth || echo "password    requisite     pam_cracklib.so try_first_pass retry=3 minlen=$minlen dcredit=-1 ocredit=-1 lcredit=-1" >> /etc/pam.d/password-auth
# 配置login.defs
cp /etc/login.defs /etc/'login.defs-'`date +%Y%m%d`.bak
egrep -q "^\s*PASS_MIN_LEN\s+\S*(\s*#.*)?\s*$" /etc/login.defs && sed -ri "s/^(\s*)PASS_MIN_LEN\s+\S*(\s*#.*)?\s*$/\PASS_MIN_LEN    $minlen/" /etc/login.defs || echo "PASS_MIN_LEN    $minlen" >> /etc/login.defs

# 设置口令生存周期（可选,缺省不配置）

echo
echo \*\*\*\* 设置口令生存周期
egrep -q "^\s*PASS_MAX_DAYS\s+\S*(\s*#.*)?\s*$" /etc/login.defs && sed -ri "s/^(\s*)PASS_MAX_DAYS\s+\S*(\s*#.*)?\s*$/\PASS_MAX_DAYS   $PASS_MAX_DAYS/" /etc/login.defs || echo "PASS_MAX_DAYS   $PASS_MAX_DAYS" >> /etc/login.defs
egrep -q "^\s*PASS_MIN_DAYS\s+\S*(\s*#.*)?\s*$" /etc/login.defs && sed -ri "s/^(\s*)PASS_MIN_DAYS\s+\S*(\s*#.*)?\s*$/\PASS_MIN_DAYS   $PASS_MIN_DAYS/" /etc/login.defs || echo "PASS_MIN_DAYS   $PASS_MIN_DAYS" >> /etc/login.defs
egrep -q "^\s*PASS_WARN_AGE\s+\S*(\s*#.*)?\s*$" /etc/login.defs && sed -ri "s/^(\s*)PASS_WARN_AGE\s+\S*(\s*#.*)?\s*$/\PASS_WARN_AGE   $PASS_WARN_AGE/" /etc/login.defs || echo "PASS_WARN_AGE   $PASS_WARN_AGE" >> /etc/login.defs


# 密码重复使用次数限制
echo
echo \*\*\*\* 密码重复使用次数限制
# 配置system-auth
egrep -q "^\s*password\s*sufficient\s*pam_unix.so.*$" /etc/pam.d/system-auth && sed -ri "s/^\s*password\s*sufficient\s*pam_unix.so.*$/\password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=$remember/" /etc/pam.d/system-auth || echo "password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=$remember" >> /etc/pam.d/system-auth
# 配置password-auth
egrep -q "^\s*password\s*sufficient\s*pam_unix.so.*$" /etc/pam.d/password-auth && sed -ri "s/^\s*password\s*sufficient\s*pam_unix.so.*$/\password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=$remember/" /etc/pam.d/password-auth || echo "password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=$remember" >> /etc/pam.d/password-auth

# 锁定与设备运行、维护等工作无关的账号
#echo
#echo \*\*\*\* 锁定与设备运行、维护等工作无关的账号
#cp /etc/shadow /etc/'shadow-'`date +%Y%m%d`.bak
#passwd -l adm&>/dev/null 2&>/dev/null; passwd -l daemon&>/dev/null 2&>/dev/null; passwd -l bin&>/dev/null 2&>/dev/null; passwd -l sys&>/dev/null 2&>/dev/null; passwd -l lp&>/dev/null 2&>/dev/null; passwd -l uucp&>/dev/null 2&>/dev/null; passwd -l nuucp&>/dev/null 2&>/dev/null; passwd -l smmsplp&>/dev/null 2&>/dev/null; passwd -l mail&>/dev/null 2&>/dev/null; passwd -l operator&>/dev/null 2&>/dev/null; passwd -l games&>/dev/null 2&>/dev/null; passwd -l gopher&>/dev/null 2&>/dev/null; passwd -l ftp&>/dev/null 2&>/dev/null; passwd -l nobody&>/dev/null 2&>/dev/null; passwd -l nobody4&>/dev/null 2&>/dev/null; passwd -l noaccess&>/dev/null 2&>/dev/null; passwd -l listen&>/dev/null 2&>/dev/null; passwd -l webservd&>/dev/null 2&>/dev/null; passwd -l rpm&>/dev/null 2&>/dev/null; passwd -l dbus&>/dev/null 2&>/dev/null; passwd -l avahi&>/dev/null 2&>/dev/null; passwd -l mailnull&>/dev/null 2&>/dev/null; passwd -l nscd&>/dev/null 2&>/dev/null; passwd -l vcsa&>/dev/null 2&>/dev/null; passwd -l rpc&>/dev/null 2&>/dev/null; passwd -l rpcuser&>/dev/null 2&>/dev/null; passwd -l nfs&>/dev/null 2&>/dev/null; passwd -l sshd&>/dev/null 2&>/dev/null; passwd -l pcap&>/dev/null 2&>/dev/null; passwd -l ntp&>/dev/null 2&>/dev/null; passwd -l haldaemon&>/dev/null 2&>/dev/null; passwd -l distcache&>/dev/null 2&>/dev/null; passwd -l webalizer&>/dev/null 2&>/dev/null; passwd -l squid&>/dev/null 2&>/dev/null; passwd -l xfs&>/dev/null 2&>/dev/null; passwd -l gdm&>/dev/null 2&>/dev/null; passwd -l sabayon&>/dev/null 2&>/dev/null; passwd -l named&>/dev/null 2&>/dev/null
#echo \*\*\*\* 锁定帐号完成

# 用户认证失败次数限制
echo
echo \*\*\*\* 连续登录失败5次锁定帐号5分钟
cp /etc/pam.d/sshd /etc/pam.d/'sshd-'`date +%Y%m%d`.bak
cp /etc/pam.d/login /etc/pam.d/'login-'`date +%Y%m%d`.bak
sed -ri "/^\s*auth\s+required\s+pam_tally2.so\s+.+(\s*#.*)?\s*$/d" /etc/pam.d/sshd /etc/pam.d/login /etc/pam.d/system-auth /etc/pam.d/password-auth
sed -ri "1a auth       required     pam_tally2.so deny=$deny unlock_time=300 even_deny_root root_unlock_time=30" /etc/pam.d/sshd  /etc/pam.d/system-auth 
egrep -q "^\s*account\s+required\s+pam_tally2.so\s*(\s*#.*)?\s*$" /etc/pam.d/sshd || sed -ri '/^password\s+.+(\s*#.*)?\s*$/i\account    required     pam_tally2.so' /etc/pam.d/sshd
egrep -q "^\s*account\s+required\s+pam_tally2.so\s*(\s*#.*)?\s*$" /etc/pam.d/login || sed -ri '/^password\s+.+(\s*#.*)?\s*$/i\account    required     pam_tally2.so' /etc/pam.d/login
egrep -q "^\s*account\s+required\s+pam_tally2.so\s*(\s*#.*)?\s*$" /etc/pam.d/system-auth || sed -ri '/^account\s+required\s+pam_permit.so\s*(\s*#.*)?\s*$/a\account     required      pam_tally2.so' /etc/pam.d/system-auth
egrep -q "^\s*account\s+required\s+pam_tally2.so\s*(\s*#.*)?\s*$" /etc/pam.d/password-auth || sed -ri '/^account\s+required\s+pam_permit.so\s*(\s*#.*)?\s*$/a\account     required      pam_tally2.so' /etc/pam.d/password-auth


# 重要目录和文件的权限设置
#echo
#echo \*\*\*\* 设置重要目录和文件的权限
#chmod 644 /etc/passwd;chmod 644 /etc/group;chmod 644 /etc/services;chmod 400 /etc/shadow;chmod 600 /etc/security



# 登录超时设置
echo
echo \*\*\*\* 设置登录超时时间为10分钟
cp /etc/ssh/sshd_config /etc/ssh/'sshd_config-'`date +%Y%m%d`.bak
egrep -q "^\s*(export|)\s*TMOUT\S\w+.*$" /etc/profile && sed -ri "s/^\s*(export|)\s*TMOUT.\S\w+.*$/export TMOUT=$TMOUT/" /etc/profile || echo "export TMOUT=$TMOUT" >> /etc/profile
egrep -q "^\s*.*ClientAliveInterval\s\w+.*$" /etc/ssh/sshd_config && sed -ri "s/^\s*.*ClientAliveInterval\s\w+.*$/ClientAliveInterval $TMOUT/" /etc/ssh/sshd_config || echo "ClientAliveInterval $TMOUT " >> /etc/ssh/sshd_config

# SSH登录前警告Banner
echo
echo \*\*\*\* 设置ssh登录前警告Banner
cp /etc/issue /etc/'issue-'`date +%Y%m%d`.bak
egrep -q "WARNING" /etc/issue || (echo "**************WARNING**************" >> /etc/issue;echo "Authorized only. All activity will be monitored and reported." >> /etc/issue)
egrep -q "^\s*(banner|Banner)\s+\W+.*$" /etc/ssh/sshd_config && sed -ri "s/^\s*(banner|Banner)\s+\W+.*$/Banner \/etc\/issue/" /etc/ssh/sshd_config || echo "Banner /etc/issue" >> /etc/ssh/sshd_config

# SSH登录后Banner
echo
echo \*\*\*\* 设置ssh登录后Banner
cp /etc/motd /etc/'motd-'`date +%Y%m%d`.bak
egrep -q "WARNING" /etc/motd || (echo "**************WARNING**************" >> /etc/motd;echo "Login success. All activity will be monitored and reported." >> /etc/motd)

# 日志文件非全局可写
echo
echo \*\*\*\* 设置日志文件非全局可写
chmod 755 /var/log/messages; chmod 775 /var/log/spooler; chmod 775 /var/log/mail&>/dev/null 2&>/dev/null; chmod 775 /var/log/cron; chmod 775 /var/log/secure; chmod 775 /var/log/maillog; chmod 775 /var/log/localmessages&>/dev/null 2&>/dev/null

# 记录su命令使用情况
echo
echo \*\*\*\* 配置并记录su命令使用情况
cp /etc/rsyslog.conf /etc/'rsyslog.conf-'`date +%Y%m%d`.bak
egrep -q "^\s*authpriv\.\*\s+.+$" /etc/rsyslog.conf && sed -ri "s/^\s*authpriv\.\*\s+.+$/authpriv.*                                              \/var\/log\/secure/" /etc/rsyslog.conf || echo "authpriv.*                                              /var/log/secure" >> /etc/rsyslog.conf

# 禁止root远程登录（暂不配置）
:<<!
echo
echo \*\*\*\* 禁止root远程SSH登录
egrep -q "^\s*PermitRootLogin\s+.+$" /etc/ssh/sshd_config && sed -ri "s/^\s*PermitRootLogin\s+.+$/PermitRootLogin no/" /etc/ssh/sshd_config || echo "PermitRootLogin no" >> /etc/ssh/sshd_config
!

# 禁用ctrl+alt+del组合键
echo
echo \*\*\*\* 禁用ctrl+alt+del组合键
mv /usr/lib/systemd/system/ctrl-alt-del.target /usr/lib/systemd/system/ctrl-alt-del-target-

# 删除潜在威胁文件
echo
echo \*\*\*\* 删除潜在威胁文件
find / -maxdepth 3 -name hosts.equiv | xargs -i mv {} {}.bak
find / -maxdepth 3 -name .netrc | xargs -i mv {} {}.bak
find / -maxdepth 3 -name .rhosts | xargs -i mv {} {}.bak

# 限制不必要的服务
echo
echo \*\*\*\* 限制不必要的服务
systemctl disable rsh&>/dev/null 2&>/dev/null;systemctl disable talk&>/dev/null 2&>/dev/null;systemctl disable telnet&>/dev/null 2&>/dev/null;systemctl disable tftp&>/dev/null 2&>/dev/null;systemctl disable rsync&>/dev/null 2&>/dev/null;systemctl disable xinetd&>/dev/null 2&>/dev/null;systemctl disable nfs&>/dev/null 2&>/dev/null;systemctl disable nfslock&>/dev/null 2&>/dev/null

# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld.service
systemctl disable bluetooth.service
systemctl disable cups.service

# 历史命令设置
echo
echo \*\*\*\* 设置保留历史命令的条数为30，并加上时间戳
egrep -q "^\s*HISTSIZE\s*\W+[0-9].+$" /etc/profile && sed -ri "s/^\s*HISTSIZE\W+[0-9].+$/HISTSIZE=$history_num/" /etc/profile || echo "HISTSIZE=$history_num" >> /etc/profile
egrep -q "^\s*HISTTIMEFORMAT\s*\S+.+$" /etc/profile && sed -ri "s/^\s*HISTTIMEFORMAT\s*\S+.+$/HISTTIMEFORMAT='%F %T | '/" /etc/profile || echo "HISTTIMEFORMAT='%F %T | '" >> /etc/profile
egrep -q "^\s*export\s*HISTTIMEFORMAT.*$" /etc/profile || echo "export HISTTIMEFORMAT" >> /etc/profile

# 配置NTP
#echo
#echo \*\*\*\* 配置NTP
#systemctl enable ntpd
#sed -i "s/^server /#server /" /etc/ntp.conf
#echo "server 10.26.5.21 iburst prefer" >> /etc/ntp.conf
#echo "server 10.26.5.22 iburst" >> /etc/ntp.conf
#systemctl restart ntpd



# 修改ssh端口
#echo
#echo \*\*\*\* 修改ssh端口
#sed -i 's/#Port 22/Port 62748/' /etc/ssh/sshd_config
