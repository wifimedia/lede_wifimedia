include $(TOPDIR)/rules.mk

PKG_NAME:=carrier-monitor
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Monitor the carrier status of all network device
  DEPENDS:=+libnl-tiny +libev
endef

define Package/$(PKG_NAME)/description
	Monitor the carrier status of all network device. And call
	etc/hotplug.d/carrier/* use hotplug-call when the carrier has changed.
endef

define Build/Prepare
	$(INSTALL_DIR) $(PKG_BUILD_DIR)
	$(INSTALL_DATA) ./src/* $(PKG_BUILD_DIR)/
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/libnl-tiny -I$(STAGING_DIR)/usr/include -D_GNU_SOURCE 
	
define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -Wall \
		-o $(PKG_BUILD_DIR)/carrier-monitor $(PKG_BUILD_DIR)/carrier.c -lnl-tiny -lev
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d $(1)/etc/hotplug.d/carrier
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/carrier-monitor $(1)/usr/bin/
	$(INSTALL_BIN) ./files/carrier-monitor.init $(1)/etc/init.d/carrier-monitor
	$(INSTALL_DATA) ./files/test.hotplug $(1)/etc/hotplug.d/carrier/00-test
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
