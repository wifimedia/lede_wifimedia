include $(TOPDIR)/rules.mk

PKG_NAME:=juci-translations-zh
PKG_VERSION:=1
PKG_RELEASE:=$(PKG_VERSION)
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS := juci 

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
    SECTION:=juci
    CATEGORY:=JUCI
    TITLE:=Chinese translation of JUCI
    SUBMENU:=Plugins
endef
    
define Package/$(PKG_NAME)/description
	Chinese translation of JUCI
endef 

define Package/$(PKG_NAME)/config
	depends on PACKAGE_juci
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	make -C $(STAGING_DIR)/usr/src/juci/ MODULE=$(PKG_BUILD_DIR)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/www
	$(CP) $(PKG_BUILD_DIR)/bin/www/js $(1)/www
	$(CP) $(PKG_BUILD_DIR)/img $(1)/www
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
# run this only during image building stage
[ -n "$${IPKG_INSTROOT}" ] && $${STAGING_DIR}/usr/src/juci/juci-update $${IPKG_INSTROOT}/www/
# otherwise just run normal version
[ -z "$${IPKG_INSTROOT}" ] && {
	uci get juci.localization.languages | grep "zh" || {
		uci add_list juci.localization.languages=zh
		uci commit juci
	}
	juci-update
}
exit 0
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
