#!/bin/sh
# Copyright � 2017 Wifimedia.vn.
# All rights reserved.

. /sbin/wifimedia/variables.sh

ip_public(){
	PUBLIC_IP=`wget http://ipecho.net/plain -O - -q ; echo`
	#echo $PUBLIC_IP
}
wr840v4() { #checking internet

	#check gateway
	ping -c 3 "$gateway" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/gpio-leds/leds/tl-wr840n-v4:*:wps/
		echo timer > trigger
	else
		cd /sys/devices/platform/gpio-leds/leds/tl-wr840n-v4:*:wps/
		echo none > trigger
	fi

	#checking internet
	ping -c 10 "8.8.8.8" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/gpio-leds/leds/tl-wr840n-v4:*:wan/
		echo timer > trigger
	else
		cd /sys/devices/platform/gpio-leds/leds/tl-wr840n-v4:*:wan/
		echo none > trigger
	fi
}

wr840v620() { #checking internet

	#checking internet
	ping -c 10 "8.8.8.8" > /dev/null
	if [ $? -eq "0" ];then
		echo none >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wan/trigger
		echo timer >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wlan/trigger
		echo timer >/sys/devices/platform/leds/leds/tl-wr840n-v6:orange:wan/trigger
		echo 350 >/sys/devices/platform/leds/leds/tl-wr840n-v6:orange:wlan/delay_on
		echo 450 >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wan/delay_on
	else
		echo timer >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wan/trigger
		echo 0 >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wan/brightness
	fi
	
	#check gateway
	ping -c 3 "$gateway" > /dev/null
	if [ $? -eq "0" ];then
		echo timer >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:lan/trigger
	else
		echo none >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wan/trigger
		echo none >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:lan/trigger
		echo 1 >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:lan/brightness
		echo 1 >/sys/devices/platform/leds/leds/tl-wr840n-v6:green:wlan/brightness
	fi
}

wr841v14() { #checking internet

	#checking internet
	ping -c 10 "8.8.8.8" > /dev/null
	if [ $? -eq "0" ];then
		echo timer >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:wan/trigger
		echo none >/sys/devices/platform/leds/leds/tl-wr841n-v14:orange:wan/trigger
	else
		echo none >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:wan/trigger
		echo timer >/sys/devices/platform/leds/leds/tl-wr841n-v14:orange:wan/trigger
	fi
	#check gateway
	ping -c 3 "$gateway" > /dev/null
	if [ $? -eq "0" ];then
		echo 1 >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:wlan/brightness
		echo timer >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:lan/trigger
	else
		echo 500 >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:lan/delay_on
		echo 0 >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:lan/delay_off
		#echo none >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:lan/trigger
		#echo 1 >/sys/devices/platform/leds/leds/tl-wr841n-v14:green:lan/brightness		
	fi	
}

wr840v13() { #checking internet

	#check gateway
	ping -c 3 "$gateway" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wps/
		echo timer > trigger
	else
		cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wps/
		echo none > trigger
	fi
	
	#checking internet
	ping -c 10 "8.8.8.8" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wan/
		echo timer > trigger
	else
		cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wan/
		echo none > trigger
	fi
}

wr940v5() { #checking internet

	#check gateway
	ping -c 3 "$gateway" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/leds-gpio/leds/tp-link:*:qss/
		echo timer > trigger
	else
		cd /sys/devices/platform/leds-gpio/leds/tp-link:*:qss/
		echo none > trigger
	fi
	
	#checking internet
	ping -c 10 "8.8.8.8" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/leds-gpio/leds/tp-link:*:wan/
		echo timer > trigger
	else
		cd /sys/devices/platform/leds-gpio/leds/tp-link:*:wan/
		echo none > trigger
	fi

}

wr940v6() { #checking internet

	#check gateway
	ping -c 3 "$gateway" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/leds-gpio/leds/tp-link:orange:diag/
		echo timer > trigger
	else
		cd /sys/devices/platform/leds-gpio/leds/tp-link:orange:diag/
		echo 1 > brightness
		echo none > trigger
	fi
	
	#checking internet
	ping -c 10 "8.8.8.8" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/leds-gpio/leds/tp-link:blue:wan/
		echo timer > trigger
	else
		cd /sys/devices/platform/leds-gpio/leds/tp-link:blue:wan/
		echo none > trigger
	fi
}


wa901nd() { #checking internet

	#check gateway
	ping -c 3 "$gateway" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/leds-gpio/leds/tp-link:green:qss/
		echo timer > trigger
	else
		cd /sys/devices/platform/leds-gpio/leds/tp-link:green:qss/
		echo 1 > brightness
		echo none > trigger
	fi
	
	#checking internet
	ping -c 10 "8.8.8.8" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/leds-gpio/leds/tp-link:green:system/
		echo timer > trigger
	else
		cd /sys/devices/platform/leds-gpio/leds/tp-link:green:system/
		echo none > trigger
	fi
}

asus56u(){
	ping -c 3 "$gateway" > /dev/null
	if [ $? -eq "0" ];then
		cd /sys/devices/platform/leds/leds/rt-ac51u:blue:power
		echo timer > trigger
	else
		cd /sys/devices/platform/leds/leds/rt-ac51u:blue:power
		echo none > trigger
		echo 1 > brightness
	fi
}

meshdesk(){
dnsctl=$(uci -q get meshdesk.internet1.dns)
ip=`nslookup $dnsctl | grep 'Address' | grep -v '127.0.0.1' | grep -v '8.8.8.8' | grep -v '0.0.0.0'|grep -v '::' | awk '{print $3}'`
if [ "$ip" != "" ] &&  [ -e /etc/config/meshdesk ];then
	uci set meshdesk.internet1.ip=$ip
	uci commit meshdesk
fi
}
#eap_name=$(cat /proc/cpuinfo | grep 'machine' | cut -f2 -d ":" | cut -b 10-19)
#
#eap(){
#if [ "$eap_name" == "TL-WA901ND" ] ;then
#	ping -c 3 "$gateway" > /dev/null
#	if [ $? -eq "0" ];then
#		echo "dhcp client"
#	else
#		uci set network.lan
#		
#	fi
#fi
#}

checking (){
	model=$(cat /proc/cpuinfo | grep 'machine' | cut -f2 -d ":" | cut -b 10-50 | tr ' ' '_')

	if [ "$model" == "TL-WR840N_v6" ];then	
		wr840v620
	elif [ "$model" == "TL-WR841N_v14" ];then	
		wr841v14		
	fi
	#asus56u
	#Clear memory
	if [ "$(cat /proc/meminfo | grep 'MemFree:' | awk '{print $2}')" -lt 5000 ]; then
		echo "Clear Cach"
		free && sync && echo 3 > /proc/sys/vm/drop_caches && free
	fi
	source /lib/functions/network.sh ; if network_get_ipaddr addr "wan"; then echo "WAN: $addr" >/tmp/ipaddr; fi
	#pidhostapd=`pidof hostapd`
	#if [ -z $pidhostapd ];then echo "Wireless Off" >/tmp/wirelessstatus;else echo "Wireless On" >/tmp/wirelessstatus;fi
}

groups_cfg(){
echo "" > $devices_cfg
echo "" > $group_cfg
if [ "$gpd_en" == "1" ];then
	echo "$mac_cfg" | sed 's/,/ /g' | xargs -n1 echo "MAC" > $devices_cfg
fi

if [ "$groups_en" == "1" ];then
	echo "ESSID: $essid" > $group_cfg
	echo "MODE: $mode_" >> $group_cfg
	echo "NETWORK: $networks_" >> $group_cfg
	echo "CLN: $cnl" >> $group_cfg
	echo "HIDE: $hide_ssid" >>$group_cfg
	echo "BRIDGE: $br_network" >>$group_cfg
	if [ $enable_rssi == "1" ];then
		echo "RSSI: $rssi" >>$group_cfg
	else
		echo "RSSI:" >>$group_cfg
	fi	
	#echo "$mac_cfg" | sed 's/,/ /g' | xargs -n1 echo $nasid > $devices
	echo "Isolation: $isolation_" >> $group_cfg
	echo "TxPower: $txpower_" >> $group_cfg
	echo "Wireless_off: $wireless_off" >> $group_cfg
	if [ $encr == "encryption" ] ; then
		echo "PASSWORD: $passwd" >> $group_cfg
		echo "FT: $ft" >> $group_cfg
	fi	
	if [ $ft == "ieee80211r" ] ; then
		echo "NASID: $nasid" >> $group_cfg
		echo "$mac_cfg" | sed 's/,/ /g' | xargs -n1 echo $nasid >> $group_cfg
		echo "$mac_cfg" | sed 's/,/ /g' | xargs -n1 echo $nasid > $devices_cfg
	else 
		echo "$mac_cfg" | sed 's/,/ /g' | xargs -n1 echo "RSN" > $devices_cfg
	fi

	if [ $admins_ == "1" ] ; then
		echo "admin: $passwd_" >> $group_cfg
	fi
fi

if [ "$reboot" == "1" ]; then
	echo "Reboot: $reboot $hour_ $minute_ " >> $group_cfg
fi
#ap_manager
echo "GRP:  $(sha256sum $group_cfg | awk '{print $1}')"  > $sha256_check

}

license_srv() {

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
					echo "enable check key"
					echo "0 0 * * * /sbin/wifimedia/controller.sh license_srv" > /etc/crontabs/wificode
					#/etc/init.d/cron restart
			fi
		done	
	fi
fi
}

lgw_srv() {
	echo "" > $gwkey
	wget -q "${codegw}" -O $gwkey
	curl_result=$?
	if [ "${curl_result}" -eq 0 ]; then
		if grep -q "." $gwkey; then
			cat "$licensekey" | while read line ; do
				if [ "$(echo $line | grep $wr940_device)" ] ;then
					#Update License Key
					uci set wifimedia.@wireless[0].wfm="$(cat /etc/opt/license/wifimedia)"
					cat /etc/opt/license/wifimedia >/etc/opt/license/status
					uci commit wifimedia
					licensegw
				else
					echo "enable check key"
					echo "0 0 * * * /sbin/wifimedia/controller.sh lgw_srv" > /etc/crontabs/wificode
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
		uci set wireless.radio1.disabled="0"
		uci commit wireless
		wifi
		#touch $status
		rm $lcs
		echo "Activated" >/etc/opt/license/status
		echo "" >/etc/crontabs/wificode
		/etc/init.d/cron restart
	else
		echo "Wrong License Code" >/etc/opt/license/status
		uci set wireless.radio0.disabled="1"
		uci set wireless.radio1.disabled="1"
		uci commit wireless
		wifi down
	fi
fi
}

###Gateway
licensegw() {

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
#status=/etc/opt/wfm_status
lcs=/etc/opt/wfm_lcs
if [ "$(uci -q get wifimedia.@wireless[0].wfm)" == "$(cat /etc/opt/license/wifimedia)" ]; then
	echo "Activated" >/etc/opt/license/status
	#touch $status
	rm $lcs
	echo "" >/etc/crontabs/wificode
	/etc/init.d/cron restart
	uci set wireless.radio0.disabled="0"
	uci set wireless.radio1.disabled="0"
	uci commit wireless
	wifi
else
	minute=`date | awk '{print $4}'|cut -c 4,5`
	if [ "minute" == "30" ] || [ "minute" == "45" ] || [ "minute" == "59" ];then
		reboot
	fi
	echo "Wrong License Code & auto reboot" >/etc/opt/license/status
	
fi
if [ "$uptime" -gt 15 ]; then #>15days
	if [ "$(uci -q get wifimedia.@wireless[0].wfm)" == "$(cat /etc/opt/license/wifimedia)" ]; then
		uci set wireless.radio0.disabled="0"
		uci set wireless.radio1.disabled="0"
		uci commit wireless
		wifi
		rm $lcs
		echo "" >/etc/crontabs/wificode
		/etc/init.d/cron restart
		echo "Activated" >/etc/opt/license/status
	else
		minute=`date | awk '{print $4}'|cut -c 4,5`
		if [ "minute" == "30" ] || [ "minute" == "45" ] || [ "minute" == "59" ];then
			reboot
		fi
		echo "Wrong License Code & auto reboot" >/etc/opt/license/status
		#rm $status
		
	fi
fi
}
#end GW
eap_manager() {

rm -f /tmp/eap_mac
rm -f /tmp/eap
cat "$eap_device" | while read line ; do
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
		echo "$mac:$zero$macinc" >>/tmp/eap_mac
	else
		#echo "Mac address= $mac:$macinc"
		echo "$mac:$macinc" >>/tmp/eap_mac
	fi
done
#EXPORT DATA AP IP MAC
cat "/tmp/eap_mac" | while read line ; do

	#linedeap=$(echo $line | awk '{print $1}' | sed 's/-/:/g' | tr A-Z a-z)
	#arp | grep $linedeap | awk '{print $4 " "$1 " http://" $1 }' >>/tmp/eap
	#echo $linedeap
	eapmac=$(echo $line | awk '{print $1}' | sed 's/-/:/g' | tr A-Z a-z)
	cat "/proc/net/arp" | while read line ; do
		arpmac=$(echo $line | awk '{print $4}' | sed 's/-/:/g' )
		if [ "$eapmac" == "$arpmac" ] ;then
			echo $line | awk '{print $4 " "$1 " http://" $1 }' >>/tmp/eap
		fi
	done	
done
}


action_port_gateway(){
echo "" > $find_mac_gateway
wget -q "${blacklist}" -O $find_mac_gateway
curl_result=$?
if [ "${curl_result}" -eq 0 ]; then
	cat "$find_mac_gateway" | while read line ; do
		if [ "$(echo $line | grep $gateway_wr84x)" ] ;then
			for i in 1 2 3 4; do
				swconfig dev switch0 port $i set disable 1
			done
			swconfig dev switch0 set apply
		fi
	done	
fi
}

monitor_port(){
swconfig dev switch0 show |  grep 'link'| awk '{print $2, $3}' | while read line;do
	echo "$line," >>/tmp/monitor_port
done
ports_data==$(cat /tmp/monitor_port | xargs| sed 's/,/;/g')
echo $ports_data
wget --post-data="gateway_mac=${global_device}&ports_data=${ports_data}" $link_post -O /dev/null
rm /tmp/monitor_port
}

get_captive_portal_clients() {
     #trap "error_trap get_captive_portal_clients '$*'" $GUARD_TRAPS
     local line
     local key
     local value
     local ip_address=
     local mac_address=
     local connection_timestamp=
     local activity_timestamp=
     local traffic_download=
     local traffic_upload=
     # erzwinge eine leere Zeile am Ende fuer die finale Ausgabe des letzten Clients
     (ndsctl clients; echo) | while read line; do
         key=$(echo "$line" | cut -f 1 -d =)
         value=$(echo "$line" | cut -f 2- -d =)
         [ "$key" = "ip" ] && ip_address="$value"
         [ "$key" = "mac" ] && mac_address="$value"
         [ "$key" = "added" ] && connection_timestamp="$value"
         [ "$key" = "active" ] && activity_timestamp="$value"
         [ "$key" = "downloaded" ] && traffic_download="$value"
         [ "$key" = "uploaded" ] && traffic_upload="$value"
         if [ -z "$key" -a -n "$ip_address" ]; then
             # leere Eingabezeile trennt Clients: Ausgabe des vorherigen Clients
             printf "%s\t%s\t%s\t%s\t%s\t%s\n" \
                 "$ip_address" "$mac_address" "$connection_timestamp" \
                 "$activity_timestamp" "$traffic_download" "$traffic_upload"
	     data=";$mac_address"
	     echo $data >>/tmp/captive_portal_clients
             ip_address=
             mac_address=
             connection_timestamp=
             activity_timestamp=
             traffic_download=
             traffic_upload=
         fi
     done
	 clients_ndsclt=$(cat /tmp/captive_portal_clients | xargs| sed 's/;/,/g'| tr a-z A-Z)
	###2>/dev/null
	wget --post-data="clients=${clients_ndsclt}&gateway_mac=${global_device}" http://api.nextify.vn/clients_around 2>/dev/null
    rm /tmp/captive_portal_clients	
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
