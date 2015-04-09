#!/bin/bash
# Creating the user of OpenStack and the Credential are added to the database
#create_user(controller_ip,admin_password,admin_email)
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

#parameters and variables
CONTROLLER_IP=$1
ADMIN_TOKEN=$(cat admin_token.txt)
ADMIN_PASS=$2
ADMIN_EMAIL=$3
DEMO_PASS=$4
DEMO_EMAIL=$5

export OS_SERVICE_TOKEN=$ADMIN_TOKEN
export OS_SERVICE_ENDPOINT=http://$CONTROLLER_IP:35357/v2.0

#Create admin tenant
if (keystone tenant-create --name admin --description "Admin Tenant" >> "$SCRIPTPATH/logs/create_user_log.txt") then
	echo "AdminTenant.Success" >> "$SCRIPTPATH/logs/create_user.txt"
else
	echo "AdminTenant.Fail" >> "$SCRIPTPATH/logs/create_user.txt"
	exit 1

#Create admin user
if (keystone user-create --name admin --pass $ADMIN_PASS --email $ADMIN_EMAIL >> "$SCRIPTPATH/logs/create_user_log.txt") then
	echo "AdminUser.Success" >> "$SCRIPTPATH/logs/create_user.txt"
else
	echo "AdminUser.Fail" >> "$SCRIPTPATH/logs/create_user.txt"
	exit 1

#Create admin role
if (keystone role-create --name admin >> "$SCRIPTPATH/logs/create_user_log.txt") then
	echo "AdminRole.Success" >> "$SCRIPTPATH/logs/create_user.txt"
else
	echo "AdminRole.Fail" >> "$SCRIPTPATH/logs/create_user.txt" 
	exit 1


#add admin role to both admin tenant and admin user
if (keystone user-role-add --user admin --tenant admin --role admin >> "$SCRIPTPATH/logs/create_user_log.txt") then
	echo "AdminTenantRoleAdd.Success" >> "$SCRIPTPATH/logs/create_user.txt"
else
	echo "AdminTenantRoleAdd.Fail" >> "$SCRIPTPATH/logs/create_user.txt"
	exit 1

#create a demo tenant
if (keystone tenant-create --name demo --description "Demo Tenant" >> "$SCRIPTPATH/logs/create_user_log.txt") then
	echo "DemoTenant.Success" >> "$SCRIPTPATH/logs/create_user.txt"
else
	echo "DemoTenant.Fail" >> "$SCRIPTPATH/logs/create_user.txt"
	exit 1

#Create demo user 
if (keystone user-create --name demo --tenant demo --pass $DEMO_PASS --email $DEMO_EMAIL >> "$SCRIPTPATH/logs/create_user_log.txt") then
	echo "DemoUser.Success" >> "$SCRIPTPATH/logs/create_user.txt"
else
	echo "DemoUser.Fail" >> "$SCRIPTPATH/logs/create_user.txt"
	exit 1

#Create a Service Tenant
if (keystone tenant-create --name service --description "Service Tenant" >> "$SCRIPTPATH/logs/create_user_log.txt") then
	echo "ServiceTenant.Success" >> "$SCRIPTPATH/logs/create_user.txt"
else
	echo "ServiceTenant.Fail" >> "$SCRIPTPATH/logs/create_user.txt"
	exit 1

#Create the Service Entity End-point
if (keystone service-create --name keystone --type identity --description "OpenStack Identity" >> "$SCRIPTPATH/logs/create_user_log.txt") then
	echo "ServiceEntityEndPoint.Success" >> "$SCRIPTPATH/logs/create_user.txt"
else
	echo "ServiceEntityEndPoint.Fail" >> "$SCRIPTPATH/logs/create_user.txt"
	exit 1

#Create an Endpoint
keystone endpoint-create \
--service-id $(keystone service-list | awk '/ identity / {print $2}') \
--publicurl http://$CONTROLLER_IP:5000/v2.0 \
--internalurl http://$CONTROLLER_IP:5000/v2.0 \
--adminurl http://$CONTROLLER_IP:35357/v2.0 \
--region regionOne


#Create admin-openrc.sh
"export OS_TENANT_NAME=admin" > admin-openrc.sh
"export OS_USERNAME=admin" > admin-openrc.sh
"export OS_PASSWORD=$ADMIN_PASS" > admin-openrc.sh
"export OS_AUTH_URL=http://$CONTROLLER_IP:35357/v2.0" > admin-openrc.sh

#Creae demo-openrc.sh
"export OS_TENANT_NAME=admin" > demo-openrc.sh
"export OS_USERNAME=admin" > demo-openrc.sh
"export OS_PASSWORD=$DEMO_PASS" > demo-openrc.sh
"export OS_AUTH_URL=http://$CONTROLLER_IP:35357/v2.0" > demo-openrc.sh

#to load these variable just source the files as per the required user
