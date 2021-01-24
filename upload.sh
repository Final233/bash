#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-05-21
#FileName：             up.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************

DATE=$(date +%F-%T)
rm -f bak-*.tar.gz
git add -f ./*
git commit -m "$DATE"
git push && echo 上传成功
DATE=$(date +%Y%m%d)
tar zcf bak-${DATE}.tar.gz * && echo 备份完成
