#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

devices="/www/luci-static/resources/devices.txt"
dhcp="/tmp/dhcp.leases"
rm -f /etc/ap
rm -f /etc/macaddress
touch -c /etc/ap
touch -c /etc/macaddress
#EXPORT DATA AP MAC
cat "$devices" | while read line ; do

	mac=$(echo $line | awk '{print $2}' | sed 's/-/:/g' | cut -d ':' -f1-5)
	maclast=$(echo $line | awk '{print $2}' | sed 's/-/:/g' | cut -d ':' -f6)
	decmac=$(echo "ibase=16; $maclast"|bc)
	if [ $decmac -eq '241' ];then
		macinc='00'
	else
		incout=`expr $decmac + 1 `
		macinc=$(echo "obase=16; $incout"|bc)
	fi
	echo "$mac:$macinc" >>/etc/macaddress
done

#EXPORT DATA AP IP MAC
cat "/etc/macaddress" | while read line ; do
	linedeap=$(echo $line | awk '{print $1}' | sed 's/-/:/g')
	arp | grep $linedeap | awk '{print $4 " "$1 " http://" $1 }' >>/etc/ap
done
