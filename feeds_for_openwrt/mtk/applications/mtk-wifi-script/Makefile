#
# Copyright (C) 2010-2013 hua.shao@mediatek.com
#
# MTK Property Software.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mtk-wifi-script
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=Used to config the chip of mtk
  SUBMENU:=Applications
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/lib/wifi
	$(INSTALL_BIN) ./files/ralink_common.sh $(1)/lib/wifi/
endef


$(eval $(call BuildPackage,$(PKG_NAME)))

