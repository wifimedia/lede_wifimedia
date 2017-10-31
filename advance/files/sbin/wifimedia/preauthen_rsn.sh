#!/bin/sh
# Copyright © 2011-2013 Wifimedia: Vietnamese.
# All rights reserved.

# Creates temporary directory if it doesn't already exist
if [ ! -d "/tmp/upgrade" ]; then mkdir /tmp/upgrade; fi

# Wipes out previous upgrade information from dashboard
hardware=/tmp/upgrade/hardware
echo "" > $hardware

echo "Waiting a bit...802.11i"
sleep $(head -30 /dev/urandom | tr -dc "0123456789" | head -c1)
device=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }'|sed 's/:/-/g')
# Defines the URL to check the firmware at
url="http://firmware.wifimedia.com.vn/hardware"
#url_v="http://firmware.wifimedia.com.vn/tplink/version"
wget -q "${url}" -O $hardware
curl_result=$?

if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $hardware; then
		cat "$hardware" | while read line ; do
			if [ "$(uci get wifimedia.@sync[0].rsn)" != "$(echo $line | awk '{print $1}')" ]; then
				if [ "$(echo $line | grep $device)" ] ;then
					#802.11i passwifi radio master
					uci set wireless.@wifi-iface[0].ssid="PDA"
					uci set wireless.@wifi-iface[0].encryption="mixed-psk"
					uci set wireless.@wifi-iface[0].key="123456A@"
					uci set wireless.@wifi-iface[0].rsn_preauth=1
					uci set wireless.@wifi-iface[0]ieee80211r=0
					uci commit wireless
					uci set wifimedia.@sync[0].rsn="$(echo $line | awk '{print $1}')"
					uci commit wifimedia
					wifi
				else
					echo "we will maintain the existing settings."
				fi
			fi	
		done	
	else
		echo "Could not connect to the upgrade server, exiting..."
	fi
else
	echo "Could not connect to the upgrade server, exiting..."
fi

