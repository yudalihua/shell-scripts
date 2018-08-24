#！/bin/bash
passwd_days=`cat /etc/login.defs | grep ^PASS_MAX_DAYS | awk '{print $2}'`
if [ "$passwd_days" -gt 90 ];then
	echo "未设置口令最长期限，不合规"
else
	echo "合规，账户口令最长生存期:""$passwd_days""天"
fi
