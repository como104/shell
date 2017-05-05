#########################################################################
# File Name: initial_setup.sh
# Author: Jensen
# Created Time: Wed 03 May 2017 03:15:21 PM CST
#########################################################################
#!/bin/bash

echo "Checking ntpdate service is installed or not..."
if [ `rpm -qa ntpdate | wc -l` -ne 0 ]; then
	echo -e "OK.\n"
else
	echo -e "Ntpdate is not installed.Installing now...\n"
	yum install ntpdate 2>&1
	if [ `rpm -qa ntpdate | wc -l` -ne 0 ]; then
		break
	else
		echo "The installation of ntpdate has failed.Please check!"
	    read -p "Please press any key to exit..."
		exit
	fi
fi

read -p "Please input the IP address of NTP server:" NTPIP
echo "Synchronize time ..."
ntpdate $NTPIP

echo "0 */1 * * * /usr/sbin/ntpdate $NTPIP" >> /var/spool/cron/root
#sed -i '$a 0 */1 * * * /usr/sbin/ntpdate $NTPIP' /var/spool/cron/root

