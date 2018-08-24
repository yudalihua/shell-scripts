#.建议限制root用户远程登录，如果远程执行管理员权限操作
#!/bin/bash
a1=no
Prohibit_remote=`cat /etc/ssh/sshd_config | grep PermitRootLogin | head -n 1  | awk '{print $2}'`
if [ "$Prohibit_remote" == "$a1" ];then
	echo "已禁用root远程登录，合规"
else
	echo "PermitRootLogin $Prohibit_remote"",未禁用root远程登录，不合规"
fi
