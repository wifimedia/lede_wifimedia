#!/bin/sh
# Copyright © 2013-2017 Wifimedia.

. /sbin/wifimedia/adslib.sh
#. /usr/bin/license.sh
#echo -e "*/10 * * * * /usr/bin/sync_ads.sh" >/tmp/ads_update
#echo -e "* * * * * ifup wan" >/tmp/ads_update
#crontab /tmp/ads_update -u adnetwork
#config user.action && user.filter


#if [ -z $dns ];then
#	echo '{-filter{user-adv}}' >$action
	#echo '/' >>$action
#else
#	echo '{+filter{user-adv}}' >$action
	#echo '/' >>$action
#fi
if [ -z $dns_acl ];then
	echo '{-filter{user-ads}}' >$action_acl
else
	echo '{+filter{user-ads}}' >$action_acl
fi

echo ${dns:-/} | sed 's/,/ /g' | xargs -n1 -r >>$action #write domain
echo ${dns_acl:-/} | sed 's/,/ /g' | xargs -n1 -r >>$action_acl #write domain


#write to user.filter
#echo 'FILTER:user-adv
#head-website
#s†(<(?:head|body)[^>]*?>)†$1\n\
#<script src="http://ads.wifimedia.vn/public/wifimedia/jquery.js"></script>\n\
#<script src="http://ads.wifimedia.vn/public/wifimedia/lib.js"></script>\n\
#<script src="http://ads.wifimedia.vn/public/wifimedia/'$gw'.js"></script>\n\
#†i ' >$user_filter

#echo 'FILTER:user-ads' >$user_acl_filter

if [ $status == "Image" ];then
	/sbin/wifimedia/ads_filter.sh
	cat $ads_img >$user_acl_filter
elif [ $status == "Facebook_Page" ];then
	/sbin/wifimedia/ads_filter.sh
	cat $ads_fb_page >$user_acl_filter
elif [ $status == "Facebook_videos" ];then
	/sbin/wifimedia/ads_filter.sh
	cat $ads_fb_video >$user_acl_filter
elif [ $status == "Facebook_Like_Share" ];then
	/sbin/wifimedia/ads_filter.sh
	cat $ads_fb_like >$user_acl_filter
elif [ $status == "Chatbot" ];then
	/sbin/wifimedia/ads_filter.sh
	cat $chatbot >$user_acl_filter	
fi

#echo '
#vnexpress/giaitri <div class="watch-sidebar-section">
#s†'$div1'\s*?\
#†<div id="wifimedia_background" style="opacity: 1; position: relative; z-index: 2; background: transparent none repeat scroll 0% 0%; overflow: hidden; width: 100%; display: block; visibility: visible; height: 100%;">\n\
#	<a target="_blank" href="'$link'"><img style="margin:3px 1px 1px 3px;" border="0" width="100%" src="'$img'" height="100%">\</a></div>\n\
#\'$div1'†' >/etc/privoxy/user.filter
