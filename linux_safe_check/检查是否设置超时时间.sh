#检查系统是否设置了超时自动退出，如果设置了，显示合规及超时时间。如果未设置，返回不合规。
#!/bin/bash
check=`cat /etc/profile|grep -E '(\s)*export(\s)*TMOUT=[0-9]+'`
delay=`cat /etc/profile|grep -E '(\s)*export(\s)*TMOUT=[0-9]+'|awk '{print $2}'|awk -F"=" '{print $2}'`
if [ "$check"  == "" ]
then
        echo "未设超时时间，不合规"
else
        echo "合规，超时时间为""$delay"
fi
