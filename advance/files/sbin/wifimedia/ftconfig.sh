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

	uci set wireless.@wifi-iface[0].network="$networks_"
	uci set wireless.@wifi-iface[0].mode="$mode_"
	if [ "$essid" == " " ];then
		echo "no change SSID"
	else 
		uci set wireless.@wifi-iface[0].ssid="$essid"
	fi
	
	uci set wireless.@wifi-iface[0].maxassoc="$cnl"
	
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
	
		macs=`uci -q get wifimedia.@advance[0].macs | sed 's/-/:/g' | sed 's/,/ /g' | xargs -n1`
		nasid=`uci -q get wifimedia.@advance[0].nasid`
		
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
		#macs=`uci -q get wifimedia.@advance[0].macs | sed 's/-/:/g' | sed 's/,/ /g' | xargs -n1`
		#nasid=`uci -q get wifimedia.@advance[0].nasid`
		if [ -z $(uci -q get wifimedia.@advance[0].macs) ];then
		#echo "test rong"
			uci del_list wireless.@wifi-iface[0].r0kh=",$nasid,000102030405060708090a0b0c0d0e0f"
			uci del_list wireless.@wifi-iface[0].r1kh=",,000102030405060708090a0b0c0d0e0f"		
		fi
		uci commit wireless
		
	else
		uci delete wireless.@wifi-iface[0].ieee80211r
		uci set wireless.@wifi-iface[0].rsn_preauth="1"
							




							
	if [ $encr == "encryption" ] ; then
		echo "PASSWORD: $passwd" >> $group
		echo "FT: $ft" >> $group
	fi	
	if [ $ft == "ieee80211r" ] ; then
		echo "NASID: $nasid" >> $group
		echo "$macs" | sed 's/,/ /g' | xargs -n1 echo $nasid >> $group
		echo "$macs" | sed 's/,/ /g' | xargs -n1 echo $nasid > $devices
	else 
		echo "$macs" | sed 's/,/ /g' | xargs -n1 echo "RSN" > $devices
	fi

	if [ $admins_ == "1" ] ; then
		echo "admin: $passwd_" >> $group
	fi
fi

if [ "$reboot" == "1" ]; then
	echo "Reboot: $reboot $hour_ $minute_ " >> $group
else
	echo "we will maintain the existing settings."
fi

#EXPORT DATA AP MAC
#cat "$devices" | while read line ; do
#
#	mac=$(echo $line | awk '{print $2}' | sed 's/-/:/g' | tr a-z A-Z  | cut -d ':' -f1-5)
#	maclast=$(echo $line | awk '{print $2}' | sed 's/-/:/g' | tr a-z A-Z  | cut -d ':' -f6)
#	decmac=$(echo "ibase=16; $maclast"|bc)
#	if [ $decmac -eq '241' ];then
#		macinc='00'
#	else
#		incout=`expr $decmac + 1 `
#		macinc=$(echo "obase=16; $incout"|bc)
#	fi
#	echo "$mac:$macinc" >>/etc/macaddress
#done

#EXPORT DATA AP IP MAC
#cat "/etc/macaddress" | while read line ; do
#
#	linedev=$(echo $line | awk '{print $1}' | sed 's/-/:/g' | tr a-z A-Z)
#		
#		cat "$dhcp" | while read line ; do
#		
#			linedhcp=$(echo $line | awk '{print $2}' | sed 's/-/:/g' | tr a-z A-Z)
			#echo $linedev
			#echo $linedhcp
#			if [ "$linedev" == "$linedhcp" ] ;then
#				echo $line | awk '{print $2 " http://" $3 " " $3}' >>/etc/ap
#			fi
#		
#		done
#done
#/etc/init.d/network restart
/sbin/wifimedia/apmanager.sh
echo "GRP:  $(sha256sum $group | awk '{print $1}')"  > $sha
#echo "Device:  $(sha256sum $devices | awk '{print $1}')"  >> $sha