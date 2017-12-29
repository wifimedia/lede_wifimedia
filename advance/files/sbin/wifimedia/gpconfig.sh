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
	if [ "$(uci get wifimedia.@advance[0].sha256)" != "$(cat $sha256 | awk '{print $2}')" ]; then #Checking SHA neu thay do thi moi apply
	echo "Checking latest sha256sum"
		wget -q "${url}" -O $grp
		wget -q "${grpd}" -O $grp_device
		#rm -f /etc/ap
		#touch -c /etc/ap
		cat "$grp_device" | while read line ; do
			##Gateway
			#echo "$(echo $line | awk '{print $2}' | sed 's/:/-/g' | tr a-z A-Z ) http://"$(echo $(echo $line | awk '{print $2}' | sed 's/://g' | tr A-Z a-z )".wifimedia.vn")  >>/etc/ap
			if [ "$(echo $line | grep $device)" ] ;then #tim thiet bi xem co trong groups hay khong
					uci set wifimedia.@advance[0].ctrs_en="1" #update config
				cat "$grp" | while read line ; do
				
					if [ "$(echo $line | grep 'NETWORK')" ] ;then #Tim LAN/WAN
						uci set wireless.@wifi-iface[0].network="$(echo $line | awk '{print $2}')"
						uci set wifimedia.@advance[0].network="$(echo $line | awk '{print $2}')"
						
					elif [ "$(echo $line | grep 'MODE')" ] ;then #Tim ap/mesh/wds
						uci set wireless.@wifi-iface[0].mode="$(echo $line | awk '{print $2}')"
						uci set wifimedia.@advance[0].mode="$(echo $line | awk '{print $2}')"
						
					elif [ "$(echo $line | grep 'ESSID')" ] ;then #Tim ten ESSID WIFI
						essid="$(echo $line | awk '{print $2}')"
						echo "ESSID: $essid"
						if [ -z "$essid" ];then
							echo "no change SSID"
						else 
							uci set wireless.@wifi-iface[0].ssid="$(echo $line | awk '{print $2}')"
						fi
						uci set wifimedia.@advance[0].essid="$essid"
						
					elif [ "$(echo $line | grep 'CLN')" ] ;then #Tim maxassoc
						uci set wireless.@wifi-iface[0].maxassoc="$(echo $line | awk '{print $2}')"
						uci set wifimedia.@advance[0].maxassoc="$(echo $line | awk '{print $2}')"
						
					elif [ "$(echo $line | grep 'PASSWORD')" ] ;then #Tim mat khau
						if [ "$(echo $line | awk '{print $2}')" == " " ];then
							uci delete wireless.@wifi-iface[0].encryption
							uci delete wireless.@wifi-iface[0].key
							uci delete wireless.@wifi-iface[0].ieee80211r
							uci delete wireless.@wifi-iface[0].rsn_preauth
							uci delete wifimedia.@advance[0].encrypt
							uci commit wireless
							rm -f >/etc/FT
						else	
							uci set wireless.@wifi-iface[0].encryption="psk2"
							uci set wireless.@wifi-iface[0].key="$(echo $line | awk '{print $2}')"
							uci set wifimedia.@advance[0].password="$(echo $line | awk '{print $2}')"
							uci set wifimedia.@advance[0].encrypt="encryption"
						fi
						
					elif [ "$(echo $line | grep 'FT')" ] ;then #enable Fast Roaming

						if [ "$(echo $line | awk '{print $2}')" == "ieee80211r"  ];then
							uci set wireless.@wifi-iface[0].ieee80211r="1"
							uci delete wireless.@wifi-iface[0].rsn_preauth
							uci set wifimedia.@advance[0].ft="ieee80211r"
							echo "Fast BSS Transition Roaming" >/etc/FT
							#Delete List r0kh r1kh
							#list_ap="/tmp/list_eap"
							#touch  /tmp/list_eap
							#cat "$list_ap" | while read  line;do #add list R0KH va R1KH
							#	uci del_list wireless.@wifi-iface[0].r0kh="$(echo $line | awk '{print $2}'),$(echo $line | awk '{print $1}'),000102030405060708090a0b0c0d0e0f"
							#	uci del_list wireless.@wifi-iface[0].r1kh="$(echo $line | awk '{print $2}'),$(echo $line | awk '{print $2}'),000102030405060708090a0b0c0d0e0f"
							#done
							uci del wireless.default_radio0.r0kh
							uci del wireless.default_radio0.r1kh
							#add List r0kh r1kh
							cat "$grp_device" | while read  line;do #add list R0KH va R1KH
								uci add_list wireless.@wifi-iface[0].r0kh="$(echo $line | awk '{print $2}'),$(echo $line | awk '{print $1}'),000102030405060708090a0b0c0d0e0f"
								uci add_list wireless.@wifi-iface[0].r1kh="$(echo $line | awk '{print $2}'),$(echo $line | awk '{print $2}'),000102030405060708090a0b0c0d0e0f"
							done

						else #Fast Roaming Preauth RSN C
							uci delete wireless.@wifi-iface[0].ieee80211r
							uci set wireless.@wifi-iface[0].rsn_preauth="1"
							uci set wifimedia.@advance[0].ft="rsn_preauth"
							echo "Fast-Secure Roaming" >/etc/FT
						fi	
						#Enable RSSI 
						/etc/init.d/watchcat stop && etc/init.d/watchcat start && /etc/init.d/watchcat enable
						uci set wifimedia.@advance[0].level=1
					elif [ "$(echo $line | grep 'NASID')" ] ;then #NASID
						mactmp="/tmp/mac_device"
						echo ''>$mactmp
						nas_id="$(echo $line | awk '{print $2}')"
						if [ -z "$nas_id" ];then
							uci del wireless.default_radio0.r0kh
							uci del wireless.default_radio0.r1kh
						else	
							uci set wireless.@wifi-iface[0].nasid="$(echo $line | awk '{print $2}')"
							uci set wifimedia.@advance[0].nasid="$(echo $line | awk '{print $2}')"
						fi	
						cat "$grp_device" | while read line ; do
							if [ "$(echo $line | grep $(echo $line | awk '{print $2}'))" ];then
								echo $line | awk '{print $2}' >>$mactmp
							fi
						done
						uci set wifimedia.@advance[0].macs="$(cat $mactmp | xargs | sed 's/:/-/g' | sed 's/ /,/g')"
					elif [ "$(echo $line | grep 'HIDE')" ] ;then #HIDE
						if [ "$(echo $line | awk '{print $2}')" == "1"  ];then
							uci set wireless.@wifi-iface[0].hidden="1"
							uci set wifimedia.@advance[0].hidessid="1"
						else
							uci set wireless.@wifi-iface[0].hidden="0"
							uci set wifimedia.@advance[0].hidessid="0"
							#uci delete wireless.@wifi-iface[0].hidden #uci: Entry not found
						fi					
					elif [ "$(echo $line | grep 'BRIDGE')" ] ;then #BRIDGE
					
						if [ "$(echo $line | awk '{print $2}')" == "1"  ];then
							uci delete network.lan
							uci set network.wan.proto='dhcp'
							uci set network.wan.ifname='eth0 eth1'
							uci set wireless.@wifi-iface[0].network='wan'
							uci set wifimedia.@advance[0].bridge_mode='1'
						else
							uci set network.lan='interface'
							uci commit network
							uci set network.lan.proto='static'
							uci set network.lan.ipaddr='172.16.99.1'
							uci set network.lan.netmask='255.255.255.0'
							uci set network.lan.type='bridge'
							uci set dhcp.lan.force='1'
							uci set dhcp.lan.netmask='255.255.255.0'
							uci del dhcp.lan.dhcp_option
							uci add_list dhcp.lan.dhcp_option='6,8.8.8.8,8.8.4.4'			
							uci set network.wan.ifname='eth0'
							uci set wireless.@wifi-iface[0].network='wan'
							#uci delete wifimedia.@advance[0].bridge_mode #uci: Entry not found
							uci set wifimedia.@advance[0].bridge_mode='0'
						fi
					
					elif [ "$(echo $line | grep 'admin')" ] ;then #Change Password admin
						echo -e "$(echo $line | awk '{print $2}')\n$(echo $line | awk '{print $2}')" | passwd admin							
			
					elif [ "$(echo $line | grep 'Isolation')" ] ;then #enable Fast Roaming

						if [ "$(echo $line | awk '{print $2}')" == "1"  ];then
							uci set wireless.@wifi-iface[0].isolate="1"
							uci set wifimedia.@advance[0].isolation="1"
						else
							#uci delete wireless.@wifi-iface[0].isolate
							uci set wireless.@wifi-iface[0].isolate="0"
							uci set wifimedia.@advance[0].isolation="0"
						fi
					#Txpower
					elif [ "$(echo $line | grep 'TxPower')" ] ;then #enable Fast Roaming

						if [ "$(echo $line | grep 'auto')"  ];then
							uci delete wireless.@wifi-device[0].txpower
							uci set wifimedia.@advance[0].txpower="auto"
						elif [ "$(echo $line | grep 'low')"  ];then
							uci set wireless.@wifi-device[0].txpower=17
							uci set wifimedia.@advance[0].txpower="low"
						elif [ "$(echo $line | grep 'medium')"  ];then
							uci set wireless.@wifi-device[0].txpower=20
							uci set wifimedia.@advance[0].txpower="medium"
						elif [ "$(echo $line | grep 'high')"  ];then
							uci set wireless.@wifi-device[0].txpower=22
							uci set wifimedia.@advance[0].txpower="high"
						fi
					fi
					wifi up
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
						uci delete scheduled.days
						uci set scheduled.days=instance
						uci delete scheduled.time
						uci set scheduled.time=times
					fi
					####END Auto reboot every day
					#commit sha256
					uci set wifimedia.@advance[0].sha256="$(sha256sum $grp | awk '{print $1}')"
					#switch interface wireless
					#if [ "$(uci -q get wifimedia.@advance[0].wireless_cfg)" == "0" ]; then
					#	cat /sbin/wifimedia/wifi.lua >/usr/lib/lua/luci/model/cbi/admin_network/wifi.lua
					#	uci set wifimedia.@advance[0].wireless_cfg=1
					#fi	
				done
				uci commit wifimedia
				uci commit wireless
				uci commit scheduled
				uci commit network
				uci commit dhcp
				wifi up
				# Restart all of the services
				/bin/ubus call network reload >/dev/null 2>/dev/null
			fi
		done	
	fi
else
	echo "Could not connect to the upgrade server, exiting..."
fi
