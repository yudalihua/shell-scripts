#设置口令更改最小间隔天数，防止口令频繁更改，推荐值为1-6天,返回值如果为0，表明不符合安全要求
passwd_Interval_days=`cat /etc/login.defs | grep ^PASS_MIN_DAYS  | awk '{print $2}'`
if [ "$passwd_Interval_days" != 0 ];then
	echo "合规"
else
	echo "未设置,不合规"
fi
