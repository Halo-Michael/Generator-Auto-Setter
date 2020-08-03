#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

UIAlertController *alert(NSString *alertTitle, NSString *alertMessage, NSString *actionTitle) {
    UIAlertController *theAlert = [UIAlertController
                                alertControllerWithTitle:alertTitle
                                message:alertMessage
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction
                                    actionWithTitle:actionTitle
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {}];
    [theAlert addAction:defaultAction];
    return theAlert;
}

@interface GeneratorAutoSetterRootListController : PSListController

@end

@implementation GeneratorAutoSetterRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    if ([[specifier propertyForKey:@"key"] isEqualToString:@"generator"]) {
        if (value == nil || [value characterAtIndex:0] != '0' || [value characterAtIndex:1] != 'x' || [[NSNumber numberWithUnsignedInteger:[value length]] intValue] != 18) {
            [self presentViewController:alert(@"setgenerator", [NSString stringWithFormat:@"Wrong generator \"%@\":\nFormat error!", value], @"OK") animated:YES completion:nil];
            return;
        }
    }
    [super setPreferenceValue:value specifier:specifier];
}

-(void)setgenerator {
    [self.view endEditing:YES];
    NSMutableString *alertMessage = [[NSMutableString alloc] init];
    FILE *fp = popen("setgenerator", "r");
    char buffer = fgetc(fp);
    while (!feof(fp)) {
        [alertMessage appendFormat:@"%c", buffer];
        buffer = fgetc(fp);
    }
    fclose(fp);
    [self presentViewController:alert(@"setgenerator", alertMessage, @"OK") animated:YES completion:nil];
}

@end
