#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=advance
PKG_VERSION:=3.2
PKG_RELEASE:=5
PKG_MAINTAINER:=Dungtd <dungtd8x@gmail.com>
PKG_LICENSE:=GPLv2

include $(INCLUDE_DIR)/package.mk

define Package/advance
  SUBMENU:=Wifimedia
  SECTION:=dev
  CATEGORY:=Advance
  DEPENDS:=+luci +luci-mod-admin-full
  TITLE:=advance ...
  URL:=http://wifimedia.vn
  MENU:=1
  PKGARCH:=all
  MAINTAINER:=DungTD <dungtd8x@gmail.com>
endef

define Package/advance/description

endef

define Build/Compile
endef

define Package/advance/install
	$(INSTALL_DIR) $(1)/root
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/hotplug.d/button
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/sbin/wifimedia
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/wifimedia
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/wifimedia_module
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/wifimedia_view
	
	$(INSTALL_BIN) ./files/controller.sh $(1)/sbin/wifimedia/controller.sh
	$(INSTALL_BIN) ./files/controller_srv.sh $(1)/sbin/wifimedia/controller_srv.sh
	$(INSTALL_BIN) ./files/settings.sh $(1)/sbin/wifimedia/settings.sh
	$(INSTALL_BIN) ./files/variables.sh $(1)/sbin/wifimedia/variables.sh
	$(INSTALL_BIN) ./files/initd_wifimedia_check $(1)/etc/init.d/wifimedia_check
	$(INSTALL_BIN) ./files/00-button.hotplus $(1)/etc/hotplug.d/button/00-button
	$(INSTALL_BIN) ./files/30-wlan.hotplus $(1)/etc/hotplug.d/iface/30-wlan
	$(INSTALL_BIN) ./files/35-wan_detect.hotplus $(1)/etc/hotplug.d/iface/35-wan_detect
	$(INSTALL_BIN) ./files/wifimedia_uci_default $(1)/etc/uci-defaults/wifimedia
	$(INSTALL_BIN) ./files/btnaction $(1)/etc/btnaction
	$(INSTALL_DATA) ./files/banner_ $(1)/etc/banner_
	$(INSTALL_DATA) ./files/codename $(1)/etc/codename
	$(INSTALL_DATA) ./files/wifimedia.config $(1)/etc/config/wifimedia
	$(INSTALL_DATA) ./files/button.config $(1)/etc/config/button
	$(INSTALL_DATA) ./files/root/advance_model.lua $(1)/root/advance_model.lua
	$(INSTALL_DATA) ./files/root/gw_index.htm $(1)/root/gw_index.htm
	$(INSTALL_DATA) ./files/root/wifi_overview.htm $(1)/root/wifi_overview.htm
	
	$(INSTALL_DATA) ./files/advance_controller.lua $(1)/usr/lib/lua/luci/controller/wifimedia/advance.lua
	$(INSTALL_DATA) ./files/advance_model.lua $(1)/usr/lib/lua/luci/model/cbi/wifimedia_module/advance.lua
	$(INSTALL_DATA) ./files/index.htm $(1)/usr/lib/lua/luci/view/wifimedia_view/index.htm
	
	$(INSTALL_DATA) ./files/bridge_controller.lua $(1)/usr/lib/lua/luci/controller/wifimedia/bridge.lua
	$(INSTALL_DATA) ./files/bridge_model.lua $(1)/usr/lib/lua/luci/model/cbi/wifimedia_module/bridge.lua
endef

<<<<<<< HEAD
define Package/advance/postinst
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
	chmod a+x /sbin/wifimedia/*.sh
	chmod a+x /etc/init.d/wifimedia_check
	chmod a+x /etc/uci-defaults/wifimedia
	chmod a+x /etc/hotplug.d/button/00-button
	chmod a+x /etc/btnaction
fi
exit 0
=======
define Package/advance/conffiles
/etc/config/button
/etc/config/wifimedia
>>>>>>> wr841v13_ext
endef

$(eval $(call BuildPackage,advance))
