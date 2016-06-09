ARCHS = arm64 armv7 armv7s
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MovieBoxUpdate
MovieBoxUpdate_FILES = Hack.xm
MovieBoxUpdate_FRAMEWORKS = UIKit CoreGraphics
MovieBoxUpdate_LDFLAGS += -Wl,-segalign,4000
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 6.0

BUNDLE_NAME = MovieBoxBundle
MovieBoxBundle_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/
include $(THEOS)/makefiles/bundle.mk

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MovieBox3; killall -9 Preferences"
include $(THEOS_MAKE_PATH)/aggregate.mk
