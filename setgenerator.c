#include <CoreFoundation/CoreFoundation.h>
#include "libdementia.h"

#define MIN(a, b) ((a) < (b) ? (a) : (b))

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
    char *generator = (char *)calloc(19, sizeof(char));
    CFArrayRef keyList = CFPreferencesCopyKeyList(bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
    if (keyList != NULL) {
        if (CFArrayContainsValue(keyList, CFRangeMake(0, CFArrayGetCount(keyList)), CFSTR("generator"))) {
            CFTypeRef CFGenerator = CFPreferencesCopyValue(CFSTR("generator"), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
            if (CFGetTypeID(CFGenerator) == CFStringGetTypeID() && CFStringGetLength(CFGenerator) == 18) {
                CFStringGetCString(CFGenerator, generator, 19, kCFStringEncodingUTF8);
                if (!vaildGenerator(generator)) {
                    memset(generator, 0, 19 * sizeof(char));
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
            if (dimentio_init(0, NULL, NULL) == KERN_SUCCESS) {
                uint8_t entangled_nonce[CC_SHA384_DIGEST_LENGTH];
                uint64_t nonce;
                bool entangled;
                size_t i;
                if (dimentio(&nonce, false, entangled_nonce, &entangled) == KERN_SUCCESS) {
                    printf("The currently generator is 0x%016" PRIX64 ".\n", nonce);
                    if (entangled_nonce[0] != 0) {
                        if (entangled) {
                            printf("entangled_apnonce: ");
                        } else {
                            printf("apnonce: ");
                        }
                        for (i = 0; entangled_nonce[i] != 0 && i < 32; ++i) {
                            printf("%02" PRIX8, entangled_nonce[i]);
                        }
                        putchar('\n');
                    }
                }
                dimentio_term();
            }
            CFArrayRef keyList = CFPreferencesCopyKeyList(bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
            if (keyList != NULL) {
                if (CFArrayContainsValue(keyList, CFRangeMake(0, CFArrayGetCount(keyList)), CFSTR("enabled")) && !CFBooleanGetValue(CFPreferencesCopyValue(CFSTR("enabled"), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost))) {
                    CFRelease(keyList);
                    printf("The program will NOT run automatically during the next jailbreak.\n");
                } else {
                    CFRelease(keyList);
                    printf("The program will run automatically during the next jailbreak.\n");
                }
            } else {
                printf("The program will run automatically during the next jailbreak.\n");
            }
            char *generator = getGenerator();
            printf("When next time the program is running, the generator will be set to %s.\n", generator);
            free(generator);
            return 0;
        } else if (!vaildGenerator(argv[1])) {
            usage();
            return 3;
        } else {
            CFPreferencesSetValue(CFSTR("generator"), CFStringCreateWithCString(kCFAllocatorDefault, argv[1], kCFStringEncodingUTF8), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
        }
    }

    if (dimentio_init(0, NULL, NULL) == KERN_SUCCESS) {
        uint64_t nonce;
        char *generator = getGenerator();
        sscanf(generator, "0x%016" PRIx64, &nonce);
        free(generator);
        uint8_t entangled_nonce[CC_SHA384_DIGEST_LENGTH];
        bool entangled;
        size_t i;
        if (dimentio(&nonce, true, entangled_nonce, &entangled) == KERN_SUCCESS) {
            printf("Set generator to 0x%016" PRIX64 "\n", nonce);
            if (entangled_nonce[0] != 0) {
                if (entangled) {
                    printf("entangled_apnonce: ");
                } else {
                    printf("apnonce: ");
                }
                for (i = 0; entangled_nonce[i] != 0 && i < 32; ++i) {
                    printf("%02" PRIX8, entangled_nonce[i]);
                }
                putchar('\n');
            }
        }
        dimentio_term();
    }
    return 0;
}
