#! /bin/sh

#--script to clean the logs ans status files

if (rm -f *.txt) then
	echo "Success"
else
	echo "Failure"
fi
