#include <Foundation/Foundation.h>

CFStringRef bundleID = CFSTR("com.michael.generator");

int main() {
    int ret = 0;
    CFArrayRef keyList = CFPreferencesCopyKeyList(bundleID, CFSTR("mobile"), kCFPreferencesAnyHost);
    if (keyList == NULL || !CFArrayContainsValue(keyList, CFRangeMake(0, CFArrayGetCount(keyList)), CFSTR("enabled")) || CFBooleanGetValue(CFPreferencesCopyValue(CFSTR("enabled"), bundleID, CFSTR("mobile"), kCFPreferencesAnyHost))) {
        int status = system("setgenerator");
        ret = WEXITSTATUS(status);
    }
    return ret;
}
