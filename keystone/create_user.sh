#!/bin/bash
# Creating the user of OpenStack and the Credential are added to the database
#create_user(controller_ip,admin_password,admin_email)
CONTROLLER_IP=$1
ADMIN_TOKEN=$(cat admin_token.txt)
ADMIN_PASS=$2
ADMIN_EMAIL=$3
DEMO_PASS=$4
DEMO_EMAIL=$5

export OS_SERVICE_TOKEN=$ADMIN_TOKEN
export OS_SERVICE_ENDPOINT=http://$CONTROLLER_IP:35357/v2.0

#Create admin tenant
keystone tenant-create --name admin --description "Admin Tenant"

#Create admin user
keystone user-create --name admin --pass $ADMIN_PASS --email $ADMIN_EMAIL

#Create admin role
keystone role-create --name admin

#add admin role to both admin tenant and admin user
keystone user-role-add --user admin --tenant admin --role admin

#create a demo tenant
keystone tenant-create --name demo --description "Demo Tenant"

#Create demo user 
keystone user-create --name demo --tenant demo --pass $DEMO_PASS --email $DEMO_EMAIL

#Create a Service Client
keystone tenant-create --name service --description "Service Tenant"

#Create the Service Entity End-point
keystone service-create --name keystone --type identity --description "OpenStack Identity"

#Create a n Endpoint
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
