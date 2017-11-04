#!/bin/sh
# Copyright © 2012-2017 Wifimedia: Vietnamese.
# All rights reserved.

# Creates temporary directory if it doesn't already exist
if [ ! -d "/tmp/upgrade" ]; then mkdir /tmp/upgrade; fi

# Wipes out previous upgrade information from dashboard
sha256=/tmp/upgrade/sha256
grp=/etc/config/group
grp_device=/tmp/upgrade/devices
echo "" > $sha256

echo "Waiting a bit..."
sleep $(head -30 /dev/urandom | tr -dc "0123456789" | head -c1)
#board_name=$(cat /tmp/sysinfo/board_name)
#tplink840nv4
#device=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }'|sed 's/:/-/g')
#tplink940/941/901..
#device=$(cat /sys/class/ieee80211/phy0/macaddress |sed 's/:/-/g' | tr a-z A-Z)
# Defines the URL to check the firmware at

url="http://local.wifimedia.vn/luci-static/resources/groups.txt"
grpd="http://local.wifimedia.vn/luci-static/resources/devices.txt"
sha="http://local.wifimedia.vn/luci-static/resources/sha256.txt"
device=$(cat /sys/class/ieee80211/phy0/macaddress | tr a-z A-Z)

wget -q "${sha}" -O $sha256
curl_result=$?

if [ "${curl_result}" -eq 0 ]; then
	echo "Checking download sha256sum"
	if [ "$(sha256sum $grp | awk '{print $1}')" != "$(cat $sha256 | awk '{print $2}')" ]; then #Checking SHA neu thay do thi moi apply
	echo "Checking latest sha256sum"
		wget -q "${url}" -O $grp
		wget -q "${grpd}" -O $grp_device
		cat "$grp_device" | while read line ; do
		
			if [ "$(echo $line | grep $device)" ] ;then #tim thiet bi xem co trong groups hay khong
	
				uci delete wireless.@wifi-iface[0]
				uci delete wireless.@wifi-iface[1]
				if [ -z "$(uci get wireless.@wifi-iface[0])" ]; then 
					uci add wireless wifi-iface; 
				fi
				uci set wireless.@wifi-iface[0].device="radio0"
				uci commit wireless
				
				cat "$grp" | while read line ; do
					if [ "$(echo $line | grep 'ESSID')" ] ;then #Tim ten ESSID WIFI
						uci set wireless.@wifi-iface[0].ssid="$(echo $line | awk '{print $2}')"
					elif [ "$(echo $line | grep 'MODE')" ] ;then #Tim ap/mesh/wds
						uci set wireless.@wifi-iface[0].mode="$(echo $line | awk '{print $2}')"
					elif [ "$(echo $line | grep 'NETWORK')" ] ;then #Tim LAN/WAN
						uci set wireless.@wifi-iface[0].network="$(echo $line | awk '{print $2}')"
					elif [ "$(echo $line | grep 'CLN')" ] ;then #Tim LAN/WAN
						uci set wireless.@wifi-iface[0].maxassoc="$(echo $line | awk '{print $2}')"
					elif [ "$(echo $line | grep 'PASSWORD')" ] ;then #Tim mat khau
						uci set wireless.@wifi-iface[0].encryption="mixed-psk"
						uci set wireless.@wifi-iface[0].key="$(echo $line | awk '{print $2}')"
					elif [ "$(echo $line | grep 'NASID')" ] ;then #NASID
						uci set wireless.@wifi-iface[0].nasid="$(echo $line | awk '{print $2}')"
					elif [ "$(echo $line | grep 'TxPower')" ] ;then #TxPower
						uci set wireless.@wifi-iface[0].nasid="$(echo $line | awk '{print $2}')"				
					fi
					### Fast Roaming
					if [ "$(echo $line | grep 'FT')" ] ;then #enable Fast Roaming

						if [ "$(echo $line | awk '{print $2}')" == "ieee80211r"  ];then
							uci set wireless.@wifi-iface[0].ieee80211r="1"
							uci set wireless.@wifi-iface[0].rsn_preauth="0"
							cat "$grp_device" | while read  line;do #add list R0KH va R1KH
								uci add_list wireless.@wifi-iface[0].r0kh="$(echo $line | awk '{print $2}'),$(echo $line | awk '{print $1}'),000102030405060708090a0b0c0d0e0f"
								uci add_list wireless.@wifi-iface[0].r1kh="$(echo $line | awk '{print $2}'),$(echo $line | awk '{print $2}'),000102030405060708090a0b0c0d0e0f"
							done
						else #Fast Roaming Preauth RSN C
							uci set wireless.@wifi-iface[0].ieee80211r="0"
							uci set wireless.@wifi-iface[0].rsn_preauth="1"
						fi
					fi
					
					#Isolation
					if [ "$(echo $line | grep 'Isolation')" ] ;then #enable Fast Roaming

						if [ "$(echo $line | awk '{print $2}')" == "1"  ];then
							uci set wireless.@wifi-iface[0].isolate="1"
						else #Fast Roaming Preauth RSN C
							uci set wireless.@wifi-iface[0].isolate="0"
						fi
					fi

					#Txpower
					if [ "$(echo $line | grep 'TxPower')" ] ;then #enable Fast Roaming

						if [ "$(echo $line | grep 'auto')"  ];then
							uci delete wireless.@wifi-device[0].txpower
						elif [ "$(echo $line | grep 'low')"  ];then
							uci set wireless.@wifi-device[0].txpower=17
						elif [ "$(echo $line | grep 'medium')"  ];then
							uci set wireless.@wifi-device[0].txpower=20
						elif [ "$(echo $line | grep 'high')"  ];then
							uci set wireless.@wifi-device[0].txpower=23						
						fi
					fi
					
					####Auto reboot every day
					if [ "$(echo $line | grep 'Reboot')" ] ;then #Auto Reboot every day
						if [ "$(echo $line | awk '{print $2}')" == "1"  ];then
							echo -e "0 5 * * 0,1,2,3,4,5,6 sleep 70 && touch /etc/banner && reboot" >/tmp/autoreboot
							crontab /tmp/autoreboot -u wifimedia
							/etc/init.d/cron start
							ntpd -q -p 0.asia.pool.ntp.org
							ntpd -q -p 1.asia.pool.ntp.org
							ntpd -q -p 2.asia.pool.ntp.org
							ntpd -q -p 3.asia.pool.ntp.org
							
							uci set scheduled.days.Mon=1
							uci set scheduled.days.Tue=1
							uci set scheduled.days.Wed=1
							uci set scheduled.days.Thu=1
							uci set scheduled.days.Fri=1
							uci set scheduled.days.Sat=1
							uci set scheduled.days.Sun=1
							uci set scheduled.time.minute="$(echo $line | awk '{print $4}')"
							uci set scheduled.time.hour="$(echo $line | awk '{print $3}')"
						fi
					else
						echo -e "" >/tmp/autoreboot
						crontab /tmp/autoreboot -u wifimedia
						/etc/init.d/cron start
						uci set scheduled.days.Mon=0
						uci set scheduled.days.Tue=0
						uci set scheduled.days.Wed=0
						uci set scheduled.days.Thu=0
						uci set scheduled.days.Fri=0
						uci set scheduled.days.Sat=0
						uci set scheduled.days.Sun=0
						
						uci set scheduled.time.minute=0
						uci set scheduled.time.hour=0
					fi
					####END Auto reboot every day
				done
				uci commit wireless
				uci commit scheduled
				sleep 5
				wifi up
			fi	
		done	
	fi
else
	echo "Could not connect to the upgrade server, exiting..."
fi
