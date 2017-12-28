#
# Copyright (C) 2010 segal.di.ubi.pt
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=watchcat
PKG_VERSION:=1
PKG_RELEASE:=6

PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/watchcat
  SUBMENU:=Wifimedia
  SECTION:=dev
  CATEGORY:=Advance
  URL:=http://wifimedia.vn
  MENU:=1
  PKGARCH:=all
  MAINTAINER:=DungTD <dungtd8x@gmail.com>
  TITLE:=Enable the configuration of programed reboots
endef

define Package/watchcat/description
Allows to configure a periodically reboot, or after losing internet connectivity. Configured trough UCI /etc/config/system.
endef

define Package/watchcat/conffiles
/etc/config/system
endef

define Build/Compile
endef

define Package/watchcat/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/initd_watchcat $(1)/etc/init.d/watchcat
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/watchcat.sh $(1)/usr/bin/watchcat.sh
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/uci_defaults_watchcat $(1)/etc/uci-defaults/50-watchcat
	$(INSTALL_DIR) $(1)/sbin/wifimedia
	$(INSTALL_BIN) ./files/rssi.sh $(1)/sbin/wifimedia/rssi.sh
endef

define Package/advance/postinst
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
	chmod a+x /sbin/wifimedia/rssi.sh
	chmod a+x /usr/bin/watchcat.sh
	chmod a+x /etc/init.d/watchcat
	chmod a+x /etc/uci-defaults/50-watchcat
fi
exit 0
endef

$(eval $(call BuildPackage,watchcat))
