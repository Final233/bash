#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2021-02-22
#FileName：             tomcat_start.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2021 All rights reserved
#********************************************************************

su - tomcat -c "/apps/tomcat/bin/catalina.sh start"
su - tomcat -c "tailf /etc/hosts"
