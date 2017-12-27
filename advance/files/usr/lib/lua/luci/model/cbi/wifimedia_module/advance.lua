--[[
LuCI - Lua Configuration Interface
Copyright 2014 dungtd8x <dungtd8x@gmail.com>
]]--

local sys = require "luci.sys"
local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()
local wfm_lcs = fs.access("/etc/opt/wfm_lcs")
--local online = fs.access("/etc/opt/online")
m = Map("wifimedia", "")
function m.on_after_commit(self)
	luci.sys.call("env -i /usr/bin/license.sh start >/dev/null")
	luci.sys.call("env -i /sbin/wifimedia/ftconfig.sh start >/dev/null")
	luci.sys.call("env -i /bin/ubus call network reload >/dev/null 2>/dev/null")
	luci.http.redirect(luci.dispatcher.build_url("admin","wifimedia","advance"))
end

s = m:section(TypedSection, "advance","")
s.anonymous = true
s.addremove = false

--[[ auto controller ]]--
s:tab("ctrgroups",  translate("Wireless"))
ctrgs_en = s:taboption("ctrgroups",Flag, "ctrs_en", "Enable")
ctrgs = s:taboption("ctrgroups",Value, "essid", "SSID")
ctrgs:depends({ctrs_en="1"})

ctrgsm = s:taboption("ctrgroups",ListValue, "mode", "MODE")
ctrgsm:value("ap","AP")
ctrgsm:value("mesh","MESH")
ctrgsm:value("wds","WDS")
ctrgsm:depends({ctrs_en="1"})

ch = s:taboption( "ctrgroups",ListValue, "channel", "Channel")
local channel = 1
while (channel < 14) do
	ch:value(channel, channel .. " ")
	channel = channel + 1
end
ctrgscnl = s:taboption("ctrgroups",Value, "maxassoc", "Connection Limit")
ctrgscnl:depends({ctrs_en="1"})

ctrgsn = s:taboption("ctrgroups",ListValue, "network", "Network")
ctrgsn:value("wan","WAN")
ctrgsn:value("lan","LAN")
ctrgsn:depends({ctrs_en="1"})

ctrgsn = s:taboption("ctrgroups",ListValue, "encrypt", "Wireless Security")
ctrgsn:value("","No Encryption")
ctrgsn:value("encryption","WPA-PSK/WPA2-PSK")
ctrgsn:depends({ctrs_en="1"})

grwpa = s:taboption("ctrgroups",Value, "password", "Password")
grwpa.datatype = "wpakey"
grwpa.rmempty = true
grwpa.password = true
grwpa:depends({encrypt="encryption"})

ctrgsft = s:taboption("ctrgroups",ListValue, "ft", "Fast Roaming")
ctrgsft:value("rsn_preauth","Fast-Secure Roaming")
ctrgsft:value("ieee80211r","Fast Basic Service Set Transition (FT)")
ctrgsft:depends({encrypt="encryption"})

nasid = s:taboption("ctrgroups",Value, "nasid", "NAS ID")
nasid:depends({ft="ieee80211r"})
device = s:taboption("ctrgroups",Value, "macs", "APID")
device:depends({ft="ieee80211r"})
--macs.datatype = "macaddr"
--[[Tx Power]]--
ctrgtx = s:taboption("ctrgroups",ListValue, "txpower", "Transmit Power")
ctrgtx:value("auto","Auto")
ctrgtx:value("low","Low")
ctrgtx:value("medium","Medium")
ctrgtx:value("high","High")
ctrgtx:depends({ctrs_en="1"})

hidessid = s:taboption("ctrgroups",Flag, "hidessid","Hide SSID")
hidessid.rmempty = false
hidessid:depends({ctrs_en="1"})
 
apisolation = s:taboption("ctrgroups",Flag, "isolation","AP Isolation")
apisolation.rmempty = false
apisolation:depends({ctrs_en="1"})

s:tab("bridge_network",  translate("Bridge Network"))
bridge_mode = s:taboption("bridge_network", Flag, "bridge_mode","Bridge","Ethernet:  wan => lan")
bridge_mode.rmempty = false
		function bridge_mode.write(self, section, value)
			if value == self.enabled then
				luci.sys.call("uci delete network.lan")
				--luci.sys.call("uci set network.lan='interface'")
				--luci.sys.call("uci set network.lan.proto='dhcp'")
				--luci.sys.call("uci set network.lan.ifname='eth1'")
				--luci.sys.call("uci set network.lan.ipaddr='172.16.99.1'")
				--luci.sys.call("uci set network.lan.netmask='255.255.255.0'")
				--luci.sys.call("uci delete network.lan.type='bridge'")
				luci.sys.call("uci set network.wan.proto='dhcp'")
				luci.sys.call("uci set network.wan.ifname='eth0 eth1'")
				luci.sys.call("uci set wireless.@wifi-iface[0].network='wan'")
				luci.sys.call("uci commit")
			else
			    luci.sys.call("uci set network.lan='interface'")
				luci.sys.call("uci set network.lan.proto='static'")
				luci.sys.call("uci set network.lan.ipaddr='172.16.99.1'")
				luci.sys.call("uci set network.lan.netmask='255.255.255.0'")
				luci.sys.call("uci set network.lan.type='bridge'")
				luci.sys.call("uci set network.lan.ifname='eth1'")
				luci.sys.call("uci set dhcp.lan.force='1'")
				luci.sys.call("uci set dhcp.lan.netmask='255.255.255.0'")
				luci.sys.call("uci del dhcp.lan.dhcp_option")
				luci.sys.call("uci add_list dhcp.lan.dhcp_option='6,8.8.8.8,8.8.4.4'")				
				luci.sys.call("uci set network.wan.ifname='eth0'")
				luci.sys.call("uci set wireless.@wifi-iface[0].network='wan'")
				luci.sys.call("uci commit")		
			end
			return Flag.write(self, section, value)
		end
		function bridge_mode.remove() end
		
		
--RSSI--
s:tab("rssi",  translate("RSSI"))
	--s:taboption("rssi", Value, "pinginterval","Interval (s)").placeholder = "interval"
	rssi = s:taboption("rssi", Flag, "enable","Enable")
	rssi.rmempty = false
		function rssi.write(self, section, value)
			if value == self.enabled then
				luci.sys.call("env -i /etc/init.d/watchping start >/dev/null")
				luci.sys.call("env -i /etc/init.d/watchping enable >/dev/null")
			else
				luci.sys.call("env -i /etc/init.d/watchping stop >/dev/null")
				luci.sys.call("env -i /etc/init.d/watchping disable >/dev/null")
			end
			return Flag.write(self, section, value)
		end
		function rssi.remove() end
	--else 
	--	m.pageaction = false

	t = s:taboption("rssi", Value, "level","RSSI:","Range:-60dBm ~ -90dBm")
	t.datatype = "min(-90)"
	--s:taboption("rssi",Value, "delays","Time Delays (s)").optional = false
	--t:depends({enable="1"})
--[[END RSSI]]--		
--License
if wfm_lcs then
	s:tab("license",  translate("License"))
	wfm = s:taboption("license",Value,"wfm","Key")
	wfm.rmempty = true
end
--[[END LICENS]]--
return m
