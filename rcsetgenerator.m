#import <Foundation/Foundation.h>

#define bundleID @"com.michael.generator"
#define containerURL [NSURL URLWithString:@"file:///private/var/mobile"]

int main() {
    id enabled = [[[NSUserDefaults alloc] _initWithSuiteName:bundleID container:containerURL] objectForKey:@"enabled"];
    if (enabled != nil) {
        if ([enabled isKindOfClass:[NSNumber class]]) {
            if (![enabled boolValue]) {
                return 0;
            }
        } else {
            [[[NSUserDefaults alloc] _initWithSuiteName:bundleID container:containerURL] removeObjectForKey:@"enabled"];
        }
    }
    execvp("setgenerator", (char *[]){"setgenerator", NULL});
    perror("setgenerator");
    return -1;
}
