--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--

local sys = require "luci.sys"
local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()
m = Map("wifimedia", "")
m.apply_on_parse = true
function m.on_apply(self)
	--luci.sys.call("env -i /bin/ubus call network reload >/dev/null 2>/dev/null")
	luci.sys.call("env -i /bin/ubus call network restart >/dev/null 2>/dev/null")
	--luci.http.redirect(luci.dispatcher.build_url("admin","wifimedia","advance"))
end

s = m:section(TypedSection, "LTE","4G LTE Interface")
s.anonymous = true
s.addremove = false

lte = s:option(Flag, "4g-lte","4G LTE Enable ")
lte.rmempty = false
		function lte.write(self, section, value)
			if value == self.enabled then			
			    luci.sys.call("uci set network.lte='interface'")
				luci.sys.call("uci set network.lan.proto='dhcp'")
				luci.sys.call("uci set network.lan.type='bridge'")
				luci.sys.call("uci set network.lan.ifname='eth1'")
				luci.sys.call("uci commit")
			else
				luci.sys.call("uci delete network.lan")
				luci.sys.call("uci commit")
			end
			return Flag.write(self, section, value)
		end
		function lte.remove() end
return m
