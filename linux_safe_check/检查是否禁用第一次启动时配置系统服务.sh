#查看是否禁用了firstboot，如果禁用了显示合规，未禁用显示不合规。，如果禁用了显示合规，未禁用显示不合规。
level3=`chkconfig --list|grep firstboot|awk '{print $5}'|awk  -F: '{print $2}'`
level5=`chkconfig --list|grep firstboot|awk '{print $5}'|awk  -F: '{print $2}'`
if [ "$level3" == "" ] && [ "$level5" == "" ]
then
        echo "未安装firstboot服务"
else
        if [ "$level3" == "off" ] && [ "$level5" == "off" ]
        then
                echo "firstboot被禁用，合规"
        else
                echo "firstboot未被禁用，不合规"
        fi
fi
