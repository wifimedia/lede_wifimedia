#!/bin/sh
# Copyright © 2013-2017 WiFiMedia.
# All rights reserved.

temp_dir="/tmp/checkin"
status_file="$temp_dir/request.txt"
response_file="$temp_dir/response.txt"
temp_file="$temp_dir/tmp"

temp_dir="/tmp/checkin"
status_file="$temp_dir/request.txt"
response_file="$temp_dir/response.txt"
response_file_cfg="$temp_dir/response_cfg.txt"
temp_file="$temp_dir/tmp"
action_data="/etc/config/action_data"
noise_data=/tmp/noise_flag

if [ -e $status_file ]; then rm $status_file; fi
if [ -e $response_file ]; then rm $response_file; fi
if [ -e $temp_file ]; then rm $temp_file; fi
if [ ! -d "$temp_dir" ]; then mkdir $temp_dir; fi

#mac_device
mac_device=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }'|sed 's/:/-/g')
#IP_WAN_ROUTE
ip_dhcp_client=$(ifconfig br-wan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
#IP_LAN Router
ip_lan=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
#IP_WAN_GATEWAY
ip_gateway=$(route -n | grep 'UG' | grep 'br-wan' | awk '{ print $2 }')
#hotname
hostname=$(uci -q get system.@system[0].hostname)
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

#echo "" >$noise_data
if [ $(cat $noise_data) -eq 1 ];then
	noise=/tmp/noise.tmp
	echo "Checking the Noise"
	echo "" > $noise
	iw wlan0 survey dump | while read line; do
		if [ "$(echo $line | grep 'frequency')" ]; then
			echo ";$(echo $line | awk '{ print $2 $4 "-" $5}')," >> /tmp/noise.tmp
		elif [ "$(echo $line | grep 'noise')" ]; then
			echo $(echo $line | awk '{ print $2 }') >> /tmp/noise.tmp
		fi
	done
	echo "" >$noise_data
	noise=$(cat /tmp/noise.tmp | tr '\n' ' ' | sed 's/ //g')
fi

#echo $noise

echo "Checking the WLAN Info"
wlaninfo=/tmp/info.tmp
echo "" > $wlaninfo
iwinfo wlan0 info | while read line; do
	if [ "$(echo $line | grep 'ESSID')" ]; then
		echo "$(echo $line | awk '{ print $2 $3 }')" >> $wlaninfo
	elif [ "$(echo $line | grep 'Channel')" ]; then
		echo "$(echo $line | awk '{ print $3 $4 $5 $6 }')" >> $wlaninfo
	elif [ "$(echo $line | grep 'Noise')" ]; then
		echo "$(echo $line | awk '{ print $4 $5 $6 }')" >> $wlaninfo		
	fi
done
wlaninfo=$(cat $wlaninfo | tr '\n' ' ' | sed 's/ /;/g')
#echo $wlaninfo

# Saving Request Data
request_data="mac_device=${mac_device}&gateway=${ip_gateway}&ip_internal=${ip_dhcp_client}&ip_lan=${ip_lan}&model_device=${model_device}&load=${load}&uptime=${uptime}&hostname=${hostname}&wlaninfo=${wlaninfo}&noise=${noise}"
action_data="action=${mac_device}"
dashboard_protocol="http"
dashboard_server=$(uci -q get wifimedia.@sync[0].domain)
dashboard_url="checkin"
url="${dashboard_protocol}://${dashboard_server}/${dashboard_url}/${request_data}"

#url="http://device.wifimedia.vn/hotspot_data"
#url_action="http://device.wifimedia.vn/hotspot"
url_action="${dashboard_protocol}://${dashboard_server}/${dashboard_url}/${action_data}"

wget -q "${url_action}" -O $action_data
action_data=$(cat $action_data | sed 's/=/ /g' | awk '{print $2}')
echo $action_data

echo "----------------------------------------------------------------"
echo "Sending data:"
echo $url_test
if [ $action_data -eq 1 ];then
	wget -q "${url}" -O $response_file
else
	wget -q -s "${url}" -O $response_file
fi	
#curl "${url}" > $response_file
curl_result=$?
curl_data=$(cat $response_file)

	if [ "$curl_result" -eq "0" ]; then
		echo "Checked in to the dashboard successfully,"
		
		if grep -q "." $response_file; then
			echo "we have new settings to apply!"
		else
			echo "we will maintain the existing settings."
			exit
		fi
	else
		logger "WARNING: Could not checkin to the dashboard."
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
	#echo "0" > /tmp/nodogsplash_flag

	cat $response_file | sed 's/=/ /g'| while read line ; do
		one=$(echo $line | awk '{print $1}')
		two=$(echo $line | awk '{print $2}')
		
		echo "$one=$two"
		
		#Change hotname
		if [ "$one" = "system.hostname.name" ]; then
			uci set system.@system[0].hostname="$two"
		#Restart router	
		elif [ "$one" = "system.reboot" ]; then
			echo $two > /tmp/reboot_flag
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

		elif [ "$one" = "network.lan.ipaddr" ]; then
			uci set network.lan.ipaddr="$two"
		elif [ "$one" = "network.lan.netmask" ]; then
			uci set network.lan.netmask="$two"
			
		elif [ "$one" = "network.lan.proto" ]; then
			uci set network.lan.proto="$two"
		elif [ "$one" = "network.lan.ifname" ]; then
			uci set network.lan.ifname="$two"
		elif [ "$one" = "network.lan.type" ]; then
			uci set network.lan.type="$two"
		elif [ "$one" = "network.lan._orig_ifname" ]; then
			uci set network.lan._orig_ifname="$two"	
		elif [ "$one" = "network.lan._orig_bridge" ]; then
			uci set network.lan._orig_bridge="$two"	

		#DHCP
		elif [ "$one" = "dhcp.lan.interface" ]; then
			uci set dhcp.lan.interface="$two"	
		elif [ "$one" = "dhcp.lan.start" ]; then
			uci set dhcp.lan.start="$two"	
		elif [ "$one" = "dhcp.lan.limit" ]; then
			uci set dhcp.lan.limit="$two"					
		elif [ "$one" = "dhcp.lan.leasetime" ]; then
			uci set dhcp.lan.leasetime="$two"		
			
		#Schedule task
		elif [ "$one" = "scheduled.days.mon" ]; then
			uci set scheduled.days.Mon="$two"
			echo "1" > /tmp/schedule_task_flag
		elif [ "$one" = "scheduled.days.tue" ]; then
			uci set scheduled.days.Tue="$two"
			echo "1" > /tmp/schedule_task_flag
		elif [ "$one" = "scheduled.days.wed" ]; then
			uci set scheduled.days.Wed="$two"
			echo "1" > /tmp/schedule_task_flag
		elif [ "$one" = "scheduled.days.thu" ]; then
			uci set scheduled.days.Thu="$two"
			echo "1" > /tmp/schedule_task_flag
		elif [ "$one" = "scheduled.days.fri" ]; then
			uci set scheduled.days.Fri="$two"
			echo "1" > /tmp/schedule_task_flag
		elif [ "$one" = "scheduled.days.sat" ]; then
			uci set scheduled.days.Sat="$two"
			echo "1" > /tmp/schedule_task_flag
		elif [ "$one" = "scheduled.days.sun" ]; then
			uci set scheduled.days.Sun="$two"
			echo "1" > /tmp/schedule_task_flag
		elif [ "$one" = "scheduled.time.hour" ]; then
			uci set scheduled.time.hour="$two"
			echo "1" > /tmp/schedule_task_flag
		elif [ "$one" = "scheduled.time.minute" ]; then
			uci set scheduled.time.minute="$two"
			echo "1" > /tmp/schedule_task_flag
			
		#Wireless
		#SSID #1 (formerly Public SSID)
		elif [ "$one" = "wireless.ssid1.enabled" ]; then
			if [ "$two" == "1" ]; then
				uci set wireless.@wifi-iface[0].disabled="0"
			else
				uci get wireless.@wifi-iface[0].disabled="1"
			fi
		elif [ "$one" = "wireless.ssid1.hide" ]; then
			uci set wireless.@wifi-iface[0].hidden="$two"
		elif [ "$one" = "wireless.ssid1.ssid" ]; then
			two=$(echo $two | sed 's/*/ /g')
			uci set wireless.@wifi-iface[0].ssid="$two"
		elif [ "$one" = "wireless.ssid1.key" ]; then
			if [ "$two" = "" ]; then
				uci set wireless.@wifi-iface[0].encryption="none"
				uci set wireless.@wifi-iface[0].key=""
			else
				uci set wireless.@wifi-iface[0].encryption="mixed-psk"
				uci set wireless.@wifi-iface[0].key="$two"
			fi
		elif [ "$one" = "wireless.ssid1.isolate" ]; then
			uci set wireless.@wifi-iface[0].isolate="$two"
			
		#SSID #2 (formerly Public SSID)	
		elif [ "$one" = "wireless.ssid2.enabled" ]; then
			if [ "$two" == "1" ]; then
				if [ -z "$(uci get wireless.@wifi-iface[1])" ]; then uci add wireless wifi-iface; fi
				uci set wireless.@wifi-iface[1].network="lan"
				uci set wireless.@wifi-iface[1].mode="ap"
				uci set wireless.@wifi-iface[1].device="radio0"
			else
				uci set wireless.@wifi-iface[1].disabled=1
			fi
		elif [ "$one" = "wireless.ssid2.hide" ]; then
			uci set wireless.@wifi-iface[1].hidden="$two"
		elif [ "$one" = "wireless.ssid2.ssid" ]; then
			two=$(echo $two | sed 's/*/ /g')
			uci set wireless.@wifi-iface[1].ssid="$two"
		elif [ "$one" = "wireless.ssid2.key" ]; then
			if [ "$two" = "" ]; then
				uci set wireless.@wifi-iface[1].encryption="none"
				uci set wireless.@wifi-iface[1].key=""
			else
				uci set wireless.@wifi-iface[1].encryption="mixed-psk"
				uci set wireless.@wifi-iface[1].key="$two"
			fi
		elif [ "$one" = "wireless.ssid2.isolate" ]; then
			uci set wireless.@wifi-iface[1].isolate="$two"
			
		#Network SSID
		elif [ "$one" = "wireless.ssid1.network" ]; then
			uci set wireless.@wifi-iface[0].network="$two"
		elif [ "$one" = "wireless.ssid2.network" ]; then
			uci set wireless.@wifi-iface[1].network="$two"
			
		#AP mode
		elif [ "$one" = "wireless.ssid1.mode" ]; then	
			uci set wireless.@wifi-iface[0].mode="$two"
		elif [ "$one" = "wireless.ssid2.mode" ]; then	
			uci set wireless.@wifi-iface[1].mode="$two"

		#AP Channel
		elif [ "$one" = "wireless.ssid1.channel" ]; then	
			uci set wireless.@wifi-iface[0].channel="$two"
		elif [ "$one" = "wireless.ssid2.channel" ]; then	
			uci set wireless.@wifi-iface[1].channel="$two"		

		#AP country
		elif [ "$one" = "wireless.ssid1.country" ]; then	
			uci set wireless.@wifi-iface[0].country="$two"
		elif [ "$one" = "wireless.ssid2.country" ]; then	
			uci set wireless.@wifi-iface[1].country="$two"		

		#AP Connect Limit
		elif [ "$one" = "wireless.ssid1.maxassoc" ]; then	
			uci set wireless.@wifi-iface[0].maxassoc="$two"
		elif [ "$one" = "wireless.ssid2.maxassoc" ]; then	
			uci set wireless.@wifi-iface[1].maxassoc="$two"	

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
	

	# Restart all of the services
	/etc/init.d/network restart
	/etc/init.d/system reload

	if [ $(cat /tmp/lanifbr_flag) -eq 2 ]; then
		echo "moving interface: $(uci get network.lan.ifname) to the WAN"
		brctl delif br-lan $(uci -q get network.lan.ifname) && brctl addif br-wan $(uci -q get network.lan.ifname)	
	fi

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
	
	if [ $(cat /tmp/schedule_task_flag) -eq 1 ]; then
		echo "restarting the schedule task"
		/usr/bin/scheduled.sh start
	fi	
	##start nodogsplash
	#if [ $(cat /tmp/nodogsplash_flag) -eq 1 ]; then
	#	crontab /etc/cron_nds -u nds 
	#	/etc/init.d/cron restart
	#	/etc/init.d/nodogsplash enable
	###disable nodogsplash	
	#elif [ $(cat /tmp/nodogsplash_flag) -eq 2 ]; then
	#	/etc/init.d/nodogsplash disable
	#	/etc/init.d/nodogsplash stop
	#	/etc/init.d/firewall restart
	#	echo ''>/etc/crontabs/nds
	#	/etc/init.d/cron restart
	#	
	#fi	
	
	# Clear out the old files
	if [ -e $status_file ]; then rm $status_file; fi
	if [ -e $response_file ]; then rm $response_file; fi
	if [ -e $temp_file ]; then rm $temp_file; fi
	echo "----------------------------------------------------------------"
	echo "Successfully applied new settings"
	echo "update: Successfully applied new settings"
