#!/bin/bash
# install.sh (mysql_password,keystone_password)
#---Script for Downloading and Installing Keystone
#--script that installs  keystone frm the debian packages and keyring for Juno
#to get the script location
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
mysql_password=$1
keystone_password=$2

#clean up the logs
rm -r -f $SCRIPTPATH/logs/*

#creating database and privillages
echo "---------------Creating the database and adding privillages----------------" >> $
date >> "$SCRIPTPATH/logs/install_log.txt"
echo -e "\n \n" >> "$SCRIPTPATH/logs/install_log.txt"

#main commands 
if(mysql -u root -p$mysql_password -e "CREATE DATABASE keystone" >> "$SCRIPTPATH/logs/install_log.txt") then
	echo "table.Success" >> "$SCRIPTPATH/logs/install.txt"
	if(mysql -u root -p$mysql_password -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$keystone_password' " >>  "$SCRIPTPATH/logs/install_log.txt") then
		echo "Privillage1.Success" >> "$SCRIPTPATH/logs/install.txt"
		if (mysql -u root -p$mysql_password -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$keystone_password'" >> "$SCRIPTPATH/logs/install_log.txt") then
			echo "Privillage2.Success" >> "$SCRIPTPATH/logs/install.txt"
		else
			echo "Privillage2.Fail" >> "$SCRIPTPATH/logs/install.txt"
			exit 1
		fi
	else
		echo "Privillage1.Fail" >> "$SCRIPTPATH/logs/install.txt"
		exit 1
	fi

else
	echo "table.Fail" >> "$SCRIPTPATH/logs/install.txt"
	exit 1
fi

#installing keystone
echo "---------------Keystone installation----------------" >> "$SCRIPTPATH/logs/install_log.txt"
date >> "$SCRIPTPATH/logs/install_log.txt"
echo -e "\n \n" >> "$SCRIPTPATH/logs/install_log.txt"

#downloading and installing the packages
if (apt-get install keystone python-keystoneclient >> "$SCRIPTPATH/logs/install_log.txt") then
	echo "Keystone.Success" >> "$SCRIPTPATH/logs/install.txt"
else
	echo "Keystone.Fail" >> "$SCRIPTPATH/logs/install.txt"
fi

#done  installing

