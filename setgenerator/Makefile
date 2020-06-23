TARGET= iphone:clang:13.0:9.0
ARCHS= arm64 arm64e
DEBUG= 0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = setgenerator

$(TOOL_NAME)_FILES = setgenerator.m
$(TOOL_NAME)_CFLAGS = -fobjc-arc
$(TOOL_NAME)_CODESIGN_FLAGS = -S../entitlements.xml

include $(THEOS_MAKE_PATH)/tool.mk
