#!/bin/sh

# Wait for network up & running
#while true; do
#    ping -c1 -W1 8.8.8.8
#    if [ ${?} -eq 0 ]; then
#        break
#    else
#        sleep 1
#    fi
#done

#Value
NODOGSPLASH_CONFIG=/tmp/etc/nodogsplash.conf
PREAUTHENTICATED_ADDRS=/tmp/preauthenticated_addrs
PREAUTHENTICATED_RULES=/tmp/preauthenticated_rules
NET_ID="nextify"
FW_ZONE="nextify"
IFNAME="nextify0.1" #VLAN1
walledgadent=`uci get wifimedia.@nodogsplash[0].preauthenticated_users | sed 's/,/ /g'`
domain=`uci -q get wifimedia.@nodogsplash[0].domain`
domain_default=${domain:-portal.nextify.vn/splash}
#redirecturl=`uci -q get wifimedia.@nodogsplash[0].redirecturl`
#redirecturl_default=${redirecturl:-https://google.com.vn}
preauthenticated_users=`uci -q get wifimedia.@nodogsplash[0].preauthenticated_users` #Walled Gardent
maxclients=`uci -q get wifimedia.@nodogsplash[0].maxclients`
maxclients_default=${maxclients:-250}
preauthidletimeout=`uci -q get wifimedia.@nodogsplash[0].preauthidletimeout`
preauthidletimeout_default=${preauthidletimeout:-30}
authidletimeout=`uci -q get wifimedia.@nodogsplash[0].authidletimeout`
authidletimeout_default=${authidletimeout:-120}
sessiontimeout=`uci -q get wifimedia.@nodogsplash[0].sessiontimeout`
sessiontimeout_default=${sessiontimeout:-20}
std=`expr $sessiontimeout_default \* 60`
checkinterval=`uci -q get wifimedia.@nodogsplash[0].checkinterval`
checkinterval_default=${checkinterval:-10}
ctv=`expr $checkinterval_default \* 60`
https=`uci -q get wifimedia.@nodogsplash[0].https`
MAC_E0=$(ifconfig eth1 | grep 'HWaddr' | awk '{ print $5 }')

uci set nodogsplash.@nodogsplash[0].enabled='1'
uci set nodogsplash.@nodogsplash[0].gatewayinterface="br-${NET_ID}";
#uci set nodogsplash.@nodogsplash[0].redirecturl="$redirecturl_default";
uci set nodogsplash.@nodogsplash[0].maxclients="$maxclients_default";
uci set nodogsplash.@nodogsplash[0].preauthidletimeout="$preauthidletimeout_default";
uci set nodogsplash.@nodogsplash[0].authidletimeout="$authidletimeout_default";
#uci set nodogsplash.@nodogsplash[0].sessiontimeout="$std";
uci set nodogsplash.@nodogsplash[0].sessiontimeout="$sessiontimeout_default";
uci set nodogsplash.@nodogsplash[0].checkinterval="$ctv";
# Whitelist IP
for i in portal.nextify.vn static.nextify.vn nextify.vn crm.nextify.vn $walledgadent; do
    nslookup ${i} 8.8.8.8 2> /dev/null | \
        grep 'Address ' | \
        grep -v '127\.0\.0\.1' | \
        grep -v '8\.8\.8\.8' | \
        grep -v '0\.0\.0\.0' | \
        awk '{print $3}' | \
        grep -v ':' >> ${PREAUTHENTICATED_ADDRS}
done
###Read line file 
uci del nodogsplash.@nodogsplash[0].users_to_router
uci del nodogsplash.@nodogsplash[0].authenticated_users
	uci add_list nodogsplash.@nodogsplash[0].users_to_router="allow all"
	uci add_list nodogsplash.@nodogsplash[0].authenticated_users="allow all"
uci commit
if [ $https == "1" ];then
	uci del nodogsplash.@nodogsplash[0].preauthenticated_users && uci commit
	uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 22"
	#uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 80"
	uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 443"
	uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 53"
	uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow udp port 53"
	while read line; do
		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow to $(echo $line)"
	done <$PREAUTHENTICATED_ADDRS

else
	uci del nodogsplash.@nodogsplash[0].preauthenticated_users && uci commit
	uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 22"
	#uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 80"
	#uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 443"
	uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 53"
	uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow udp port 53"
	while read line; do
		uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow to $(echo $line)"
	done <$PREAUTHENTICATED_ADDRS
fi
uci commit
rm -f $PREAUTHENTICATED_ADDRS
#write file splash
echo '<!doctype html>
<html lang="en">
  <head>
      <meta charset="utf-8">
      <title>$gatewayname</title>
  </head>
  <body>
      <form id="info" method="POST" action="//'$domain_default'">
          <input type="hidden" name="gateway_name" value="$gatewayname">
          <input type="hidden" name="gateway_mac" value="'$MAC_E0'">
          <input type="hidden" name="client_mac" value="$clientmac">
          <input type="hidden" name="num_clients" value="$nclients">
          <input type="hidden" name="uptime" value="$uptime">
          <input type="hidden" name="auth_target" value="$authtarget">
      </form>
      <script>
          document.getElementById("info").submit();
      </script>
  </body>
</html>' >/etc/nodogsplash/htdocs/splash.html

#write file infoskel
echo '<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>Whoops...</title>
        <meta http-equiv="refresh" content="0; url="//'$domain'">
        <style>
            html {
                background: #F7F7F7;
            }
        </style>
    </head>
    <body></body>
</html>' >/etc/nodogsplash/htdocs/status.html
/etc/init.d/nodogsplash enable

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
## T?t nodogsplash cu n?u có
#kill -9 $(ps | grep '[n]odogsplash' | awk '{print $1}')
#
## B?t nodogsplash m?i
#nodogsplash -c ${NODOGSPLASH_CONFIG}
##if [ ${?} -eq 0 ]; then
#   	#cd /sys/devices/platform/leds-gpio/leds/tp-link:*:wps/
#	#cd /sys/devices/platform/gpio-leds/leds/tl-wr841n-v13:*:wps/
#   	#echo timer > trigger
##	echo "Nodogsplash running"
##fi


#Create Network

#uci commit network
#uci commit dhcp
#uci commit firewall
#/etc/init.d/network restart
#/etc/init.d/dnsmasq restart
#/etc/init.d/firewall restart
/etc/init.d/nodogsplash stop
/etc/init.d/nodogsplash start


next_net(){

	uci set network.${NET_ID}=interface
	uci set network.${NET_ID}.ifname=${IFNAME}
	uci set network.${NET_ID}.proto=static
	uci set network.${NET_ID}.type=bridge
	uci set network.${NET_ID}.ipaddr=10.68.255.1
	uci set network.${NET_ID}.netmask=255.255.255.0
	uci set dhcp.${NET_ID}=dhcp
	uci set dhcp.${NET_ID}.interface=${NET_ID}
	uci set dhcp.${NET_ID}.start=100
	uci set dhcp.${NET_ID}.leasetime=1h
	uci set dhcp.${NET_ID}.limit=150
	uci set firewall.${FW_ZONE}=zone
	uci set firewall.${FW_ZONE}.name=${FW_ZONE}
	uci set firewall.${FW_ZONE}.network=${NET_ID}
	uci set firewall.${FW_ZONE}.forward=REJECT
	uci set firewall.${FW_ZONE}.output=ACCEPT
	uci set firewall.${FW_ZONE}.input=REJECT 
	uci set firewall.${FW_ZONE}_fwd=forwarding
	uci set firewall.${FW_ZONE}_fwd.src=${FW_ZONE}
	uci set firewall.${FW_ZONE}_fwd.dest=wan
	uci set firewall.${FW_ZONE}_dhcp=rule
	uci set firewall.${FW_ZONE}_dhcp.name=${FW_ZONE}_DHCP
	uci set firewall.${FW_ZONE}_dhcp.src=${FW_ZONE}
	uci set firewall.${FW_ZONE}_dhcp.target=ACCEPT
	uci set firewall.${FW_ZONE}_dhcp.proto=udp
	uci set firewall.${FW_ZONE}_dhcp.dest_port=67-68
	uci set firewall.${FW_ZONE}_dns=rule
	uci set firewall.${FW_ZONE}_dns.name=${FW_ZONE}_DNS
	uci set firewall.${FW_ZONE}_dns.src=${FW_ZONE}
	uci set firewall.${FW_ZONE}_dns.target=ACCEPT
	uci set firewall.${FW_ZONE}_dns.proto=tcpudp
	uci set firewall.${FW_ZONE}_dns.dest_port=53
	#uci set dhcp.${NET_ID}.force=1
	#uci set dhcp.${NET_ID}.netmask=255.255.255.0
	#uci add_list dhcp.${NET_ID}.dhcp_option=6,8.8.8.8,8.8.4.4
	commit network
	commit firewall
}
