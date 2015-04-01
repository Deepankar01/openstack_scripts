#!/bin/bash
#--------Script for Installing the Prequisits for Installing Openstack-------
#--------The Script has to run on every node------------
# required.sh (mysql-password,rabbitmq_password,mysql_ip)

#to get the script location
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
export mysql_password=$1
rabbitmq_password=$2
mysql_ip=$3

#clean up the logs folder
rm -r $SCRIPTPATH/logs/*


#using MySQL as a Database Server
echo "---------------MySQL Installation----------------" >> "$SCRIPTPATH/logs/required_log.txt"
date >> "$SCRIPTPATH/logs/required_log.txt"
echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
#adding the passowrd before installation beacuse mysql asks for password on prompt
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password $mysql_password'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $mysql_password'
#installing MySQL
if (apt-get -y install mysql-server python-mysqldb >> "$SCRIPTPATH/logs/required_log.txt") then
	echo "MySQLInstall.Success" >> "$SCRIPTPATH/logs/required.txt"
	#Configuring the MySQL conf file /etc/mysql/my.cnf
 	echo "---------------Configuring Mysql----------------" >> "$SCRIPTPATH/logs/required_log.txt"
	date >> "$SCRIPTPATH/logs/required_log.txt"
	echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
	echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
else
	echo "MySQLInstall.Fail" >> "$SCRIPTPATH/logs/required.txt"
	exit 1
fi


#using RabbitMQ as a Messaging Server
echo "---------------RabbitMQ Server Installation----------------" >> "$SCRIPTPATH/logs/required_log.txt"
date >> "$SCRIPTPATH/logs/required_log.txt"
echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
if (apt-get -y install rabbitmq-server >> "$SCRIPTPATH/logs/required_log.txt") then
	echo "RabbitInstall.Success" >> "$SCRIPTPATH/logs/required.txt"
	echo "---------------Configuring RabbitMQ-Server----------------" >> "$SCRIPTPATH/logs/required_log.txt"
        date >> "$SCRIPTPATH/logs/required_log.txt"
        echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
        echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
	if(rabbitmqctl change_password guest $rabbitmq_password >> "$SCRIPTPATH/logs/required_log.txt") then
		echo "RabbitConfig.Success" >> "$SCRIPTPATH/logs/required.txt"
	else
		echo "RabbitConfig.Fail" >> "$SCRIPTPATH/logs/required.txt"
        	exit 1
	fi
else
	echo "RabbitInstall.Fail" >> "$SCRIPTPATH/logs/required.txt"
	exit 1
fi
