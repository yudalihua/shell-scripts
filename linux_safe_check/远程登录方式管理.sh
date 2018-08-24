#远程登录管理时使用安全的SSH协议，而不使用明文传输的Telnet协议
a1=`chkconfig --list | grep telnet`
chkconfig --list | grep sshd | awk '{print $5,$7}' | grep "on" >/dev/null 2>&1
if [ $? -eq -0 -a -z "${a1}" ];then
	echo "合规"
else
	echo "$a1 or  not off or sshd is not open"
fi