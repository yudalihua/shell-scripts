#!/bin/bash

#necessities for building mysql master-slave cluster.
    #the /etc/hosts file of each node should have the hostname and ip map of the other.
    #close iptables and selinux.
    #confirm that the master node has grant remote connection of slave node.
    #confirm present user has the right to write the my.cnf.
    #confirm present user has the right to write the directory of /etc.because if sed modify a file ,it will first create a temporary file in the directory.
#list of configuration parameters

#问题在于加上了这个读取文件的内容，虽然也会给变量正确赋值，但是后边对比的时候就对比不成功了？？？
config_file="`dirname $0`/cluster.cfg"
[ -f $config_file ] || { echo "The config file <$config_file> doesn't exists!"; exit 1; }
master_hostname=`cat $config_file|grep -v "^#"|grep -w "master_hostname"|awk -F= '{print$2}'`
slave_hostname=`cat $config_file|grep -v "^#"|grep -w "slave_hostname"|awk -F= '{print$2}'`
master_grant_username=`cat $config_file|grep -v "^#"|grep -w "master_grant_username"|awk -F= '{print$2}'`
master_grant_password=`cat $config_file|grep -v "^#"|grep -w "master_grant_password"|awk -F= '{print$2}'`
master_mysql_connect_username=`cat $config_file|grep -v "^#"|grep -w "master_mysql_connect_username"|awk -F= '{print$2}'`
master_mysql_connect_password=`cat $config_file|grep -v "^#"|grep -w "master_mysql_connect_password"|awk -F= '{print$2}'`
slave_mysql_connect_password=`cat $config_file|grep -v "^#"|grep -w "slave_mysql_connect_password"|awk -F= '{print$2}'`
slave_mysql_connect_username=`cat $config_file|grep -v "^#"|grep -w "slave_mysql_connect_username"|awk -F= '{print$2}'`
master_mysql_remote_connect_username=`cat $config_file|grep -v "^#"|grep -w "master_mysql_remote_connect_username"|awk -F= '{print$2}'`
master_mysql_remote_connect_password=`cat $config_file|grep -v "^#"|grep -w "master_mysql_remote_connect_password"|awk -F= '{print$2}'`




#list of global variables
current_hostname=`hostname`
mysql_bin_dir=`locate -r mysqladmin$| xargs -i dirname {}`
mysql_account=`ls -l $mysql_bin_dir|awk 'NR==2{print $3}'`
mysql_base_dir=`dirname $mysql_bin_dir`
present_user=`whoami`  
#export global variables
export current_hostname
export mysql_bin_dir
export mysql_base_dir
export mysql_account
export present_user


#check whether selinux has been disabled
selinux_status=`getenforce`
if [ "$selinux_status" != "Disabled" ]
then
    echo "please shutdown the selinux"
    exit -1
fi

#check whether the iptables has been forbidden.
level3=`chkconfig --list iptables|awk '{print $5}'|awk  -F: '{print $2}'`
level5=`chkconfig --list iptables|awk '{print $7}'|awk  -F: '{print $2}'`
if [ "$level3" == "on" ] || [ "$level5" == "on" ]
then
    echo "iptables is not forbidden"
    exit -1  
fi 

#check the /etc/hosts file,and determine the ip of the other node from the /etc/hosts.
if [ "$current_hostname" == "$master_hostname" ]
then
    cat /etc/hosts|grep "$slave_hostname">/dev/null
    if [ $? -eq 1 ]
    then
        echo "cann't find the slave_hostname in /etc/hosts"
        exit 1
    else
        slave_ip=`cat /etc/hosts|grep "$slave_hostname"|awk '{print $1}'`
    fi

elif  [ "$current_hostname" == "$slave_hostname" ]
then
    cat /etc/hosts|grep "$master_hostname">/dev/null
    if [ $? -eq 1 ]
    then
        echo "cann't find the master_hostname in /etc/hosts"
        exit 1
    else
        master_ip=`cat /etc/hosts|grep "$master_hostname"|awk '{print $1}'`
    fi
fi

#check the account who is starting mysql,and restart mysql.only the owner of mysql or root can restart the mysql
function restart_mysql {
	cd "`locate -r mysqladmin$| xargs -i dirname {}`"
    if [ "$mysql_account" == $present_user ]
    then
        if [ -f $mysql_base_dir/mysqld ]
        then
            cd $mysql_base_dir
            ./mysqld restart &>/dev/null
        elif [ -f $mysql_base_dir/support-files/mysql.server ]
        then

            cd $mysql_base_dir/support-files
            ./mysql.server restart &>/dev/null
        else
            echo "can't find the start file of mysql"
            exit 1
        fi
    elif [ "$present_user" == "root" ]
    then
        if [ -f $mysql_base_dir/mysqld ]
        then
            cd $mysql_base_dir
            ./mysqld restart &>/dev/null
        elif [ -f $mysql_base_dir/support-files/mysql.server ]
        then
            cd $mysql_base_dir/support-files
           sudo -u $mysql_account ./mysql.server restart &>/dev/null
        fi
    else
        echo "you have no right to restart mysql"
        exit -1
    fi
    ps aux|grep mysql|grep -v grep

    if [ $? -eq 1 ]
    then   
    echo "you haven't installed mysql or something wrong ,can't restart mysql!"
    exit 1
    fi
}
restart_mysql &>/dev/null 

#connect mysql


#check whether username or password is a must to connect mysql, and test whether can ping through mysql
cd "`locate -r mysqladmin$| xargs -i dirname {}`"
./mysqladmin ping 2>/dev/null |grep alive &>/dev/null
if [ $? -eq 0 ]
then 
    ./mysqladmin ping 2>/dev/null |grep alive &>/dev/null
    exit_code=$?
    if [ "$exit_code" != "0" ]
    then
        echo "can't ping through the mysql,please check the configuration"
        exit -1
    fi
else
    if [ "$current_hostname" == "$master_hostname" ]
    then
        ./mysqladmin -u$master_mysql_connect_username -p$master_mysql_connect_password ping 2>/dev/null |grep alive &>/dev/null
        exit_code=$?
        if [ "$exit_code" != "0" ]
        then
            echo "can't ping through the mysql,please check the configuration"
            exit -1
        fi  


    elif  [ "$current_hostname" == "$slave_hostname" ]
    then    
        ./mysqladmin -u$slave_mysql_connect_username -p$slave_mysql_connect_password ping 2>/dev/null |grep alive &>/dev/null
        exit_code=$?
        if [ "$exit_code" != "0" ]
        then
            echo "can't ping through the mysql,please check the configuration"
            exit -1
        fi  
    fi
     
fi

#the configure_mysql_master function 
function configure_mysql_master {
   #because some items has been commented by #,so we have to exclude these rows by grep -v "\#".for example server-id
   cat /etc/my.cnf|grep -v "\#"|grep -E '(\s)*log[_-]bin(\s)*' &>/dev/null
    code1=$?
    if [ $code1 -eq 0 ]
    then
        sed  -ir 's/(\s)*log[_-]bin(\s)*=.*/log_bin=mysql_bin/' /etc/my.cnf
    else
        sed -i '/\[mysqld\]/a\log_bin=mysql_bin' /etc/my.cnf
    fi

    cat /etc/my.cnf|grep -v "\#"|grep -E '(\s)*innodb_file_per_table(\s)*' &>/dev/null
    code2=$?
    if [ $code2 -eq 0 ]
    then
        sed  -ir 's/(\s)*innodb_file_per_table(\s)*=.*/innodb_file_per_table=ON/' /etc/my.cnf
    else
        sed -i '/\[mysqld\]/a\innodb_file_per_table=ON' /etc/my.cnf
    fi

     cat /etc/my.cnf|grep -v "\#"|grep -E '(\s)*skip_name_resolve(\s)*' &>/dev/null
    code3=$?
    if [ $code3 -eq 0 ]
    then
        sed  -ir 's/(\s)*skip_name_resolve(\s)*=.*/skip_name_resolve=ON/' /etc/my.cnf
    else

        sed -i '/\[mysqld\]/a\skip_name_resolve=ON' /etc/my.cnf
    fi

    cat /etc/my.cnf|grep -v "\#" |grep -E '(\s)*server[_-]id(\s)*' &>/dev/null
    code4=$?
    if [ $code4 -eq 0 ]
    then

        awk -F= '$1~/server[_-]id/{i++;if(i<2){$1="";$2="server_id=1";}else{exit}}1' /etc/my.cnf 1<>/etc/my.cnf
    
    else

        sed -i '/\[mysqld\]/a\server_id = 1' /etc/my.cnf
    fi

 }

#import the configuration information to the my.cnf file according to separate hostname.

#configure_mysql_slave function 
function configure_mysql_slave {
    cat /etc/my.cnf|grep -E '(\s)*relay-log(\s)*' &>/dev/null
    code1=$?
    if [ $code1 -eq 0 ]
    then
        sed  -ir 's/(\s)*relay-log(\s)*=.*/relay-log=relay-log/' /etc/my.cnf
    else
        sed -i '/\[mysqld\]/a\relay-log=relay-log' /etc/my.cnf
    fi

    cat /etc/my.cnf|grep -E '(\s)*relay-log-index(\s)*' &>/dev/null
    code2=$?
    if [ $code2 -eq 0 ]
    then
        sed  -ir 's/(\s)*relay-log-index(\s)*=.*/relay-log-index=relay-log.index/' /etc/my.cnf
    else
        sed -i '/\[mysqld\]/a\relay-log-index=relay-log.index' /etc/my.cnf
    fi

    cat /etc/my.cnf|grep -E '(\s)*skip_name_resolve(\s)*' &>/dev/null
    code3=$?
    if [ $code3 -eq 0 ]
    then
        sed  -ir 's/(\s)*skip_name_resolve(\s)*=.*/skip_name_resolve=ON/' /etc/my.cnf
    else
        sed -i '/\[mysqld\]/a\skip_name_resolve=ON' /etc/my.cnf
    fi

    cat /etc/my.cnf|grep -v "\#" |grep -E '(\s)*server[_-]id(\s)*' &>/dev/null
    code4=$?
    if [ $code4 -eq 0 ]
    then

        awk -F= '$1~/server[_-]id/{i++;if(i<2){$1="";$2="server_id=2";}else{exit}}1' /etc/my.cnf 1<>/etc/my.cnf
   
    else

        sed -i '/\[mysqld\]/a\server_id = 2' /etc/my.cnf
    fi

    cat /etc/my.cnf|grep -E '(\s)*innodb_file_per_table(\s)*' &>/dev/null
    code5=$?
    if [ $code5 -eq 0 ]
    then
        sed  -ir 's/(\s)*innodb_file_per_table(\s)*=.*/innodb_file_per_table=ON/' /etc/my.cnf
    else
        sed -i '/\[mysqld\]/a\innodb_file_per_table=ON' /etc/my.cnf

    fi

 }
#splitsplit
if [ "$current_hostname" == "$master_hostname" ]
then
    #check whether /etc/my.cnf of master node has been defined these fields,if not ,append these fields and values to right place.
   
    configure_mysql_master
    restart_mysql &>/dev/null
    slave_ip=`cat /etc/hosts|grep "$slave_hostname"|awk '{print $1}'`

    cd "`locate -r mysqladmin$| xargs -i dirname {}`"
    slave_ip=`cat /etc/hosts|grep "$slave_hostname"|awk '{print $1}'`
    ./mysqladmin ping 2>/dev/null |grep alive &>/dev/null
    if [ $? -eq 0 ]
    
    then 
        ./mysql << EOF &>/dev/null
        GRANT REPLICATION SLAVE ON *.* TO '$master_grant_username'@'$slave_ip' IDENTIFIED BY 'master_grant_password';
        GRANT ALL PRIVILEGES ON *.* TO '$master_mysql_remote_connect_username'@'$slave_ip' IDENTIFIED BY  '$master_mysql_remote_connect_password';
        FLUSH PRIVILEGES;
        exit;
EOF

    else
        ./mysql -u$master_mysql_connect_username -p$master_mysql_connect_password << EOF &>/dev/null
        GRANT REPLICATION SLAVE ON *.* TO '$master_grant_username'@'$slave_ip' IDENTIFIED BY 'master_grant_password';
        GRANT ALL PRIVILEGES ON *.* TO '$master_mysql_remote_connect_username'@'$slave_ip' IDENTIFIED BY  '$master_mysql_remote_connect_password';
        FLUSH PRIVILEGES;
        exit;
EOF
    fi

elif  [ "$current_hostname" == "$slave_hostname" ]
then
    #check whether /etc/my.cnf of slave node has been defined these fields,if not ,append these fields and values to right place.
    configure_mysql_slave       
    restart_mysql &>/dev/null
    master_ip=`cat /etc/hosts|grep "$master_hostname"|awk '{print $1}'`   
    cd "`locate -r mysqladmin$| xargs -i dirname {}`"
    sleep 5
    ./mysqladmin ping 2>/dev/null |grep alive &>/dev/null
    if [ $? -eq 0 ]
    then 
        var=`./mysql -h $master_ip -u$master_mysql_remote_connect_username -p$master_mysql_remote_connect_password <<EOF 
        show master status;
EOF
`
        log_pos=`echo $var|awk '{print $NF}'`
        log_file=`echo $var|awk '{print $(NF-1)}'`
        ./mysql << EOF &>/dev/null
        stop slave;
        reset slave all;
        CHANGE MASTER TO MASTER_HOST='$master_ip', MASTER_USER='$master_grant_username', MASTER_PASSWORD='$master_grant_password', MASTER_LOG_FILE='$log_file', MASTER_LOG_POS=$log_pos;
        start slave;
        exit;
EOF

    else
        var=`./mysql -h $master_ip -u$master_mysql_remote_connect_username -p$master_mysql_remote_connect_password <<EOF 
        show master status;
EOF
`        log_pos=`echo $var|awk '{print $NF}'`
        log_file=`echo $var|awk '{print $(NF-1)}'`
        ./mysql -u$slave_mysql_connect_username -p$slave_mysql_connect_password << EOF &>/dev/null
        stop slave;
        reset slave all;
        CHANGE MASTER TO MASTER_HOST='$master_ip', MASTER_USER='$master_grant_username', MASTER_PASSWORD='$master_grant_password', MASTER_LOG_FILE='$log_file', MASTER_LOG_POS=$log_pos;
        start slave;
        
EOF
    
    fi

fi
echo "finished"


#如果不能实现主从节点的原因是server_id冲突，需要把除了/etc/my.cnf外的所有my.cnf删除。
#把两个节点分别都当做主节点和从节点执行一次，就实现了双主复制。可能配置文件中少了一些参数。