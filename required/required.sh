#! /bin/bash
#--------Script for Installing the Prequisits for Installing Openstack-------
#--------The Script has to run on every node------------

echo "---------------Updating Packages----------------" > "required_log.txt"
date >> "required_log.txt"
echo ""
echo ""

if (sudo apt-get update >> "required_log.txt") then
	 echo "Update.Success" > "required.txt"
 	 echo "---------------Installing NTP----------------" >> "required_log.txt"
	 date >> "required_log.txt" 
	 echo ""
	 echo ""
	 if (sudo apt-get install -y ntp >> "required_log.txt") then
                echo "ntp.Success" >> "required.txt"
         else
                echo "ntp.Fail" >> "required.txt"
		exit 1
         fi
else
	echo "Update.Fail" > "required.txt"
	exit 1
fi
