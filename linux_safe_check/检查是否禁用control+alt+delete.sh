#检查是否禁用control+alt-delete，如果没有禁用，则显示不合规。
check=`cat /etc/init/control-alt-delete.conf |grep -E '^start on control-alt-delete'`
if [ "$check" != "start on control-alt-delete" ]
then
        echo "已禁用，合规"
else
        echo "未禁止control-alt-delete，不合规" 
fi
