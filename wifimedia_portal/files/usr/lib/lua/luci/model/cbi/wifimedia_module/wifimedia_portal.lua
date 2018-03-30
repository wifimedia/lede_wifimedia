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
--s:option( Value, "nds_domain","Domain")
s:option( Value, "ndsurl","Redirect URL")
s:option( Value, "nds_wg","Walled Garden")
s:option( Value, "ndsclient","MaxClients")
s:option( Value, "ndsidletimeout","Client Idle Timeout")

local pid = luci.util.exec("pidof nodogsplash")
local message = luci.http.formvalue("message")

function captive_process_status()
  local status = "Captive portal is not running now and "

  if pid ~= "" then
      status = "Captive portal is running PID: "..pid.. "and "
  end

  if nixio.fs.access("/etc/rc.d/S99nodogsplash") then
    status = status .. "it's enabled on the startup"
  else
    status = status .. "it's disabled on the startup"
  end

  local status = { status=status, message=message }
  local table = { pid=status }
  return table
end

t = m:section(Table, captive_process_status())
t.anonymous = true

t:option(DummyValue, "status","Captive portal status")

	if nixio.fs.access("/etc/rc.d/S99nodogsplash") then
	  disable = t:option(Button, "_disable","Disable from startup")
	  disable.inputstyle = "remove"
	  function disable.write(self, section)
			luci.util.exec("/etc/init.d/nodogsplash disable")
			luci.util.exec(" /etc/init.d/nodogsplash stop && /etc/init.d/firewall restart ")
			luci.util.exec("echo ''>/etc/crontabs/nds && /etc/init.d/cron restart")
			luci.http.redirect(
            		luci.dispatcher.build_url("admin", "wifimedia", "wifimedia_portal")
			)			
	  end
	else
	  enable = t:option(Button, "_enable","Enable on startup")
	  enable.inputstyle = "apply"
	  function enable.write(self, section)
			luci.util.exec("/etc/init.d/nodogsplash enable")
			luci.util.exec("crontab /etc/cron_nds -u nds && /etc/init.d/cron restart")
			luci.http.redirect(
            		luci.dispatcher.build_url("admin", "wifimedia", "wifimedia_portal")
			)			
	  end
	end

return m
