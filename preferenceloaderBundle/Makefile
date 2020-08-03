include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = generatorautosetter

generatorautosetter_FILES = GeneratorAutoSetterRootListController.m
generatorautosetter_INSTALL_PATH = /Library/PreferenceBundles
generatorautosetter_FRAMEWORKS = UIKit
generatorautosetter_PRIVATE_FRAMEWORKS = Preferences
generatorautosetter_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/generatorautosetter.plist$(ECHO_END)
