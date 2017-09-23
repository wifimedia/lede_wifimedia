--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--

local sys = require "luci.sys"
local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()
local wfm_lcs = fs.access("/etc/opt/wfm_lcs")
local online = fs.access("/etc/opt/online")
m = Map("wifimedia", "")
function m.on_after_commit(self)
	luci.sys.call("env -i /usr/bin/license.sh start >/dev/null")
end

s = m:section(TypedSection, "advance","")
s.anonymous = true
s.addremove = false

s:tab("rssi",  translate("RSSI"))
	--s:taboption("rssi", Value, "pinginterval","Interval (s)").placeholder = "interval"
	rssi = s:taboption("rssi", Flag, "enable","Status")
	rssi.rmempty = false
		function rssi.write(self, section, value)
			if value == self.enabled then
				luci.sys.call("env -i /etc/init.d/watchping start >/dev/null")
				luci.sys.call("env -i /etc/init.d/watchping enable >/dev/null")
			else
				luci.sys.call("env -i /etc/init.d/watchping stop >/dev/null")
				luci.sys.call("env -i /etc/init.d/watchping disable >/dev/null")
			end
			return Flag.write(self, section, value)
		end
		function rssi.remove() end
	--else 
	--	m.pageaction = false

	t = s:taboption("rssi", Value, "level","RSSI:","Range:-60dBm ~ -90dBm")
	t.datatype = "min(-90)"
	--s:taboption("rssi",Value, "delays","Time Delays (s)").optional = false
	--t:depends({enable="1"})
--[[
if online then
	s:tab("online",  translate("Staus Online"))
	rm= s:taboption("online",Flag, "online", "Status","On/Off")
	rm.rmempty = false
end
]]--
if wfm_lcs then
	s:tab("license",  translate("License"))
	wfm = s:taboption("license",Value,"wfm","wifimedia")
	wfm.rmempty = true
end
return m