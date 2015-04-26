#!/bin/bash
#----Script Required for Fetching Prequisits for Glance
#required.sh(mysql_passowrd,glance_db_password,glance_password,controller_ip)

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
MYSQL_PASSWORD=$1
GLANCE_DB_PASSWORD=$2
GLANCE_PASSWORD=$3
CONTROLLER_IP=$4

#clean the logs of the glance required script
rm -r -f $SCRIPTPATH/logs/required*


#Adding glance Database to MySQL database
if(mysql -u root -p$MYSQL_PASSWORD -e "CREATE DATABASE glance" >> "$SCRIPTPATH/logs/required_log.txt") then
	echo "table.Success" >> "$SCRIPTHPATH/logs/required.txt"
else
	echo "table.Fail" >> "$SCRIPTPATH/logs/required.txt"
	exit 1

fi

#Adding the Access Rights to glance
if(mysql -u root -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$GLANCE_DB_PASSWORD'" >> "$SCRIPTPATH/logs/required_log.txt") then
	echo "Privillage1.Success" >> "$SCRIPTHPATH/logs/required.txt"
else
	echo "Privillage1.Fail" >> "$SCRIPTHPATH/logs/required.txt"
	exit 1
fi

if(mysqL -u root -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$GLANCE_DB_PASSWORD'" >> "$SCRIPTPATH/logs/required_log.txt") then
	 echo "Privillage2.Success" >> "$SCRIPTHPATH/logs/required.txt"
else
	 echo "Privillage2.Fail" >> "$SCRIPTHPATH/logs/required.txt"
	 exit 1

#Source the credentials file ---REMEMBER TO ADD IT TO THE MAIN FOLDER INSTEAD OF THE KEYSTONE FOLDER
source admin-openrc.sh

#Create the glance user
if (keystone user-create --name glance --pass $GLANCE_PASSWORD >> "$SCRIPTPATH/logs/required_log.txt") then
	 echo "UserCreate.Success" >> "$SCRIPTHPATH/logs/required.txt"
else
	 echo "UserCreate.Fail" >> "$SCRIPTHPATH/logs/required.txt"
	 exit 1

fi
#Add glance user to admin role
if (keystone user-role-add --user glance --tenant service --role admin >> "$SCRIPTPATH/logs/required_log.txt") then
	 echo "UserRole.Success" >> "$SCRIPTHPATH/logs/required.txt"
else
	 echo "UserRole.Fail" >> "$SCRIPTHPATH/logs/required.txt"
	 exit 1
fi

#Creating the glance service in the keystone
if(keystone service-create --name glance --type image --description "OpenStack Image Service" >> "$SCRIPTPATH/logs/required_log.txt") then
	 echo "ServiceCreate.Success" >> "$SCRIPTHPATH/logs/required.txt"
else
	 echo "ServiceCreate.Fail" >> "$SCRIPTHPATH/logs/required.txt"
	 exit 1
fi

#Creating the Glance Endpoint
keystone endpoint-create \
--service-id $(keystone service-list | awk '/ image / {print $2}') \
--publicurl http://$CONTROLLER_IP:9292 \
--internalurl http://$CONTROLLER_IP:9292 \
--adminurl http://$CONTROLLER_IP:9292 \
--region regionOne

#Installing Glance and glance client
if (apt-get -y install glance python-glanceclient >> "$SCRIPTPATH/logs/required_log.txt") then
	 echo "Install.Success" >> "$SCRIPTHPATH/logs/required.txt"
else
	 echo "Install.Fail" >> "$SCRIPTHPATH/logs/required.txt"
	 exit 1
fi
