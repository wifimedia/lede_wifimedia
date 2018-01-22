#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

. /sbin/wifimedia/variables.sh
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
		cd /sys/devices/platform/leds-gpio/leds/tp-link:red:wan/
		echo timer > trigger
	else
		cd /sys/devices/platform/leds-gpio/leds/tp-link:red:wan/
		echo 0 > brightness
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

checking (){
	model=$(cat /proc/cpuinfo | grep 'machine' | cut -f2 -d ":" | cut -b 10-50 | tr ' ' '_')
	if [ "$model" == "TL-WR840N_v4" ];then
		wr840v4
		eap_manager
	elif [ "$model" == "TL-WR841N_v13" ];then
		wr841v13
		eap_manager
	elif [ "$model" == "TL-WR940N_v4" ];then
		wr940v5
	elif [ "$model" == "TL-WR940N_v6" ];then
		wr940v6
	fi
	#Clear memory
	if [ "$(cat /proc/meminfo | grep 'MemFree:' | awk '{print $2}')" -lt 5000 ]; then
		sync && echo 3 > /proc/sys/vm/drop_caches
	fi
}

remote_cfg() {

echo "" > $sha256_download
wget -q "${sha_download}" -O $sha256_download
curl_result=$?

if [ "${curl_result}" -eq 0 ]; then
echo "Checking download sha256sum"
	if [ "$(uci -q get wifimedia.@advance[0].sha256)" != "$(cat $sha256_download | awk '{print $2}')" ]; then #Checking SHA neu thay do thi moi apply

		wget -q "${url}" -O $grp_download
		wget -q "${grpd}" -O $grp_device_download
		cat "$grp_device_download" | while read line ; do
			if [ "$(echo $line | grep $device_cfg)" ] ;then #tim thiet bi xem co trong groups hay khong
					uci set wifimedia.@advance[0].ctrs_en="1" #update config
				cat "$grp_download" | while read line ; do
				
					if [ "$(echo $line | grep 'NETWORK')" ] ;then #Tim LAN/WAN
						uci set wireless.@wifi-iface[0].network="$(echo $line | awk '{print $2}')"
						uci set wifimedia.@advance[0].network="$(echo $line | awk '{print $2}')"
						
					elif [ "$(echo $line | grep 'MODE')" ] ;then #Tim ap/mesh/wds
						uci set wireless.@wifi-iface[0].mode="$(echo $line | awk '{print $2}')"
						uci set wifimedia.@advance[0].mode="$(echo $line | awk '{print $2}')"
						
					elif [ "$(echo $line | grep 'ESSID')" ] ;then #Tim ten ESSID WIFI
						essid="$(echo $line | awk '{print $2}')"
						echo "ESSID: $essid"
						if [ -z "$essid" ];then
							echo "no change SSID"
						else 
							uci set wireless.@wifi-iface[0].ssid="$(echo $line | awk '{print $2}')"
						fi
						uci set wifimedia.@advance[0].essid="$essid"
						
					elif [ "$(echo $line | grep 'CLN')" ] ;then #Tim maxassoc
						uci set wireless.@wifi-iface[0].maxassoc="$(echo $line | awk '{print $2}')"
						uci set wifimedia.@advance[0].maxassoc="$(echo $line | awk '{print $2}')"
						
					elif [ "$(echo $line | grep 'PASSWORD')" ] ;then #Tim mat khau
						if [ "$(echo $line | awk '{print $2}')" == " " ];then
							uci delete wireless.@wifi-iface[0].encryption
							uci delete wireless.@wifi-iface[0].key
							uci delete wireless.@wifi-iface[0].ieee80211r
							uci delete wireless.@wifi-iface[0].rsn_preauth
							uci delete wifimedia.@advance[0].encrypt
							uci commit wireless
							rm -f >/etc/FT
						else	
							uci set wireless.@wifi-iface[0].encryption="psk2"
							uci set wireless.@wifi-iface[0].key="$(echo $line | awk '{print $2}')"
							uci set wifimedia.@advance[0].password="$(echo $line | awk '{print $2}')"
							uci set wifimedia.@advance[0].encrypt="encryption"
						fi
						
					elif [ "$(echo $line | grep 'FT')" ] ;then #enable Fast Roaming

						if [ "$(echo $line | awk '{print $2}')" == "ieee80211r"  ];then
							uci set wireless.@wifi-iface[0].ieee80211r="1"
							uci set wireless.@wifi-iface[0].ft_psk_generate_local="1"
							uci delete wireless.@wifi-iface[0].rsn_preauth
							uci set wifimedia.@advance[0].ft="ieee80211r"
							echo "Fast BSS Transition Roaming" >/etc/FT
							#Delete List r0kh r1kh
							uci del wireless.default_radio0.r0kh
							uci del wireless.default_radio0.r1kh
							#add List r0kh r1kh
							cat "$grp_device_download" | while read  line;do #add list R0KH va R1KH
								uci add_list wireless.@wifi-iface[0].r0kh="$(echo $line | awk '{print $2}'),$(echo $line | awk '{print $1}'),000102030405060708090a0b0c0d0e0f"
								uci add_list wireless.@wifi-iface[0].r1kh="$(echo $line | awk '{print $2}'),$(echo $line | awk '{print $2}'),000102030405060708090a0b0c0d0e0f"
							done

						else #Fast Roaming Preauth RSN C
							uci delete wireless.@wifi-iface[0].ieee80211r
							uci delete wireless.@wifi-iface[0].ft_psk_generate_local
							uci set wireless.@wifi-iface[0].rsn_preauth="1"
							uci set wifimedia.@advance[0].ft="rsn_preauth"
							echo "Fast-Secure Roaming" >/etc/FT
						fi	
					elif [ "$(echo $line | grep 'NASID')" ] ;then #NASID
						mactmp="/tmp/mac_device"
						echo ''>$mactmp
						nas_id="$(echo $line | awk '{print $2}')"
						if [ -z "$nas_id" ];then
							uci del wireless.default_radio0.r0kh
							uci del wireless.default_radio0.r1kh
						else	
							uci set wireless.@wifi-iface[0].nasid="$(echo $line | awk '{print $2}')"
							uci set wifimedia.@advance[0].nasid="$(echo $line | awk '{print $2}')"
						fi	
						cat "$grp_device_download" | while read line ; do
							if [ "$(echo $line | grep $(echo $line | awk '{print $2}'))" ];then
								echo $line | awk '{print $2}' >>$mactmp
							fi
						done
						uci set wifimedia.@advance[0].macs="$(cat $mactmp | xargs | sed 's/:/-/g' | sed 's/ /,/g')"
					elif [ "$(echo $line | grep 'HIDE')" ] ;then #HIDE
						if [ "$(echo $line | awk '{print $2}')" == "1"  ];then
							uci set wireless.@wifi-iface[0].hidden="1"
							uci set wifimedia.@advance[0].hidessid="1"
						else
							uci set wireless.@wifi-iface[0].hidden="0"
							uci set wifimedia.@advance[0].hidessid="0"
							#uci delete wireless.@wifi-iface[0].hidden #uci: Entry not found
						fi					
					
					elif [ "$(echo $line | grep 'admin')" ] ;then #Change Password admin
						echo -e "$(echo $line | awk '{print $2}')\n$(echo $line | awk '{print $2}')" | passwd admin							
			
					elif [ "$(echo $line | grep 'Isolation')" ] ;then #enable Fast Roaming

						if [ "$(echo $line | awk '{print $2}')" == "1"  ];then
							uci set wireless.@wifi-iface[0].isolate="1"
							uci set wifimedia.@advance[0].isolation="1"
						else
							#uci delete wireless.@wifi-iface[0].isolate
							uci set wireless.@wifi-iface[0].isolate="0"
							uci set wifimedia.@advance[0].isolation="0"
						fi
					#Txpower
					elif [ "$(echo $line | grep 'TxPower')" ] ;then #enable Fast Roaming

						if [ "$(echo $line | grep 'auto')"  ];then
							uci delete wireless.@wifi-device[0].txpower
							uci set wifimedia.@advance[0].txpower="auto"
						elif [ "$(echo $line | grep 'low')"  ];then
							uci set wireless.@wifi-device[0].txpower=17
							uci set wifimedia.@advance[0].txpower="low"
						elif [ "$(echo $line | grep 'medium')"  ];then
							uci set wireless.@wifi-device[0].txpower=20
							uci set wifimedia.@advance[0].txpower="medium"
						elif [ "$(echo $line | grep 'high')"  ];then
							uci set wireless.@wifi-device[0].txpower=22
							uci set wifimedia.@advance[0].txpower="high"
						fi
					elif [ "$(echo $line | grep 'RSSI')" ] ;then #RSSI
						rssi="$(echo $line | awk '{print $2}')"
						if [ -z "$rssi" ];then
							uci set wifimedia.@advance[0].enable="0"
							/etc/init.d/watchcat stop && /etc/init.d/watchcat disable
						else
							uci set wifimedia.@advance[0].enable="1"
							/etc/init.d/watchcat start && /etc/init.d/watchcat enable
							uci set wifimedia.@advance[0].level="$rssi"
						fi
					elif [ "$(echo $line | grep 'BRIDGE')" ] ;then #BRIDGE
					
						if [ "$(echo $line | awk '{print $2}')" == "1"  ];then
							uci delete network.lan
							uci set network.wan.proto='dhcp'
							uci set network.wan.ifname='eth0 eth1.1'
							uci set wireless.@wifi-iface[0].network='wan'
							uci set wifimedia.@advance[0].bridge_mode='1'
						else
							uci set network.lan='interface'
							uci commit network
							uci set network.lan.proto='static'
							uci set network.lan.ipaddr='172.16.99.1'
							uci set network.lan.netmask='255.255.255.0'
							uci set network.lan.type='bridge'
							uci set network.lan.ifname='eth1.1'
							uci set dhcp.lan.force='1'
							uci set dhcp.lan.netmask='255.255.255.0'
							uci del dhcp.lan.dhcp_option
							uci add_list dhcp.lan.dhcp_option='6,8.8.8.8,8.8.4.4'			
							uci set network.wan.ifname='eth0'
							uci set wireless.@wifi-iface[0].network='wan'
							uci set wifimedia.@advance[0].bridge_mode='0'
						fi						
					fi
					wifi up
					####Auto reboot every day
					if [ "$(echo $line | grep 'Reboot')" ] ;then #Auto Reboot every day
						if [ "$(echo $line | awk '{print $2}')" == "1"  ];then
							echo -e "0 5 * * 0,1,2,3,4,5,6 sleep 70 && touch /etc/banner && reboot" >/tmp/autoreboot
							crontab /tmp/autoreboot -u wifimedia
							/etc/init.d/cron start
							#ntpd -q -p 0.asia.pool.ntp.org				
							uci set scheduled.days.Mon=1
							uci set scheduled.days.Tue=1
							uci set scheduled.days.Wed=1
							uci set scheduled.days.Thu=1
							uci set scheduled.days.Fri=1
							uci set scheduled.days.Sat=1
							uci set scheduled.days.Sun=1
							uci set scheduled.time.minute="$(echo $line | awk '{print $4}')"
							uci set scheduled.time.hour="$(echo $line | awk '{print $3}')"
						fi
					else
						echo -e "" >/tmp/autoreboot
						crontab /tmp/autoreboot -u wifimedia
						/etc/init.d/cron start
						uci delete scheduled.days
						uci set scheduled.days=instance
						uci delete scheduled.time
						uci set scheduled.time=times
					fi
					####END Auto reboot every day
					#commit sha256
					uci set wifimedia.@advance[0].sha256="$(sha256sum $grp_download | awk '{print $1}')"
					#switch interface wireless
					#if [ "$(uci -q get wifimedia.@advance[0].wireless_cfg)" == "0" ]; then
					#	cat /sbin/wifimedia/wifi.lua >/usr/lib/lua/luci/model/cbi/admin_network/wifi.lua
					#	uci set wifimedia.@advance[0].wireless_cfg=1
					#fi	
				done
				uci commit wifimedia
				uci commit wireless
				uci commit scheduled
				uci commit network
				uci commit dhcp
				wifi up
				# Restart all of the services
				/bin/ubus call network reload >/dev/null 2>/dev/null 
				echo "update: Successfully applied new settings"
			fi
		done
	fi
fi
}

local_config(){
touch  /tmp/list_eap
if [ "$groups_en" == "1" ];then
	#Network
	uci set wireless.@wifi-iface[0].network="$networks_"
	#Mode
	uci set wireless.@wifi-iface[0].mode="$mode_"
	#ESSID
	if [ -z "$essid" ];then
		echo "no change SSID"
	else 
		uci set wireless.@wifi-iface[0].ssid="$essid"
	fi
	#channel
	uci set wireless.radio0.channel="$ch"
	#Connect Limit
	uci set wireless.@wifi-iface[0].maxassoc="$cnl"
	#Passwd ssid
	if [ -z "$passwd" ];then
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
		uci set wireless.@wifi-iface[0].ft_psk_generate_local="1"
		uci delete wireless.@wifi-iface[0].rsn_preauth
		echo "Fast BSS Transition Roaming" >/etc/FT
		
		#delete all r0kh r1kh
		uci del wireless.default_radio0.r0kh
		uci del wireless.default_radio0.r1kh
		echo "$macs"  | while read  line;do #add list R0KH va R1KH
			uci add_list wireless.@wifi-iface[0].r0kh="$(echo $line | awk '{print $1}'),$nasid,000102030405060708090a0b0c0d0e0f"
			uci add_list wireless.@wifi-iface[0].r1kh="$(echo $line | awk '{print $1}'),$(echo $line | awk '{print $1}'),000102030405060708090a0b0c0d0e0f"
		done

		if [ -z $(uci -q get wifimedia.@advance[0].macs) ];then
		#echo "test rong"
			uci del wireless.default_radio0.r0kh
			uci del wireless.default_radio0.r1kh	
		fi
		#uci commit wireless
	else
		uci delete wireless.@wifi-iface[0].ieee80211r
		uci delete wireless.@wifi-iface[0].ft_psk_generate_local
		uci set wireless.@wifi-iface[0].rsn_preauth="1"
		uci del wireless.default_radio0.r0kh
		uci del wireless.default_radio0.r1kh
		echo "Fast-Secure Roaming" >/etc/FT
	fi
	#NASID
	if [ -z "$nasid" ];then
		uci del wireless.default_radio0.r0kh
		uci del wireless.default_radio0.r1kh
	else
		uci set wireless.@wifi-iface[0].nasid="$nasid"
	fi	

	#TxPower
	if [ "$txpower_" == "auto"  ];then
		uci delete wireless.@wifi-device[0].txpower
	elif [ "$txpower_" == "low"  ];then
		uci set wireless.@wifi-device[0].txpower="17"
	elif [ "$txpower_" == "medium"  ];then
		uci set wireless.@wifi-device[0].txpower="20"
	elif [ "$txpower_" == "high"  ];then
		uci set wireless.@wifi-device[0].txpower="22"
	fi
	
	#Hide SSID
	uci set wireless.@wifi-iface[0].hidden="$hide_ssid"
	#ISO
	uci set wireless.@wifi-iface[0].isolate="$isolation_"
	uci commit wireless
fi
sleep 5 && wifi

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
wget -q "${license_srv}" -O $licensekey
curl_result=$?
if [ "${curl_result}" -eq 0 ]; then
	if grep -q "." $licensekey; then
		cat "$licensekey" | while read line ; do
			if [ "$(echo $line | grep $apid)" ] ;then
				#Update License Key
				uci set wifimedia.@advance[0].wfm="$(cat /etc/opt/license/wifimedia)"
				uci commit wifimedia
				license_local
			else
				echo "we will maintain the existing settings."
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
time=$(uci -q get wifimedia.@advance[0].time)
time1=${days}
uptime="${time:-$time1}"
#uptime="${$(uci get license.active.time):-${days}}"
#uptime="${days}d:${hours}h:${min}m"
status=/etc/opt/wfm_status
lcs=/etc/opt/wfm_lcs
if [ "$(uci -q get wifimedia.@advance[0].wfm)" == "$(cat /etc/opt/license/wifimedia)" ]; then
	cat /etc/opt/license/wifimedia >/etc/opt/license/status
	touch $status
	rm $lcs
else
	echo "Wrong License Code" >/etc/opt/license/status
fi
if [ "$uptime" -gt 15 ]; then #>15days
	if [ "$(uci -q get wifimedia.@advance[0].wfm)" == "$(cat /etc/opt/license/wifimedia)" ]; then
		uci set wireless.radio0.disabled="0"
		uci commit wireless
		wifi
		touch $status
		rm $lcs
		cat /etc/opt/license/wifimedia >/etc/opt/license/status
	else
		echo "Wrong License Code" >/etc/opt/license/status
		uci set wireless.radio0.disabled="1"
		uci commit wireless
		wifi down
		rm $status
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

rssi() {

if [ $rssi_on == "1" ];then
	level_defaults=-80
	level=$(uci -q get wifimedia.@advance[0].level)
	level=${level%dBm}
	LOWER=${level:-$level_defaults}
	#echo $LOWER	
	dl_time=$(uci -q get wifimedia.@advance[0].delays)
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
