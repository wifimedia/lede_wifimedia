#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

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
if [ "$groups_en" == "1" ];then
	echo "ESSID: $essid" > $group
	echo "MODE: $mode_" >> $group
	echo "NETWORK: $networks_" >> $group
	echo "CLN: $cnl" >> $group
	echo "PASSWORD: $passwd" >> $group
	#echo "$macs" | sed 's/,/ /g' | xargs -n1 echo $nasid > $devices
	echo "Isolation: $isolation_" >> $group
	echo "TxPower: $txpower_" >> $group
	echo "Wireless_off: $wireless_off" >> $group
	echo "FT: $ft" >> $group
		if [ $ft == "ieee80211r" ] ; then
			echo "NASID: $nasid" >> $group
			
		fi

		if [ $admins_ == "1" ] ; then
			echo "PASSWORD: $passwd_" >> $group
		fi
else
	echo "" > $group
fi

if [ "$gpd_en" == "1" ];then
	echo "$macs" | sed 's/,/ /g' | xargs -n1 echo $nasid > $devices
fi

if [ "$reboot" == "1" ]; then
	echo "Reboot: $reboot $hour_ $minute_ " >> $group
else
	echo "we will maintain the existing settings."
fi

echo "GRP:  $(sha256sum $group | awk '{print $1}')"  > $sha
#echo "Device:  $(sha256sum $devices | awk '{print $1}')"  >> $sha
