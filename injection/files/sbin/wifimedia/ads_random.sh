#!/bin/sh
# Copyright © 2013-2017 Wifimedia.

#. /sbin/wifimedia/ads_settings.sh
user_acl_filter=/etc/privoxy/useracl.filter
ads_img=/tmp/img.txt
ads_fb_page=/tmp/fbpage.txt
ads_fb_video=/tmp/fbvideo.txt
ads_fb_like=/tmp/fblike.txt

ads_random=`head /dev/urandom | tr -dc "6789" | head -c1`
adsrandom=`uci -q get wifimedia.@adnetwork[0].random_status`
if [ $adsrandom == "1" ];then
#write to user.filter
	if [ $ads_random == "6" ];then
		cat $ads_img >$user_acl_filter
	elif [ $ads_random == "7" ];then
		cat $ads_fb_page >$user_acl_filter
	elif [ $ads_random == "8" ];then
		cat $ads_fb_video >$user_acl_filter
	elif [ $ads_random == "9" ];then
		cat $ads_fb_like >$user_acl_filter
	fi
fi