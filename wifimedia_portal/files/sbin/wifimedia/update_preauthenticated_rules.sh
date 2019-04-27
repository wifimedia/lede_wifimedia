#!/bin/s h

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
walledgadent=`uci get wifimedia.@nodogsplash[0].preauthenticated_users | sed 's/,/ /g'`

# Whitelist IP
for domain in portal.nextify.vn static.nextify.vn nextify.vn crm.nextify.vn $walledgadent; do
    nslookup ${domain} 8.8.8.8 2> /dev/null | \
        grep 'Address ' | \
        grep -v '127\.0\.0\.1' | \
        grep -v '8\.8\.8\.8' | \
        grep -v '0\.0\.0\.0' | \
        awk '{print $3}' | \
        grep -v ':' >> ${PREAUTHENTICATED_ADDRS}
done
###Read line file 

uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 53"
uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow udp port 53"
while read line; do
	uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow to $(echo $line)"
done <$PREAUTHENTICATED_ADDRS
uci commit

#grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"

# Make rules
#cat ${PREAUTHENTICATED_ADDRS} | sort | uniq | \
#    xargs -n1 -r echo '    FirewallRule allow to' \
#    > ${PREAUTHENTICATED_RULES}
#
#mkdir -p /tmp/etc/
#
## Render config file
#sed -e "/# include \/tmp\/preauthenticated_rules/ {" \
#    -e "r ${PREAUTHENTICATED_RULES}" \
#    -e "d" \
#    -e "}" \
#    /etc/nodogsplash/nodogsplash.conf \
#    > ${NODOGSPLASH_CONFIG}
#
## Remove comments
#sed -i -e 's/#.*$//' ${NODOGSPLASH_CONFIG}
#
## Tắt nodogsplash cũ nếu có
#kill -9 $(ps | grep '[n]odogsplash' | awk '{print $1}')
#
## Bật nodogsplash mới
#nodogsplash -c ${NODOGSPLASH_CONFIG}
##if [ ${?} -eq 0 ]; then
#   	#cd /sys/devices/platform/leds-gpio/leds/tp-link:*:wps/
#	#cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wps/
#   	#echo timer > trigger
##	echo "Nodogsplash running"
##fi
