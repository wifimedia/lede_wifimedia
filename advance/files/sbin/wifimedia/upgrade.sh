#!/bin/sh
# Copyright © 2012-2017 Wifimedia: Vietnamese.
# All rights reserved.

# Creates temporary directory if it doesn't already exist
if [ ! -d "/tmp/upgrade" ]; then mkdir /tmp/upgrade; fi

# Wipes out previous upgrade information from dashboard
version=/tmp/upgrade/version
echo "" > $version

echo "Waiting a bit..."
sleep $(head -30 /dev/urandom | tr -dc "0123456789" | head -c1)
board_name=$(cat /tmp/sysinfo/board_name)
<<<<<<< HEAD
#tplink840nv4
#device=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }'|sed 's/:/-/g')
#tplink940/941/901..
device=$(cat /sys/class/ieee80211/phy0/macaddress |sed 's/:/-/g' | tr a-z A-Z)
=======
device=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }'|sed 's/:/-/g')
>>>>>>> Blacklist
# Defines the URL to check the firmware at

url="http://firmware.wifimedia.com.vn/tplink/$board_name.bin"
url_v="http://firmware.wifimedia.com.vn/tplink/version"

echo "Checking latest version number"
wget -q "${url_v}" -O $version
echo "Getting latest version hashes and filenames"
curl_result=$?

if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $version; then
		cat "$version" | while read line ; do
			if [ "$(uci get wifimedia.@sync[0].version)" != "$(echo $line | awk '{print $1}')" ]; then
				# Make sure no old firmware exists
				#if [ -e "/tmp/firmware.bin" ]; then rm "/tmp/firmware.bin"; fi
<<<<<<< HEAD
				#echo "Checking for upgrade binary"
=======
				echo "Checking for upgrade binary"
>>>>>>> Blacklist
				if [ "$(echo $line | grep $device)" ] ;then
					#echo "Downloading upgrade binary: $(grep $(cat /tmp/sysinfo/board_name)'-squashfs-sysupgrade' /tmp/upgrade/md5sums | awk '{ print $2 }' | sed 's/*//')"
					wget -q "${url}" -O /tmp/firmware.bin
					# Stop if the firmware file does not exist
					if [ ! -e "/tmp/firmware.bin" ]; then
						echo "The upgrade binary download was not successful, exiting..."
					
					# If the hash is correct: flash the firmware
					elif [ "$(echo $line | awk '{print $3}')" = "$(sha256sum /tmp/firmware.bin | awk '{ print $1 }')" ]; then
						#remove all crontabs/*
						rm -f /etc/crontabs/*
						#remove option wireless
							uci del_list wireless.radio0.ht_capab="SHORT-GI-20"
							uci del_list wireless.radio0.ht_capab="SHORT-GI-40"
							uci del_list wireless.radio0.ht_capab="RX-STBC1"
							uci del_list wireless.radio0.ht_capab="DSSS_CCK-40"
							uci commit wireless
						logger "Installing upgrade binary..."
						if [ "$(echo $line | grep all)" ] ;then
							sysupgrade -v -n /tmp/firmware.bin
						else
							sysupgrade -c /tmp/firmware.bin
						fi	
						#sysupgrade -c -d 600 /tmp/firmware.bin
					# The hash is invalid, stopping here
					else
						echo "The upgrade binary hash did not match, exiting..."
					fi	
				#else
				#	echo "There is no upgrade binary for this device ($(cat /tmp/sysinfo/model)/$(cat /tmp/sysinfo/board_name)), exiting..."
				fi
<<<<<<< HEAD
			#else
			#	echo "Update Version: v$(echo $line | awk '{print $1}') is the latest firmware version available."
=======
			else
				echo "Update Version: v$(echo $line | awk '{print $1}') is the latest firmware version available."
>>>>>>> Blacklist
			fi
		done	
	#else
	#	echo "Could not connect to the upgrade server, exiting..."
	fi
else
	echo "Could not connect to the upgrade server, exiting..."
fi
