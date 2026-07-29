ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = OneWhamScale

OneWhamScale_FILES = Tweak.xm
OneWhamScale_CFLAGS = -fobjc-arc
OneWhamScale_FRAMEWORKS = UIKit CoreLocation AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk
