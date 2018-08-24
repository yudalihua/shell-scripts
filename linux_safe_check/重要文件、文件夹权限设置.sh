#重要文件权限安全基线要求项,返回值的权限如果大于安全基线要求中的权限，表明不符合安全要求
flag=7
a1=644
a2=0
a3=644
a4=644
a5=755
a6=755
a7=755

log1=`stat -c %a /etc/passwd`
if [ "$log1" != "$a1" ];then
        echo "/etc/passwd $log1"
        let flag=$flag-1
fi

log2=`stat -c %a /etc/shadow`
if [ "$log2" != "$a2" ];then
        echo "/etc/shadow $log2"
        let flag=$flag-1
fi

log3=`stat -c %a /etc/group`
if [ "$log3" != "$a3" ];then
        echo "/etc/group $log3"
        let flag=$flag-1
fi

log4=`stat -c %a /etc/services `
if [ "$log4" != "$a4" ];then
        echo "/etc/services $log4"
        let flag=$flag-1
fi

log5=`stat -c %a /etc`
if [ "$log5" != "$a5" ];then
        echo "/etc $log5"
        let flag=$flag-1
fi

log6=`stat -c %a /etc/security`
if [ "$log6" != "$a6" ];then
        echo "/etc/security $log6"
        let flag=$flag-1
fi

log7=`stat -c %a /etc/rc.d`
if [ "$log7" != "$a7" ];then
        echo "/etc/rc.d $log7"
        let flag=$flag-1
fi


if [ $flag -eq 7 ]
then
    echo "合规"
fi