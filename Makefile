VERSION = 0.5.8
64CC = xcrun -sdk iphoneos clang -arch arm64 -miphoneos-version-min=9.0
64eCC = xcrun -sdk iphoneos clang -arch arm64 -arch arm64e -miphoneos-version-min=9.0
LDID = ldid

.PHONY: all clean

all: clean rcsetgenerator postinst setgenerator GeneratorAutoSetterRootListController
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/DEBIAN
	cp control com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/DEBIAN
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
	$(64CC) rcsetgenerator.c -framework CoreFoundation -o rcsetgenerator
	strip rcsetgenerator
	$(LDID) -Sentitlements.xml rcsetgenerator

setgenerator: clean
	$(64CC) setgenerator.c libdementia.tbd -framework CoreFoundation -o setgenerator
	strip setgenerator
	$(LDID) -Stfp0.xml setgenerator

GeneratorAutoSetterRootListController: clean
	$(64eCC) -dynamiclib -fobjc-arc -install_name /Library/PreferenceBundles/GeneratorAutoSetter.bundle/GeneratorAutoSetter -I${THEOS}/vendor/include/ -framework Foundation -framework UIKit ${THEOS}/sdks/iPhoneOS13.0.sdk/System/Library/PrivateFrameworks/Preferences.framework/Preferences.tbd GeneratorAutoSetterRootListController.m -o GeneratorAutoSetterRootListController
	strip -x GeneratorAutoSetterRootListController
	$(LDID) -S GeneratorAutoSetterRootListController

clean:
	rm -rf com.michael.generatorautosetter_*
	rm -f postinst rcsetgenerator setgenerator GeneratorAutoSetterRootListController
