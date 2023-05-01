TARGET = iphone:clang:latest:15.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TOOL_NAME = vnodebypass

vnodebypass_FILES = main.m vnode.m libdimentio.c kernel.m
vnodebypass_CFLAGS = -fobjc-arc -Iinclude
vnodebypass_CODESIGN_FLAGS = -Sent.plist
vnodebypass_INSTALL_PATH = /usr/bin
vnodebypass_FRAMEWORKS = IOKit

include $(THEOS_MAKE_PATH)/tool.mk
SUBPROJECTS += app
SUBPROJECTS += debian-script
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	chmod -R 755 $(THEOS_STAGING_DIR)
	chmod 6755 $(THEOS_STAGING_DIR)/usr/bin/vnodebypass
	chmod 666 $(THEOS_STAGING_DIR)/DEBIAN/control
