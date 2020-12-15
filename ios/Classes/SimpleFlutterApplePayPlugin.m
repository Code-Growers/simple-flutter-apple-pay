#import "SimpleFlutterApplePayPlugin.h"
#import <simple_flutter_apple_pay/simple_flutter_apple_pay-Swift.h>

@implementation SimpleFlutterApplePayPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterApplePayPlugin registerWithRegistrar:registrar];
}
@end
