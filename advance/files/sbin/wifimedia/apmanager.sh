#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

devices="/www/luci-static/resources/devices.txt"
rm -f /etc/macap
rm -f /tmp/eap
#touch -c /etc/macap
#touch -c /etc/macap

cat "$devices" | while read line ; do

mac=$(echo $line | awk '{print $2}'| tr '[a-z]' '[A-Z]' | cut -d ':' -f1-5)
maclast=$(echo $line | awk '{print $2}'| tr '[a-z]' '[A-Z]' | cut -d ':' -f6)
#echo $maclast
zero=$(echo $maclast | cut -c 1)
echo $zero
#echo "Mac address= $mac:$maclast"

decmac=$(echo "ibase=16; $maclast"|bc)
if [ $decmac -eq '241' ]
then
macinc='00'
else
incout=`expr $decmac + 1 `
macinc=$(echo "obase=16; $incout"|bc)

fi
	
if [ $zero -eq '0' ];then
	#echo "Mac address= $mac:$zero$macinc"
	echo "$mac:$zero$macinc" >>/etc/macap
else
	#echo "Mac address= $mac:$macinc"
	echo "$mac:$macinc" >>/etc/macap
fi
done
#EXPORT DATA AP IP MAC
cat "/etc/macap" | while read line ; do

	linedeap=$(echo $line | awk '{print $1}' | sed 's/-/:/g' | tr A-Z a-z)
	arp | grep $linedeap | awk '{print $4 " "$1 " http://" $1 }' >>/tmp/eap
	echo $linedeap
done
