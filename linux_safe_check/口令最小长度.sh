#口令最小长度不少于6个字符,返回值如果小于6，表明不符合安全要求
passwd_length=`cat /etc/login.defs | grep ^PASS_MIN_LEN | awk '{print $2}'`
if [ "$passwd_length" -ge 6 ];then
	echo "合规"
else
	echo "口令最小长度为""$passwd_length"",不合规"
fi