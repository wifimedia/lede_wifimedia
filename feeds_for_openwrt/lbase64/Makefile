include $(TOPDIR)/rules.mk

PKG_NAME:=lbase64
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/lbase64
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=lua-base64
  DEPENDS:=+lua
endef

define Package/lbase64/description
	This is a base64 library for Lua 5.1. For information on base64 see
endef

define Build/Prepare
	$(INSTALL_DIR) $(PKG_BUILD_DIR)
	$(INSTALL_DATA) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/lbase64/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/base64.so $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lbase64))
