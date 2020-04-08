TARGET = GeneratorAutoSetter
VERSION = 0.2.2
CC = xcrun -sdk iphoneos clang -arch arm64 -arch arm64e -miphoneos-version-min=9.0
LDID = ldid

.PHONY: all clean

all: clean postinst setgenerator
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/DEBIAN
	cp control com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/DEBIAN
	mv postinst com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/DEBIAN
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/usr
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/usr/bin
	mv setgenerator/.theos/obj/setgenerator com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/usr/bin
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/etc
	mkdir com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/etc/rc.d
	ln -s ../../../usr/bin/setgenerator com.michael.generatorautosetter_$(VERSION)_iphoneos-arm/etc/rc.d
	dpkg -b com.michael.generatorautosetter_$(VERSION)_iphoneos-arm

postinst: clean
	$(CC) postinst.c -o postinst
	strip postinst
	$(LDID) -Sentitlements.xml postinst

setgenerator: clean
	sh make-setgenerator.sh

clean:
	rm -rf com.michael.generatorautosetter_* setgenerator/.theos
	rm -f postinst
