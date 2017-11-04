--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--
module("luci.controller.wifimedia.advance", package.seeall)
function index()
	entry( { "admin", "wifimedia"}, firstchild(), "Wifimedia", 50).dependent=false
	entry( { "admin", "wifimedia", "advance" }, cbi("wifimedia_module/advance"), _("Controller"),      10)
	entry( { "admin", "wifimedia", "info"    }, template("wifimedia_view/index"),    _("Info"), 80)
end