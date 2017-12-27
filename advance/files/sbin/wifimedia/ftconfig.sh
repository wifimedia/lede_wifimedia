#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

groups_en=`uci -q get wifimedia.@advance[0].ctrs_en`
essid=`uci -q get wifimedia.@advance[0].essid | sed 's/ /_/g'`
mode_=`uci -q get wifimedia.@advance[0].mode`
networks_=`uci -q get wifimedia.@advance[0].network`
cnl=`uci -q get wifimedia.@advance[0].maxassoc`

encr=`uci -q get wifimedia.@advance[0].encrypt`
passwd=`uci -q get wifimedia.@advance[0].password`
ft=`uci -q get wifimedia.@advance[0].ft`
nasid=`uci -q get wifimedia.@advance[0].nasid`

isolation_=`uci -q get wifimedia.@advance[0].isolation`
hide_ssid=`uci -q get wifimedia.@advance[0].hidessid`
txpower_=`uci -q get wifimedia.@advance[0].txpower`
macs=`uci -q get wifimedia.@advance[0].macs | sed 's/-/:/g' | sed 's/,/ /g' | xargs -n1`

list_ap="/tmp/list_eap"

if [ "$groups_en" == "1" ];then
	#Network
	uci set wireless.@wifi-iface[0].network="$networks_"
	#Mode
	uci set wireless.@wifi-iface[0].mode="$mode_"
	#ESSID
	if [ "$essid" == " " ];then
		echo "no change SSID"
	else 
		uci set wireless.@wifi-iface[0].ssid="$essid"
	fi
	#Connect Limit
	uci set wireless.@wifi-iface[0].maxassoc="$cnl"
	#Passwd ssid
	if [ "$passwd" == " " ];then
		uci delete wireless.@wifi-iface[0].encryption
		uci delete wireless.@wifi-iface[0].key
		uci delete wireless.@wifi-iface[0].ieee80211r
		uci delete wireless.@wifi-iface[0].rsn_preauth
		rm -f >/etc/FT
	else
		uci set wireless.@wifi-iface[0].encryption="psk2"
		uci set wireless.@wifi-iface[0].key="$passwd"
	fi
	#Fast Roaming
	if [ "$ft" == "ieee80211r"  ];then
		uci set wireless.@wifi-iface[0].ieee80211r="1"
		uci delete wireless.@wifi-iface[0].rsn_preauth
		echo "Fast BSS Transition Roaming" >/etc/FT
		
		#delete all r0kh r1kh
		cat "/root/c" | while read  line;do #add list R0KH va R1KH
			uci del_list wireless.@wifi-iface[0].r0kh="$(echo $line | awk '{print $1}'),$nasid,000102030405060708090a0b0c0d0e0f"
			uci del_list wireless.@wifi-iface[0].r1kh="$(echo $line | awk '{print $1}'),$(echo $line | awk '{print $1}'),000102030405060708090a0b0c0d0e0f"
		done
		uci commit wireless
		
		echo "$macs"  | while read  line;do #add list R0KH va R1KH
			uci add_list wireless.@wifi-iface[0].r0kh="$(echo $line | awk '{print $1}'),$nasid,000102030405060708090a0b0c0d0e0f"
			uci add_list wireless.@wifi-iface[0].r1kh="$(echo $line | awk '{print $1}'),$(echo $line | awk '{print $1}'),000102030405060708090a0b0c0d0e0f"
		done
		uci -q get wifimedia.@advance[0].macs | sed 's/-/:/g' | sed 's/,/ /g' | xargs -n1 >/root/c

		if [ -z $(uci -q get wifimedia.@advance[0].macs) ];then
		#echo "test rong"
			uci del_list wireless.@wifi-iface[0].r0kh=",$nasid,000102030405060708090a0b0c0d0e0f"
			uci del_list wireless.@wifi-iface[0].r1kh=",,000102030405060708090a0b0c0d0e0f"		
		fi
		#uci commit wireless
		
	else
		uci delete wireless.@wifi-iface[0].ieee80211r
		uci set wireless.@wifi-iface[0].rsn_preauth="1"
		echo "Fast-Secure Roaming" >/etc/FT
	fi
	#NASID
	uci set wireless.@wifi-iface[0].nasid="$nasid"

	#TxPower
	if [ "$txpower_" == "auto"  ];then
		uci delete wireless.@wifi-device[0].txpower
	elif [ "$txpower_" == "low"  ];then
		uci set wireless.@wifi-device[0].txpower="17"
	elif [ "$txpower_" == "medium"  ];then
		uci set wireless.@wifi-device[0].txpower="20"
	elif [ "$txpower_" == "high"  ];then
		uci set wireless.@wifi-device[0].txpower="22"
	fi
	
	#Hide SSID
	uci set wireless.@wifi-iface[0].hidden="$hide_ssid"
	#ISO
	uci set wireless.@wifi-iface[0].isolate="$isolation_"
	uci commit wireless
fi
