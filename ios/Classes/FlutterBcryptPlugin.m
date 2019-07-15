#import "FlutterBcryptPlugin.h"
#import <flutter_bcrypt/flutter_bcrypt-Swift.h>

@implementation FlutterBcryptPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterBcryptPlugin registerWithRegistrar:registrar];
}
@end
