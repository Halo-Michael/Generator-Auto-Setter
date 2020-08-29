#include <CoreFoundation/CoreFoundation.h>

CFStringRef bundleID = CFSTR("com.michael.generator");

void usage() {
    printf("Usage:\tsetgenerator [generator]\n");
    printf("\t-s\tShow current setting.\n");
}

bool vaildGenerator(char *generator) {
    if (strlen(generator) != 18 || generator[0] != '0' || generator[1] != 'x') {
        return false;
    }
    for (int i = 2; i <= 17; i++) {
        if (!isxdigit(generator[i])) {
            return false;
        }
    }
    return true;
}

char *getGenerator() {
    char *generator = "0x1111111111111111";
    CFArrayRef keyList = CFPreferencesCopyKeyList(bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
    if (keyList != NULL) {
        if (CFArrayContainsValue(keyList, CFRangeMake(0, CFArrayGetCount(keyList)), CFSTR("generator"))) {          
            CFStringRef CFGenerator = CFPreferencesCopyValue(CFSTR("generator"), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
            CFIndex maxSize = CFStringGetMaximumSizeForEncoding(CFStringGetLength(CFGenerator), kCFStringEncodingUTF8) + 1;
            generator = (char *)malloc(maxSize);
            memset(generator, 0, maxSize);
            CFStringGetCString(CFGenerator, generator, maxSize, kCFStringEncodingUTF8);
            CFRelease(CFGenerator);
            if (!vaildGenerator(generator)) {
                free(generator);
                generator = "0x1111111111111111";
                CFPreferencesSetValue(CFSTR("generator"), NULL, bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
            }
        }
        CFRelease(keyList);
    }
    return generator;
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
            printf("The currently set generator is %s.\n", getGenerator());
            return 0;
        } else if (!vaildGenerator(argv[1])) {
            usage();
            return 3;
        } else {
            CFPreferencesSetValue(CFSTR("generator"), CFStringCreateWithCString(kCFAllocatorDefault, argv[1], kCFStringEncodingUTF8), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
        }
    }

    execvp("dimentio", (char *[]){"dimentio", getGenerator(), NULL});
    perror("dimentio");
    return -1;
}
