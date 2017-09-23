#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=license
PKG_VERSION:=1.6.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Dungtd <dungtd8x@gmail.com>
PKG_LICENSE:=GPLv2

include $(INCLUDE_DIR)/package.mk

define Package/license
  SUBMENU:=Wifimedia
  SECTION:=dev
  CATEGORY:=Advance
  DEPENDS:=+wifimedia_config
  TITLE:=License Users
  URL:=http://wifimedia.vn
  MENU:=1
  PKGARCH:=all
  MAINTAINER:=DungTD <dungtd8x@gmail.com>
endef

define Package/license/description

endef

define Build/Compile
endef

define Package/license/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)
endef

define Package/license/postinst
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
	echo "Fix the permissions for license"
	chmod a+x /usr/bin/license.sh
fi
exit 0
endef

$(eval $(call BuildPackage,license))