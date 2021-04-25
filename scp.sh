#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2021-03-11
#FileName：             scp.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2021 All rights reserved
#********************************************************************

for i in {81..84};do
    sshpass -p 1 ssh-copy-id -o StrictHostKeyChecking=no root@192.168.10.$i
done
