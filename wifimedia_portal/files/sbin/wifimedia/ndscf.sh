#!/bin/sh

fbs_gw1=`uci -q get wifimedia.@nodogsplash[0].ndsname`
fbs_gw=${fbs_gw1:-WIFIMEDIA.VN}

fbs_url1=`uci -q get wifimedia.@nodogsplash[0].ndsurl`
fbs_url=${fbs_url1:-}
#fbs_url=${fbs_url1:-http://google.com.vn}

MaxClients1=`uci -q get wifimedia.@nodogsplash[0].ndsclient`
MaxClients=${MaxClients1:-120}

clidtimeout1=`uci -q get wifimedia.@nodogsplash[0].ndsidletimeout`
clidtimeout=${clidtimeout1:-7200}

domain=`uci -q get wifimedia.@nodogsplash[0].nds_domain`
domain=${domain:-crm.wifimedia.vn}

key=`uci -q get wifimedia.@nodogsplash[0].nds_apkey`
#captive_id=`ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }'| sed 's/://g'`
captive_id=`cat /sys/class/ieee80211/phy0/macaddress | sed 's/://g' | tr a-z A-Z`
apkey=${key:-$captive_id}
wg=`uci -q get wifimedia.@nodogsplash[0].nds_wg`

ip_gateway=`ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }'`
if [ "$fbs_url" != "" ];then
	redir="RedirectURL "$fbs_url
fi
#write file splash
echo '<!doctype html>
<html lang="en">
  <head>
      <meta charset="utf-8">
      <title>$gatewayname</title>
  </head>
  <body>
<<<<<<< HEAD
      <form id="info" method="POST" action="//'$domain'/back_end/'$apkey'/1">
=======
      <form id="info" method="POST" action="//firmware.wifimedia.com.vn/splash">
>>>>>>> Blacklist
          <input type="hidden" name="gateway_name" value="$gatewayname">
          <input type="hidden" name="gateway_mac" value="$gatewaymac">
          <input type="hidden" name="client_mac" value="$clientmac">
          <input type="hidden" name="num_clients" value="$nclients">
          <input type="hidden" name="uptime" value="$uptime">
		  <input type="hidden" name="splashcheck" value="1">
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
<<<<<<< HEAD
        <meta http-equiv="refresh" content="0; url="//'$domain'/back_end/'$apkey'/1">
=======
        <meta http-equiv="refresh" content="0; url="//firmware.wifimedia.com.vn/splash">
>>>>>>> Blacklist
        <style>
            html {
                background: #F7F7F7;
            }
        </style>
    </head>
    <body></body>
</html>' >/etc/nodogsplash/htdocs/infoskel.html

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

    # Phần whitelist cho domain www.wifiman.tech được thực hiện lúc startup,
    # để sau mà đổi server thì các router sẽ tự update, không cần vào từng
    # router chỉnh lại
	FirewallRule allow to '$ip_gateway'
	FirewallRule allow to 103.237.145.75
	FirewallRule allow to 172.16.99.1
    # include /tmp/preauthenticated_rules
}
'$redir'
BinVoucher "/sbin/wifimedia/nodogsplash_preauth.sh"
EnablePreAuth yes

ClientIdleTimeout '$clidtimeout'
#ClientIdleTimeout 240

' >/etc/nodogsplash/nodogsplash.conf