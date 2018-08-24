#查看是否开启系统日志审核功能，如果开启则显示合规。
service auditd status >/dev/null
value=`echo $?`
if [ "$value" == "0" ]
then
        echo "系统日志审核功能已开启，合规" 
elif [ "$value" == "3" ]
then
        echo "系统日志审核功能已关闭，不合规" 
fi
