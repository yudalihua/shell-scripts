#系统在口令过期前多少天发出修改口令的警告信息给用户，推荐值为15天,返回值如果小于15，表明不符合安全要求
passwd_warning=`cat /etc/login.defs | grep ^PASS_WARN_AGE | awk '{print $2}'`
if [ "$passwd_warning" -ge 15  ];then
	echo "合规"
else
	echo "$passwd_warning""天"
fi