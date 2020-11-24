#!/bin/sh
# CentOS 7.5 64bit v1.2
##编辑 /etc/security/limits.conf
cat <<ENDlimits >> /etc/security/limits.conf
*               soft    nproc           2047
*               hard    nproc           16384
*               soft    nofile          65536	
*               hard    nofile          101365
ENDlimits

##编辑 /etc/sysctl.conf
cat <<ENDsysctl >>/etc/sysctl.conf
kernel.sem = 500  64000  200  640
vm.swappiness = 10
ENDsysctl
sysctl -p

##ssh配置
service sshd stop
cp /etc/pam.d/sshd /tmp/install/initconfig/openssh/sshd.bak
rpm -e openssh-clients --nodeps
rpm -e openssh-server --nodeps
rpm -e openssh --nodeps
chmod 744 /tmp/install/initconfig/openssh/openssh-*
rpm -Uvh /tmp/install/initconfig/openssh/openssh-7.8p1-1.el7.x86_64.rpm
rpm -Uvh /tmp/install/initconfig/openssh/openssh-server-7.8p1-1.el7.x86_64.rpm
rpm -Uvh /tmp/install/initconfig/openssh/openssh-debuginfo-7.8p1-1.el7.x86_64.rpm
rpm -Uvh /tmp/install/initconfig/openssh/openssh-clients-7.8p1-1.el7.x86_64.rpm
chmod 600 /etc/ssh/ssh_*_key
wait
cp /tmp/install/initconfig/openssh/sshd.bak /etc/pam.d/sshd
cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
cat <<ENDssh >>/etc/ssh/sshd_config
PermitRootLogin no
UsePAM yes
ENDssh
service sshd start
sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config

##disable service
systemctl disable abrt-ccpp.service
systemctl disable abrt-oops.service
systemctl disable abrt-vmcore.service
systemctl disable abrt-xorg.service
systemctl disable abrtd.service
systemctl disable accounts-daemon.service
systemctl disable avahi-daemon.service
systemctl disable kdump.service
systemctl disable ksm.service
systemctl disable ksmtuned.service
systemctl disable libvirtd.service
systemctl disable cups.service
systemctl disable auditd.service
systemctl disable bluetooth.service
systemctl disable atd.service
systemctl disable postfix.service
systemctl disable NetworkManager.service
systemctl disable mdmonitor.service

## change group
groupadd -g 500 noright
usermod -g noright jfcz
usermod -G noright jfcz
groupdel jfcz

##jfcz cron
mkdir -p /tmp/ls/output
cp /tmp/install/initconfig/linux_check.sh /tmp/ls/
chmod 755 /tmp/ls/linux_check.sh
chown -R jfcz.noright /tmp/ls
cat <<ENDcron >> /var/spool/cron/jfcz
0 7  * * * sh /tmp/ls/linux_check.sh
5 16 * * * sh /tmp/ls/linux_check.sh
ENDcron
##使用非root用户修改系统时间
ln -s /bin/date /bin/datenew
cp -p /etc/sudoers /etc/sudoers.bak
sed -i '/^root/a\jfcz	 ALL=(ALL) NOPASSWD: /bin/datenew' /etc/sudoers
##调整登录数限制
cp -p /etc/xinetd.conf /etc/xinetd.conf.bak
sed -i 's/^.*instances.*$/        instances       = 1024/' /etc/xinetd.conf
service xinetd restart

##关闭IP v6
sed -i 's/crashkernel=auto/ipv6.disable=1 crashkernel=auto/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
##禁用SELinux
cp -p /etc/selinux/config /etc/selinux/config.bak
sed -i 's/^.*SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config
sed -i 's/rhgb quiet.*$/rhgb quiet selinux=0/' /boot/grub/grub.conf 

##防止误使用Ctrl+Alt+Del重启系统
rm -rf /usr/lib/systemd/system/ctrl-alt-del.target
##umask设置
echo "umask  027" >> /etc/profile
##SNMP弱口令修改
cp -p /etc/cups/snmp.conf /etc/cups/snmp.conf.bak
sed -i 's/Community public/Community sywg1234/' /etc/cups/snmp.conf

##修改文件权限
chmod 600 /etc/xinetd.conf
chmod 604 /var/log/messages
# change /etc/hosts
grep ^# /etc/hosts > /tmp/hosts.tmp
echo "127.0.0.1               localhost" >> /tmp/hosts.tmp
mv /etc/hosts /etc/hosts.bak
mv /tmp/hosts.tmp /etc/hosts

## 部署 nmon
mkdir -p /nmon/scripts/
mkdir -p /nmon/logs
mkdir -p /nmon/logs/ftp
cp /tmp/install/initconfig/nmon_x86_64_rhel7 /nmon/scripts/
chmod 755 /nmon/scripts/nmon_x86_64_rhel7
ln -s /nmon/scripts/nmon_x86_64_rhel7 /bin/nmon
cat <<ENDnmon > /nmon/scripts/nmon.sh
#!/bin/bash
ftpfile=\`ls -ltr /nmon/logs/*nmon|tail -n1|awk '{print \$9}'\`
rm -f /nmon/logs/ftp/*
cp -p \$ftpfile /nmon/logs/ftp/
/nmon/scripts/nmon_x86_64_rhel7 -s30 -c2879 -f -m /nmon/logs
find /nmon/logs -type f -atime +7 -exec rm {} \;
ENDnmon
chown -R jfcz.noright /nmon
chmod 755 /nmon/scripts/nmon.sh
cat <<ENDcron >> /var/spool/cron/jfcz
05 15 * * * sh /nmon/scripts/nmon.sh > /nmon/logs/nmon.log 2>&1
ENDcron

#YUM config
mkdir -p /etc/yum.repos.d/bak
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak
cat <<ENDyum > /etc/yum.repos.d/iso.repo
[iso]
name=CentOS 7.5
baseurl=file:///yum
enabled=1
gpgcheck=0
ENDyum
chown -R root.root /etc/yum.repos.d/iso.repo
chmod 744 /etc/yum.repos.d/iso.repo
yum clean all
yum makecache

#安装ntp服务
yum install ntp -y



##设置最小密码长度
cp -p /etc/login.defs /etc/login.defs.bak
sed  -i '/^PASS_MIN_LEN/s/5/12/g' /etc/login.defs

##设置密码复杂度
cp -p /etc/pam.d/system-auth-ac /etc/pam.d/system-auth-ac.bak
sed -i 's/.* pam_pwquality.so.*/password    requisite     pam_cracklib.so try_first_pass retry=10 minlen=12 minclass=3 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 type='/g /etc/pam.d/system-auth-ac

cp -p /etc/pam.d/password-auth-ac /etc/pam.d/password-auth-ac.bak
sed -i 's/.* pam_pwquality.so.*/password    requisite     pam_cracklib.so try_first_pass retry=10 minlen=12 minclass=3 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 type='/g /etc/pam.d/password-auth-ac

##登录失败10次锁定
sed -i '4 a\auth        required      pam_tally2.so onerr=fail deny=10 unlock_time=300' /etc/pam.d/system-auth-ac
sed -i '4 a\auth        required      pam_tally2.so onerr=fail deny=10 unlock_time=300' /etc/pam.d/password-auth-ac

##编辑 /etc/rsyslog.conf 20180626 cancel
#cp -p /etc/rsyslog.conf /etc/rsyslog.conf.bak
#cat <<ENDrsyslog >>/etc/rsyslog.conf
#*.* @日志服务器ip:514
#ENDrsyslog
#systemctl restart rsyslog.service

##登录超时设置
sed -i '/^HISTSIZE=/a\TMOUT=600' /etc/profile
