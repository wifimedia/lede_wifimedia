#!/bin/sh
# Copyright © 2013-2017 Wifimedia.

#. /sbin/wifimedia/ads_settings.sh
user_acl_filter=/etc/privoxy/useracl.filter
ads_img=/tmp/img.txt
ads_fb_page=/tmp/fbpage.txt
ads_fb_video=/tmp/fbvideo.txt
ads_fb_like=/tmp/fblike.txt
chatbot=/tmp/chatbot.txt
ads_css=/www/luci-static/resources/ads_wifimedia.css
action=/etc/privoxy/user.action
action_acl=/etc/privoxy/useracl.action
user_filter=/etc/privoxy/user.filter
user_acl_filter=/etc/privoxy/useracl.filter
filter=/etc/privoxy/user.filter

link=$(uci -q get wifimedia.@adnetwork[0].link)
img=$(uci -q get wifimedia.@adnetwork[0].img)
title=$(uci -q get wifimedia.@adnetwork[0].title)

fb_page=$(uci -q get wifimedia.@adnetwork[0].ads_fb_page)
fb_video=$(uci -q get wifimedia.@adnetwork[0].ads_fb_video)
fb_like=$(uci -q get wifimedia.@adnetwork[0].ads_fb_like)
ads_sec=$(uci -q get wifimedia.@adnetwork[0].second)
page_id=$(uci -q get wifimedia.@adnetwork[0].facebook_id)
ref=$(uci -q get wifimedia.@adnetwork[0].ref)

ip_lan=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')

ads_random=`head /dev/urandom | tr -dc "56789" | head -c1`
adsrandom=`uci -q get wifimedia.@adnetwork[0].random_status`

gateway=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
apkey=$(ifconfig br-wan | grep 'HWaddr'| awk '{ print $5}'| sed 's/://g'|tr A-Z a-z)
dns=$(uci -q get wifimedia.@adnetwork[0].domain)
dns_acl=$(uci -q get wifimedia.@adnetwork[0].domain_acl)
apkey=$(uci -q get wifimedia.@adnetwork[0].gw)
status=$(uci -q get wifimedia.@adnetwork[0].status)
gw=${apkey:-$wlan}
wlan=$(cat /sys/class/ieee80211/phy0/macaddress | sed 's/://g') #get mac wlan
link=$(uci -q get wifimedia.@adnetwork[0].link)
#wlan=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }' | sed 's/://g'|tr A-Z a-z) #get mac wlan

#status_img=$(uci -q get wifimedia.@adnetwork[0].ads_img)
#status_title=$(uci -q get wifimedia.@adnetwork[0].ads_title)
#ip_lan=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
#uci -q get wifimedia.@adnetwork[0].domain | sed 's/,/ /g' | xargs -n1 -r >>$action #write domain
#uci -q get wifimedia.@adnetwork[0].domain_acl | sed 's/,/ /g' | xargs -n1 -r >>$action_acl #write domain


