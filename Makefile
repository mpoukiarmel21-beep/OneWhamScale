FINALPACKAGE=1
ARCHS = arm64 arm64e
TARGET := iphone:clang:16.5:14.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = OneWhamScale
OneWhamScale_FILES = Tweak.m \
    src/utility.c \
    src/filebypass.c \
    src/spawnbypass.c \
    src/dylibbypass.c \
    src/sysctlbypass.c \
    src/hardwarespoof.c \
    src/mgspoof.c \
    src/fishhook.c \
    src/objcbypass.m \
    src/datingappbypass.m \
    src/tinderhooks.m \
    src/fingerprintbypass.m \
    src/biometricbypass.m \
    src/attestationbypass.m \
    src/mediabypass.m \
    src/recaptchabypass.m

OneWhamScale_INSTALL_PATH = /usr/lib
OneWhamScale_CFLAGS = -fobjc-arc -I./src -Wno-deprecated-declarations -Wno-availability
OneWhamScale_LDFLAGS = -framework Foundation -framework UIKit -framework CoreLocation -framework AVFoundation -framework Photos -framework ImageIO -framework WebKit -framework CoreMotion -lMobileGestalt

include $(THEOS_MAKE_PATH)/library.mk