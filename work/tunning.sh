#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-02-25
#FileName：             tunning.sh
#URL:                   http://cnblogs.com/fina
#Description：          The tunning script
#Copyright (C):         2020 All rights reserved
#********************************************************************
#适用于Linux调优
. /etc/init.d/functions
DATE=$(date +%Y%m%d-%H%M%S)

_grub(){
#/etc/default/grub grub2-mkconfig -o /boot/grub2/grub.cfg /boot/EFI/cenots/grub2/grub.cfg
#isolcpus hugepages change setting and rhgb quiet is delete
#sed -ri '/CMDLINE/s@(.*)"@\1 ipv6.disable=1 selinux=0 isolcpus=1-22 nohz_full=1-22 default_hugepagesz=1G hugepagesz=1G hugepages=32 intel_idle.max_cstate=0 processor.max_cstate=0 idle=poll intel_iommu=off nosoftlockup mce=ignore_ce nmi_watchdog=0 pcie_aspm=off nohz=off audit=0 biosdevname=0 net.ifnames=0"@p'  /etc/default/grub
    [ -f "$GRUB" ] && cp -av "$GRUB"{,.bak"${DATE}"}
    if [ -f "$FILE" ];then
        sed -ri "/GRUB_CMDLINE_LINUX=/s@(.*)\"@\1 ${VAULE1}\"@"  /etc/default/grub
        grub2-mkconfig -o "${FILE}"
    else
        echo "grub file is not exist"                                                                                     
    fi
}

_grublevel(){
    FILE=$(find /boot -name 'grub.cfg' -type f)
    GRUB=/etc/default/grub
    CPUS=1
    CPUE=$(echo "$(grep -c "cpu cores" /proc/cpuinfo)" - 2 | bc)
    VAULE1="ipv6.disable=1 selinux=0 isolcpus=${CPUS}-${CPUE} nohz_full=${CPUS}-${CPUE} transparent_hugepage=never default_hugepagesz=2M hugepagesz=2M hugepages=20480 intel_idle.max_cstate=0 processor.max_cstate=0 idle=poll intel_iommu=off nosoftlockup mce=ignore_ce nmi_watchdog=0 pcie_aspm=off nohz=off audit=0"
    if grep -q selinux=0 ${GRUB};then
        action "grub is success"
    else
        if [ "$1" = "grub1" ];then
            _grub
        elif [ "$1" = "grub2" ];then
        VAULE1="ipv6.disable=1 selinux=0 transparent_hugepage=never default_hugepagesz=2M hugepagesz=2M intel_idle.max_cstate=0 processor.max_cstate=0 idle=poll intel_iommu=off nosoftlockup mce=ignore_ce nmi_watchdog=0 pcie_aspm=off nohz=off audit=0 biosdevname=0 net.ifnames=0"
            _grub
        elif [ "$1" = "grub3" ];then
        VAULE1="ipv6.disable=1 selinux=0 transparent_hugepage=never default_hugepagesz=2M hugepagesz=2M intel_idle.max_cstate=0 processor.max_cstate=0 idle=poll intel_iommu=off nosoftlockup mce=ignore_ce nmi_watchdog=0 pcie_aspm=off nohz=off audit=0"
            _grub
        fi
    fi
}

#网卡调优 write is to /etc/rc.d/rc.local but +x Permission
_nic(){
#NETPROT=eth0
#echo ethtool -G $2 2048 tx 2048  >> ${FILE}
#echo ethtool -C $2 rx-usecs 0 rx-usecs-irq 0 adaptive-rx off >> ${FILE}
    FILE=/etc/rc.d/rc.local 
    if [ -n "$2" ];then
        if grep -q "$2" ${FILE};then
            true
        else
            [ -f ${FILE} ] && cp -av ${FILE}{,.bak"${DATE}"}
            cat >> ${FILE} <<- EOF
			ethtool -G $2 2048 tx 2048
			ethtool -C $2 rx-usecs 0 rx-usecs-irq 0 adaptive-rx off
			EOF
            chmod +x ${FILE} && grep ethtool ${FILE}
        fi
    fi
    exit
    echo "\$2 is null"
}

_net(){
FILE=/etc/rc.d/rc.local
    for DEV in $(ip link show | awk -F: '/UP/{print $2}' | sed 's/[[:space:]]//');do
        if ethtool "${DEV}" | awk '/Speed/{print $2}' | grep -q 10000;then
            ethtool -G "${DEV}" 2048 tx 2048
            ethtool -C "${DEV}" rx-usecs 0 rx-usecs-irq 0 adaptive-rx off
            if ! grep -q "${DEV}" "${FILE}";then
                cat >> ${FILE} <<- EOF
				ethtool -G $DEV 2048 tx 2048
				ethtool -C $DEV rx-usecs 0 rx-usecs-irq 0 adaptive-rx off
				EOF
            fi
            chmod +x ${FILE} && grep ethtool ${FILE}
            action "network interface is change success"
        fi
    done
}

#硬盘调优，根据实际情况
_disktunning(){
    if grep -q noatime /etc/fstab;then
        action "disktunning is success"
    else
        cd /etc/ && cp -a fstab{,.bak"${DATE}"}
        sed '/\//s/defaults/defaults,noatime/' /etc/fstab -i
        #sed '/defaults/s/defaults/defaults,noatime/' /etc/fstab -i
        #sed '/defaults/s/defaults/defaults,noatime,nobarrier,inode64/' /etc/fstab -i
        action "disktunning is change success"
    fi
}

_tunning(){
    timedatectl set-timezone Asia/Shanghai
    systemctl set-default multi-user.target
    tuned-adm profile network-latency
    x86_energy_perf_policy performance
    ulimit -c unlimited

    chkconfig NetworkManager off &> /dev/null
    chkconfig --del NetworkManager &> /dev/null
    virsh net-destroy default &> /dev/null
    virsh net-undefine default  &> /dev/null
    #virsh net-list
    {
    #停止不必要的服务
    systemctl stop libvirtd.service &> /dev/null
    systemctl stop iptables.service &> /dev/null
    systemctl stop firewalld.service &> /dev/null
    #用于中断优化分配，它会自动收集系统数据以分析使用模式，并依据系统负载状况将CPU转为C1-C6状态 
    systemctl stop irqbalance.service &> /dev/null
    systemctl stop abrt-ccpp.service &> /dev/null
    systemctl stop abrt-oops.service &> /dev/null
    systemctl stop abrt-xorg.service &> /dev/null
    systemctl stop abrtd.service &> /dev/null
    systemctl stop alsa-state.service &> /dev/null
    #通用unix打印服务
    systemctl stop cups.service &> /dev/null
    systemctl stop ModemManager.service &> /dev/null
    systemctl stop postfix.service &> /dev/null
    #cpupower服务提供CPU的运行规范
    systemctl stop cpuspower  &> /dev/null
    systemctl stop firewalld &> /dev/null

    #关闭开机自启的服务
    systemctl disable firewalld.service &> /dev/null
    systemctl disable libvirtd.service &> /dev/null
    systemctl disable iptables.service &> /dev/null
    systemctl disable irqbalance.service &> /dev/null
    systemctl disable alsa-state.service &> /dev/null
    systemctl disable cups.service &> /dev/null
    systemctl disable ModemManager.service &> /dev/null
    systemctl disable postfix.service &> /dev/null
    }&
    wait
    action "tunning is success"
}

#关闭selinux
_selinux(){
    sed '/SELINUX=/s/enforcing/disabled/' /etc/selinux/config -i
    action "selinux is disable"
}

#内核调优 sysctl -p
_sysctl(){
#mds is up
#net.ipv4.conf.default.rp_filter = 0
#net.ipv4.conf.all.rp_filter = 0
#net.ipv4.conf.eth0.rp_filter = 0
    DATE=$(date +%Y%m%d-%H%M%S)
    FILE=/etc/sysctl.conf
    if grep -q "^kernel" ${FILE};then
        action "sysctl is success"
    else
        [ -f ${FILE} ] && cp -av ${FILE}{,.bak"${DATE}"} 
        #cat > ${FILE} << EOF 
        cat >> ${FILE} <<- EOF 
		# Increase size of file handles and inode cache
		fs.file-max = 2097152
		kernel.pid_max = 147456
		
		# tells the kernel how many TCP sockets that are not attached to any
		# user file handle to maintain. In case this number is exceeded,
		# orphaned connections are immediately reset and a warning is printed.
		net.ipv4.tcp_max_orphans = 60000
		
		# Do not cache metrics on closing connections
		net.ipv4.tcp_no_metrics_save = 1
		
		# Turn on window scaling which can enlarge the transfer window
		net.ipv4.tcp_window_scaling = 1
		
		# Enable timestamps as defined in RFC1323
		net.ipv4.tcp_timestamps = 1
		
		# Enable select acknowledgments
		net.ipv4.tcp_sack = 1
		
		# Maximum number of remembered connection requests, which did not yet
		# receive an acknowledgment from connecting client.
		#net.ipv4.tcp_max_syn_backlog = 10240
		net.ipv4.tcp_max_syn_backlog = 1024
		
		# recommended for hosts with jumbo frames enabled
		net.ipv4.tcp_mtu_probing=1
		#net.ipv4.tcp_mtu_probing=0
		
		# Turn on SYN-flood protections
		#net.ipv4.tcp_syncookies = 1
		net.ipv4.tcp_syncookies = 0
		
		# Disable tcp slow start mechanism for high-speed network
		net.ipv4.tcp_slow_start_after_idle = 0
		
		# Number of times SYNACKs for passive TCP connection.
		net.ipv4.tcp_synack_retries = 2
		net.ipv4.tcp_syn_retries = 2
		
		# Allowed local port range
		#net.ipv4.ip_local_port_range = 1024 65535
		net.ipv4.ip_local_port_range = 10000 65535
		
		# Protect Against TCP Time-Wait
		net.ipv4.tcp_rfc1337 = 1
		
		# Decrease the time default value for tcp_fin_timeout connection
		net.ipv4.tcp_fin_timeout = 15
		
		# Increase number of incoming connections
		# somaxconn defines the number of request_sock structures
		# allocated per each listen call. The
		# queue is persistent through the life of the listen socket.
		net.core.somaxconn = 1024
		
		# Increase number of incoming connections backlog queue
		# Sets the maximum number of packets, queued on the INPUT
		# side, when the interface receives packets faster than
		# kernel can process them.
		net.core.netdev_max_backlog = 65536
		
		# Increase the maximum amount of option memory buffers
		net.core.optmem_max = 25165824
		
		# Increase the maximum total buffer-space allocatable (4096 bytes)
		#net.ipv4.tcp_mem = 65536 131072 262144
		#net.ipv4.udp_mem = 65536 131072 262144
		net.ipv4.tcp_mem = 524288 1048576 2621440
		net.ipv4.udp_mem = 524288 1048576 2621440
		
		### Set the max OS send buffer size (wmem) and receive buffer
		# size (rmem) to 12 MB for queues on all protocols. In other
		# words set the amount of memory that is allocated for each
		# TCP socket when it is opened or created while transferring files
		
		# Default Socket Receive Buffer
		#net.core.rmem_default = 25165824
		net.core.rmem_default = 524288
		
		# Maximum Socket Receive Buffer
		#net.core.rmem_max = 25165824
		net.core.rmem_max = 11960320
		
		# Increase the read-buffer space allocatable (minimum size,
		# initial size, and maximum size in bytes)
		#net.ipv4.tcp_rmem = 20480 12582912 25165824
		net.ipv4.tcp_rmem = 16384 524288 11960320
		net.ipv4.udp_rmem_min = 16384
		
		# Default Socket Send Buffer
		#net.core.wmem_default = 25165824
		net.core.wmem_default = 524288
		
		# Maximum Socket Send Buffer
		#net.core.wmem_max = 25165824
		net.core.wmem_max = 11960320
		
		# Increase the write-buffer-space allocatable
		#net.ipv4.tcp_wmem = 20480 12582912 25165824
		net.ipv4.tcp_wmem = 16384 524288 11960320
		net.ipv4.udp_wmem_min = 16384
		
		# sysctl net.ipv4.tcp_moderate_rcvbuf
		#net.ipv4.tcp_moderate_rcvbuf = 0
		net.ipv4.tcp_moderate_rcvbuf = 1
		
		# Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
		#net.ipv4.tcp_max_tw_buckets = 1440000
		net.ipv4.tcp_max_tw_buckets = 180000
		#net.ipv4.tcp_tw_recycle = 1  # 不建议开启 tcp_tw_recycle
		net.ipv4.tcp_tw_recycle = 0
		net.ipv4.tcp_tw_reuse = 1
		
		# Keepalive
		net.ipv4.tcp_keepalive_time = 300
		net.ipv4.tcp_keepalive_intvl = 15
		net.ipv4.tcp_keepalive_probes = 5
		
		# with polling
		net.core.busy_poll = 50
		net.core.busy_read = 50
		
		###
		
		# recommended default congestion control is htcp
		# sysctl net.ipv4.tcp_available
		#net.ipv4.tcp_congestion_control = htcp
		#net.ipv4.tcp_congestion_control = reno
		net.ipv4.tcp_congestion_control = cubic
		
		# Enable low latency mode for TCP
		net.ipv4.tcp_low_latency = 1
		
		###
		
		vm.swappiness = 0
		vm.stat_interval = 10
		#vm.nr_hugepages=2048
		
		kernel.shmmax = 68719476736
		kernel.shmall = 4294967296
		kernel.msgmnb = 65536
		kernel.msgmax = 65536
		kernel.nmi_watchdog = 0
		
		kernel.core_uses_pid = 1
		kernel.core_pattern = core.%e.%p
		
		###
		
		# Disable Reverse Path Forwarding
		#net.ipv4.conf.default.rp_filter = 0
		#net.ipv4.conf.all.rp_filter = 0
		#net.ipv4.conf.eno2.rp_filter = 0
		#net.ipv4.conf.eno3.rp_filter = 0
		
		#vm.hugetlb_shm_group=1001
		EOF
    fi
}
		
#环境变量 profile 
_env(){
#HISTTIMEFORMAT="%F %T `whoami` `who -u am i 2> /dev/null |awk '{print $NF}'|sed -e 's/[()]//g'` "
#PS1="\[\e[1;36m\][\u@\h \W]\\$ \[\e[0m\]"
#连接超时时间 TMOUT=900
#umaks标准 umask 027
    FILE=/etc/profile.d/env.sh
    cat > ${FILE} <<- EOF
	#setterm -blank 0
	#TMOUT=900
	umask 027
	PS1="\[\e[1;36m\][\u@\h \W]\\\\$ \[\e[0m\]"
	HISTTIMEFORMAT="| %F | %T | \$(whoami) | \$(who -u am i 2> /dev/null | awk '{print \$NF}'| sed -e 's/[()]//g') | "
	alias cdnet='cd /etc/sysconfig/network-scripts/'
	alias yy='yum install -y '
	alias yd='yum install --downloadonly --downloaddir=/tmp '
	alias yp='yum provides '
	alias ys='yum search '
	EOF
    #export EDITOR=vim
    source /etc/profile
    #exec bash 
    #exit
    action "env setting success"
}
		
#vim 忽略大小写 忽略下划线 自动缩进 粘贴 TAB键4个空格
_vimrc(){
    cat > ~/.vimrc <<- EOF
	set ignorecase
	set cursorline
	set autoindent
	set paste
	set tabstop=4
	set shiftwidth=4
	set expandtab
	set sts=4
	autocmd BufNewFile *.sh exec ":call SetTitle()"
	func SetTitle() 
        if expand("%:e") == 'sh'
        call setline(1,"#!/usr/bin/env bash") 
        call setline(2,"#") 
        call setline(3,"#********************************************************************") 
        call setline(4,"#Author:                Final") 
        call setline(5,"#QQ:                    438803792") 
        call setline(6,"#Date:                  ".strftime("%Y-%m-%d"))
        call setline(7,"#FileName：             ".expand("%"))
        call setline(8,"#URL:                   http://cnblogs.com/fina")
        call setline(9,"#Description：          The test script") 
        call setline(10,"#Copyright (C):         ".strftime("%Y")." All rights reserved")
        call setline(11,"#********************************************************************") 
        call setline(12,"") 
        endif
	endfunc
	autocmd BufNewFile * normal G
	EOF
    action "vim setting success"
}

#login is message
_motd(){
    FILE=/etc/motd
    cat > ${FILE} <<- EOF 
	/**
	 * ┌───┐   ┌───┬───┬───┬───┐ ┌───┬───┬───┬───┐ ┌───┬───┬───┬───┐ ┌───┬───┬───┐
	 * │Esc│   │ F1│ F2│ F3│ F4│ │ F5│ F6│ F7│ F8│ │ F9│F10│F11│F12│ │P/S│S L│P/B│  ┌┐    ┌┐    ┌┐
	 * └───┘   └───┴───┴───┴───┘ └───┴───┴───┴───┘ └───┴───┴───┴───┘ └───┴───┴───┘  └┘    └┘    └┘
	 * ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───────┐ ┌───┬───┬───┐ ┌───┬───┬───┬───┐
	 * │~ \`│! 1│@ 2│# 3│$ 4│% 5│^ 6│& 7│* 8│( 9│) 0│_ -│+ =│ BacSp │ │Ins│Hom│PUp│ │N L│ / │ * │ - │
	 * ├───┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─────┤ ├───┼───┼───┤ ├───┼───┼───┼───┤
	 * │ Tab │ Q │ W │ E │ R │ T │ Y │ U │ I │ O │ P │{ [│} ]│ | \ │ │Del│End│PDn│ │ 7 │ 8 │ 9 │   │
	 * ├─────┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴─────┤ └───┴───┴───┘ ├───┼───┼───┤ + │
	 * │ Caps │ A │ S │ D │ F │ G │ H │ J │ K │ L │: ;│" '│ Enter  │               │ 4 │ 5 │ 6 │   │
	 * ├──────┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴────────┤     ┌───┐     ├───┼───┼───┼───┤
	 * │ Shift  │ Z │ X │ C │ V │ B │ N │ M │< ,│> .│? /│  Shift   │     │ ↑ │     │ 1 │ 2 │ 3 │   │
	 * ├─────┬──┴─┬─┴──┬┴───┴───┴───┴───┴───┴──┬┴───┼───┴┬────┬────┤ ┌───┼───┼───┐ ├───┴───┼───┤ E││
	 * │ Ctrl│    │Alt │         Space         │ Alt│    │    │Ctrl│ │ ← │ ↓ │ → │ │   0   │ . │←─┘│
	 * └─────┴────┴────┴───────────────────────┴────┴────┴────┴────┘ └───┴───┴───┘ └───────┴───┴───┘
	 **/
	EOF
    action "motd is success"
}

#消息提示
_m(){
    FILE=$(find /boot -name 'grub.cfg' -type f)
    GRUB=/etc/default/grub
    echo "vim ${GRUB}"
    echo "grub2-mkconfig -o ${FILE} "
    echo "CPU 隔离 isolcpus=1-22 nohz_full=1-22"
    echo "大页内存设置 default_hugepagesz=1G hugepagesz=1G hugepages=32 default_hugepagesz=2M hugepagesz=2M hugepages=20480"
    echo "上海L1 FAST流开启 net.ipv4.conf.default.rp_filter = 0 net.ipv4.conf.all.rp_filter = 0 net.ipv4.conf.eth0.rp_filter = 0"
    echo "setcap 'cap_ipc_lock=+ep' oes && setcap 'cap_ipc_lock=+ep' mds"
    echo "sysctl.conf >> vm.hugetlb_shm_group=1001 这里是gidnum"
}

#安全检查security check
_securitycheck(){
    #echo "检查未使用的账号"
    egrep -v '.*:*|:!' /etc/shadow | awk -F: '{print $1}'
    if [ $? -le 0 ];then 
        echo 未检查出未使用的账号
    else 
        echo "锁定账号 /usr/sbin/usermod -L -s /dev/null USERNAME"
        echo "删除账号 /usr/sbin/userdel USERNAME"
    fi 

    #echo "禁止空密码登录"
    SSHCONF=/etc/ssh/sshd_config
    if grep -q "^#PermitEmptyPasswords no" ${SSHCONF};then
        [ -f ${SSHCONF} ] && cp -av ${SSHCONF}{,.bak"${DATE}"}
        sed -i '/^#PermitEmptyPasswords no/s/#//g' "${SSHCONF}"
        echo "修改完成后请重启sshd服务 systemctl restart sshd"
    fi

    PAMFILE=/etc/pam.d/system-auth
    if grep -q remember=5 "${PAMFILE}";then
        true
    else
        sed -ri '/password    sufficient/s/(.*)/\1 remember=5/g' "${PAMFILE}"
    fi
    echo -e "列出空口令用户:"
    awk -F: '($2 == "") { print $1 }' /etc/shadow

    #密码长度不小于 8 个字符，至少包含大小写字母、数字及特殊符号中的 3 类
    #echo 密码复杂度
    if grep -q minlen=8 "${PAMFILE}";then
        true
    else
        [ -f "${PAMFILE}" ] && cp -av "${PAMFILE}"{,.bak"${DATE}"}
        sed -ri '/password    requisite/s/(.*)/\1 minlen=8 minclass=3/g' "${PAMFILE}"
    fi

    echo "列出UID为0的用户:"
    awk -F ':' '($3 == "0"){print $1}' /etc/passwd

    echo "列出重要的文件及目录权限标准:"
    ls -l /etc/passwd /etc/group /etc/shadow
    #chmod 644 /etc/passwd /etc/group && chmod 000 /etc/shadow
    #chmod 000 /etc/shadow || chmod 400 /etc/shadow

    FILE="/usr/lib/systemd/system/ctrl-alt-del.target"
    #ln -s /usr/lib/systemd/system/reboot.target /usr/lib/systemd/system/ctrl-alt-del.target
    if [ -f "$FILE" ];then
        rm -f "$FILE" && init q
        echo "禁用 ctrl-alt-delete 完成"
    fi

    ENVFILE="/etc/profile.d/env.sh"
    #连接超时时间 TMOUT=900
    #umaks标准 umask 027
    if grep -q TMOUT=900 ${ENVFILE};then
        true
    else
        echo TMOUT=900 >> ${ENVFILE}
    fi
    if grep -q "umask 027" ${ENVFILE};then
        true
    else
        echo "umask 027" >> ${ENVFILE}
    fi

    FILE="/etc/security/limits.conf"
    if grep -q "^\*" "${FILE}";then
        true
    else
        [ -f "${FILE}" ] && cp -av "${FILE}"{,.bak"${DATE}"}
        cat >> "${FILE}" <<- EOF
		* soft nofile 65535
		* hard nofile 65535
		* soft nproc 65535
		* hard nproc 65535
		* soft core unlimited
		* hard core unlimited
		EOF
        source /etc/profile
        #ulimits -a || ulimits -n
    fi

    FILE="/etc/systemd/system.conf"
    if grep -q "^DefaultLimitNPROC" "${FILE}";then
    #grep ^DefaultLimitNOFILE "${FILE}" &> /dev/null
        true
    else
        [ -f "${FILE}" ] && cp -av ${FILE}{,.bak"$DATE"}
        echo "DefaultLimitNOFILE=65535" >> "${FILE}"
        echo "DefaultLimitNPROC=65535" >> "${FILE}"
    fi

    #设置最小密码长度
    #cp -p /etc/login.defs /etc/login.defs.bak
    #sed  -i '/^PASS_MIN_LEN/s/5/12/g' /etc/login.defs

    #设置密码复杂度
    #cp -p /etc/pam.d/system-auth-ac /etc/pam.d/system-auth-ac.bak
    #sed -i 's/.* pam_pwquality.so.*/password    requisite     pam_cracklib.so try_first_pass retry=10 minlen=12 minclass=3 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 type='/g /etc/pam.d/system-auth-ac

    #cp -p /etc/pam.d/password-auth-ac /etc/pam.d/password-auth-ac.bak
    #sed -i 's/.* pam_pwquality.so.*/password    requisite     pam_cracklib.so try_first_pass retry=10 minlen=12 minclass=3 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 type='/g /etc/pam.d/password-auth-ac

    #登录失败10次锁定
    #sed -i '4 a\auth        required      pam_tally2.so onerr=fail deny=10 unlock_time=300' /etc/pam.d/system-auth-ac
    #sed -i '4 a\auth        required      pam_tally2.so onerr=fail deny=10 unlock_time=300' /etc/pam.d/password-auth-ac
    
    #禁止root远程登录
    #sed -i '/^#PermitRootLogin/cPermitRootLogin no' /etc/ssh/sshd_config

    #删除潜在威胁文件
    find / -maxdepth 3 -name hosts.equiv -o -name .netrc -o -name .rhosts
}

#脚本帮助菜单
_help(){
    echo "Usage: bash command [options] [args]"
    echo ""
    echo "Commands are:"
    echo "    参数1：set1 生产主机;set2 生产备机;set3 个性化;set4 虚拟机;set5 安全加固" 
    echo "    网卡调优: bash $0 nic 网卡设备的名称"
    echo "=============================================================================="
    echo ""
    echo "执行命令例如："
    echo "        bash $0 set3"
    echo ""
}

_ssh(){
    cp /etc/ssh/sshd_config{,.bak"${DATE}"}
    sed -i '/GSSAPIAuthentication/s/yes/no/'  /etc/ssh/sshd_config 
    sed -i '/#UseDNS/cUseDNS no'  /etc/ssh/sshd_config
    if sshd -t;then
        systemctl restart sshd
        action "sshd setting success"
    else
        action "sshd conf file error."
    fi
}

_execute(){
case "$1" in
    set1)
        _tunning
        _selinux
        _sysctl
        _grublevel grub1
        ;;
    set2)
        _tunning
        _selinux
        _sysctl
        _grublevel grub3
        ;;
    set3)
        _tunning
        _selinux
        _sysctl
        _env
        _vimrc
        _motd
        _disktunning
        _grublevel grub2
        _ssh
        ;;
    nic)
        _nic "$@"
        ;;
    set4)
        _tunning
        _selinux
        _sysctl
        _grublevel grub3
        _env
        ;;
    scy)
        _securitycheck
        ;;
    net)
        _net
        ;;
    m)
        _m
        ;;
    *)
        _help
    esac
}

#传参
_execute "$@"
