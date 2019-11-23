#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

. /sbin/wifimedia/variables.sh

ip_public(){
	PUBLIC_IP=`wget http://ipecho.net/plain -O - -q ; echo`
	#echo $PUBLIC_IP
}

wr940v6() { #checking internet

	#check gateway
	ping -c 3 "$gateway" > /dev/null
	if [ $? -eq "0" ];then
		echo timer >/sys/devices/platform/leds-gpio/leds/tp-link:orange:diag/trigger
	else
		echo none >/sys/devices/platform/leds-gpio/leds/tp-link:orange:diag/trigger
		echo 1 >/sys/devices/platform/leds-gpio/leds/tp-link:orange:diag/brightness
	fi
	
	#checking internet
	ping -c 10 "8.8.8.8" > /dev/null
	if [ $? -eq "0" ];then
		echo timer >/sys/devices/platform/leds-gpio/leds/tp-link:blue:wan/trigger
	else
		echo none >/sys/devices/platform/leds-gpio/leds/tp-link:blue:wan/trigger
	fi
}

checking (){

	if [ "$model" == "TL-WR940N_v6" ];then
		wr940v6
	fi	

	if [ "$(cat /proc/meminfo | grep 'MemFree:' | awk '{print $2}')" -lt 5000 ]; then
		echo "Clear Cach"
		free && sync && echo 3 > /proc/sys/vm/drop_caches && free
	fi
	source /lib/functions/network.sh ; if network_get_ipaddr addr "wan"; then echo "WAN: $addr" >/tmp/ipaddr; fi
	#pidhostapd=`pidof hostapd`
	#if [ -z $pidhostapd ];then echo "Wireless Off" >/tmp/wirelessstatus;else echo "Wireless On" >/tmp/wirelessstatus;fi
}

license_srv() {
###MAC WAN:WR940NV6 --Ethernet0 OPENWRT19
echo "" > $licensekey
wget -q "${code_srv}" -O $licensekey
curl_result=$?
if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $licensekey; then
		cat "$licensekey" | while read line ; do
			if [ "$(echo $line | grep $wr940_device)" ] ;then
				#Update License Key
				uci set wifimedia.@wireless[0].wfm="$(cat /etc/opt/license/wifimedia)"
				uci commit wifimedia
				cat /etc/opt/license/wifimedia >/etc/opt/license/status
				license_local
			else
				uci set wireless.radio0.disabled="1"
				uci commit wireless
				wifi down
				echo "0 0 * * * /sbin/wifimedia/controller.sh license_srv" > /etc/crontabs/wificode
				#/etc/init.d/cron restart
			fi
		done	
	fi
fi
}

license_local() {

first_time=$(cat /etc/opt/first_time.txt)
timenow=$(date +"%s")
diff=$(expr $timenow - $first_time)
days=$(expr $diff / 86400)
diff=$(expr $diff \% 86400)
hours=$(expr $diff / 3600)
diff=$(expr $diff \% 3600)
min=$(expr $diff / 60)

#uptime="${days}"
time=$(uci -q get wifimedia.@wireless[0].time)
time1=${days}
uptime="${time:-$time1}"
#uptime="${$(uci get license.active.time):-${days}}"
#uptime="${days}d:${hours}h:${min}m"
status=/etc/opt/wfm_status
lcs=/etc/opt/wfm_lcs
if [ "$(uci -q get wifimedia.@wireless[0].wfm)" == "$(cat /etc/opt/license/wifimedia)" ]; then
	echo "Activated" >/etc/opt/license/status
	#touch $status
	echo "" >/etc/crontabs/wificode
	/etc/init.d/cron restart	
	rm $lcs
else
	echo "Wrong License Code" >/etc/opt/license/status
fi
if [ "$uptime" -gt 15 ]; then #>15days
	if [ "$(uci -q get wifimedia.@wireless[0].wfm)" == "$(cat /etc/opt/license/wifimedia)" ]; then
		uci set wireless.radio0.disabled="0"
		#uci set wireless.radio1.disabled="0"
		uci commit wireless
		wifi
		#touch $status
		rm $lcs
		echo "Activated" >/etc/opt/license/status
		echo "" >/etc/crontabs/wificode
		/etc/init.d/cron restart
	else
		echo "Wrong License Code" >/etc/opt/license/status
	fi
fi
}

action_lan_wlan(){
echo "" > $find_mac_gateway
wget -q "${blacklist}" -O $find_mac_gateway
curl_result=$?
if [ "${curl_result}" -eq 0 ]; then
	cat "$find_mac_gateway" | while read line ; do
		if [ "$(echo $line | grep $wr940_device)" ] ;then
			wifi down
			ifdown lan
		fi
	done	
fi
}
##Sent Client MAC to server Nextify
get_client_connect_wlan(){
	NEWLINE_IFS='
'
	OLD_IFS="$IFS"; IFS=$NEWLINE_IFS
	signal=''
	host=''
	mac=''
	touch /tmp/client_connect_wlan
	for iface in `iw dev | grep Interface | awk '{print $2}'`; do
		for line in `iwinfo $iface assoclist`; do
			if echo "$line" | grep -q "SNR"; then
				if [ -f /etc/ethers ]; then
					mac=$(echo $line | awk '{print $1}' FS=" ")
					host=$(awk -v MAC=$mac 'tolower($1)==MAC {print $1}' FS=" " /etc/ethers)
					data=";$mac"
					echo $data >>/tmp/client_connect_wlan
				fi
			fi
		done
	done
	IFS="$OLD_IFS"
	client_connect_wlan=$(cat /tmp/client_connect_wlan | xargs| sed 's/;/,/g'| tr a-z A-Z)
	wget --post-data="clients=${client_connect_wlan}&gateway_mac=${global_device}" http://api.nextify.vn/clients_around -O /dev/null
	echo $client_connect_wlan
	rm /tmp/client_connect_wlan
}

rssi() {
if [ $rssi_on == "1" ];then
	level_defaults=-80
	level=$(uci -q get wifimedia.@wireless[0].level)
	level=${level%dBm}
	LOWER=${level:-$level_defaults}
	#echo $LOWER	
	dl_time=$(uci -q get wifimedia.@wireless[0].delays)
	dl_time=${dl_time%s}
	ban_time=$(expr $dl_time \* 1000)
	touch /tmp/denyclient
	chmod a+x /tmp/denyclient
	NEWLINE_IFS='
'
	OLD_IFS="$IFS"; IFS=$NEWLINE_IFS
	signal=''
	host=''
	mac=''

	for iface in `iw dev | grep Interface | awk '{print $2}'`; do
		for line in `iw $iface station dump`; do
			if echo "$line" | grep -q "Station"; then
				if [ -f /etc/ethers ]; then
					mac=$(echo $line | awk '{print $2}' FS=" ")
					host=$(awk -v MAC=$mac 'tolower($1)==MAC {print $2}' FS=" " /etc/ethers)
				fi
			fi
			if echo "$line" | grep -q "signal:"; then
				signal=`echo "$line" | awk '{print $2}'`
				#echo "$mac (on $iface) $signal $host"
				if [ "$signal" -lt "$LOWER" ]; then
					#echo $MAC IS $SNR - LOWER THAN $LOWER DEAUTH THEM
					echo "ubus call hostapd.$iface "del_client" '{\"addr\":\"$mac\", \"reason\": 1, \"deauth\": True, \"ban_time\": $ban_time}'" >>/tmp/denyclient
				fi
			fi
		done
	done
	IFS="$OLD_IFS"
	/tmp/denyclient
	echo "#!/bin/sh" >/tmp/denyclient
fi #END RSSI

}

"$@"
