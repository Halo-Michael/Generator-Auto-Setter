#include <CoreFoundation/CoreFoundation.h>

CFStringRef bundleID = CFSTR("com.michael.generator");

int main() {
    CFArrayRef keyList = CFPreferencesCopyKeyList(bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
    if (keyList == NULL || !CFArrayContainsValue(keyList, CFRangeMake(0, CFArrayGetCount(keyList)), CFSTR("enabled")) || CFBooleanGetValue(CFPreferencesCopyValue(CFSTR("enabled"), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost))) {
        execvp("setgenerator", (char *[]){"setgenerator", NULL});
        perror("setgenerator");
        return -1;
    }
    return 0;
}
