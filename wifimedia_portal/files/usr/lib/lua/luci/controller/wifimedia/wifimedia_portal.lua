--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--
module("luci.controller.wifimedia.wifimedia_portal", package.seeall)
function index()
	entry( { "admin", "wifimedia"}, firstchild(), "Wifimedia", 50).dependent=false
	entry( { "admin", "wifimedia", "wifimedia_portal" }, cbi("wifimedia_module/wifimedia_portal"), _("Wifimedia Portal"),      25)
end