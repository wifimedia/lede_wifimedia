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
	luci.util.exec("/sbin/wifimedia/controller.sh dhcp_extension >/dev/null")
	luci.sys.call("env -i /bin/ubus call network restart >/dev/null 2>/dev/null")
end

s = m:section(TypedSection, "dhcp_relay","DHCP Relay")
s.anonymous = true
s.addremove = false

dhcp_relay = s:option( Flag, "relay","DHCP Relay")
dhcp_relay.rmempty = false
		
function dhcp_relay.write(self, section, value)
if value == self.enabled then
		luci.sys.call("uci set network.local='interface'")
		luci.sys.call("uci set network.local.proto='relay'")
		luci.sys.call("uci set network.local.ipaddr='172.16.99.1'")
		--luci.sys.call("uci add_list network.local.network='lan'")
		--luci.sys.call("uci add_list network.local.network='wan'")
		luci.sys.call("uci set dhcp.lan.ignore='1'")
		luci.sys.call("uci set wireless.@wifi-iface[0].network='lan'")
		--luci.sys.call("uci set nodogsplash.@nodogsplash[0].gatewayinterface='br-lan'")
	else
		luci.sys.call("uci del network.local")
		luci.sys.call("uci set dhcp.lan.ignore='0'")
		luci.sys.call("uci set wireless.@wifi-iface[0].network='lan'")
		--luci.sys.call("uci set nodogsplash.@nodogsplash[0].gatewayinterface='br-private'")
	end
	return Flag.write(self, section, value)
end
		-- retain server list even if disabled
function dhcp_relay.remove() end
return m
