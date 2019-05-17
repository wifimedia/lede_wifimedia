#!/usr/bin/lua

local ev = require "ev"
local posix = require "posix"
local bit = require "bit"
local forkpty = require "forkpty"

local loop = ev.Loop.default

local pid, pty = forkpty.forkpty()
if not pid then
	print("error:", pty)
	os.exit()
end

if pid == 0 then
	if posix.access("/bin/login") then
		posix.exec("/bin/login", {})
	elseif posix.access("/usr/bin/login") then
		posix.exec("/usr/bin/login", {})
	else
		print("Please install login")
	end
else
	local oterm = posix.tcgetattr(0)
	local nterm = posix.tcgetattr(0)
	
	nterm.iflag = bit.band(nterm.iflag, bit.bnot(bit.bor(posix.IGNBRK, posix.BRKINT, posix.PARMRK, posix.ISTRIP, posix.INLCR, posix.IGNCR, posix.ICRNL, posix.IXON)))
	nterm.lflag = bit.band(nterm.lflag, bit.bnot(bit.bor(posix.ECHO, posix.ECHONL, posix.ICANON, posix.IEXTEN)))
	nterm.lflag = bit.bor(nterm.lflag, posix.ISIG)
	nterm.cc[posix.VMIN] = 1
	nterm.cc[posix.VTIME] = 0
	nterm.cc[posix.VINTR] = 1
	
	posix.tcsetattr(0, posix.TCSANOW, nterm)
	
	ev.IO.new(function()
				local data = posix.read(pty, 1024)
				if data then
					posix.write(1, data)
				end
			end, pty, ev.READ):start(loop)
		
	ev.IO.new(function()
				local data = posix.read(0, 1024)
				if data then
					posix.write(pty, data)
				end
			end, 0, ev.READ):start(loop)
	
	ev.Signal.new(function() posix.tcsetattr(0, posix.TCSANOW, oterm) loop:unloop() end, ev.SIGCHLD):start(loop)
end

loop:loop()


