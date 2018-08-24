#检查是否有磁盘空间大于等于80%
space=`df -h|awk -F "[ %]+" 'NR!=1{print $5}'`
flag=0
for i in $space
do
        if [ $i -ge 80 ]
        then
                flag=$[$flag+1]
        fi
done
if [ $flag -gt 0 ]
then
        echo "磁盘容量超过80%，不合规"
else
        echo "合规"
fi
