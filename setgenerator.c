#include <CoreFoundation/CoreFoundation.h>
#include "dimentio/libdimentio.h"

#define bundleID CFSTR("com.michael.generator")

void usage() {
    printf("Usage:\tsetgenerator [generator]\n");
    printf("\t-s\tShow current status.\n");
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
    static char generator[19] = {0};
    CFArrayRef keyList = CFPreferencesCopyKeyList(bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
    if (keyList != NULL) {
        if (CFArrayContainsValue(keyList, CFRangeMake(0, CFArrayGetCount(keyList)), CFSTR("generator"))) {
            CFTypeRef CFGenerator = CFPreferencesCopyValue(CFSTR("generator"), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
            if (CFGetTypeID(CFGenerator) == CFStringGetTypeID() && CFStringGetLength(CFGenerator) == 18) {
                CFStringGetCString(CFGenerator, generator, 19, kCFStringEncodingUTF8);
                if (!vaildGenerator(generator)) {
                    memset(generator, 0, 19);
                    CFPreferencesSetValue(CFSTR("generator"), NULL, bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
                }
            } else {
                CFPreferencesSetValue(CFSTR("generator"), NULL, bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
            }
            CFRelease(CFGenerator);
        }
        CFRelease(keyList);
    }
    if (generator[0] == '\0') {
        strcpy(generator, "0x1111111111111111");
    }
    char *pointer = generator;
    return pointer;
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
            if (dimentio_init(0, NULL, NULL) == KERN_SUCCESS) {
                uint8_t entangled_nonce[CC_SHA384_DIGEST_LENGTH];
                bool entangled = false;
                uint64_t nonce;
                if (dementia(&nonce, entangled_nonce, &entangled) == KERN_SUCCESS) {
                    printf("The currently generator is 0x%016" PRIX64 ".\n", nonce);
                }
                dimentio_term();
            }
            printf("The currently set generator is %s.\n", getGenerator());
            return 0;
        } else if (!vaildGenerator(argv[1])) {
            usage();
            return 3;
        } else {
            CFPreferencesSetValue(CFSTR("generator"), CFStringCreateWithCString(kCFAllocatorDefault, argv[1], kCFStringEncodingUTF8), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
        }
    }

    uint8_t entangled_nonce[CC_SHA384_DIGEST_LENGTH];
    bool entangled = false;
    uint64_t nonce;
    if (dimentio_init(0, NULL, NULL) == KERN_SUCCESS) {
        sscanf(getGenerator(), "0x%016" PRIx64, &nonce);
        if (dimentio(nonce, entangled_nonce, &entangled) == KERN_SUCCESS) {
            printf("Set nonce to 0x%016" PRIX64 "\n", nonce);
            if(entangled) {
                printf("entangled_nonce: ");
                for(size_t i = 0; i < MIN(sizeof(entangled_nonce), 32); ++i) {
                    printf("%02" PRIX8, entangled_nonce[i]);
                }
                putchar('\n');
            }
        }
        dimentio_term();
    }
    return 0;
}
