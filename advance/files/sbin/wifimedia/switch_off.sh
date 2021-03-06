#!/bin/sh
# Copyright © 2011-2013 Wifimedia: Vietnamese.
# All rights reserved.

# Creates temporary directory if it doesn't already exist
if [ ! -d "/tmp/upgrade" ]; then mkdir /tmp/upgrade; fi

# Wipes out previous upgrade information from dashboard
hardware=/tmp/upgrade/hardware
echo "" > $hardware

<<<<<<< HEAD
echo "Waiting a bit...switch off"
sleep $(head -30 /dev/urandom | tr -dc "0123456789" | head -c1)
device=$(cat /sys/class/ieee80211/phy0/macaddress | tr a-z A-Z)
# Defines the URL to check the firmware at
url="http://firmware.wifimedia.com.vn/hardware"
#url_v="http://firmware.wifimedia.com.vn/tplink/version"
=======
echo "Waiting a bit..."
sleep $(head -30 /dev/urandom | tr -dc "0123456789" | head -c1)
device=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }'|sed 's/:/-/g')
# Defines the URL to check the firmware at
url="http://firmware.wifimedia.com.vn/hardware"
>>>>>>> Blacklist
wget -q "${url}" -O $hardware
curl_result=$?

if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $hardware; then
		cat "$hardware" | while read line ; do
<<<<<<< HEAD
			if [ "$(uci get wifimedia.@sync[0].sw)" != "$(echo $line | awk '{print $5}')" ]; then
=======
				echo "Switch off hardware"
>>>>>>> Blacklist
				if [ "$(echo $line | grep $device)" ] ;then
					#switch off support TPLINK 840Nv4
					swconfig dev switch0 port 1 set disable 1		
					swconfig dev switch0 port 2 set disable 1
					swconfig dev switch0 port 3 set disable 1		
					swconfig dev switch0 port 4 set disable 1
					swconfig dev switch0 set apply
<<<<<<< HEAD
					uci set wifimedia.@sync[0].sw="$(echo $line | awk '{print $5}')"
					uci commit wifimedia
				else
					echo "we will maintain the existing settings."
				fi
			fi	
		done	
	#else
	#	echo "Could not connect to the upgrade server, exiting..."
=======
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
