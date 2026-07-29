export TARGET := iphone:clang:16.0:14.0
export ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = OneWhamScale
OneWhamScale_FILES = Tweak.xm
OneWhamScale_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
OneWhamScale_LDFLAGS = -lsubstrate -framework Foundation -framework UIKit -framework Security
OneWhamScale_PRIVATE_FRAMEWORKS = SpringBoardServices

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"