#!/bin/bash
#-----install.sh(mysql_password,keystone_password,controller_ip)
#-----Script for Downloading and Installing Keystone
#-----Script that installs  keystone from the debian packages

#to get the script location
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

#parameters
MYSQL_PASSWORD=$1
KEYSTONE_PASSWORD=$2
CONTROLLER_IP=$3

#variables
ADMIN_TOKEN=$(openssl rand -hex 10)
KEYSTONE_PROVIDER="keystone.token.providers.uuid.Provider"
KEYSTONE_DRIVER="keystone.token.persistence.backends.sql.Token"
KEYSTONE_REVOKE_DRIVER="keystone.contrib.revoke.backends.sql.Revoke"
VERBOSE_STATUS="true"
KEYSTONE_CONF="/etc/keystone/keystone.conf"


#clean up the logs
rm -f $SCRIPTPATH/logs/install*

#creating database and privillages
echo "---------------Creating the database and adding privillages----------------" >> "$SCRIPTPATH/logs/install_log.txt"
date >> "$SCRIPTPATH/logs/install_log.txt"
echo -e "\n \n" >> "$SCRIPTPATH/logs/install_log.txt"

#main commands
if(mysql -u root -p$MYSQL_PASSWORD -e "CREATE DATABASE keystone" >> "$SCRIPTPATH/logs/install_log.txt") then
	echo "table.Success" >> "$SCRIPTPATH/logs/install.txt"
	if(mysql -u root -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$KEYSTONE_PASSWORD' " >>  "$SCRIPTPATH/logs/install_log.txt") then
		echo "Privillage1.Success" >> "$SCRIPTPATH/logs/install.txt"
		if (mysql -u root -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$KEYSTONE_PASSWORD'" >> "$SCRIPTPATH/logs/install_log.txt") then
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
if (apt-get -y install keystone python-keystoneclient >> "$SCRIPTPATH/logs/install_log.txt") then
	echo "Keystone.Success" >> "$SCRIPTPATH/logs/install.txt"
else
	echo "Keystone.Fail" >> "$SCRIPTPATH/logs/install.txt"
fi
#done  installing


#configure /etc/keystone/keystone.conf
sed -i.old 's/#admin_token=ADMIN/admin_token='"$ADMIN_TOKEN"'/' "$KEYSTONE_CONF"
sed -i.old 's/connection=sqlite:\/\/\/\/var\/lib\/keystone\/keystone.db/connection=mysql:\/\/keystone:'"$KEYSTONE_PASSWORD"'@'"$CONTROLLER_IP"'\/keystone/' "$KEYSTONE_CONF"
sed -i.old 's/#provider=<None>/provider='"$KEYSTONE_PROVIDER"'/' "$KEYSTONE_CONF"
sed -i.old 's/#driver=keystone.token.persistence.backends.sql.Token/driver='"$KEYSTONE_DRIVER"'/' "$KEYSTONE_CONF"
sed -i.old 's/#verbose=false/verbose='"$VERBOSE_STATUS"'/' "$KEYSTONE_CONF"
sed -i.old 's/#driver=keystone.contrib.revoke.backends.kvs.Revoke/driver='"$KEYSTONE_REVOKE_DRIVER"'/' "$KEYSTONE_CONF"
#configuring the keystone.conf complete

echo "---------------Keystone Syncing with DB----------------" >> "$SCRIPTPATH/logs/install_log.txt"
date >> "$SCRIPTPATH/logs/install_log.txt"
echo -e "\n \n" >> "$SCRIPTPATH/logs/install_log.txt"
if ( su -s /bin/sh -c "keystone-manage db_sync" keystone >> "$SCRIPTPATH/logs/install_log.txt") then
	echo "KeystoneSync.Success" >> "$SCRIPTPATH/logs/install.txt"
else
	echo "KeystoneSync.Fail" >> "$SCRIPTPATH/logs/install.txt"
	exit 1
fi

if( service keystone restart >> "$SCRIPTPATH/logs/install_log.txt" ) then
	echo "KeystoneRestart.Success" >> "$SCRIPTPATH/logs/install.txt"
else
	echo "KeystoneRestart.Fail" >> "$SCRIPTPATH/logs/install.txt"
	exit 1
fi

#remove the mysql database sometimes it is sometimes it doesn't so no check 
rm -f /var/lib/keystone/keystone.db

#adding a cron job 
(crontab -l -u keystone 2>&1 | grep -q token_flush) || \
echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/
keystone-tokenflush.log 2>&1' \
>> /var/spool/cron/crontabs/keystone

