TARGET = iphone:clang:latest:15.0
ARCHS = arm64

INSTALL_TARGET_PROCESSES = vnodebypass

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = vnodebypass

vnodebypass_FILES = vnode-main.swift RootView.swift Controller.swift SpawnUtil.swift BypassButton.swift  \
					Settings.swift DeviceInfo.swift Preferences.swift ../shared/Constants.m
vnodebypass_FRAMEWORKS = UIKit CoreGraphics SwiftUI
vnodebypass_CFLAGS = -I../include
vnodebypass_CODESIGN_FLAGS = -Sappent.xml

include $(THEOS_MAKE_PATH)/application.mk
