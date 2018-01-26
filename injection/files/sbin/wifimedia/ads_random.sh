#!/bin/sh
# Copyright © 2013-2017 Wifimedia.

. /sbin/wifimedia/adslib.sh
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
	elif [ $ads_random == "5" ];then
		cat $chatbot >$user_acl_filter		
	fi
fi
