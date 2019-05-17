
include $(TOPDIR)/rules.mk

PKG_NAME:=shellinabox
PKG_VERSION:=2.19
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/shellinabox/shellinabox.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=1a8010f2c94a62e7398c4fa130dfe9e099dc55cd
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=a web based terminal emulator
  URL:=https://github.com/shellinabox/shellinabox
  DEPENDS:=+zlib +libopenssl +openssl-util +busybox +@BUSYBOX_CUSTOM +@BUSYBOX_CONFIG_LOGIN
endef

define Package/$(PKG_NAME)/description
	Shell In A Box implements a web server that 
	can export arbitrary command line tools to 
	a web based terminal emulator. This emulator 
	is accessible to any JavaScript and CSS 
	enabled web browser and does not require any additional browser plugins.
endef

define Package/$(PKG_NAME)/conffiles
/etc/shellinaboxd/certificate.pem
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/shellinaboxd $(1)/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/shellinaboxd $(1)/usr/sbin
	$(INSTALL_BIN) ./files/shellinaboxd.init $(1)/etc/init.d/shellinaboxd
	$(INSTALL_CONF) ./files/shellinaboxd.config $(1)/etc/config/shellinaboxd
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/shellinabox/white-on-black.css $(1)/etc/shellinaboxd
	
endef

$(eval $(call BuildPackage,shellinabox))
