#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

groups_en=`uci -q get wifimedia.@advance[0].ctrs_en`
essid=`uci -q get wifimedia.@advance[0].essid`
passwd=`uci -q get wifimedia.@advance[0].password`
ft=`uci -q get wifimedia.@advance[0].ft`
nasid=`uci -q get wifimedia.@advance[0].nasid`
macs=`uci -q get wifimedia.@advance[0].macs`
reboot=`uci -q get wifimedia.@advance[0].Everyday`
group="/www/luci-static/resources/groups.txt"
devices="/www/luci-static/resources/devices.txt"
sha="/www/luci-static/resources/sha256.txt"
if [ "$groups_en" == "1" ];then
	echo "ESSID: $essid" > $group
	echo "PASSWORD: $passwd" >> $group
	echo "FT: $ft" >> $group
		if [ $ft == "ieee80211r" ] ; then
			echo "NASID: $nasid" >> $group
			echo "$macs" | sed 's/,/ /g' | xargs -n1 echo $nasid > $devices
		fi
else
	echo "" > $group
fi

if [ "$reboot" == "1" ]; then
	echo "Reboot: $reboot" >> $group
else
	echo "Reboot: 0" >> $group	
fi

echo "SHA256:  $(sha256sum $group | awk '{print $1}')"  > $sha
