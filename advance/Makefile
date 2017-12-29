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
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)
endef

define Package/advance/postinst
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
	chmod a+x /sbin/wifimedia/*
	chmod a+x /etc/init.d/wifimedia_check
	chmod a+x /etc/uci-defaults/wifimedia
	chmod a+x /etc/hotplug.d/button/00-button
	chmod a+x /etc/btnaction
	
fi
exit 0
endef

define Package/advance/prerm
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
	echo "advance..."
fi
exit 0
endef

$(eval $(call BuildPackage,advance))