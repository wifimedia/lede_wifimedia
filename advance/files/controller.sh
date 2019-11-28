#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

. /sbin/wifimedia/variables.sh

ip_public(){
	PUBLIC_IP=`wget http://ipecho.net/plain -O - -q ; echo`
	#echo $PUBLIC_IP
}

meshdesk(){
	dnsctl=$(uci -q get meshdesk.internet1.dns)
	ip=`nslookup $dnsctl | grep 'Address' | grep -v '127.0.0.1' | grep -v '8.8.8.8' | grep -v '0.0.0.0'|grep -v '::' | awk '{print $3}'`
	if [ "$ip" != "" ] &&  [ -e /etc/config/meshdesk ];then
		uci set meshdesk.internet1.ip=$ip
		uci commit meshdesk
	fi
}

checking (){
	#Clear memory
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
					#echo "we will maintain the existing settings."
					#echo "Wrong License Code & auto reboot" >/etc/opt/license/status
					#enable cronjob chek key
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

monitor_port(){
swconfig dev switch0 show |  grep 'link'| awk '{print $2, $3}' | while read line;do
	echo "$line," >>/tmp/monitor_port
done
ports_data==$(cat /tmp/monitor_port | xargs| sed 's/,/;/g')
echo $ports_data
wget --post-data="gateway_mac=${global_device}&ports_data=${ports_data}" $link_post -O /dev/null
rm /tmp/monitor_port
}

##Sent Client MAC to server Nextify
get_client_connect_wlan(){
    ip_opvn=`ifconfig tun0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }'`
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
	#monitor_port
	wget --post-data="clients=${client_connect_wlan}&vpn=${ip_opvn}&gateway_mac=${global_device}" $cpn_url -O /dev/null
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
