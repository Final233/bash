#!/usr/bin/env bash
#
#********************************************************************
#Author:                Final
#QQ:                    438803792
#Date:                  2020-05-18
#FileName：             select.sh
#URL:                   http://cnblogs.com/fina
#Description：          The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************
PS3="please menu 1-7: "
select menu in pre install conf start backup stop uninstall;do
    case $menu in
    pre)
        echo $menu is pre
        ;;
    install)
        echo $menu is install
        ;;
    conf)
        echo $menu is conf
        ;;
    start)
        echo $menu is start
        ;;
    backup)
        echo $menu is backup
        ;;
    stop)
        echo $menu is stop
        ;;
    uninstall)
        echo $menu is uninstall
        ;;
    *)
        break
    esac
done
