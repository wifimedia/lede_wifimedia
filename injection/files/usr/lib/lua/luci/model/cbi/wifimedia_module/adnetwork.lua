--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--

require("luci.sys")
local sys = require "luci.sys"
local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()

m = Map("wifimedia",translate(""))
function m.on_after_commit(self)
		luci.util.exec("/usr/bin/adnetwork_local.sh start")
end
s = m:section(TypedSection, "adnetwork","")
s.anonymous = true
s.addremove = false

--s:tab("adnetwork_cfg","Cloud")
s:tab("chatbot","Chatbot")
s:tab("fb","Facebook")
s:tab("youtube","Youtube")
s:tab("image","Image")
s:tab("adv","Advanced")

--s:taboption("adnetwork_cfg", Value, "domain","Domain").placeholder = "exp: .vnexpress.net, ..."
--s:taboption("adnetwork_cfg", Value,"gw","APkey").placeholder = "APKEY"
--s:taboption("chatbot", Value,"facebook_id","Facebook ID").placeholder = "Facebook ID"
s:taboption("chatbot", Value,"ref","Messenger").placeholder = "User ID: vnpictures"
s:taboption("youtube", Value,"youtube","Youtube").placeholder = "Video ID: X8AOQRz6m8Q"
s:taboption("image", Value,"img","Imge","Min-width:360px, Height:120px").placeholder = "http://ads.wifimedia.vn/../picture.jpg"
s:taboption("image", Value,"title","Title").placeholder = "Support langue english"
url_web=s:taboption("image", Value,"link","Website")
url_web.placeholder = "http://ads.wifimedia.vn/"

s:taboption("adv", Value, "domain_acl","Domain").placeholder = "exp: .vnexpress.net, ..."

ads_st = s:taboption("adv", Flag,"ads_status","Status")
rd = s:taboption("adv", Flag,"random_status","Random Option")
rd:depends({ads_status="1"})
st = s:taboption("adv", ListValue,"status","Option")
st:depends({ads_status="1"})

local data = {"Chatbot","Facebook_Page","Facebook_Videos", "Facebook_Like_Share","Youtube","Image" }
for _, status in ipairs(data) do 
	st:value(status, status .. " ")
end

sec = s:taboption("adv", ListValue, "second", "Second")
sec.default = "20"
sec:depends({ads_status="1"})
local second = 9
while (second < 301) do
	sec:value(second, second .. " ")
	second = second + 1
end

s:taboption("fb", Value,"ads_fb_page","Facebook Page").placeholder = "Facebook Page Url"
s:taboption("fb", Value,"ads_fb_video","Facebook videos and Facebook live videos ").placeholder = "Facebook videos Url"
s:taboption("fb", Value,"ads_fb_like","Facebook Like & Share").placeholder = "Facebook Like & Share Url"

local pid = luci.util.exec("pidof privoxy")
local message = luci.http.formvalue("message")

function advertis_network_process_status()
  local status = "Ad network is not running now and "

  if pid ~= "" then
      status = "Ad network is running PID: "..pid.. "and "
  end

  if nixio.fs.access("/etc/rc.d/80privoxy") then
    status = status .. "it's enabled on the startup"
  else
    status = status .. "it's disabled on the startup"
  end

  local status = { status=status, message=message }
  local table = { pid=status }
  return table
end

t = m:section(Table, advertis_network_process_status())
t.anonymous = true

t:option(DummyValue, "status","Ad network status")

if nixio.fs.access("/etc/rc.d/S80privoxy") then
  disable = t:option(Button, "_disable","Disable from startup")
  disable.inputstyle = "remove"
  function disable.write(self, section)
		luci.util.exec("echo ''>/etc/crontabs/adnetwork && /etc/init.d/cron restart")
		luci.util.exec("/etc/init.d/privoxy disable")
		luci.util.exec(" /etc/init.d/privoxy  stop && /etc/init.d/firewall restart")
		luci.http.redirect(
        		luci.dispatcher.build_url("admin", "wifimedia", "adnetwork")
		)			
  end
else
  enable = t:option(Button, "_enable","Enable on startup")
  enable.inputstyle = "apply"
  function enable.write(self, section)
		luci.util.exec("uci set privoxy.privoxy.permit_access=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }'|cut -c 1,2,3,4,5,6,7,8,9,10,11)0/24:8118 && uci commit privoxy")
		luci.util.exec("uci set privoxy.privoxy.listen_address=$(ifconfig br-lan | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }'):8118 && uci commit privoxy")
		luci.util.exec("/etc/init.d/privoxy enable")
		luci.util.exec(" /etc/init.d/privoxy start ")
		luci.util.exec("crontab /etc/cron_ads -u adnetwork && /etc/init.d/cron restart")
		luci.http.redirect(
        		luci.dispatcher.build_url("admin", "wifimedia", "adnetwork")
		)			
  end
end
return m
