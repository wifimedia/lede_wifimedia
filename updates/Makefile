#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=updates
PKG_VERSION:=1.0.0
PKG_RELEASE:=3
PKG_MAINTAINER:=Dungtd <dungtd8x@gmail.com>
PKG_LICENSE:=GPLv2

include $(INCLUDE_DIR)/package.mk

define Package/updates
  SUBMENU:=Wifimedia
  SECTION:=dev
  CATEGORY:=Advance
  TITLE:=Configuration Online
  URL:=http://wifimedia.vn
  MENU:=1
  PKGARCH:=all
  MAINTAINER:=DungTD <dungtd8x@gmail.com>
endef

define Package/updates/description

endef

define Build/Compile
endef

define Package/updates/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)
endef

define Package/updates/postinst
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
	echo "Fix the permissions "
	chmod a+x /sbin/wifimedia/updates.sh
fi
exit 0
endef

define Package/updates/prerm
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
	echo "Removing rc.d symlink for wifimedia"
fi
exit 0
endef
$(eval $(call BuildPackage,updates))