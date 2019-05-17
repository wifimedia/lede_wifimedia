include $(TOPDIR)/rules.mk

PKG_NAME:=lua-requests
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/lua-requests
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=lua-requests
  DEPENDS:=+luasocket +luasec +lua-md5 +lua-cjson +lbase64
endef

define Package/lua-requests/description
	The same friendly python Requests interface for Lua!
endef

define Build/Prepare
endef

define Build/Compile
endef

define Package/lua-requests/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DATA) ./src/requests.lua $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lua-requests))
