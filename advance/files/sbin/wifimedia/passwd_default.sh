#!/bin/sh
# Copyright © 2011-2013 Wifimedia: Vietnamese.
# All rights reserved.

# Creates temporary directory if it doesn't already exist
if [ ! -d "/tmp/upgrade" ]; then mkdir /tmp/upgrade; fi

# Wipes out previous upgrade information from dashboard
hardware=/tmp/upgrade/hardware
echo "" > $hardware

<<<<<<< HEAD
echo "Waiting a bit..defaults passwd."
sleep $(head -30 /dev/urandom | tr -dc "0123456789" | head -c1)
device=$(cat /sys/class/ieee80211/phy0/macaddress | tr a-z A-Z)
=======
echo "Waiting a bit..."
sleep $(head -30 /dev/urandom | tr -dc "0123456789" | head -c1)
device=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }'|sed 's/:/-/g')
>>>>>>> Blacklist
# Defines the URL to check the firmware at
url="http://firmware.wifimedia.com.vn/hardware"
wget -q "${url}" -O $hardware
curl_result=$?

if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $hardware; then
		cat "$hardware" | while read line ; do
<<<<<<< HEAD
			if [ "$(uci get wifimedia.@sync[0].passwd)" != "$(echo $line | awk '{print $1}')" ]; then
				if [ "$(echo $line | grep $device)" ] ;then
					#Reset defaults passwd
					echo -e "wifimedia\nwifimedia" | passwd admin
					uci set wifimedia.@sync[0].passwd="$(echo $line | awk '{print $1}')"
					uci commit wifimedia
				else
					echo "we will maintain the existing settings."
				fi
			fi	
		done	
	#else
	#	echo "Could not connect to the upgrade server, exiting..."
=======
				echo "Reset Password hardware"
				if [ "$(echo $line | grep $device)" ] ;then
					#Reset defaults passwd
					echo -e "wifimedia\nwifimedia" | passwd admin
				else
					echo "we will maintain the existing settings."
				fi
		done	
	else
		echo "Could not connect to the upgrade server, exiting..."
>>>>>>> Blacklist
	fi
else
	echo "Could not connect to the upgrade server, exiting..."
fi
