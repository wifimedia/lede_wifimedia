module("luci.controller.wifisniffer", package.seeall)

function index()
	entry({"admin", "services", "wifisniffer"}, template("wifisniffer/wifisniffer"), _("WiFi Sniffer"), 40).index = true
	entry({"admin", "services", "wifisniffer", "getList"}, call("getList"))
	entry({"admin", "services", "wifisniffer", "chansel"}, call("chansel"))
	entry({"admin", "services", "wifisniffer", "scan"}, call("scan"))
	entry({"admin", "services", "wifisniffer", "si"}, call("si"))
end

function getList()
	local fs = require "nixio.fs"
	local util = require "luci.util"
	
	if os.execute("pidof wifisniffer.lua > /dev/null") ~= 0 then
		os.execute("/usr/bin/wifisniffer.lua &")
	end
	
	local RespData = util.ubus("wifisniffer", "get") or {list = {}}
	
	luci.http.prepare_content("application/json")
	
	local list = {}
	for k, v in pairs(RespData.list) do
		list[#list + 1] = {
			timestamp = os.date("%Y-%m-%d %H:%M:%S", v.timestamp),
			packet_type = (v.packet_type == "BEACON") and "AP" or "STA",
			src = v.src:upper(),
			dst = v.dst:upper(),
			bssid = v.bssid:upper(),
			signal = v.signal,
			channel = v.channel,
			essid = v.essid,
			encryption = v.encryption,
			pkts = v.pkts
		}
	end
	
	luci.http.write_json(list)
end

function chansel()
	local util = require "luci.util"
	local ch = luci.http.formvalue("channel")
	
	os.execute("iw dev mon_horst set channel " .. ch)
	
	util.ubus("wifisniffer", "clear")
	
	luci.http.write_json({ch = ch})
end

function scan()
	local util = require "luci.util"
	local s = luci.http.formvalue("scan")
	
	if s == "true" then
		util.ubus("wifisniffer", "scan", {scan = true})
	else
		util.ubus("wifisniffer", "scan")
	end
	luci.http.write_json({s = s})
end

function si()
	local util = require "luci.util"
	local i = luci.http.formvalue("si") or 250
	
	i = tonumber(i)
	
	if i > 10 then
		util.ubus("wifisniffer", "scan", {scan = true, i = i})
	end
	
	luci.http.write_json({i = i})
end