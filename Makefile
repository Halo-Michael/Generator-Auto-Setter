VERSION = 0.5.11
THEOS=/opt/theos
64CC = xcrun -sdk $(THEOS)/sdks/iPhoneOS13.0.sdk clang -arch arm64 -miphoneos-version-min=9.0 -O2
64eCC = $(64CC) -arch arm64e
SED = gsed
LDID = ldid

.PHONY: all clean

all: clean rcsetgenerator postinst setgenerator GeneratorAutoSetterRootListController
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/DEBIAN
	cp control com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/DEBIAN
	$(SED) -i 's/^Version:\x24/Version: $(VERSION)/g' com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/DEBIAN/control
	mv postinst com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/DEBIAN
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/usr
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/usr/bin
	mv setgenerator com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/usr/bin
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/etc
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/etc/rc.d
	mv rcsetgenerator com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/etc/rc.d/setgenerator
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/Library
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/Library/PreferenceLoader
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/Library/PreferenceLoader/Preferences
	cp entry.plist com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/Library/PreferenceLoader/Preferences/GeneratorAutoSetter.plist
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/Library/PreferenceBundles
	cp -r Resources com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/Library/PreferenceBundles/GeneratorAutoSetter.bundle
	mv GeneratorAutoSetterRootListController com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/Library/PreferenceBundles/GeneratorAutoSetter.bundle/GeneratorAutoSetter
	dpkg -b com.michael.generatorautosetter_$(VERSION)_iphoneos-arm

postinst: clean
	$(64CC) postinst.c -o postinst
	strip postinst
	$(LDID) -Sentitlements.xml postinst

rcsetgenerator: clean
	$(64CC) -fobjc-arc rcsetgenerator.m -framework Foundation -o rcsetgenerator
	strip rcsetgenerator
	$(LDID) -Sentitlements.xml rcsetgenerator

setgenerator: clean
	$(64CC) -fobjc-arc setgenerator.m libdementia.tbd -framework Foundation -o setgenerator
	strip setgenerator
	$(LDID) -Stfp0.xml setgenerator

GeneratorAutoSetterRootListController: clean
	$(64eCC) -dynamiclib -fobjc-arc -install_name /Library/PreferenceBundles/GeneratorAutoSetter.bundle/GeneratorAutoSetter -I${THEOS}/vendor/include/ -framework Foundation -framework UIKit ${THEOS}/sdks/iPhoneOS13.0.sdk/System/Library/PrivateFrameworks/Preferences.framework/Preferences.tbd GeneratorAutoSetterRootListController.m -o GeneratorAutoSetterRootListController
	strip -x GeneratorAutoSetterRootListController
	$(LDID) -S GeneratorAutoSetterRootListController

clean:
	rm -rf com.michael.generatorautosetter_*
	rm -f postinst rcsetgenerator setgenerator GeneratorAutoSetterRootListController
