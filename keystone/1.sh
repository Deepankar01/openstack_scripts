#! /bin/bash
#--------Script for Installing the Prequisits for Installing Openstack-------
#--------The Script has to run on every node------------

#to get the script location 
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
mysql_password=$1
rabbitmq_password=$2
mysql_ip=$3


echo $SCRIPTPATH
echo $mysql_password
echo $rabbitmq_password
echo $mysql_ip

