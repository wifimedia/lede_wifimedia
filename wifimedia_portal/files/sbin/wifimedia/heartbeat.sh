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
    sh /root/update_preauthenticated_rules.sh
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

MAC=$(ifconfig | grep br-lan | grep HWaddr | tr -s ' ' | cut -d' ' -f5)
SSID=$(uci show wireless.@wifi-iface[0].ssid | cut -d= -f2 | tr -d "'")

UPTIME=$(awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
NUM_CLIENTS=$(cat /tmp/ndsctl_status.txt | grep 'Client authentications since start' | cut -d':' -f2 | xargs)
RAM_FREE=$(grep -i 'MemFree:'  /proc/meminfo | cut -d':' -f2 | xargs)
TOTAL_CLIENTS=$(cat /tmp/ndsctl_status.txt | grep 'Current clients' | cut -d':' -f2 | xargs)
SSH_PORT=$(ps | grep ssh | grep '127.0.0.1:1422' | tr -s ' ' | cut -d':' -f1 | cut -d'R' -f2 | tr -d ' ')

wget -q --timeout=3 \
     "http://portal.nextify.vn/heartbeat?ssid=$(urlencode "${SSID}")&mac=${MAC}&uptime=${UPTIME}&num_clients=${NUM_CLIENTS}&total_clients=${TOTAL_CLIENTS
     -O /tmp/ssid.txt


# Update l...i t..n m...ng wifi
SSID_CLOUD=$(cat /tmp/ssid.txt)
if [ "${SSID_CLOUD}" != "${SSID}" ]; then
  echo 'Done'
  uci set wireless.@wifi-iface[0].ssid="${SSID_CLOUD}"
  uci commit
  wifi
fi