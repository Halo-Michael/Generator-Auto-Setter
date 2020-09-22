#include <CoreFoundation/CoreFoundation.h>

#define bundleID CFSTR("com.michael.generator")

int main() {
    CFArrayRef keyList = CFPreferencesCopyKeyList(bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
    if (keyList != NULL) {
        if (CFArrayContainsValue(keyList, CFRangeMake(0, CFArrayGetCount(keyList)), CFSTR("enabled")) && !CFBooleanGetValue(CFPreferencesCopyValue(CFSTR("enabled"), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost))) {
            CFRelease(keyList);
            return 0;
        }
        CFRelease(keyList);
    }
    execvp("setgenerator", (char *[]){"setgenerator", NULL});
    perror("setgenerator");
    return -1;
}
