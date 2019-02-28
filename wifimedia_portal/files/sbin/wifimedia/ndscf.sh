#!/bin/sh

fbs_gw1=`uci -q get wifimedia.@nodogsplash[0].ndsname`
fbs_gw=${fbs_gw1:-Netify}

fbs_url1=`uci -q get wifimedia.@nodogsplash[0].ndsurl`
fbs_url=${fbs_url1:-}
fbs_url=${fbs_url1:-http://google.com.vn}

MaxClients1=`uci -q get wifimedia.@nodogsplash[0].ndsclient`
MaxClients=${MaxClients1:-120}

clidtimeout1=`uci -q get wifimedia.@nodogsplash[0].ndsidletimeout`
clidtimeout=${clidtimeout1:-7200}

url=`uci -q get wifimedia.@nodogsplash[0].nds_url`


key=`uci -q get wifimedia.@nodogsplash[0].nds_apkey`
captive_id=`ifconfig br-lan | grep 'HWaddr' | awk '{ print $5 }'| sed 's/://g'`
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
      <form id="info" method="POST" action="//'$url'">
          <input type="hidden" name="gateway_name" value="$gatewayname">
          <input type="hidden" name="gateway_mac" value="$gatewaymac">
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
</html>' >/etc/nodogsplash/htdocs/infoskel.html

#write file config
cat /sbin/wifimedia/nodogsplash_cfg >/etc/config/nodogsplash