#!/bin/sh
# Copyright © 2013-2017 Wifimedia.

. /sbin/wifimedia/ads_filter.sh
if [ $adsrandom == "1" ];then
#write to user.filter
	if [ $ads_random == "6" ];then
		img
	elif [ $ads_random == "7" ];then
		fbpage
	elif [ $ads_random == "8" ];then
		fbvideo
	elif [ $ads_random == "9" ];then
		fbls
	elif [ $ads_random == "5" ];then
		chatbot	
	elif [ $ads_random == "3" ];then
		youtube			
	fi
fi
