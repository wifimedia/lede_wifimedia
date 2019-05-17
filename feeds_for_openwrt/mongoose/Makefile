
include $(TOPDIR)/rules.mk

PKG_NAME:=mongoose
PKG_VERSION:=6.7
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/cesanta/mongoose.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=4d9f8168b8bb264d4160b219b10ad43d2eb7c88a
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_CONFIG_DEPENDS:= CONFIG_MONGOOSE_SSL_NONE CONFIG_MONGOOSE_SSL_OPENSSL CONFIG_MONGOOSE_SSL_MBEDTLS CONFIG_MONGOOSE_COMPILE_EXAMPLE

include $(INCLUDE_DIR)/package.mk

define Package/mongoose
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Networking
  TITLE:=Mongoose Embedded Web Server Library
  URL:=https://github.com/cesanta/mongoose
  DEPENDS:=+libpthread +MONGOOSE_SSL_OPENSSL:libopenssl +MONGOOSE_SSL_MBEDTLS:libmbedtls
endef

define Package/mongoose/description
	Mongoose Embedded Web Server Library.
	Mongoose is more than an embedded webserver. It is a
	multi-protocol embedded networking library with functions
	including TCP, HTTP client and server, WebSocket client
	and server, MQTT client and broker and much more. 
endef

define Package/mongoose/config
menu "Configuration"
	depends on PACKAGE_mongoose

	choice
		prompt "SSl"
		default MONGOOSE_SSL_NONE
		
		config MONGOOSE_SSL_NONE
			bool "none"
			
		config MONGOOSE_SSL_OPENSSL
			bool "openssl"
			
		config MONGOOSE_SSL_MBEDTLS
			bool "mbedtls"
		
	endchoice
endmenu
endef

ifeq ($(CONFIG_MONGOOSE_SSL_OPENSSL),y)
  TARGET_CFLAGS += -DMG_ENABLE_SSL -lssl -lcrypto
endif

ifeq ($(CONFIG_MONGOOSE_SSL_MBEDTLS),y)
  TARGET_CFLAGS += -DMG_ENABLE_SSL -DMG_SSL_IF=MG_SSL_IF_MBEDTLS -DMG_SSL_MBED_DUMMY_RANDOM -lmbedcrypto -lmbedtls -lmbedx509
endif

TARGET_CFLAGS += -lpthread

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -Wall -fPIC -shared \
		$(PKG_BUILD_DIR)/mongoose.c -o $(PKG_BUILD_DIR)/libmongoose.so		
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/libmongoose.so $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/mongoose.h $(1)/usr/include
endef

define Package/mongoose/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libmongoose.so $(1)/usr/lib
endef

$(eval $(call BuildPackage,mongoose))
