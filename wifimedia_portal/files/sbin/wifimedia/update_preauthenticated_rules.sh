#!/bin/sh

# Wait for network up & running
while true; do
    ping -c1 -W1 8.8.8.8
    if [ ${?} -eq 0 ]; then
        break
    else
        sleep 1
    fi
done

#sh /root/create_ssh_tunnel.sh

NODOGSPLASH_CONFIG=/tmp/etc/nodogsplash.conf
PREAUTHENTICATED_ADDRS=/tmp/preauthenticated_addrs
PREAUTHENTICATED_RULES=/tmp/preauthenticated_rules
#whitelist=`uci get `
echo '' > ${PREAUTHENTICATED_ADDRS}
echo '' > ${PREAUTHENTICATED_RULES}

# Whitelist IP
for domain in firmware.wifimedia.com.vn ; do
    nslookup ${domain} 8.8.8.8 2> /dev/null | \
        grep 'Address ' | \
        grep -v '127\.0\.0\.1' | \
        grep -v '8\.8\.8\.8' | \
        grep -v '0\.0\.0\.0' | \
        awk '{print $3}' | \
        grep -v ':' >> ${PREAUTHENTICATED_ADDRS}
done

# Make rules
cat ${PREAUTHENTICATED_ADDRS} | sort | uniq | \
    xargs -n1 -r echo '    FirewallRule allow to' \
    > ${PREAUTHENTICATED_RULES}

mkdir -p /tmp/etc/

# Render config file
sed -e "/# include \/tmp\/preauthenticated_rules/ {" \
    -e "r ${PREAUTHENTICATED_RULES}" \
    -e "d" \
    -e "}" \
    /etc/nodogsplash/nodogsplash.conf \
    > ${NODOGSPLASH_CONFIG}

# Remove comments
sed -i -e 's/#.*$//' ${NODOGSPLASH_CONFIG}

# Tắt nodogsplash cũ nếu có
kill -9 $(ps | grep '[n]odogsplash' | awk '{print $1}')

# Bật nodogsplash mới
nodogsplash -c ${NODOGSPLASH_CONFIG}
if [ ${?} -eq 0 ]; then
   	cd /sys/devices/platform/leds-gpio/leds/tp-link:*:wps/
	#cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wps/
   	echo timer > trigger
fi
