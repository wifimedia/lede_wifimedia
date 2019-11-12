--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--
module("luci.controller.wifimedia.dhcp_relay", package.seeall)
function index()
	entry( { "admin", "services", "dhcp_relay" }, cbi("wifimedia_module/dhcp_relay"), _("DHCP RELAY"),      15)
end
