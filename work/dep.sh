#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-12-31
#FileName：             dep.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************

#建立目录、复制文件、解压文件、复制上场数据、修改配置文件

#MASTER_IP="192.168.10.2"
#BACKUP_IP=""
#ARBITRATION_IP=""

_set(){
APP_DIR="${4/.tar.gz/}"
SSH_PORT="22"
MDSUSER="mdsuser"
OESUSER="oesuser"
    if [ $# -eq 4 ];then
        [ -f "$4" ] && echo is file not exist
        if [ $1 -eq 1 ];then
            NODE=1
            MASTER_IP=$(echo $3)
        elif [ $1 -eq 3 ];then
            NODE=3
            MASTER_IP=$(echo $3 | awk -F, '{print $1}')
            BACKUP_IP=$(echo $3 | awk -F, '{print $2}')
            ARBITRATION_IP=$(echo $3 | awk -F, '{print $3}')
        else
            true
        fi
    elif [ $# -eq 3 ];then
        if [ $1 -eq 1 ];then
            NODE=1
            MASTER_IP=$(echo $3)
        elif [ $1 -eq 3 ];then
            NODE=3
            MASTER_IP=$(echo $3 | awk -F, '{print $1}')
            BACKUP_IP=$(echo $3 | awk -F, '{print $2}')
            ARBITRATION_IP=$(echo $3 | awk -F, '{print $3}')
        else
            true
        fi 
    else
        return
    fi
}

_depmds(){
    if [ $NODE -eq 1 ];then
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "mkdir -p ~/host_01"
        scp -P ${SSH_PORT} ${APP_DIR}.tar.gz ${MDSUSER}@${MASTER_IP}:~
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "tar xf ${APP_DIR}.tar.gz -C ~/host_01/ && rm -f ${APP_DIR}.tar.gz"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "cp -a ~/host_01/${APP_DIR}/sample/data ~/host_01/${APP_DIR}/."

        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "sed -i 's/IP_ADDR_01=127.0.0.1/IP_ADDR_01=${MASTER_IP}/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "sed -i 's/HOST_NUM:=01/HOST_NUM:=01/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "sed -i 's/SET_NUM:=00/SET_NUM:=01/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "sed -i 's/#CALL   \${SET_NRW:=1 1 1}/!CALL   \${SET_NRW:=1 1 1}/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "sed -i 's/!CALL   \${SET_NRW:=3 1 1}/#CALL   \${SET_NRW:=3 1 1}/g' ~/host_01/${APP_DIR}/conf/system.conf"
    elif [ $NODE -eq 3 ];then
        #master
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "mkdir -p ~/host_01"
        scp -P ${SSH_PORT} ${APP_DIR}.tar.gz ${MDSUSER}@${MASTER_IP}:~
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "tar xf ${APP_DIR}.tar.gz -C ~/host_01/ && rm -f ${APP_DIR}.tar.gz"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "cp -a ~/host_01/${APP_DIR}/sample/data ~/host_01/${APP_DIR}/."

        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "sed -i 's/IP_ADDR_01=127.0.0.1/IP_ADDR_01=${MASTER_IP}/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "sed -i 's/HOST_NUM:=01/HOST_NUM:=01/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "sed -i 's/SET_NUM:=00/SET_NUM:=01/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "sed -i 's/!CALL   \${SET_NRW:=1 1 1}/#CALL   \${SET_NRW:=1 1 1}/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "sed -i 's/#!CALL   \${SET_NRW:=3 1 1}/!CALL   \${SET_NRW:=3 1 1}/g' ~/host_01/${APP_DIR}/conf/system.conf"

        #backup
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${BACKUP_IP} "mkdir -p ~/host_02"
        scp -P ${SSH_PORT} ${APP_DIR}.tar.gz ${MDSUSER}@${BACKUP_IP}:~
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${BACKUP_IP} "tar xf ${APP_DIR}.tar.gz -C ~/host_02/ && rm -f ${APP_DIR}.tar.gz"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${BACKUP_IP} "cp -a ~/host_02/${APP_DIR}/sample/data ~/host_02/${APP_DIR}/."

        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${BACKUP_IP} "sed -i 's/IP_ADDR_01=127.0.0.1/IP_ADDR_01=${BACKUP_IP}/g' ~/host_02/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${BACKUP_IP} "sed -i 's/HOST_NUM:=01/HOST_NUM:=02/g' ~/host_02/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${BACKUP_IP} "sed -i 's/SET_NUM:=00/SET_NUM:=01/g' ~/host_02/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${BACKUP_IP} "sed -i 's/!CALL   \${SET_NRW:=1 1 1}/#CALL   \${SET_NRW:=1 1 1}/g' ~/host_02/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${BACKUP_IP} "sed -i 's/#CALL   \${SET_NRW:=3 1 1}/!CALL   \${SET_NRW:=3 1 1}/g' ~/host_02/${APP_DIR}/conf/system.conf"

        #ARBITRATION_IP
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${ARBITRATION_IP} "mkdir -p ~/host_03"
        scp -P ${SSH_PORT} ${APP_DIR}.tar.gz ${MDSUSER}@${ARBITRATION_IP}:~
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${ARBITRATION_IP} "tar xf ${APP_DIR}.tar.gz -C ~/host_03/ && rm -f ${APP_DIR}.tar.gz"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${ARBITRATION_IP} "cp -a ~/host_03/${APP_DIR}/sample/data ~/host_03/${APP_DIR}/."

        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${ARBITRATION_IP} "sed -i 's/IP_ADDR_01=127.0.0.1/IP_ADDR_01=${ARBITRATION_IP}/g' ~/host_03/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${ARBITRATION_IP} "sed -i 's/HOST_NUM:=01/HOST_NUM:=03/g' ~/host_03/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${ARBITRATION_IP} "sed -i 's/SET_NUM:=00/SET_NUM:=01/g' ~/host_03/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${ARBITRATION_IP} "sed -i 's/!CALL   \${SET_NRW:=1 1 1}/#CALL   \${SET_NRW:=1 1 1}/g' ~/host_03/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${ARBITRATION_IP} "sed -i 's/#CALL   \${SET_NRW:=3 1 1}/!CALL   \${SET_NRW:=3 1 1}/g' ~/host_03/${APP_DIR}/conf/system.conf"        
    else
        true
    fi
}

_startmds(){
    [ -f "$4" ] && echo is file not exist && exit
    if [ $NODE -eq 1 ];then
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "cd ~/host_01/${APP_DIR}/bin && ./mds st"
    elif [ $NODE -eq 3 ];then
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "cd ~/host_01/${APP_DIR}/bin && ./mds st"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${BACKUP_IP} "cd ~/host_02/${APP_DIR}/bin && ./mds st"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${ARBITRATION_IP} "cd ~/host_03/${APP_DIR}/bin && ./mds st"
    else
        true
    fi
}

_stopmds(){
    [ -f "$4" ] && echo is file not exist && exit
    if [ $NODE -eq 1 ];then
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "cd ~/host_01/${APP_DIR}/bin && ./mds sp"
    elif [ $NODE -eq 3 ];then
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "cd ~/host_01/${APP_DIR}/bin && ./mds sp"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${BACKUP_IP} "cd ~/host_02/${APP_DIR}/bin && ./mds sp"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${ARBITRATION_IP} "cd ~/host_03/${APP_DIR}/bin && ./mds sp"
    else
        true
    fi
}   

_cleanmds(){
    if [ $NODE -eq 1 ];then
        _stopmds 
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "rm -rf ~/host_01"
    elif [ $NODE -eq 3 ];then
        _stopmds 
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${MASTER_IP} "rm -rf ~/host_01"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${BACKUP_IP} "rm -rf ~/host_02"
        ssh -t -t -p ${SSH_PORT} ${MDSUSER}@${ARBITRATION_IP} "rm -rf ~/host_03"
    else
        true
    fi
}

_depoes(){
    if [ $NODE -eq 1 ];then
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "mkdir -p ~/host_01"
        scp -P ${SSH_PORT} ${APP_DIR}.tar.gz ${OESUSER}@${MASTER_IP}:~
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "tar xf ${APP_DIR}.tar.gz -C ~/host_01/ && rm -f ${APP_DIR}.tar.gz"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "cp -a ~/host_01/${APP_DIR}/sample/data ~/host_01/${APP_DIR}/."

        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i 's/IP_ADDR_01=127.0.0.1/IP_ADDR_01=${MASTER_IP}/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i 's/HOST_NUM:=01/HOST_NUM:=01/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i 's/SET_NUM:=11/SET_NUM:=01/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i 's/#CALL   \${SET_NRW:=1 1 1}/!CALL   \${SET_NRW:=1 1 1}/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i 's/!CALL   \${SET_NRW:=3 1 1}/#CALL   \${SET_NRW:=3 1 1}/g' ~/host_01/${APP_DIR}/conf/system.conf"

        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i 's/#CALL   \${SSE_EZOES_GRP0_ENABLE=true}/!CALL   \${SSE_EZOES_GRP0_ENABLE=true}/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SSE_EZOES_GRP0_PBU=XXX}/!CALL   \${SSE_EZOES_GRP0_PBU=88822}/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SSE_EZOES_GRP0_DB_SERVER=XXX:1433}/!CALL   \${SSE_EZOES_GRP0_DB_SERVER=127.0.0.1:1433}/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SSE_EZOES_GRP0_BAK_SERVER=xxx:1433}/!CALL   \${SSE_EZOES_GRP0_BAK_SERVER=127.0.0.1:1433}/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i 's/#CALL   \${SZSE_TGW_GRP0_ENABLE=true}/!CALL   \${SZSE_TGW_GRP0_ENABLE=true}/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SZSE_TGW_GRP0_PBU=XXX}/!CALL   \${SZSE_TGW_GRP0_PBU=555215,555213}/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SZSE_TGW_GRP0_IP=XXX}/!CALL   \${SZSE_TGW_GRP0_IP=127.1}/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i '/#CALL   \${SZSE_TGW_GRP1_ENABLE=true}/,+9d' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i '/collector.runLevel/s/1/0/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i '/scheduler.runLevel/s/1/0/' ~/host_01/${APP_DIR}/conf/system.conf"

    elif [ $NODE -eq 3 ];then
        #master
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "mkdir -p ~/host_01"
        scp -P ${SSH_PORT} ${APP_DIR}.tar.gz ${OESUSER}@${MASTER_IP}:~
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "tar xf ${APP_DIR}.tar.gz -C ~/host_01/ && rm -f ${APP_DIR}.tar.gz"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "cp -a ~/host_01/${APP_DIR}/sample/data ~/host_01/${APP_DIR}/."

        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i 's/IP_ADDR_01=127.0.0.1/IP_ADDR_01=${MASTER_IP}/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i 's/IP_ADDR_02=127.0.0.1/IP_ADDR_02=${BACKUP_IP}/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i 's/IP_ADDR_03=127.0.0.1/IP_ADDR_03=${ARBITRATION_IP}/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i 's/HOST_NUM:=01/HOST_NUM:=01/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i 's/SET_NUM:=11/SET_NUM:=01/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i 's/!CALL   \${SET_NRW:=1 1 1}/#CALL   \${SET_NRW:=1 1 1}/g' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i 's/#CALL   \${SET_NRW:=3 1 1}/!CALL   \${SET_NRW:=3 1 1}/g' ~/host_01/${APP_DIR}/conf/system.conf"

        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i 's/#CALL   \${SSE_EZOES_GRP0_ENABLE=true}/!CALL   \${SSE_EZOES_GRP0_ENABLE=true}/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SSE_EZOES_GRP0_PBU=XXX}/!CALL   \${SSE_EZOES_GRP0_PBU=88822}/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SSE_EZOES_GRP0_DB_SERVER=XXX:1433}/!CALL   \${SSE_EZOES_GRP0_DB_SERVER=127.0.0.1:1433}/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SSE_EZOES_GRP0_BAK_SERVER=xxx:1433}/!CALL   \${SSE_EZOES_GRP0_BAK_SERVER=127.0.0.1:1433}/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i 's/#CALL   \${SZSE_TGW_GRP0_ENABLE=true}/!CALL   \${SZSE_TGW_GRP0_ENABLE=true}/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SZSE_TGW_GRP0_PBU=XXX}/!CALL   \${SZSE_TGW_GRP0_PBU=555215,555213}/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SZSE_TGW_GRP0_IP=XXX}/!CALL   \${SZSE_TGW_GRP0_IP=127.1}/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i '/#CALL   \${SZSE_TGW_GRP1_ENABLE=true}/,+9d' ~/host_01/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "sed -i '/collector.runLevel/s/1/0/' ~/host_01/${APP_DIR}/conf/system.conf && sed -i '/scheduler.runLevel/s/1/0/' ~/host_01/${APP_DIR}/conf/system.conf"
        
        #backup
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "mkdir -p ~/host_02"
        scp -P ${SSH_PORT} ${APP_DIR}.tar.gz ${OESUSER}@${BACKUP_IP}:~
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "tar xf ${APP_DIR}.tar.gz -C ~/host_02/ && rm -f ${APP_DIR}.tar.gz"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "cp -a ~/host_02/${APP_DIR}/sample/data ~/host_02/${APP_DIR}/."

        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "sed -i 's/IP_ADDR_01=127.0.0.1/IP_ADDR_01=${MASTER_IP}/g' ~/host_02/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "sed -i 's/IP_ADDR_02=127.0.0.1/IP_ADDR_02=${BACKUP_IP}/g' ~/host_02/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "sed -i 's/IP_ADDR_03=127.0.0.1/IP_ADDR_03=${ARBITRATION_IP}/g' ~/host_02/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "sed -i 's/HOST_NUM:=01/HOST_NUM:=02/g' ~/host_02/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "sed -i 's/SET_NUM:=11/SET_NUM:=01/g' ~/host_02/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "sed -i 's/!CALL   \${SET_NRW:=1 1 1}/#CALL   \${SET_NRW:=1 1 1}/g' ~/host_02/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "sed -i 's/#CALL   \${SET_NRW:=3 1 1}/!CALL   \${SET_NRW:=3 1 1}/g' ~/host_02/${APP_DIR}/conf/system.conf"

        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "sed -i 's/#CALL   \${SSE_EZOES_GRP0_ENABLE=true}/!CALL   \${SSE_EZOES_GRP0_ENABLE=true}/' ~/host_02/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SSE_EZOES_GRP0_PBU=XXX}/!CALL   \${SSE_EZOES_GRP0_PBU=88822}/' ~/host_02/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SSE_EZOES_GRP0_DB_SERVER=XXX:1433}/!CALL   \${SSE_EZOES_GRP0_DB_SERVER=127.0.0.1:1433}/' ~/host_02/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SSE_EZOES_GRP0_BAK_SERVER=xxx:1433}/!CALL   \${SSE_EZOES_GRP0_BAK_SERVER=127.0.0.1:1433}/' ~/host_02/${APP_DIR}/conf/system.conf && sed -i 's/#CALL   \${SZSE_TGW_GRP0_ENABLE=true}/!CALL   \${SZSE_TGW_GRP0_ENABLE=true}/' ~/host_02/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SZSE_TGW_GRP0_PBU=XXX}/!CALL   \${SZSE_TGW_GRP0_PBU=555215,555213}/' ~/host_02/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SZSE_TGW_GRP0_IP=XXX}/!CALL   \${SZSE_TGW_GRP0_IP=127.1}/' ~/host_02/${APP_DIR}/conf/system.conf && sed -i '/#CALL   \${SZSE_TGW_GRP1_ENABLE=true}/,+9d' ~/host_02/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "sed -i '/collector.runLevel/s/1/0/' ~/host_02/${APP_DIR}/conf/system.conf && sed -i '/scheduler.runLevel/s/1/0/' ~/host_02/${APP_DIR}/conf/system.conf"

        #ARBITRATION
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "mkdir -p ~/host_03"
        scp -P ${SSH_PORT} ${APP_DIR}.tar.gz ${OESUSER}@${ARBITRATION_IP}:~
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "tar xf ${APP_DIR}.tar.gz -C ~/host_03/ && rm -f ${APP_DIR}.tar.gz"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "cp -a ~/host_03/${APP_DIR}/sample/data ~/host_03/${APP_DIR}/."

        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "sed -i 's/IP_ADDR_01=127.0.0.1/IP_ADDR_01=${MASTER_IP}/g' ~/host_03/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "sed -i 's/IP_ADDR_02=127.0.0.1/IP_ADDR_02=${BACKUP_IP}/g' ~/host_03/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "sed -i 's/IP_ADDR_03=127.0.0.1/IP_ADDR_03=${ARBITRATION_IP}/g' ~/host_03/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "sed -i 's/HOST_NUM:=01/HOST_NUM:=03/g' ~/host_03/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "sed -i 's/SET_NUM:=11/SET_NUM:=01/g' ~/host_03/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "sed -i 's/!CALL   \${SET_NRW:=1 1 1}/#CALL   \${SET_NRW:=1 1 1}/g' ~/host_03/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "sed -i 's/#CALL   \${SET_NRW:=3 1 1}/!CALL   \${SET_NRW:=3 1 1}/g' ~/host_03/${APP_DIR}/conf/system.conf"

        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "sed -i 's/#CALL   \${SSE_EZOES_GRP0_ENABLE=true}/!CALL   \${SSE_EZOES_GRP0_ENABLE=true}/' ~/host_03/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SSE_EZOES_GRP0_PBU=XXX}/!CALL   \${SSE_EZOES_GRP0_PBU=88822}/' ~/host_03/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SSE_EZOES_GRP0_DB_SERVER=XXX:1433}/!CALL   \${SSE_EZOES_GRP0_DB_SERVER=127.0.0.1:1433}/' ~/host_03/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SSE_EZOES_GRP0_BAK_SERVER=xxx:1433}/!CALL   \${SSE_EZOES_GRP0_BAK_SERVER=127.0.0.1:1433}/' ~/host_03/${APP_DIR}/conf/system.conf && sed -i 's/#CALL   \${SZSE_TGW_GRP0_ENABLE=true}/!CALL   \${SZSE_TGW_GRP0_ENABLE=true}/' ~/host_03/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SZSE_TGW_GRP0_PBU=XXX}/!CALL   \${SZSE_TGW_GRP0_PBU=555215,555213}/' ~/host_03/${APP_DIR}/conf/system.conf && sed -i 's/!CALL   \${SZSE_TGW_GRP0_IP=XXX}/!CALL   \${SZSE_TGW_GRP0_IP=127.1}/' ~/host_03/${APP_DIR}/conf/system.conf && sed -i '/#CALL   \${SZSE_TGW_GRP1_ENABLE=true}/,+9d' ~/host_03/${APP_DIR}/conf/system.conf"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "sed -i '/collector.runLevel/s/1/0/' ~/host_03/${APP_DIR}/conf/system.conf && sed -i '/scheduler.runLevel/s/1/0/' ~/host_03/${APP_DIR}/conf/system.conf"
    else
        true
    fi
}

_startoes(){
    [ -f "$4" ] && echo is file not exist && exit
    if [ $NODE -eq 1 ];then
       ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "cd ~/host_01/${APP_DIR}/bin && ./oes st && ./oes open"
    elif [ $NODE -eq 3 ];then
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "cd ~/host_01/${APP_DIR}/bin && ./oes st && ./oes open"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "cd ~/host_02/${APP_DIR}/bin && ./oes st"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "cd ~/host_03/${APP_DIR}/bin && ./oes st"
    else
        true
    fi                                                                                                                                                                           
}

_stopoes(){
    #[ -f "$4" ] && echo is file not exist && exit
    if [ $NODE -eq 1 ];then
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "cd ~/host_01/${APP_DIR}/bin && ./oes sp"
    elif [ $NODE -eq 3 ];then
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "cd ~/host_01/${APP_DIR}/bin && ./oes sp"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "cd ~/host_02/${APP_DIR}/bin && ./oes sp"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "cd ~/host_03/${APP_DIR}/bin && ./oes sp"
    else
        true
    fi
}


_cleanoes(){                                                                                                                                                                     
    if [ $NODE -eq 1 ];then
        _stopoes "$@" 
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "rm -rf ~/host_01"
    elif [ $NODE -eq 3 ];then
        _stopoes "$@"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${MASTER_IP} "rm -rf ~/host_01"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${BACKUP_IP} "rm -rf ~/host_02"
        ssh -t -t -p ${SSH_PORT} ${OESUSER}@${ARBITRATION_IP} "rm -rf ~/host_03"
    else
        true
    fi
}

_help(){
    echo "Usage: bash command [options] [args]"
    echo ""
    echo "Commands are:"
    echo "    参数1 1 / 3" 
    echo "    参数2 mdsdep / mdsstart / mdsstop / mdsclean" 
    echo "    参数2 oesdep / oesstart / oesstop / oesclean" 
    echo "    参数3 192.168.10.2 / 192.168.10.2,192.168.10.3,192.168.10.4" 
    echo "    参数4 mds-0.15.11.10_FullTS-release-20200901.tar.gz " 
    echo ""
    echo "=============================================================================="
    echo ""
    echo "执行命令例如："
    echo "        bash $0 1 mdsdep 192.168.10.2 mds-0.15.11.10_FullTS-release-20200901.tar.gz"
    echo "        bash $0 3 mdsdep 192.168.10.2,192.168.10.3,192.168.10.4 mds-0.15.11.10_FullTS-release-20200901.tar.gz"
    echo ""
}

_isexecute(){
    case "$2" in
        mdsdep|mdsd)
        _depmds
        ;;
        mdsstart|mdsst)
        _startmds
        ;;
        mdsstop|mdssp)
        _stopmds
        ;;
        mdsclean|mdscl)
        _cleanmds
        ;;
        oesdep|oesd)
        _depoes
        ;;
        oesstart|oesst)
        _startoes
        ;;
        oesstop|oessp)
        _stopoes
        ;;
        oesclean|oescl)
        _cleanoes
        ;;
        *)
        _help
    esac
}

_set "$@"
_isexecute "$@"

