#rhosts，.netrc等文件都具有潜在的危险，建议删除或更名,返回值如果显示.rhosts或.netrc的路径，则文件存在，表明不符合安全要求
a1=`find / -name .rhosts`
a2=`find / -name .netrc`
if [ -z "$a1" -a -z "$a2" ]
then 
	echo "未发现潜在危险文件，合规"
else
	echo "发现潜在危险文件""$a1 and $a2"
fi
