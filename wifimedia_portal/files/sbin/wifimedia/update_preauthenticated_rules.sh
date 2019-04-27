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
#Value
NODOGSPLASH_CONFIG=/tmp/etc/nodogsplash.conf
PREAUTHENTICATED_ADDRS=/tmp/preauthenticated_addrs
PREAUTHENTICATED_RULES=/tmp/preauthenticated_rules

walledgadent=`uci get wifimedia.@nodogsplash[0].preauthenticated_users | sed 's/,/ /g'`
domain=`uci -q get wifimedia.@nodogsplash[0].domain`
domain_default=${domain:-portal.nextify.vn}
redirecturl=`uci -q get wifimedia.@nodogsplash[0].redirecturl`
redirecturl_default=${redirecturl:-https://google.com.vn}
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
MAC_E0=$(ifconfig eth1 | grep 'HWaddr' | awk '{ print $5 }')

uci set nodogsplash.@nodogsplash[0].redirecturl="$redirecturl_default";
uci set nodogsplash.@nodogsplash[0].maxclients="$maxclients_default";
uci set nodogsplash.@nodogsplash[0].preauthidletimeout="$preauthidletimeout_default";
uci set nodogsplash.@nodogsplash[0].authidletimeout="$authidletimeout_default";
uci set nodogsplash.@nodogsplash[0].sessiontimeout="$std";
uci set nodogsplash.@nodogsplash[0].checkinterval="$ctv";
uci commit

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
uci del nodogsplash.@nodogsplash[0].preauthenticated_users && uci commit
uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow tcp port 53"
uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow udp port 53"
while read line; do
	uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users="allow to $(echo $line)"
done <$PREAUTHENTICATED_ADDRS
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
      <form id="info" method="POST" action="//'$domain_default'/splash">
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
        <meta http-equiv="refresh" content="0; url="//'$domain'/splash">
        <style>
            html {
                background: #F7F7F7;
            }
        </style>
    </head>
    <body></body>
</html>' >/etc/nodogsplash/htdocs/status.html
#config option nodogsplash

/etc/init.d/firewall restart


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
