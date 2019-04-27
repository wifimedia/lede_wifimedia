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
		luci.util.exec("/sbin/wifimedia/ndscf.sh start >/dev/null")
		--luci.util.exec("sleep 15 && reboot >/dev/null")
end

s = m:section(TypedSection, "nodogsplash", "")
s.anonymous = true
s.addremove = false
--s:option( Value, "ndsname","Name")
--s:option( Value, "nds_apkey","APKEY")
s:tab("basic","Basic")
s:tab("advance","Advanced")
s:tab("network","Network")
s:taboption( "basic",Value, "domain","Domain","portal.nextify.vn")
s:taboption( "basic",Value, "redirecturl","Redirect URL")
s:taboption( "basic",Value, "preauthenticated_users","Walled Garden")
s:taboption( "advance",Value, "maxclients","Maxclients","Max Clients:250")
s:taboption( "advance",Value, "preauthidletimeout","Preauthidletimeout","30 mins")
s:taboption( "advance",Value, "authidletimeout","Authidletimeoutt","120 mins")
s:taboption( "advance",Value, "sessiontimeout","Sessiontimeout","20 mins")
s:taboption( "advance",Value, "checkinterval","Checkinterval","10 mins")
--s:taboption( "advance",Value, "ndsidletimeout","Client Idle Timeout")

local pid = luci.util.exec("pidof nodogsplash")
local message = luci.http.formvalue("message")

function captive_process_status()
  local status = "Captive portal is not running"

  if pid ~= "" then
      --status = "Captive portal is running PID: "..pid.. ""
	  status = "Captive portal is running"
  end

  if nixio.fs.access("/etc/rc.d/S99nodogsplash") then
    status = status .. ""
  else
    status = status .. ""
  end

  local status = { status=status, message=message }
  local table = { pid=status }
  return table
end

t = m:section(Table, captive_process_status())
t.anonymous = true

t:option(DummyValue, "status","Captive portal status")

	if nixio.fs.access("/etc/rc.d/S95nodogsplash") then
	  disable = t:option(Button, "_disable","Disable")
	  disable.inputstyle = "remove"
	  function disable.write(self, section)
			luci.util.exec(" /sbin/wifimedia/preauthenticated_rules.sh nds_del")
			luci.util.exec("echo ''>/etc/crontabs/nds && /etc/init.d/cron restart")
			luci.http.redirect(
            		luci.dispatcher.build_url("admin", "wifimedia", "wifimedia_portal")
			)			
	  end
	else
	  enable = t:option(Button, "_enable","Enable")
	  enable.inputstyle = "apply"
	  function enable.write(self, section)
			luci.util.exec("/sbin/wifimedia/preauthenticated_rules.sh nds_start")
			luci.util.exec("/sbin/wifimedia/preauthenticated_rules.sh nds_add_network")
			luci.util.exec("crontab /etc/cron_nds -u nds && /etc/init.d/cron restart")
			luci.http.redirect(
            		luci.dispatcher.build_url("admin", "wifimedia", "wifimedia_portal")
			)			
	  end
	end

return m
