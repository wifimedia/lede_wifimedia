#!/usr/bin/lua

require "ubus"
require "uloop"

local DBG = false

if arg[1] == "dbg" then
	DBG = true
end

local function dbg(fmt, ...)
	if DBG then
		print(string.format(fmt, ...))
		print()
	end
end

uloop.init()

dbg("uloop init ok")

local conn = ubus.connect()
if not conn then
	error("Failed to connect to ubus")
end

dbg("ubus connect ok")

os.execute("iw phy phy1 interface add mon_horst type monitor 2> /dev/null")
dbg("create mon_horst ok")

os.execute("ifconfig mon_horst up")
dbg("start mon_horst ok")

os.execute("iw dev mon_horst set channel 1")
dbg("set channel = 1")

os.execute("echo '' > /etc/horst.conf")
os.execute("/usr/sbin/horst -i mon_horst -q -f BEACON -f PROBRQ >/dev/null 2>/dev/null &")
dbg("start horst ok")

local list = {}

local subscriber = {
	notify = function(msg)
		if msg.src == "ff:ff:ff:ff:ff:ff" then
			return
		end
		
		if not list[msg.src] then
			list[msg.src] = {pkts = 0}
		else
			list[msg.src].pkts = list[msg.src].pkts + 1
		end
		
		list[msg.src].timestamp = msg.timestamp
		list[msg.src].packet_type = msg.packet_type
		list[msg.src].src = msg.src
		list[msg.src].dst = msg.dst
		list[msg.src].bssid = msg.bssid
		list[msg.src].signal = msg.signal
		list[msg.src].channel = msg.channel
		list[msg.src].essid = msg.essid
		list[msg.src].encryption = msg.encryption
	end
}

uloop.timer(function() conn:subscribe("horst", subscriber) end, 1000)
dbg("subscribe horst ok")

local alive = 10
local keepalive_timer

local function quit_cb()
	keepalive_timer:cancel()
	uloop:cancel()
	os.execute("kill -9 `pidof horst`; iw dev mon_horst del")
end

local function keepalive_timer_cb()
	alive = alive - 1
	keepalive_timer:set(1000)
	
	if alive == 0 then
		quit_cb()
	end
end

keepalive_timer = uloop.timer(keepalive_timer_cb, 1)

local my_method = {
	wifisniffer = {
		get = {
			function(req, msg)
				alive = 10
				conn:reply(req, {list = list})
			end, { }
		},
		
		scan = {
			function(req, msg)
				os.execute("kill -9 `pidof horst`")
				os.execute("iw dev mon_horst set channel 1")
				
				if msg.i then
					os.execute("echo channel_dwell=" .. msg.i ..  " > /etc/horst.conf")
				else
					os.execute("echo '' > /etc/horst.conf")
				end
				
				if msg.scan then
					os.execute("/usr/sbin/horst -i mon_horst -s -q -f BEACON -f PROBRQ >/dev/null 2>/dev/null &")
				else
					os.execute("/usr/sbin/horst -i mon_horst -q -f BEACON -f PROBRQ >/dev/null 2>/dev/null &")
				end
				
				list = {}
				uloop.timer(function() conn:subscribe("horst", subscriber) end, 1000)
				
				conn:reply(req, {})
			end, {}
		},
		
		clear = {
			function(req, msg)
				list = {}
				conn:reply(req, {});
			end, { }
		},
		
		quit = {
			function(req, msg)
				uloop.timer(function() quit_cb() end, 500)
				conn:reply(req, {});
			end, { }
		}
	}
}

conn:add(my_method)
dbg("add my_method ok")

uloop.run()