#检查是否为grub加密，如果加过密，则合规。
check=`cat /boot/grub/grub.conf |grep -E 'password --md5.*'`
if [ "$check" != "" ]
then
        echo "合规"
else
        echo "未加密，不合规" 
fi
