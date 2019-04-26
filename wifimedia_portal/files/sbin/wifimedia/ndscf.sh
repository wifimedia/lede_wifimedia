#!/bin/sh

domain=`uci -q get wifimedia.@nodogsplash[0].domain`
domain_default=${domain:-portal.nextify.vn}

redirecturl=`uci -q get wifimedia.@nodogsplash[0].redirecturl`
redirecturl_default=${redirecturl:-https://google.com.vn}

preauthenticated_users=`uci -q get wifimedia.@nodogsplash[0].preauthenticated_users` #Walled Gardent

maxclients=`uci -q get wifimedia.@nodogsplash[0].maxclients`
maxclients_default=${maxclients:-120}

preauthidletimeout=`uci -q get wifimedia.@nodogsplash[0].preauthidletimeout`
preauthidletimeout_default=${preauthidletimeout:-30}

authidletimeout=`uci -q get wifimedia.@nodogsplash[0].authidletimeout`
authidletimeout_default=${authidletimeout:-120}

sessiontimeout=`uci -q get wifimedia.@nodogsplash[0].sessiontimeout`
sessiontimeout_default=${sessiontimeout:-20}

checkinterval=`uci -q get wifimedia.@nodogsplash[0].checkinterval`
checkinterval_default=${checkinterval:-5}

uci del nodogsplash.@nodogsplash[0].preauthenticated_users
uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users='allow tcp port 53'
uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users='allow udp port 53'
uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users='allow tcp port 0:79'
uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users='allow tcp port 81:65535'
uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users='allow to 172.16.99.1'
uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users='allow to 125.212.224.252'
uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users='allow to 171.244.6.33'
uci add_list nodogsplash.@nodogsplash[0].preauthenticated_users='allow to 103.104.116.6'
uci commit

MAC_E0=$(ifconfig eth1 | grep 'HWaddr' | awk '{ print $5 }'| sed 's/://g')

if [ "$domain" != "" ];then
	uci set nodogsplash.@nodogsplash[0].domain=$domain
elif [ "$redirecturl" != "" ];then
	uci set nodogsplash.@nodogsplash[0].redirecturl=$redirecturl_default	
elif [ "$preauthenticated_users" != "" ];then
	uci set nodogsplash.@nodogsplash[0].preauthenticated_users=$preauthenticated_users
elif [ "$maxclients" != ""];then
	uci -q get nodogsplash.@nodogsplash[0].maxclients=$maxclients
elif [ "$preauthidletimeout" != "" ];then
	uci -q get nodogsplash.@nodogsplash[0].preauthidletimeout=$preauthidletimeout
elif [ "$authidletimeout" != "" ];then
	uci set nodogsplash.@nodogsplash[0].authidletimeout=$authidletimeout
elif [ "$sessiontimeout" != "" ];then
	sessiontimeout_=$(expr $sessiontimeout_default * 60)
	uci set nodogsplash.@nodogsplash[0].sessiontimeout=$sessiontimeout_	
elif [ "$checkinterval" != "" ];then
	checkinterval_=$(expr $checkinterval_default * 60)
	uci set nodogsplash.@nodogsplash[0].checkinterval=$checkinterval_
fi
uci commit
#write file splash

echo '<!doctype html>
<html lang="en">
  <head>
      <meta charset="utf-8">
      <title>$gatewayname</title>
  </head>
  <body>
      <form id="info" method="POST" action="//'$domain'/splash">
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
        <meta http-equiv="refresh" content="0; url="//'$url'">
        <style>
            html {
                background: #F7F7F7;
            }
        </style>
    </head>
    <body></body>
</html>' >/etc/nodogsplash/htdocs/status.html

#write file config
#cat /sbin/wifimedia/nodogsplash_cfg >/etc/config/nodogsplash
#write file config
echo 'GatewayInterface br-lan

FirewallRuleSet authenticated-users {
    FirewallRule allow all
}

FirewallRuleSet users-to-router {
    FirewallRule allow all
}

FirewallRuleSet preauthenticated-users {
    # DNS
    FirewallRule allow tcp port 53
    FirewallRule allow udp port 53

    # Chỉ chặn port 80, còn lại mở hết
    FirewallRule allow tcp port 0:79
    FirewallRule allow tcp port 81:65535

    # Phần whitelist cho domain nextify được thực hiện lúc startup,
    # để sau mà đổi server thì các router sẽ tự update, không cần vào từng
    # router chỉnh lại
	FirewallRule allow to '$ip_gateway'
	FirewallRule allow to 125.212.224.252
    # include /tmp/preauthenticated_rules
}
'$redir'
BinVoucher "/sbin/wifimedia/nodogsplash_preauth.sh"
EnablePreAuth yes

ClientIdleTimeout '$clidtimeout'
#ClientIdleTimeout 240

' >/etc/nodogsplash/nodogsplash.conf