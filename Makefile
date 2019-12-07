TARGET = GeneratorAutoSetter
VERSION = 0.1.0
CC = xcrun -sdk iphoneos clang -arch arm64 -miphoneos-version-min=9.0
LDID = ldid

.PHONY: all clean

all: clean postinst setgenerator
	mkdir com.michael.generatorautosetter-$(VERSION)_iphoneos-arm
	mkdir com.michael.generatorautosetter-$(VERSION)_iphoneos-arm/DEBIAN
	cp control com.michael.generatorautosetter-$(VERSION)_iphoneos-arm/DEBIAN
	mv postinst com.michael.generatorautosetter-$(VERSION)_iphoneos-arm/DEBIAN
	mkdir com.michael.generatorautosetter-$(VERSION)_iphoneos-arm/usr
	mkdir com.michael.generatorautosetter-$(VERSION)_iphoneos-arm/usr/bin
	mv setgenerator com.michael.generatorautosetter-$(VERSION)_iphoneos-arm/usr/bin
	mkdir com.michael.generatorautosetter-$(VERSION)_iphoneos-arm/etc
	mkdir com.michael.generatorautosetter-$(VERSION)_iphoneos-arm/etc/rc.d
	ln -s ../../../usr/bin/setgenerator setgenerator
	mv setgenerator com.michael.generatorautosetter-$(VERSION)_iphoneos-arm/etc/rc.d
	dpkg -b com.michael.generatorautosetter-$(VERSION)_iphoneos-arm

postinst: clean
	$(CC) postinst.c -o postinst
	strip postinst
	$(LDID) -Sentitlements.xml postinst

setgenerator: clean
	$(CC) setgenerator.c -o setgenerator
	strip setgenerator
	$(LDID) -Sentitlements.xml setgenerator

clean:
	rm -rf com.michael.generatorautosetter-*
	rm -f postinst setgenerator
