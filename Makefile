FINALPACKAGE=1
ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = OneWhamScale

OneWhamScale_FILES = Tweak.xm \
    src/utility.c \
    src/filebypass.c \
    src/spawnbypass.c \
    src/dylibbypass.c \
    src/sysctlbypass.c \
    src/hardwarespoof.c \
    src/mgspoof.c \
    src/objcbypass.xm \
    src/datingappbypass.xm \
    src/fingerprintbypass.xm \
    src/biometricbypass.xm \
    src/attestationbypass.xm \
    src/mediabypass.xm \
    src/recaptchabypass.xm \
    src/tinderhooks.xm

OneWhamScale_CFLAGS = -fobjc-arc -I./src -Wno-deprecated-declarations -Wno-availability
OneWhamScale_FRAMEWORKS = UIKit CoreLocation AVFoundation CoreMotion Photos ImageIO WebKit
OneWhamScale_PRIVATE_FRAMEWORKS =
OneWhamScale_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk