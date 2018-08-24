#系统中不能存在空口令账户,返回值如果显示账户，即为空口令的账户，表明不符合安全要求
accunt_null=`awk -F: '($2 == "") { print $1 }' /etc/shadow`
if [ -z ${accunt_null} ];then
	echo "合规"
else
	echo "$accunt_null"
fi
