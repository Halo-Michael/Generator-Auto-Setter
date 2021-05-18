#import <Foundation/Foundation.h>
#import "libdementia.h"

#define bundleID @"com.michael.generator"
#define containerURL [NSURL URLWithString:@"file:///private/var/mobile"]

void usage() {
    printf("Usage:\tsetgenerator [generator]\n");
    printf("\t-s\tShow current status.\n");
}

bool vaildGenerator(const char *generator) {
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

const char *getGenerator() {
    id generator = [[[NSUserDefaults alloc] _initWithSuiteName:bundleID container:containerURL] objectForKey:@"generator"];
    if (generator != nil) {
        if ([generator isKindOfClass:[NSString class]]) {
            const char *value = [generator cStringUsingEncoding:NSUTF8StringEncoding];
            if (vaildGenerator(value)) {
                return value;
            }
        }
        [[[NSUserDefaults alloc] _initWithSuiteName:bundleID container:containerURL] removeObjectForKey:@"generator"];
    }
    return "0x1111111111111111";
}

int main(int argc, char **argv) {
    if (getuid() && setuid(0)) {
        printf("Can't set uid as 0.\n");
        return 2;
    }

    if (argc > 2) {
        usage();
        return 3;
    }

    if (argc == 2) {
        if (strcmp(argv[1], "-s") == 0) {
            uint8_t nonce_d[CC_SHA384_DIGEST_LENGTH];
            size_t i, nonce_d_sz;
            uint64_t nonce;
            if (dimentio_preinit(&nonce, false, nonce_d, &nonce_d_sz) == KERN_SUCCESS || (dimentio_init(0, NULL, NULL) == KERN_SUCCESS && dimentio(&nonce, false, nonce_d, &nonce_d_sz) == KERN_SUCCESS)) {
                printf("The currently generator is 0x%016" PRIX64 ".\n", nonce);
                if(nonce_d_sz != 0) {
                    printf("nonce_d: ");
                    for(i = 0; i < nonce_d_sz; ++i) {
                        printf("%02" PRIX8, nonce_d[i]);
                    }
                    putchar('\n');
                }
                dimentio_term();
            }
            id enabled = [[[NSUserDefaults alloc] _initWithSuiteName:bundleID container:containerURL] objectForKey:@"enabled"];
            if (enabled != nil) {
                if ([enabled isKindOfClass:[NSNumber class]]) {
                    if (![enabled boolValue]) {
                        printf("The program will NOT run automatically during the next jailbreak.\n");
                        goto next;
                    }
                } else {
                    [[[NSUserDefaults alloc] _initWithSuiteName:bundleID container:containerURL] removeObjectForKey:@"enabled"];
                }
            }
            printf("The program will run automatically during the next jailbreak.\n");
next:
            printf("When next time the program is running, the generator will be set to %s.\n", getGenerator());
            return 0;
        } else if (!vaildGenerator(argv[1])) {
            usage();
            return 3;
        } else {
            [[[NSUserDefaults alloc] _initWithSuiteName:bundleID container:containerURL] setObject:[[NSString alloc] initWithUTF8String:argv[1]] forKey:@"generator"];
        }
    }

    uint8_t nonce_d[CC_SHA384_DIGEST_LENGTH];
    size_t i, nonce_d_sz;
    uint64_t nonce;
    sscanf(getGenerator(), "0x%016" PRIx64, &nonce);
    if (dimentio_preinit(&nonce, true, nonce_d, &nonce_d_sz) == KERN_SUCCESS || (dimentio_init(0, NULL, NULL) == KERN_SUCCESS && dimentio(&nonce, true, nonce_d, &nonce_d_sz) == KERN_SUCCESS)) {
        printf("Set generator to 0x%016" PRIX64 "\n", nonce);
        if(nonce_d_sz != 0) {
            printf("nonce_d: ");
            for(i = 0; i < nonce_d_sz; ++i) {
                printf("%02" PRIX8, nonce_d[i]);
            }
            putchar('\n');
        }
        dimentio_term();
    }
    return 0;
}
