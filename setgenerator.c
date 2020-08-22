#include <CoreFoundation/CoreFoundation.h>

CFStringRef bundleID = CFSTR("com.michael.generator");

void usage() {
    printf("Usage:\tsetgenerator [generator]\n");
    printf("\t-s\tShow current setting.\n");
}

char *CFStringCopyUTF8String(CFStringRef aString) {
    if (aString == NULL) {
        return NULL;
    }

    CFIndex length = CFStringGetLength(aString);
    CFIndex maxSize = CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8) + 1;
    char *buffer = (char *)malloc(maxSize);
    if (CFStringGetCString(aString, buffer, maxSize, kCFStringEncodingUTF8)) {
        return buffer;
    }
    free(buffer);
    return NULL;
}

int main(int argc, char **argv) {
    if (getuid() != 0) {
        setuid(0);
    }

    if (getuid() != 0) {
        printf("Can't set uid as 0.\n");
        return 2;
    }

    if (argc > 2) {
        usage();
        return 3;
    }

    if (argc == 2) {
        if (strcmp(argv[1], "-s") == 0) {
            CFArrayRef keyList = CFPreferencesCopyKeyList(bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
            if (keyList != NULL && CFArrayContainsValue(keyList, CFRangeMake(0, CFArrayGetCount(keyList)), CFSTR("generator"))) {
                char *generator = CFStringCopyUTF8String(CFPreferencesCopyValue(CFSTR("generator"), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost));
                if (strlen(generator) == 18 && generator[0] == '0' && generator[1] == 'x') {
                    printf("The currently set generator is %s.\n", generator);
                    return 0;
                } else {
                    CFPreferencesSetValue(CFSTR("generator"), NULL, bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
                }
            }
            CFRelease(keyList);
            printf("The currently set generator is 0x1111111111111111.\n");
            return 0;
        } else if (strlen(argv[1]) != 18 || argv[1][0] != '0' || argv[1][1] != 'x') {
            usage();
            return 3;
        } else {
            CFPreferencesSetValue(CFSTR("generator"), CFStringCreateWithCString(kCFAllocatorDefault, argv[1], kCFStringEncodingUTF8), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
        }
    }

    char *generator = "0x1111111111111111";
    CFArrayRef keyList = CFPreferencesCopyKeyList(bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
    if (keyList != NULL && CFArrayContainsValue(keyList, CFRangeMake(0, CFArrayGetCount(keyList)), CFSTR("generator"))) {
        generator = CFStringCopyUTF8String(CFPreferencesCopyValue(CFSTR("generator"), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost));
        if (strlen(generator) != 18 || generator[0] != '0' || generator[1] != 'x') {
            CFPreferencesSetValue(CFSTR("generator"), NULL, bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
            generator = "0x1111111111111111";
        }
    }
    CFRelease(keyList);
    execvp("dimentio", (char *[]){"dimentio", generator, NULL});
    perror("dimentio");
    return -1;
}
