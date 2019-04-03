#!/usr/bin/lua

-- Include libraries
package.path = "libs/?.lua;" .. package.path

--[[--
This script will typically be started during the setup of the **GATEWAY** MESHdesk device
If will then loop while checking the following:
1.) If the MESHdesk setup script is still running if will wait  and loop
2.) If the MESHdesk setup script is not running; it will 
	2.1)  run the /etc/MESHdesk/alfred_scripts/alfred_report_to_server.lua
3.) Sleep
--]]--a

debug 	 = true
interval = 120
local uci= require('uci')

require "socket" 
require("rdLogger")
l   	= rdLogger() 

--======================================
---- Some general functions -----------
--=====================================
function log(m,p)
	if(debug)then                                                                                     
        	l:log(m,p)                                                                                
	end                               
end
                                                                                                       
function sleep(sec)
	socket.select(nil, nil, sec)                                                                          
end        

function pidof(program)
	local handle = io.popen('pidof '.. program)
        local result = handle:read("*a")
        handle:close()
        result = string.gsub(result, "[\r\n]+$", "")
        if(result ~= nil)then
        	return tonumber(result)
        else
        	return false
        end
end

function send_heartbeat()
	os.execute("/etc/MESHdesk/alfred_scripts/alfred_report_to_server.lua")      
end

--=================================================

loop = true
while(loop)do
	if(not(pidof('a.lua')))then                   
		log("Reporting mesh status to server")
		send_heartbeat()
	else
		--print("Setup script running already wait for it to finish")
		log("Setup script running already wait for it to finish")
	end
	--os.execute("/etc/MESHdesk/a.lua &")
	--Check if there are another interval besides the default of 30 seconds
	local x = uci.cursor(nil,'/var/state')
	local time_to_sleep = x.get('meshdesk','settings','heartbeat_interval')
	if(time_to_sleep)then
		interval = time_to_sleep
	end
	sleep(interval)
end 

function last_check()
	print("check-in")
	
	-- See if we can ping it
	local server 		= fetch_config_value('meshdesk.internet1.ip')
	local c 			= rdConfig()
	local got_settings	=false                                          
	if(c:pingTest(server))then
		print("Ping os server was OK try to fetch the settings")
		log("Ping os server was OK try to fetch the settings")
--		local id	="A8-40-41-13-60-E3"
        local id_if     = fetch_config_value('meshdesk.settings.id_if')
		local id	    = getMac(id_if)
		local proto 	= fetch_config_value('meshdesk.internet1.protocol')
		local url   	= fetch_config_value('meshdesk.internet1.url')
		local query     = proto .. "://" .. server .. "/" .. url 
		print("Query url is " .. query )
		if(c:fetchSettings(query,id,false))then
			print("Funky -> got settings through WIFI")
			got_settings=true
		end
	end
	return got_settings
end
