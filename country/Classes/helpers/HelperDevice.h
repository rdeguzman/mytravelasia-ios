#import <Foundation/Foundation.h>
@interface HelperDevice : NSObject
@end

@interface HelperDevice (Device)
+(BOOL)isDeviceAniPad;
+(BOOL)isDeviceAniPhone;
+(NSString *)nibNameForDevice:(NSString*)_nibName;
+(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end
