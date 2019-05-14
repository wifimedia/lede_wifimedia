--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--
module("luci.controller.wifimedia.advance", package.seeall)
function index()
	entry( { "admin", "wifimedia"}, firstchild(), "Service", 50).dependent=false
	entry( { "admin", "wifimedia", "advance" }, cbi("wifimedia_module/advance"), _("Advanced"),      10)
	entry( { "admin", "wifimedia", "info"    }, template("wifimedia_view/index"),    _("Info"), 80)
end