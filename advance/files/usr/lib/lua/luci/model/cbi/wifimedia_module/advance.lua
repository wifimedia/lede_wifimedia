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
	--luci.sys.call("env -i /usr/bin/license.sh start >/dev/null")
	luci.sys.call("env -i /sbin/wifimedia/groups.sh start >/dev/null")
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
--[[ auto controller ]]--
s:tab("ctrgroups",  translate("Wireless Groups"))
ctrgs_en = s:taboption("ctrgroups",Flag, "ctrs_en", "Enable Groups")
ctrgs = s:taboption("ctrgroups",Value, "essid", "SSIDs")
ctrgs:depends({ctrs_en="1"})

ctrgsm = s:taboption("ctrgroups",ListValue, "mode", "MODE")
ctrgsm:value("ap","AP")
ctrgsm:value("mesh","MESH")
ctrgsm:value("wds","WDS")
ctrgsm:depends({ctrs_en="1"})

ctrgscnl = s:taboption("ctrgroups",Value, "maxassoc", "Connection Limit")
ctrgscnl:depends({ctrs_en="1"})

ctrgsn = s:taboption("ctrgroups",ListValue, "network", "Network")
ctrgsn:value("wan","WAN")
ctrgsn:value("lan","LAN")
ctrgsn:depends({ctrs_en="1"})

grwpa = s:taboption("ctrgroups",Value, "password", "Password")
grwpa.datatype = "wpakey"
grwpa:depends({ctrs_en="1"})

ctrgsft = s:taboption("ctrgroups",ListValue, "ft", "Fast Roaming")
ctrgsft:value("rsn_preauth","Fast roaming")
ctrgsft:value("ieee80211r","Fast Basic Service Set Transition (FT)")
ctrgsft:depends({ctrs_en="1"})

nasid = s:taboption("ctrgroups",Value, "nasid", "LocalID")
nasid:depends({ft="ieee80211r"})

--macs.datatype = "macaddr"
--[[Tx Power]]--
ctrgtx = s:taboption("ctrgroups",ListValue, "txpower", "Transmit Power")
ctrgtx:value("auto","Auto")
ctrgtx:value("low","Low")
ctrgtx:value("medium","Medium")
ctrgtx:value("high","High")
ctrgtx:depends({ctrs_en="1"})

apisolation = s:taboption("ctrgroups",Flag, "isolation","AP Isolation")
apisolation.rmempty = false
apisolation:depends({ctrs_en="1"})

s:tab("device",  translate("AP Groups"))
device = s:taboption("device",Flag, "gpd_en","Enable Groups")
device.rmempty = false
device = s:taboption("device",Value, "macs", "Devices")
device:depends({gpd_en="1"})

--[[Auto Reboot ]]--
s:tab("autoreboot",  translate("Reboot Groups"))
Everyday = s:taboption("autoreboot",Flag, "Everyday","Everyday Auto Reboot")
Everyday.rmempty = false

h = s:taboption("autoreboot", ListValue, "hour", "Hours")
local time = 0
while (time < 24) do
	h:value(time, time .. " ")
	time = time + 1
end
h:depends({Everyday="1"})
mi = s:taboption("autoreboot", ListValue, "minute", "Minutes")
local minute = 0
while (minute < 60) do
	mi:value(minute, minute .. " ")
	minute = minute + 1
end
mi:depends({Everyday="1"})

s:tab("administrator",  translate("Administrators"))
admingr = s:taboption("administrator",Flag, "admins", "Enable Groups")
admingr = s:taboption("administrator",Value, "passwords", "Password")
admingr:depends({admins="1"})
return m
