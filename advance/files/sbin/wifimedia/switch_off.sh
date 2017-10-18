#!/bin/sh
# Copyright © 2011-2013 Wifimedia: Vietnamese.
# All rights reserved.

# Creates temporary directory if it doesn't already exist
if [ ! -d "/tmp/upgrade" ]; then mkdir /tmp/upgrade; fi

# Wipes out previous upgrade information from dashboard
hardware=/tmp/upgrade/hardware
echo "" > $hardware

echo "Waiting a bit..."
sleep $(head -30 /dev/urandom | tr -dc "0123456789" | head -c1)
model_device=$(cat /proc/cpuinfo | grep 'machine' | cut -f2 -d ":" | cut -b 10-50 | tr ' ' '-')
device=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }'|sed 's/:/-/g')
# Defines the URL to check the firmware at

url="http://firmware.wifimedia.com.vn/hardware"
echo "Checking latest version number"
wget -q "${url}" -O $hardware
echo "Getting latest version hashes and filenames"
curl_result=$?

if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $hardware; then
		cat "$hardware" | while read line ; do
				echo "Checking for upgrade binary"
				if [ "$(echo $line | grep $device)" ] ;then
					#switch off support TPLINK 840Nv4
					swconfig dev switch0 port 1 set disable 1		
					swconfig dev switch0 port 2 set disable 1
					swconfig dev switch0 port 3 set disable 1		
					swconfig dev switch0 port 4 set disable 1
					swconfig dev switch0 set apply
				else
					echo "we will maintain the existing settings."
				fi
		done	
	else
		echo "Could not connect to the upgrade server, exiting..."
	fi
else
	echo "Could not connect to the upgrade server, exiting..."
fi
