#!/bin/sh
# Copyright © 2017 Wifimedia.vn.
# All rights reserved.

gateway=$(route -n | grep 'UG' | grep 'br-wan' | awk '{ print $2 }')

#check gateway
ping -c 3 "$gateway" > /dev/null
if [ $? -eq "0" ];then
	#cd /sys/devices/platform/leds-gpio/leds/tp-link:*:qss/
	#cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wps/
	#echo timer > trigger
	cd /sys/devices/platform/gpio-leds/leds/tl-wr840n-v4:*:wps/
	echo timer > trigger
else
	#cd /sys/devices/platform/leds-gpio/leds/tp-link:*:qss/
	#cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wps/
	#echo none > trigger
	cd /sys/devices/platform/gpio-leds/leds/tl-wr840n-v4:*:wps/
	echo none > trigger
fi

#checking internet
ping -c 10 "8.8.8.8" > /dev/null
if [ $? -eq "0" ];then
	#cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wan/
	#echo timer > trigger
	#cd /sys/devices/platform/leds-gpio/leds/tp-link:*:wan/
	cd /sys/devices/platform/gpio-leds/leds/tl-wr840n-v4:*:wan/
	echo timer > trigger
else
	#cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wan/
	#cd /sys/devices/platform/leds-gpio/leds/tp-link:*:wan/
	#echo none > trigger
	cd /sys/devices/platform/gpio-leds/leds/tl-wr840n-v4:*:wan/
	echo timer > trigger
fi
#Clear memory
if [ "$(cat /proc/meminfo | grep 'MemFree:' | awk '{print $2}')" -lt 5000 ]; then
	sync && echo 3 > /proc/sys/vm/drop_caches
fi
