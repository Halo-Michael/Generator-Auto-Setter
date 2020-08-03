#include <Foundation/Foundation.h>
#include <removefile.h>

CFStringRef bundleID = CFSTR("com.michael.generator");

void usage() {
    printf("Usage:\tsetgenerator [generator]\n");
    printf("\t-s\tShow current setting.\n");
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
                NSString *generator = (NSString *)CFBridgingRelease(CFPreferencesCopyValue(CFSTR("generator"), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost));
                if ([generator characterAtIndex:0] == '0' && [generator characterAtIndex:1] == 'x' && [[NSNumber numberWithUnsignedInteger:[generator length]] intValue] == 18) {
                    printf("The currently set generator is %s.\n", [generator UTF8String]);
                    return 0;
                } else {
                    removefile("/private/var/mobile/Library/Preferences/com.michael.generator.plist", NULL, REMOVEFILE_RECURSIVE);
                    CFPreferencesSynchronize(bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
                }
            }
            printf("The currently set generator is 0x1111111111111111.\n");
            return 0;
        } else if (argv[1][0] != '0' || argv[1][1] != 'x' || strlen(argv[1]) != 18) {
            usage();
            return 3;
        } else {
            removefile("/private/var/mobile/Library/Preferences/com.michael.generator.plist", NULL, REMOVEFILE_RECURSIVE);
            CFPreferencesSynchronize(bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
            CFPreferencesSetValue(CFSTR("generator"), CFStringCreateWithCString(kCFAllocatorDefault, argv[1], kCFStringEncodingUTF8), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
        }
    }

    int ret = 1, status;
    CFArrayRef keyList = CFPreferencesCopyKeyList(bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
    if (keyList != NULL && CFArrayContainsValue(keyList, CFRangeMake(0, CFArrayGetCount(keyList)), CFSTR("generator"))) {
        NSString *generator = (NSString *)CFBridgingRelease(CFPreferencesCopyValue(CFSTR("generator"), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost));
        if ([generator characterAtIndex:0] == '0' && [generator characterAtIndex:1] == 'x' && [[NSNumber numberWithUnsignedInteger:[generator length]] intValue] == 18) {
            status = system([[NSString stringWithFormat:@"dimentio %@", generator] UTF8String]);
            ret = WEXITSTATUS(status);
            return ret;
        } else {
            removefile("/private/var/mobile/Library/Preferences/com.michael.generator.plist", NULL, REMOVEFILE_RECURSIVE);
            CFPreferencesSynchronize(bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
        }
    }
    status = system("dimentio 0x1111111111111111");
    ret = WEXITSTATUS(status);
    return ret;
}
