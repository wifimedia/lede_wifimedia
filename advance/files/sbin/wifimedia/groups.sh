#!/bin/sh
# Copyright � 2017 Wifimedia.vn.
# All rights reserved.

<<<<<<< HEAD
groups_en=`uci -q get wifimedia.@advance[0].ctrs_en` #Enable config
essid=`uci -q get wifimedia.@advance[0].essid | sed 's/ /_/g'` #SSID
mode_=`uci -q get wifimedia.@advance[0].mode`
networks_=`uci -q get wifimedia.@advance[0].network`
cnl=`uci -q get wifimedia.@advance[0].maxassoc` #Max Connect

encr=`uci -q get wifimedia.@advance[0].encrypt` #Type Ecrypt
passwd=`uci -q get wifimedia.@advance[0].password` #PASSWORD ESSID
ft=`uci -q get wifimedia.@advance[0].ft`	#Fast Roaming
nasid=`uci -q get wifimedia.@advance[0].nasid`

isolation_=`uci -q get wifimedia.@advance[0].isolation`
hide_ssid=`uci -q get wifimedia.@advance[0].hidessid`
txpower_=`uci -q get wifimedia.@advance[0].txpower`
hour_=`uci -q get wifimedia.@advance[0].hour`	#Time Schedule
minute_=`uci -q get wifimedia.@advance[0].minute` #Time Schedule
reboot=`uci -q get wifimedia.@advance[0].Everyday` #Auto reboot

gpd_en=`uci -q get wifimedia.@advance[0].gpd_en` #Enable List AP
macs=`uci -q get wifimedia.@advance[0].macs | sed 's/-/:/g'` #List MAC AP

wireless_off=`uci -q get wifimedia.@advance[0].wireless_off`
br_network=`uci -q get wifimedia.@advance[0].bridge_mode` #switch 5 port

rssi=`uci -q get wifimedia.@advance[0].level` #level rssi
enable_rssi=`uci -q get wifimedia.@advance[0].enable` #enable rssi

admins_=`uci -q get wifimedia.@advance[0].admins`
passwd_=`uci -q get wifimedia.@advance[0].passwords`
group="/www/luci-static/resources/groups.txt"
devices="/www/luci-static/resources/devices.txt"
sha="/www/luci-static/resources/sha256.txt"
macaddr="/etc/macaddr"
dhcp="/tmp/dhcp.leases"
echo "" > $devices
echo "" > $group
rm -f /etc/ap
rm -f /etc/macaddress
touch -c /etc/ap
touch -c /etc/macaddress

if [ "$gpd_en" == "1" ];then
	echo "$macs" | sed 's/,/ /g' | xargs -n1 echo "MAC" > $devices
=======
groups_en=`uci -q get wifimedia.@advance[0].ctrs_en`
essid=`uci -q get wifimedia.@advance[0].essid | sed 's/ /_/g'`
mode_=`uci -q get wifimedia.@advance[0].mode`
networks_=`uci -q get wifimedia.@advance[0].network`
cnl=`uci -q get wifimedia.@advance[0].maxassoc`
passwd=`uci -q get wifimedia.@advance[0].password`
ft=`uci -q get wifimedia.@advance[0].ft`
nasid=`uci -q get wifimedia.@advance[0].nasid`

isolation_=`uci -q get wifimedia.@advance[0].isolation`
txpower_=`uci -q get wifimedia.@advance[0].txpower`
hour_=`uci -q get wifimedia.@advance[0].hour`
minute_=`uci -q get wifimedia.@advance[0].minute`
reboot=`uci -q get wifimedia.@advance[0].Everyday`

gpd_en=`uci -q get wifimedia.@advance[0].gpd_en`
macs=`uci -q get wifimedia.@advance[0].macs | sed 's/-/:/g' `

wireless_off=`uci -q get wifimedia.@advance[0].wireless_off`

admins_=`uci -q get wifimedia.@advance[0].admins`
passwd_=`uci -q get wifimedia.@advance[0].password`
group="/www/luci-static/resources/groups.txt"
devices="/www/luci-static/resources/devices.txt"
sha="/www/luci-static/resources/sha256.txt"
echo "" > $devices
echo "" > $group

if [ "$gpd_en" == "1" ];then
	echo "$macs" | sed 's/,/ /g' | xargs -n1 echo $nasid > $devices
>>>>>>> master
fi

if [ "$groups_en" == "1" ];then
	echo "ESSID: $essid" > $group
	echo "MODE: $mode_" >> $group
	echo "NETWORK: $networks_" >> $group
	echo "CLN: $cnl" >> $group
<<<<<<< HEAD
	echo "HIDE: $hide_ssid" >>$group
	echo "BRIDGE: $br_network" >>$group
	if [ $enable_rssi == "1" ];then
		echo "RSSI: $rssi" >>$group
	else
		echo "RSSI:" >>$group
	fi	
=======
	echo "PASSWORD: $passwd" >> $group
>>>>>>> master
	#echo "$macs" | sed 's/,/ /g' | xargs -n1 echo $nasid > $devices
	echo "Isolation: $isolation_" >> $group
	echo "TxPower: $txpower_" >> $group
	echo "Wireless_off: $wireless_off" >> $group
<<<<<<< HEAD
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
=======
	echo "FT: $ft" >> $group
		if [ $ft == "ieee80211r" ] ; then
			echo "NASID: $nasid" >> $group
			echo "$macs" | sed 's/,/ /g' | xargs -n1 echo $nasid >> $group
		else 
			echo "$macs" | sed 's/,/ /g' | xargs -n1 echo "RSN" > $devices
		fi

		if [ $admins_ == "1" ] ; then
			echo "PASSWORD: $passwd_" >> $group
		fi
else
	echo "" > $group
>>>>>>> master
fi

if [ "$reboot" == "1" ]; then
	echo "Reboot: $reboot $hour_ $minute_ " >> $group
else
	echo "we will maintain the existing settings."
fi

<<<<<<< HEAD
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
=======
echo "GRP:  $(sha256sum $group | awk '{print $1}')"  > $sha
#echo "Device:  $(sha256sum $devices | awk '{print $1}')"  >> $sha
>>>>>>> master
