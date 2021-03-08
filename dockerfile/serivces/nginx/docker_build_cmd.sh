#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2021-02-22
#FileName：             docker_build_cmd.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2021 All rights reserved
#********************************************************************

DATE=$(date +%Y%m%d)
DOCKER_IMAGE_NAME="harbor.final.com/final/nginx_base:v1.16.1_$DATE"
docker build -t $DOCKER_IMAGE_NAME .
sleep 1
docker push $DOCKER_IMAGE_NAME
