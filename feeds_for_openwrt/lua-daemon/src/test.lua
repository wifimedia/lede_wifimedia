#!/usr/bin/lua

local daemon = require "daemon"

print(daemon.daemonize(true))

while true do
	os.execute("sleep 1")
end
