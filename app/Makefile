TARGET = iphone:clang:latest:15.0
ARCHS = arm64

INSTALL_TARGET_PROCESSES = vnodebypass

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = vnodebypass

vnodebypass_FILES = vnode-main.swift SceneDelegate.swift RootView.swift Controller.swift SpawnUtil.swift
vnodebypass_FRAMEWORKS = UIKit CoreGraphics SwiftUI

include $(THEOS_MAKE_PATH)/application.mk
