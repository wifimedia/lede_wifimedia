#!/bin/sh
# Copyright © 2012-2017 Wifimedia: Vietnamese.
# All rights reserved.

# Creates temporary directory if it doesn't already exist
if [ ! -d "/tmp/upgrade" ]; then mkdir /tmp/upgrade; fi

# Wipes out previous upgrade information from dashboard
sha256=/tmp/upgrade/sha256
grp=/tmp/upgrade/group
grp_device=/tmp/upgrade/devices
echo "" > $sha256

echo "Waiting a bit..."
sleep $(head -30 /dev/urandom | tr -dc "0123456789" | head -c1)
board_name=$(cat /tmp/sysinfo/board_name)
#tplink840nv4
#device=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }'|sed 's/:/-/g')
#tplink940/941/901..
device=$(cat /sys/class/ieee80211/phy0/macaddress |sed 's/:/-/g' | tr a-z A-Z)
# Defines the URL to check the firmware at

url="http://local.wifimedia.vn/luci-static/resources/groups.txt"
sha="http://local.wifimedia.vn/luci-static/resources/sha256.txt"
device=$(cat /sys/class/ieee80211/phy0/macaddress |sed 's/:/-/g' | tr a-z A-Z)
echo "Checking latest sha256sum"
wget -q "${url}" -O $grp
wget -q "${sha}" -O $sha256
echo "Getting latest version hashes and filenames"
curl_result=$?

if [ "${curl_result}" -eq 0 ]; then

	if [ "$(sha256sum $grp | awk '{print $1}')" != "$(cat $sha256 | awk '{print $2}')" ]; then #Checking SHA neu thay do thi moi apply
	
		cat "$grp" | while read line ; do
			if [ "$(echo $line | grep 'MACs')" ] ;then
				echo $line | awk '{print $2}' | sed 's/,/ /g' | xargs -n1 echo  >$grp_device #ghi cac thiet bi ra mot file rieng
			fi
		done
		
		cat "$grp_device" | while read line ; do
		
			if [ "$(echo $line | grep $device)" ] ;then #tim thiet bi xem co trong groups hay khong
	
				uci delete wireless.@wifi-iface[0]
				uci delete wireless.@wifi-iface[1]
				if [ -z "$(uci get wireless.@wifi-iface[0])" ]; then 
					uci add wireless wifi-iface; 
				fi
				uci set wireless.@wifi-iface[0].network="wan"
				uci set wireless.@wifi-iface[0].mode="ap"
				uci set wireless.@wifi-iface[0].device="radio0"
				uci commit wireless
				
				cat "$grp" | while read line ; do
					if [ "$(echo $line | grep 'ESSID')" ] ;then #Tim ten ESSID WIFI
						uci set wireless.@wifi-iface[0].ssid="$(echo $line | awk '{print $2}')"
					elif [ "$(echo $line | grep 'PASSWORD')" ] ;then #Tim mat khau
						uci set wireless.@wifi-iface[0].encryption="mixed-psk"
						uci set wireless.@wifi-iface[0].key="$(echo $line | awk '{print $2}')"
					elif [ "$(echo $line | grep 'NASID')" ] ;then #NASID
						uci set wireless.@wifi-iface[0].nasid="$(echo $line | awk '{print $2}')"
						uci commit wireless
				
					fi
					
					if [ "$(echo $line | grep 'FT')" ] ;then #enable Fast Roaming
						uci set wireless.@wifi-iface[0].ieee80211r="1"
						uci set wireless.@wifi-iface[0].rsn_preauth="0"
						
						cat "$grp_device" | while read  line;do #add list R0KH va R1KH
							uci add_list wireless.@wifi-iface[0].r0kh="$(echo $line | awk '{print $1}'),wifimedia,000102030405060708090a0b0c0d0e0f"
							uci add_list wireless.@wifi-iface[0].r1kh="$(echo $line | awk '{print $1}'),$(echo $line | awk '{print $1}'),000102030405060708090a0b0c0d0e0f"
						done
						uci commit wireless
					else #Fast Roaming Preauth RSN C
						uci set wireless.@wifi-iface[0].ieee80211r="0"
						uci set wireless.@wifi-iface[0].rsn_preauth="1"
					fi
				done
				uci commit wireless
			fi	
		done	
	fi
else
	echo "Could not connect to the upgrade server, exiting..."
fi

