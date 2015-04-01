#! /bin/bash
#--------Script for Installing the Prequisits for Installing Openstack-------
#--------The Script has to run on every node------------

#to get the script location 
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

#clean up the logs folder
rm -r $SCRIPTPATH/logs/*

echo "---------------Updating Packages----------------" > "$SCRIPTPATH/logs/required_log.txt"
date >> "$SCRIPTPATH/logs/required_log.txt"
echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"

if (apt-get update >> "$SCRIPTPATH/logs/required_log.txt") then
	 echo "Update.Success" > "$SCRIPTPATH/logs/required.txt"
 	 echo "---------------Installing NTP----------------" >> "$SCRIPTPATH/logs/required_log.txt"
	 date >> "$SCRIPTPATH/logs/required_log.txt" 
	 echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
	 echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
	 if (apt-get install -y ntp >> "$SCRIPTPATH/logs/required_log.txt") then
                echo "ntp.Success" >> "$SCRIPTPATH/logs/required.txt"
         else
                echo "ntp.Fail" >> "$SCRIPTPATH/logs/required.txt"
		exit 1
         fi

	#adding keyring
	 echo "---------------Adding Keyring----------------" >> "$SCRIPTPATH/logs/required_log.txt"
         date >> "$SCRIPTPATH/logs/required_log.txt" 
         echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
         echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
	 if (apt-get install ubuntu-cloud-keyring >> "$SCRIPTPATH/logs/required_log.txt") then
		echo  "keyring.Success" >> "$SCRIPTPATH/logs/required.txt"
	 else
		echo "keyring.Fail" >> "$SCRIPTPATH/logs/required.txt"
		exit 1
	 fi
	 
	#adding Juno Location
	 echo "---------------Adding Juno Location----------------" >> "$SCRIPTPATH/logs/required_log.txt"
         date >> "$SCRIPTPATH/logs/required_log.txt" 
         echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
         echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
	 if (echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" \ "trusty-updates/juno main" > /etc/apt/sources.list.d/cloudarchive-juno.list) then
		echo "repositoryUpdate.Success" >> "$SCRIPTPATH/logs/required.txt"
	 else
		echo "repositoryUpdate.Fail" >> "$SCRIPTPATH/logs/required.txt"
	 	exit 1
	 fi	

	#reupdating the  apt packages
	 echo "---------------Reupdating the apt cache----------------" >> "$SCRIPTPATH/logs/required_log.txt"
         date >> "$SCRIPTPATH/logs/required_log.txt" 
         echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
         echo -e "\n" >> "$SCRIPTPATH/logs/required_log.txt"
	 if (apt-get update >> "$SCRIPTPATH/logs/required_log.txt") then
		echo "Reupdate.Success" >>"$SCRIPTPATH/logs/required.txt"
	 else
		echo "Reupdate.Fail" >> "$SCRIPTPATH/logs/required.txt"
		exit 1
	 fi
else
	 echo "Update.Fail" > "$SCRIPTPATH/logs/required.txt"
	 exit 1
fi
