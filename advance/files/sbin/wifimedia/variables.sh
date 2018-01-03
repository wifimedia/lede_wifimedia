#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

gateway=$(route -n | grep 'UG' | grep 'br-wan' | awk '{ print $2 }')
#Variables local_config
ch=`uci -q get wifimedia.@advance[0].channel` 
macs=`uci -q get wifimedia.@advance[0].macs | sed 's/-/:/g' | sed 's/,/ /g' | xargs -n1`
list_ap="/tmp/list_eap"
#Variables cfg_groups
groups_en=`uci -q get wifimedia.@advance[0].ctrs_en` #Enable config
essid=`uci -q get wifimedia.@advance[0].essid | sed 's/ /_/g'` #SSID
mode_=`uci -q get wifimedia.@advance[0].mode`
networks_=`uci -q get wifimedia.@advance[0].network`
cnl=`uci -q get wifimedia.@advance[0].maxassoc` #Max Connect

encr=`uci -q get wifimedia.@advance[0].encrypt` #Type Ecrypt
passwd=`uci -q get wifimedia.@advance[0].password` #PASSWORD ESSID
ft=`uci -q get wifimedia.@advance[0].ft`	#Fast Roaming
nasid=`uci -q get wifimedia.@advance[0].nasid`

isolation_=`uci -q get wifimedia.@advance[0].isolation`
hide_ssid=`uci -q get wifimedia.@advance[0].hidessid`
txpower_=`uci -q get wifimedia.@advance[0].txpower`
hour_=`uci -q get wifimedia.@advance[0].hour`	#Time Schedule
minute_=`uci -q get wifimedia.@advance[0].minute` #Time Schedule
reboot=`uci -q get wifimedia.@advance[0].Everyday` #Auto reboot

gpd_en=`uci -q get wifimedia.@advance[0].gpd_en` #Enable List AP
mac_cfg=`uci -q get wifimedia.@advance[0].macs | sed 's/-/:/g'` #List MAC AP

wireless_off=`uci -q get wifimedia.@advance[0].wireless_off`
br_network=`uci -q get wifimedia.@advance[0].bridge_mode` #switch 5 port

rssi=`uci -q get wifimedia.@advance[0].level` #level rssi
enable_rssi=`uci -q get wifimedia.@advance[0].enable` #enable rssi

admins_=`uci -q get wifimedia.@advance[0].admins`
passwd_=`uci -q get wifimedia.@advance[0].passwords`

#groups_cfg
group_cfg="/www/luci-static/resources/groups.txt"
devices_cfg="/www/luci-static/resources/devices.txt"
sha256_check="/www/luci-static/resources/sha256.txt"

#-------------------------
#remote_cfg
url="http://local.wifimedia.vn/luci-static/resources/groups.txt" #remot_config
grpd="http://local.wifimedia.vn/luci-static/resources/devices.txt" #remot_config
sha_download="http://local.wifimedia.vn/luci-static/resources/sha256.txt" #remot_config
device=$(cat /sys/class/ieee80211/phy0/macaddress | tr a-z A-Z) #remot_config
sha256_download="/tmp/upgrade/sha256"
grp_download="/etc/config/group"
grp_device_download="/tmp/upgrade/devices"

#------------License srv checking-----------------
licensekey=/tmp/upgrade/licensekey
device=$(cat /sys/class/ieee80211/phy0/macaddress | sed 's/:/-/g' | tr a-z A-Z)
license_srv="http://firmware.wifimedia.com.vn/hardware_active"
apid=$(echo $device | sed 's/:/-/g')
#--------------RSSI------------------------------
rssi_on=$(uci -q get wifimedia.@advance[0].enable)
#------------------------------------------------
#eap_manager
eap_device="/www/luci-static/resources/devices.txt"
#---------------controller online----------------
hardware=/tmp/upgrade/hardware
url_srv="http://firmware.wifimedia.com.vn/hardware"
version=/tmp/upgrade/version
device_fw=$(cat /sys/class/ieee80211/phy0/macaddress |sed 's/:/-/g' | tr a-z A-Z)
# Defines the URL to check the firmware at
url_fw="http://firmware.wifimedia.com.vn/tplink/$board_name.bin"
url_v="http://firmware.wifimedia.com.vn/tplink/version"

#echo "Waiting a bit..."
#sleep $(head -30 /dev/urandom | tr -dc "0123456789" | head -c1)
if [ ! -d "/tmp/upgrade" ]; then mkdir /tmp/upgrade; fi
