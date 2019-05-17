include $(TOPDIR)/rules.mk

PKG_NAME:=statistics-shell
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=statistics speed of every ip by a shell
  DEPENDS:=+iptables
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/statistics-shell.sh $(1)/usr/bin/statistics-shell
endef

define Build/Prepare
endef

define Build/Compile
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
