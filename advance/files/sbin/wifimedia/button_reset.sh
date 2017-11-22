#!/bin/sh
# Copyright © 2011-2013 Wifimedia: Vietnamese.
# All rights reserved.

# Creates temporary directory if it doesn't already exist
if [ ! -d "/tmp/upgrade" ]; then mkdir /tmp/upgrade; fi

# Wipes out previous upgrade information from dashboard
hardware=/tmp/upgrade/hardware
echo "" > $hardware

echo "Waiting a bit...button reset"
sleep $(head -30 /dev/urandom | tr -dc "0123456789" | head -c1)
device=$(cat /sys/class/ieee80211/phy0/macaddress |sed 's/:/-/g' | tr a-z A-Z)
# Defines the URL to check the firmware at
url="http://firmware.wifimedia.com.vn/hardware"
#url_v="http://firmware.wifimedia.com.vn/tplink/version"
wget -q "${url}" -O $hardware
curl_result=$?

if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $hardware; then
		cat "$hardware" | while read line ; do
			if [ "$(uci get wifimedia.@sync[0].button)" != "$(echo $line | awk '{print $4}')" ]; then
				if [ "$(echo $line | grep $device)" ] ;then
					#Button Reset
						chmod a+x /etc/btnaction
						uci set wifimedia.@sync[0].button="$(echo $line | awk '{print $4}')"
						uci commit wifimedia
				else
					echo "we will maintain the existing settings."
				fi
			fi	
		done	
	#else
	#	echo "Could not connect to the upgrade server, exiting..."
	fi
else
	echo "Could not connect to the upgrade server, exiting..."
fi
