#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=horst-ubus
PKG_VERSION:=2016-12-22
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/br101/horst.git
PKG_SOURCE_VERSION:=af8f8a3aff2f06978c08dba15393185236b556b5
PKG_SOURCE:=horst-$(PKG_VERSION).tar.gz

PKG_MAINTAINER:=Bruno Randolf <br1@einfach.org>
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS += LIBNL=tiny 

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=wireless
	DEPENDS:=+libncurses +libnl-tiny +libubus +libubox +libubus-lua +libubox-lua
	MAINTAINER:=Bruno Randolf <br1@einfach.org>
	TITLE:=Highly Optimized 802.11 Radio Scanning Tool(Support UBUS)
	URL:=http://br1.einfach.org/tech/horst/
endef

define Package/$(PKG_NAME)/description
	[horst] is a scanning and analysis tool for 802.11 wireless networks
	and especially IBSS (ad-hoc) mode and mesh networks (OLSR).
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/usr/lib $(1)/etc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/horst $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/horst.sh $(1)/usr/sbin/
	$(CP) $(PKG_BUILD_DIR)/libuwifi/libuwifi.so* $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/horst.conf $(1)/etc
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
