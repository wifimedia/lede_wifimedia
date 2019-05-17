#!/usr/bin/env lua
local cjson = require("cjson")
local ubus = require("ubus")
local uloop = require("uloop")

uloop.init()

local conn = ubus.connect()
if not conn then
	error("Failed to connect to ubus")
end

local configs = {}

local timer
function timer_cb()
	if #configs > 0 then
		local config = configs[1]
		table.remove(configs, 1)
		
		local msg = {
			type = "config.change",
			data = {
				package = config
			}
		}
		
		if #configs > 0 then
			timer:set(1000)
		end
		conn:call("service", "event", msg)
	end
end
timer = uloop.timer(timer_cb)

local luci2_method = {
	luci2 = {
		apply = {
			function(req, msg)
				conn:reply(req, {message = "ok"})
				configs[#configs + 1] = msg.config
				timer:set(1000)
			end, {config = ubus.STRING }
		}
	}
}

conn:add(luci2_method)

uloop.run()