--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--
module("luci.controller.wifimedia.advance", package.seeall)
function index()
<<<<<<< HEAD
	entry( { "admin", "wifimedia"}, firstchild(), "Service", 50).dependent=false
	entry( { "admin", "wifimedia", "advance" }, cbi("wifimedia_module/advance"), _("Advanced"),      10)
=======
	entry( { "admin", "wifimedia"}, firstchild(), "Wifimedia", 50).dependent=false
	entry( { "admin", "wifimedia", "controller" }, cbi("wifimedia_module/advance"), _("Controller"),      10)
>>>>>>> master
	entry( { "admin", "wifimedia", "info"    }, template("wifimedia_view/index"),    _("Info"), 80)
end