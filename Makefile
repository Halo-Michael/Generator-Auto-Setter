export TARGET = iphone:clang::9.0
export ARCHS = arm64 arm64e
export VERSION = 0.3.3
export DEBUG = no
CC = xcrun -sdk iphoneos clang -arch arm64 -arch arm64e -miphoneos-version-min=9.0
LDID = ldid

.PHONY: all clean

all: clean rcsetgenerator postinst setgenerator preferenceloaderBundle
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
	cp preferenceloaderBundle/entry.plist com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/Library/PreferenceLoader/Preferences/GeneratorAutoSetter.plist
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/Library/PreferenceBundles
	mv preferenceloaderBundle/.theos/obj/GeneratorAutoSetter.bundle com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/Library/PreferenceBundles
	dpkg -b com.michael.generatorautosetter_$(VERSION)_iphoneos-arm

postinst: clean
	$(CC) postinst.c -o postinst
	strip postinst
	$(LDID) -Sentitlements.xml postinst

rcsetgenerator: clean
	$(CC) rcsetgenerator.c -framework CoreFoundation -o rcsetgenerator
	strip rcsetgenerator
	$(LDID) -Sentitlements.xml rcsetgenerator

setgenerator: clean
	$(CC) setgenerator.c -framework CoreFoundation -o setgenerator
	strip setgenerator
	$(LDID) -Sentitlements.xml setgenerator

preferenceloaderBundle: clean
	cd preferenceloaderBundle && make

clean:
	rm -rf com.michael.generatorautosetter_* preferenceloaderBundle/.theos
	rm -f postinst rcsetgenerator setgenerator
