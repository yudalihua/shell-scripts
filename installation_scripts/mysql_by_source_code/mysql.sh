#!/bin/bash
#remove all the old mysql-relative softwares.
list=`rpm -qa|grep mysql`
for i in $list
do
        rpm -e $i --nodeps >/dev/null
done
#install dependencies of mysql
yum -y install make gcc-c++ cmake bison-devel ncurses-devel &>/dev/null

#if the group of mysql doesn't exist,create it.
cat /etc/group|grep mysql|awk -F: '{print $1}'|grep -E '^mysql$'>/dev/null
if [ $? -eq 0 ]
then
	echo
else
	groupadd mysql
fi
#if mysql exists,delete it,and create a new mysql user.
cat /etc/passwd|grep mysql|awk -F: '{print $1}'|grep -E '^mysql$'>/dev/null
if [ $? -eq 0 ]
then
        useradd -g mysql -M -s /sbin/nologin mysqltest007 &>/dev/null
        userdel mysql &>/dev/null
        useradd -g mysql -M -s /sbin/nologin mysql &>/dev/null
        userdel mysqltest007
        rm -rf /var/spool/mysqltest007
else
         useradd -g mysql -M -s /sbin/nologin mysql &>/dev/null
         echo
fi
mkdir -p /usr/local/mysql
cd /usr/local/mysql
tar -xvzf mysql-5.6.29.tar.gz
mv mysql-5.6.29 mysql
rm -rf mysql-5.6.29.tar.gz
cd /usr/local/mysql/mysql
 cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/data/mysql/data -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=/var/lib/mysql/mysql.sock -DMYSQL_TCP_PORT=3306 -DENABLED_LOCAL_INFILE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci 
make 
make install 
if [ -d /data/mysql/data ];then
        echo
else
        mkdir -p /data/mysql/data
fi
./scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/data/mysql/data --user=mysql
cp support-files/mysql.server /etc/init.d/mysql
chkconfig mysql on
service mysql start

