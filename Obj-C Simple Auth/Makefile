ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

include $(THEOS)/makefiles/common.mk
TWEAK_NAME = objcauth

objcauth_FRAMEWORKS =  UIKit Foundation Security QuartzCore CoreGraphics  CoreText  AVFoundation Accelerate GLKit SystemConfiguration GameController
objcauth_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG
objcauth_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-module-import-in-extern-c
objcauth_FILES = Tweak.xm $(wildcard Includes/Toast/*.m) $(wildcard Includes/SCLAlertView/*.m)

#ipaauth_LIBRARIES += substrate
# GO_EASY_ON_ME = 1

include $(THEOS_MAKE_PATH)/tweak.mk
after-install::
   install.exec "killall -9 com.spotify.client || :"
