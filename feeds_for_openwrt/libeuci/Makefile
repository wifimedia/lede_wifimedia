include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

PKG_NAME:=libeuci
PKG_RELEASE:=1

define Package/$(PKG_NAME)
 SECTION:=libs
 CATEGORY:=Libraries
 DEPENDS:=+libuci
 TITLE:=wrap for libuci,designed to use simple
 MAINTAINER:=zhaojianhui <zjhsucceed_329@163.com>
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libeuci.h $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/libeuci.so $(1)/usr/lib
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_BUILD_DIR)/libeuci.so $(1)/lib
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
