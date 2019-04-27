#!/bin/sh

#Delete Network
/etc/init.d/nodogsplash disable
uci batch << EOF
	del network.${NET_ID}
	del dhcp.${NET_ID}
	del firewall.${FW_ZONE}
	set nodogsplash.@nodogsplash[0].enabled='0'
	commit
EOF
service network reload
service dnsmasq restart
service firewall restart
service nodogsplash stop



