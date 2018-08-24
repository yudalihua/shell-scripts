#!/bin/bash
level3=`chkconfig --list|grep cups|awk '{print $5}'|awk  -F: '{print $2}'`
level5=`chkconfig --list|grep cups|awk '{print $5}'|awk  -F: '{print $2}'`
if [ "$level3" == "" ] && [ "$level5" == "" ]
then
        echo "未安装cups服务"
else
        if [ "$level3" == "off" ] && [ "$level5" == "off" ]
        then
                echo "cups被禁用，合规"
        else
                echo "cups未被禁用，不合规"
        fi
fi
