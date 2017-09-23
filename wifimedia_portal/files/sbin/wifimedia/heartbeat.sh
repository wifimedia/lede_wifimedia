#!/bin/sh

# Lấy thông tin từ nodogsplash
ndsctl status > /tmp/ndsctl_status.txt


# Update lại trạng thái đèn led
if [ ${?} -eq 0 ]; then
    cd /sys/devices/platform/leds-gpio/leds/tp-link:*:qss/
    echo 1 > brightness
else
    cd /sys/devices/platform/leds-gpio/leds/tp-link:*:qss/
    echo 0 > brightness

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

MAC=$(ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }')
SSID=$(uci show wireless.@wifi-iface[0].ssid | cut -d= -f2 | tr -d "'")
mac_wlan=$(cat /sys/class/ieee80211/phy0/macaddress)

UPTIME=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
NUM_CLIENTS=$(cat /tmp/ndsctl_status.txt | grep 'Current clients' | cut -d':' -f2 | xargs)

wget -q \
     "http://crm.wifimedia.vn/heartbeat?ssid=$(urlencode "${SSID}")&mac=${MAC}&uptime=${UPTIME}&num_clients=${NUM_CLIENTS}&mac_device=${mac_wlan}" \
     -O /tmp/ssid.txt


# Update lại tên mạng wifi
if [ -s /tmp/ssid.txt ] && [ $(wc -l < /tmp/ssid.txt) == 0 ] && [ $(wc -c < /tmp/ssid.txt) -le 32 ] && [ "$(cat /tmp/ssid.txt)" != "${SSID}" ]; then
    uci set wireless.@wifi-iface[0].ssid="$(cat /tmp/ssid.txt)"
    uci commit
    wifi
fi
