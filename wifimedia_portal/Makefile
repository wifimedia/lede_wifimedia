#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wifimedia_portal
PKG_VERSION:=2.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Dungtd <dungtd8x@gmail.com>
PKG_LICENSE:=GPLv2

include $(INCLUDE_DIR)/package.mk

define Package/wifimedia_portal
  SUBMENU:=Wifimedia
  SECTION:=dev
  CATEGORY:=Advance
  TITLE:=Wireless LAN HotSpot controller
  URL:=http://wifimedia.vn
  MENU:=1
  PKGARCH:=all
  MAINTAINER:=DungTD <dungtd8x@gmail.com>
endef

define Package/wifimedia_portal/description
	Wifimedia offer it supports Wireless
endef

define Build/Compile
endef

define Package/wifimedia_portal/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)
endef
$(eval $(call BuildPackage,wifimedia_portal))