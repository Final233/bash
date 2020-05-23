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
DATE=`date +%F-%T`
rm -f bak-*.tar.gz
git add ./*
git commit -m "$DATE"
git push && echo 上传成功
tar zcf bak-${DATA}.tar.gz * && echo 备份完成
