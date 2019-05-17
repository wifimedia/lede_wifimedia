#!/bin/sh

dev=br-lan

delete_rule() {
	iptables -F statistics 2> /dev/null
	iptables -D FORWARD -j statistics 2> /dev/null
	iptables -X statistics 2> /dev/null
	iptables -X DOWNLOAD 2> /dev/null
	iptables -X UPLOAD 2> /dev/null
}

add_rule() {
	iptables -N statistics
	iptables -I FORWARD 1 -j statistics

	iptables -N UPLOAD
	iptables -N DOWNLOAD
}

add_ip() {
	cat /proc/net/arp | grep : | grep -v 00:00:00:00:00:00 | grep $dev | awk '{print $1}' > ip
	while read line
	do
		iptables -C statistics -s $line -j UPLOAD 2> /dev/null
		[ $? -eq 1 ] && {
			iptables -I statistics -s $line -j UPLOAD
			iptables -I statistics -d $line -j DOWNLOAD
		}
	done < ip
}

delete_rule
[ "$1" = "-c" ] && exit 0

add_rule

echo "Collecting data..."
echo ""

while true
do
	add_ip
	
	echo "Download speed:"
	echo ""
	iptables -nvx -L statistics | grep DOWNLOAD | awk '{print $2/1024/1" KB/s ",$1/10" packets/s", $9}' | sort -n -r

	echo ""
	echo "Upload speed:"
	echo ""
	iptables -nvx -L statistics | grep UPLOAD | awk '{print $2/1024/1" KB/s ",$1/10" packets/s", $8}' | sort -n -r
	
	iptables -Z statistics
	sleep 1
	clear
done