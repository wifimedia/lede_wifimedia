#!/bin/sh
# Copyright © 2011-2013 Wifimedia: Vietnamese.
# All rights reserved.

# Creates temporary directory if it doesn't already exist
if [ ! -d "/tmp/upgrade" ]; then mkdir /tmp/upgrade; fi

# Wipes out previous upgrade information from dashboard
<<<<<<< HEAD
licensekey=/tmp/upgrade/licensekey
echo "" > $licensekey

echo "Waiting a bit..check license key."
sleep $(head -30 /dev/urandom | tr -dc "0123456789" | head -c1)
device=$(cat /sys/class/ieee80211/phy0/macaddress | sed 's/:/-/g' | tr a-z A-Z)
# Defines the URL to check the license key at
url="http://firmware.wifimedia.com.vn/hardware_active"
wget -q "${url}" -O $licensekey
curl_result=$?

if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $licensekey; then
		cat "$licensekey" | while read line ; do
			if [ "$(echo $line | grep $device)" ] ;then
				#Update License Key
				uci set wifimedia.@advance[0].wfm="$(cat /etc/opt/license/wifimedia)"
				uci commit wifimedia
				/usr/bin/license.sh
=======
hardware=/tmp/upgrade/hardware
echo "" > $hardware

echo "Waiting a bit..check license key."
sleep $(head -30 /dev/urandom | tr -dc "0123456789" | head -c1)
device=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }'|sed 's/:/-/g')
# Defines the URL to check the firmware at
url="http://firmware.wifimedia.com.vn/hardware_active"
wget -q "${url}" -O $hardware
curl_result=$?

if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $hardware; then
		cat "$hardware" | while read line ; do
			if [ "$(echo $line | grep $device)" ] ;then
				#Update License Key
				uci -q get wifimedia.@advance[0].wfm="$(cat /etc/opt/license/wifimedia)"
				uci commit wifimedia
>>>>>>> master
			else
				echo "we will maintain the existing settings."
			fi
		done	
	fi
else
	echo "Could not connect to the upgrade server, exiting..."
fi
