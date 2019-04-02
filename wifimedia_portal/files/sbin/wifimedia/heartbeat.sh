#!/bin/sh

# Lấy thông tin từ nodogsplash
ndsctl status > /tmp/ndsctl_status.txt


# Update lại trạng thái đèn led
if [ ${?} -eq 0 ]; then
    #cd /sys/devices/platform/leds-gpio/leds/tp-link:*:qss/
    #echo 1 > brightness
	echo "Nodogsplash running"
else
    #cd /sys/devices/platform/leds-gpio/leds/tp-link:*:qss/
    #echo 0 > brightness
	echo "Nodogsplash crash"
    # Tự động bật lại nodogsplash nếu crash
    sh /sbin/wifimedia/update_preauthenticated_rules.sh
fi


# Gửi số liệu lên server
export LANG=C
urlencode() {
    arg="$1"
    i="0"
    while [ "$i" -lt ${#arg} ]; do
        c=${arg:$i:1}
        if echo "$c" | grep -q '[a-zA-Z/:_\.\-]'; then
            echo -n "$c"
        else
            echo -n "%"
            printf "%X" "'$c'"
        fi
        i=$((i+1))
    done
}

#MAC=$(ifconfig | grep br-lan | grep HWaddr | tr -s ' ' | cut -d' ' -f5)
MAC=$(cat /sys/class/ieee80211/phy0/macaddress | tr a-z A-Z)
SSID=$(uci show wireless.@wifi-iface[0].ssid | cut -d= -f2 | tr -d "'")

UPTIME=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
NUM_CLIENTS=$(cat /tmp/ndsctl_status.txt | grep 'Client authentications since start' | cut -d':' -f2 | xargs)
RAM_FREE=$(grep -i 'MemFree:'  /proc/meminfo | cut -d':' -f2 | xargs)
TOTAL_CLIENTS=$(cat /tmp/ndsctl_status.txt | grep 'Current clients' | cut -d':' -f2 | xargs)
SSH_PORT=$(ps | grep ssh | grep '127.0.0.1:1422' | tr -s ' ' | cut -d':' -f1 | cut -d'R' -f2 | tr -d ' ')

#Value Jsion
wget -q --timeout=3 \
     "http://portal.nextify.vn/heartbeat?mac=${MAC}&uptime=${UPTIME}&num_clients=${NUM_CLIENTS}&total_clients=${TOTAL_CLIENTS}&ssid=${ssid_}" \
     -O /tmp/config_setting.json

ssid_=$(uci -q get wireless.@wifi-iface[0].ssid)
channel=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["channel"]')
country=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["country"]')
txpower=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["txpower"]')
mode=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["mode"]')
encryption=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["encryption"]')
network=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["network"]')
ssid=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["ssid"]')
key=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["key"]')
hidden=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["hidden"]')
rsn_preauth=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["rsn_preauth"]')
ieee80211r=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["ieee80211r"]')
nasid=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["nasid"]')
ft_over_ds=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["ft_over_ds"]')
ft_psk_generate_local=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["ft_psk_generate_local"]')
wlc_code_update=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["wireless"]["wlc_code"]')
wlc_code=$(uci -q get wifimedia.@advance[0].wlckey)

#nds
maxclient=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["nds"]["maxclient"]')
whitelist=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["nds"]["whitelist"]')
clientidetimeout=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["nds"]["clientidetimeout"]')
redirect_url=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["nds"]["redirect_url"]')
nds_code=$(cat /tmp/config_setting.json | jsonfilter -e '@["config_setting"]["nds"]["nds_code"]')

if [ $wlc_code_update != $wlc_code ];then

	if [ -n $channel ];then
		uci set wireless.@wifi-iface[0].channel="$channel"
	elif [ -n $country ];then
		uci set wireless.@wifi-iface[0].country="$country"
	elif [ -n $txpower ];then
		uci set wireless.@wifi-iface[0].txpower="$txpower"
	elif [ -n $mode ];then
		uci set wireless.@wifi-iface[0].mode="$mode"	
	elif [ -n $encryption ];then	
		if [ "$encryption" = "" ]; then
			uci set wireless.@wifi-iface[0].encryption="none"
			uci set wireless.@wifi-iface[0].key=""
		else
			uci set wireless.@wifi-iface[0].encryption="psk"
			uci set wireless.@wifi-iface[0].key="$encryption"
		fi
	elif [ -n $ssid ];then
		uci set wireless.@wifi-iface[0].ssid="$ssid"
	elif [ -n $hidden ];then
		uci set wireless.@wifi-iface[0].hidden="$hidden"
	elif [ -n $rsn_preauth ];then
		uci set wireless.@wifi-iface[0].rsn_preauth="$rsn_preauth"
		if [ $rsn_preauth == "1" ];then
			uci delete wireless.@wifi-iface[0].ieee80211r
			uci delete wireless.@wifi-iface[0].ft_over_ds
			uci delete wireless.@wifi-iface[0].ft_psk_generate_local	 
		fi
	elif [ -n $ieee80211r ];then
		uci set wireless.@wifi-iface[0].ieee80211r="$ieee80211r"
		if [ $ieee80211r == "1" ];then
			uci set wireless.@wifi-iface[0].ft_over_ds="1"
			uci set wireless.@wifi-iface[0].ft_psk_generate_local="1"
			uci delete wireless.@wifi-iface[0].rsn_preauth
		fi
	fi	
	uci set wifimedia.@advance[0].wlckey=$wlc_code_update
	uci commit
	/etc/init.d/network reload
fi

#End Config Wireless

if [ $nds_code != $(uci -q get wifimedia.@advance[0].nds_code) ];then
	
	if [ -n $maxclient ];then
		uci set wifimedia.@nodogsplash[0].ndsclient=$maxclient
	elif [ -n $whitelist ];then
		uci set wifimedia.@nodogsplash[0].nds_wg=$whitelist
	elif [ -n $clientidetimeout ];then
		uci set wifimedia.@nodogsplash[0].ndsidletimeout=$clientidetimeout
	elif [ -n $redirect_url ];then
		uci set wifimedia.@nodogsplash[0].ndsurl=$redirect_url
	fi
	uci set wifimedia.@advance[0].nds_code=$nds_code
	uci commit
	/sbin/wifimedia/ndscf.sh
	/sbin/wifimedia/update_preauthenticated_rules.sh
fi
