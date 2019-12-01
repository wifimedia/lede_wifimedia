#!/bin/sh
# Copyright © 2013-2017 WiFiMedia.
# All rights reserved.

temp_dir="/tmp/checkin"
status_file="$temp_dir/request.txt"
response_file="$temp_dir/response.txt"
temp_file="$temp_dir/tmp"
action_data="/etc/config/action_data"

if [ ! -d "$temp_dir" ]; then
	mkdir $temp_dir
	echo "" >/tmp/checkin/request.txt
	echo "" >/tmp/checkin/response.txt

fi

#mac_device
#mac_device=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }'|sed 's/:/-/g')
mac_device=$(cat /sys/class/ieee80211/phy0/macaddress | sed 's/:/-/g' | tr a-z A-Z)
#IP_WAN_ROUTE
ip_dhcp_client=$(ifconfig br-wan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
#IP_LAN Router
ip_lan=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
#IP_WAN_GATEWAY
ip_gateway=$(route -n | grep 'UG' | grep 'br-wan' | awk '{ print $2 }')
#hotname
hostname=$(uci -q get system.@system[0].hostname)
wifi=$(pidof hostapd)

if [ "$wifi" != "" ];then
	wifi_status="Online"
else
	wifi_status="Offline"
fi

echo "Wifimedia checking"
echo "----------------------------------------------------------------"

echo "Calculating memory and load averages"
#memfree=$(free | grep 'Mem:' | awk '{print $4}')
#memtotal=$(free | grep 'Mem:' | awk '{print $2}')
#uptime
uptime=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
#load
load=$(uptime | awk '{ print $8 $9 $10 }')
echo "Getting the model information"
model_device=$(cat /proc/cpuinfo | grep 'machine' | cut -f2 -d ":" | cut -b 10-50 | tr ' ' '_')

# Saving Request Data
<<<<<<< HEAD
request_data="mac_device=${mac_device}&gateway=${ip_gateway}&ip_internal=${ip_dhcp_client}&ip_lan=${ip_lan}&model_device=${model_device}&load=${load}&uptime=${uptime}&hostname=${hostname}&wifi_status=${wifi_status}"
=======
request_data="mac_device=${mac_device}&gateway=${ip_gateway}&ip_internal=${ip_dhcp_client}&ip_lan=${ip_lan}&model_device=${model_device}&load=${load}&uptime=${uptime}&hostname=${hostname}&wlaninfo=${wlaninfo}&noise=${noise}"
>>>>>>> Blacklist
dashboard_protocol="http"
dashboard_server=$(uci -q get wifimedia.@sync[0].domain)
dashboard_url="checkin"
url_r="${dashboard_protocol}://${dashboard_server}/${dashboard_url}?${request_data}"

<<<<<<< HEAD
#url="http://device.wifimedia.vn/hotspot_data"
#url_action="http://device.wifimedia.vn/hotspot"
url_action="http://firmware.wifimedia.com.vn/data"

wget -q "${url_action}" -O $action_data
<<<<<<< HEAD
#if [ "$(cat "$action_data" | grep 'upgrade')" ] ;then
	#Upgrade firmware
<<<<<<< HEAD
	echo "upgrade"
	/sbin/wifimedia/controller_srv.sh upgrade_srv
fi
=======
#	echo "upgrade"
#	/sbin/wifimedia/upgrade.sh
#fi
>>>>>>> master
if [ "$(cat "$action_data" | grep 'facetory')" ] ;then
	echo "facetory..."
	/sbin/wifimedia/controller_srv.sh restore_srv
fi
if [ "$(cat "$action_data" | grep 'password')" ] ;then
	echo "password default"
	/sbin/wifimedia/controller_srv.sh passwd_admin_srv
fi
#if [ "$(cat "$action_data" | grep 'switchoff')" ] ;then
#	echo "switch off"
#	/sbin/wifimedia/switch_off.sh
#fi
if [ "$(cat "$action_data" | grep '802.11i')" ] ;then
	echo "802.11i"
	/sbin/wifimedia/controller_srv.sh preauth_rsn_srv
fi
if [ "$(cat "$action_data" | grep 'passwdwifi')" ] ;then
	echo "delete passwd wifi"
	/sbin/wifimedia/controller_srv.sh passwd_wifi
fi
if [ "$(cat "$action_data" | grep 'button')" ] ;then
	echo "disable button reset"
	/sbin/wifimedia/controller_srv.sh btn_reset
fi
<<<<<<< HEAD
if [ "$(cat "$action_data" | grep 'switchoff')" ] ;then
	echo "switch off"
	/sbin/wifimedia/switch_off.sh
fi
if [ "$(cat "$action_data" | grep '802.11i')" ] ;then
	echo "802.11i"
	/sbin/wifimedia/preauthen_rsn.sh
fi
if [ "$(cat "$action_data" | grep 'passwdwifi')" ] ;then
	echo "delete passwd wifi"
	/sbin/wifimedia/passwifi.sh
fi
if [ "$(cat "$action_data" | grep 'button')" ] ;then
	echo "delete passwd wifi"
	/sbin/wifimedia/button_reset.sh
fi
<<<<<<< HEAD
=======
>>>>>>> wr841v13_ext
=======
>>>>>>> master
=======
if [ "$(cat "$action_data" | grep 'upgrade')" ] ;then
	#Upgrade firmware
	echo "upgrade"
	/sbin/wifimedia/upgrade.sh
fi
if [ "$(cat "$action_data" | grep 'facetory')" ] ;then
	echo "facetory..."
	/sbin/wifimedia/restore_defaults.sh
fi
if [ "$(cat "$action_data" | grep 'password')" ] ;then
	echo "password default"
	/sbin/wifimedia/passwd_default.sh
fi
if [ "$(cat "$action_data" | grep 'switchoff')" ] ;then
	echo "switch off"
	/sbin/wifimedia/switch_off.sh
fi	
>>>>>>> Blacklist
if [ "$(cat "$action_data" | grep 'update')" ] ;then
	echo "updade"
	wget -q "${url}" -O $response_file
else
	echo "No..."
	wget -q -s "${url}" -O $response_file
	echo ${url}
	
fi
<<<<<<< HEAD
=======
url="http://firmware.wifimedia.com.vn/test"
>>>>>>> origin/wr84xx
=======
>>>>>>> Blacklist

echo "----------------------------------------------------------------"
echo "Sending data:"

<<<<<<< HEAD
echo $url_r
wget -q "${url_r}" -O $response_file
=======
>>>>>>> Blacklist
#curl "${url}" > $response_file
curl_result=$?

if [ "$curl_result" -eq "0" ]; then
	echo "Checked in to the dashboard successfully,"

	if [ "$(cat "$response_file" | grep 'Token' | awk '{print $2}')" != "$(uci -q get wifimedia.@advance[0].token)"  ] ;then
	#if grep -q "." $response_file; then
		echo "we have new settings to apply!"
	else
		echo "we will maintain the existing settings."
		exit
	fi
else
	echo "WARNING: Could not checkin to the dashboard."
	exit
fi

echo "----------------------------------------------------------------"
echo "Applying settings"

# define the hosts file
echo "127.0.0.1 localhost" > /etc/hosts
echo "0" > /tmp/reboot_flag
echo "0" > /tmp/lanifbr_flag
echo "0" > /tmp/schedule_task_flag

cat $response_file | sed 's/=/ /g'| while read line ; do

	one=$(echo $line | awk '{print $1}')
	two=$(echo $line | awk '{print $2}')
	three=$(echo $line | awk '{print $3}')
	
	echo "Name:$one Value:$two Value:$three"
	
	#Change hotname OK
	if [ "$one" = "system.hostname" ]; then
		uci set system.@system[0].hostname="$two"
	#Restart router	
	elif [ "$one" = "system.reboot" ]; then
		echo $two > /tmp/reboot_flag
	#Password OK
	elif [ "$one" = "system.admin.passwd" ]; then
		two=$(echo $two | sed 's/*/ /g')
		echo -e "$two\n$two" | passwd admin		
		
	#time update ok
	elif [ "$one" = "wifimedia.sync.time" ]; then

		sync_time="/tmp/checkin/sync_time.txt"
		echo "*/$two * * * * /sbin/wifimedia/updates.sh" >$sync_time
		crontab $sync_time -u live
		
<<<<<<< HEAD
	#Network wan
	elif [ "$one" = "network.wan.ipaddr" ]; then
		uci set network.wan.ipaddr="$two"
	elif [ "$one" = "network.wan.netmask" ]; then
		uci set network.wan.netmask="$two"
		
	elif [ "$one" = "network.wan.proto" ]; then
		uci set network.wan.proto="$two"
	elif [ "$one" = "network.wan.type" ]; then
		uci set network.wan.type="$two"
		
	#Network LAN
	elif [ "$one" = "network.lan.ipaddr" ]; then
		uci set network.lan.ipaddr="$two"
	elif [ "$one" = "network.lan.netmask" ]; then
		uci set network.lan.netmask="$two"
		
	elif [ "$one" = "network.lan.proto" ]; then
		uci set network.lan.proto="$two"
	elif [ "$one" = "network.lan.type" ]; then
		uci set network.lan.type="$two"
=======
		#Change hotname
		if [ "$one" = "system.hostname.name" ]; then
			uci set system.@system[0].hostname="$two"
		#Restart router	
		elif [ "$one" = "system.reboot" ]; then
			echo $two > /tmp/reboot_flag
		#Password
		elif [ "$one" = "system.ssh.password" ]; then
			two=$(echo $two | sed 's/*/ /g')
			echo -e "$two\n$two" | passwd root		
		#Time Sync	
		elif [ "$one" = "servers.ntp.server" ]; then
			uci set system.ntp.server="$two"
		elif [ "$one" = "servers.ntp.timezone" ]; then
			uci set system.@system[0].timezone="$two"
		elif [ "$one" = "servers.dns.domain" ]; then
			uci set dhcp.@dnsmasq[0].domain="$two"
			
		#time update
		elif [ "$one" = "wifimedia.sync.time" ]; then
	
			sync_time="/tmp/checkin/sync_time.txt"
			echo "*/$two * * * * /sbin/wifimedia/updates.sh" >$sync_time
			crontab $sync_time -u live
			
		#Network wan
		elif [ "$one" = "network.wan.ipaddr" ]; then
			uci set network.wan.ipaddr="$two"
		elif [ "$one" = "network.wan.netmask" ]; then
			uci set network.wan.netmask="$two"
			
		elif [ "$one" = "network.wan.proto" ]; then
			uci set network.wan.proto="$two"
		elif [ "$one" = "network.wan.ifname" ]; then
			uci set network.wan.ifname="$two"
		elif [ "$one" = "network.wan.type" ]; then
			uci set network.wan.type="$two"
			
		#Network LAN
>>>>>>> Blacklist

	#DHCP
	elif [ "$one" = "dhcp.lan.interface" ]; then
		uci set dhcp.lan.interface="$two"	
	elif [ "$one" = "dhcp.lan.start" ]; then
		uci set dhcp.lan.start="$two"	
	elif [ "$one" = "dhcp.lan.limit" ]; then
		uci set dhcp.lan.limit="$two"					
	elif [ "$one" = "dhcp.lan.leasetime" ]; then
		uci set dhcp.lan.leasetime="$two"		
		
	#Schedule task all
	elif [ "$one" = "scheduled" ]; then
		if [ "$two" == "enable" ];then
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
		else
			echo -e "" >/tmp/autoreboot
			crontab /tmp/autoreboot -u wifimedia
			/etc/init.d/cron start
			#ntpd -q -p 0.asia.pool.ntp.org				
			uci set scheduled.days.Mon=0
			uci set scheduled.days.Tue=0
			uci set scheduled.days.Wed=0
			uci set scheduled.days.Thu=0
			uci set scheduled.days.Fri=0
			uci set scheduled.days.Sat=0
			uci set scheduled.days.Sun=0			
		fi
	elif [ "$one" = "scheduled.time.hour" ]; then
		uci set scheduled.time.hour="$two"
		
	elif [ "$one" = "scheduled.time.minute" ]; then
		uci set scheduled.time.minute="$two"
		
	#Wireless
	#ESSID # (formerly Public ESSID)
	elif [ "$one" = "wireless.radio.enable" ]; then
		if [ "$two" == "enable" ]; then
			uci set wireless.radio0.disabled="0"
		else
			uci set wireless.radio0.disabled="1"
		fi
		
	elif [ "$one" = "wireless.essid.hide" ]; then
		uci set wireless.@wifi-iface[0].hidden="$two"
		
	elif [ "$one" = "wireless.essid.ssid" ]; then
		two=$(echo $two | sed 's/*/ /g')
		uci set wireless.@wifi-iface[0].ssid="$two"
		
	elif [ "$one" = "wireless.essid.key" ]; then
		if [ "$two" = "" ]; then
			uci set wireless.@wifi-iface[0].encryption="none"
			uci set wireless.@wifi-iface[0].key=""
		else
			uci set wireless.@wifi-iface[0].encryption="psk2"
			uci set wireless.@wifi-iface[0].key="$two"
		fi
		
	elif [ "$one" = "wireless.essid.isolate" ]; then
		uci set wireless.@wifi-iface[0].isolate="$two"
		
	#Network SSID
	elif [ "$one" = "wireless.essid.network" ]; then
		uci set wireless.@wifi-iface[0].network="$two"
		
	#AP mode
	elif [ "$one" = "wireless.essid.mode" ]; then	
		uci set wireless.@wifi-iface[0].mode="$two"

	#AP Channel
	elif [ "$one" = "wireless.essid.channel" ]; then	
		uci set wireless.@wifi-iface[0].channel="$two"
	#AP country
	elif [ "$one" = "wireless.essid.country" ]; then	
		uci set wireless.@wifi-iface[0].country="$two"	

	#AP Connect Limit
	elif [ "$one" = "wireless.essid.maxassoc" ]; then	
		uci set wireless.@wifi-iface[0].maxassoc="$two"
		
	#NASID
	elif [ "$one" = "wireless.essid.nasid" ];then
		if [ -z "$two" ];then
			uci del wireless.default_radio0.r0kh
			uci del wireless.default_radio0.r1kh
		else
			uci set wireless.@wifi-iface[0].nasid="$two"
		fi	
		uci commit wireless
	#AP 802.11i Preauth RSN
	#elif [ "$one" = "wireless.essid.rsn_preauth" ]; then	
	#	uci set wireless.@wifi-iface[0].rsn_preauth="$two"
	
	#AP 802.11r
	elif [ "$one" = "wireless.essid.fastroaming" ]; then
	
		nasid=`uci get wireless.@wifi-iface[0].nasid`
		
		if [ "$two" == "ieee80211r"  ];then
			uci set wireless.@wifi-iface[0].ieee80211r="1"
			uci set wireless.@wifi-iface[0].ft_psk_generate_local="1"
			uci delete wireless.@wifi-iface[0].rsn_preauth
			uci set wifimedia.@advance[0].ft="ieee80211r"
			echo "Fast BSS Transition Roaming" >/etc/FT
		
			if [ "$three" != "" ];then
				#Ghi du lieu APID ra file
				echo "$three" | sed 's/,/ /g' | sed 's/-/:/g' | xargs -n1 echo $nasid > /tmp/apid_list
			fi
			
			#Delete List r0kh r1kh
			uci del wireless.default_radio0.r0kh
			uci del wireless.default_radio0.r1kh
			
			#add List r0kh r1kh
			cat "/tmp/apid_list" | while read  line;do #add list R0KH va R1KH
				uci add_list wireless.@wifi-iface[0].r0kh="$(echo $line | awk '{print $2}'),$(echo $line | awk '{print $1}'),000102030405060708090a0b0c0d0e0f"
				uci add_list wireless.@wifi-iface[0].r1kh="$(echo $line | awk '{print $2}'),$(echo $line | awk '{print $2}'),000102030405060708090a0b0c0d0e0f"
			done

		else #Fast Roaming Preauth RSN C
			uci delete wireless.@wifi-iface[0].ieee80211r
			uci delete wireless.@wifi-iface[0].ft_psk_generate_local
			uci set wireless.@wifi-iface[0].rsn_preauth="1"
			uci set wifimedia.@advance[0].ft="rsn_preauth"
			uci del wireless.default_radio0.r0kh
			uci del wireless.default_radio0.r1kh
			uci del wireless.@wifi-iface[0].nasid
			echo "Fast-Secure Roaming" >/etc/FT
		fi	

	##upgrade
	elif [ "$one" = "ap.upgade" ]; then
		/sbin/wifimedia/controller_srv.sh upgrade_srv
	elif [ "$one" = "ap.reset" ]; then
		/sbin/wifimedia/controller_srv.sh restore_srv
	fi
done
uci set wifimedia.@advance[0].token="$(cat "$response_file" | grep 'Token' | awk '{print $2}')"
# Save all of that
uci commit

# Restart all of the services
/bin/ubus call network reload >/dev/null 2>/dev/null
/etc/init.d/system reload

<<<<<<< HEAD
if [ $(cat /tmp/lanifbr_flag) -eq 2 ]; then
	echo "moving interface: $(uci get network.lan.ifname) to the WAN"
	brctl delif br-lan $(uci -q get network.lan.ifname) && brctl addif br-wan $(uci -q get network.lan.ifname)	
fi
=======
		#AP 802.11i Preauth RSN
		elif [ "$one" = "wireless.ssid1.rsn_preauth" ]; then	
			uci set wireless.@wifi-iface[0].rsn_preauth="$two"
		elif [ "$one" = "wireless.ssid2.rsn_preauth" ]; then
			uci set wireless.@wifi-iface[1].rsn_preauth="$two"
			
		#Scan Noise
		elif [ "$one" = "wireless.noise.scan" ]; then
			if [ "$two" == "1" ]; then
				echo "1" > $noise_data
			else
				echo "0" > $noise_data
			fi	
			
		##nodogslplash
		#elif [ "$one" = "wifimedia.nodogsplash.nds_apkey" ]; then
		#	uci set wifimedia.@nodogsplash[0].nds_apkey="$two"
		#	
		#elif [ "$one" = "wifimedia.nodogsplash.nds_domain" ]; then
		#	uci set wifimedia.@nodogsplash[0].nds_domain="$two"
		#
		#elif [ "$one" = "wifimedia.nodogsplash.ndsurl" ]; then
		#	uci set wifimedia.@nodogsplash[0].ndsurl="$two"
		#
		#elif [ "$one" = "wifimedia.nodogsplash.nds_wg" ]; then
		#	uci set wifimedia.@nodogsplash[0].nds_wg="$two"
		#
		#elif [ "$one" = "wifimedia.nodogsplash.ndsclient" ]; then
		#	uci set wifimedia.@nodogsplash[0].ndsclient="$two"
		#
		#elif [ "$one" = "wifimedia.nodogsplash.ndsidletimeout" ]; then
		#	uci set wifimedia.@nodogsplash[0].ndsidletimeout="$two"
		#	
		#elif [ "$one" = "wifimedia.nodogsplash.enabled" ]; then
		#	if [ "$two" == "1" ]; then
		#		echo "1" > /tmp/nodogsplash_flag
		#	else
		#		echo "2" > /tmp/nodogsplash_flag
		#	fi	
			
		fi
	done
	# Save all of that
	uci commit
>>>>>>> Blacklist

if [ "$(brctl show | grep br-wan | awk '{print $3}')" = "no" ]; then
	echo "stp is is disabled on the WAN, enable stp"
	# Enable stp on the wan bridge
	sleep 1 && brctl stp br-wan on
fi

#Reboot
if [ $(cat /tmp/reboot_flag) -eq 1 ]; then
	echo "restarting the node"
	reboot
fi

echo "----------------------------------------------------------------"
echo "Successfully applied new settings"
echo "update: Successfully applied new settings"
