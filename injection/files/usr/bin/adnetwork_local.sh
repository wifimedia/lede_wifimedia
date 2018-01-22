#!/bin/sh
# Copyright © 2013-2017 Wifimedia.

. /sbin/wifimedia/ads_settings.sh
#. /usr/bin/license.sh
#echo -e "*/10 * * * * /usr/bin/sync_ads.sh" >/tmp/ads_update
#echo -e "* * * * * ifup wan" >/tmp/ads_update
#crontab /tmp/ads_update -u adnetwork
#config user.action && user.filter
action=/etc/privoxy/user.action
action_acl=/etc/privoxy/useracl.action
user_filter=/etc/privoxy/user.filter
user_acl_filter=/etc/privoxy/useracl.filter
filter=/etc/privoxy/user.filter
ads_img=/tmp/img.txt
ads_fb_page=/tmp/fbpage.txt
ads_fb_video=/tmp/fbvideo.txt
ads_fb_like=/tmp/fblike.txt

rm -f /etc/privoxy/default.filter
rm -f /etc/privoxy/default.action
rm -f /etc/privoxy/regression-tests.action
dns=$(uci -q get wifimedia.@adnetwork[0].domain)
dns_acl=$(uci -q get wifimedia.@adnetwork[0].domain_acl)
if [ -z $dns ];then
	echo '{-filter{user-adv}}' >$action
	echo '/' >>$action
else
	echo '{+filter{user-adv}}' >$action
	echo '/' >>$action
fi
if [ -z $dns_acl ];then
	echo '{-filter{user-ads}}' >$action_acl
	echo '/' >>$action_acl
else
	echo '{+filter{user-ads}}' >$action_acl
	echo '/' >>$action_acl
fi

#uci -q get wifimedia.@adnetwork[0].domain | sed 's/,/ /g' | xargs -n1 -r >>$action #write domain
#uci -q get wifimedia.@adnetwork[0].domain_acl | sed 's/,/ /g' | xargs -n1 -r >>$action_acl #write domain


echo ${dns:-/} | sed 's/,/ /g' | xargs -n1 -r >>$action #write domain
echo ${dns_acl:-/} | sed 's/,/ /g' | xargs -n1 -r >>$action_acl #write domain

#wlan=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }' | sed 's/://g'|tr A-Z a-z) #get mac wlan
wlan=$(cat /sys/class/ieee80211/phy0/macaddress | sed 's/://g') #get mac wlan
link=$(uci -q get wifimedia.@adnetwork[0].link)
#status_img=$(uci -q get wifimedia.@adnetwork[0].ads_img)
#status_title=$(uci -q get wifimedia.@adnetwork[0].ads_title)
#ip_lan=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
apkey=$(uci -q get wifimedia.@adnetwork[0].gw)
status=$(uci -q get wifimedia.@adnetwork[0].status)
gw=${apkey:-$wlan}

#write to user.filter
echo 'FILTER:user-adv
#head-website
s†(<(?:head|body)[^>]*?>)†$1\n\
<script src="http://ads.wifimedia.vn/public/wifimedia/jquery.js"></script>\n\
<script src="http://ads.wifimedia.vn/public/wifimedia/lib.js"></script>\n\
<script src="http://ads.wifimedia.vn/public/wifimedia/'$gw'.js"></script>\n\
†i ' >$user_filter

echo 'FILTER:user-ads' >$user_acl_filter

if [ $status == "Image" ];then
	cat $ads_img >$user_acl_filter
elif [ $status == "Facebook_Page" ];then
	cat $ads_fb_page >$user_acl_filter
elif [ $status == "Facebook_videos" ];then
	cat $ads_fb_video >$user_acl_filter
elif [ $status == "Facebook_Like_Share" ];then
	cat $ads_fb_like >$user_acl_filter
fi

#echo '
#vnexpress/giaitri <div class="watch-sidebar-section">
#s†'$div1'\s*?\
#†<div id="wifimedia_background" style="opacity: 1; position: relative; z-index: 2; background: transparent none repeat scroll 0% 0%; overflow: hidden; width: 100%; display: block; visibility: visible; height: 100%;">\n\
#	<a target="_blank" href="'$link'"><img style="margin:3px 1px 1px 3px;" border="0" width="100%" src="'$img'" height="100%">\</a></div>\n\
#\'$div1'†' >/etc/privoxy/user.filter
