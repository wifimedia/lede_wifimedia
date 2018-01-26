--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--
module("luci.controller.wifimedia.adnetwork", package.seeall)
function index()
	entry( { "admin", "wifimedia"}, firstchild(), "Wifimedia", 50).dependent=false
	entry( { "admin", "wifimedia", "adnetwork" }, cbi("wifimedia_module/adnetwork"), _("Ads"),      26)
end