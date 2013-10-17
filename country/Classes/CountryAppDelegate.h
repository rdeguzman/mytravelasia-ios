#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "User.h"

@interface CountryAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *window;
	UINavigationController *navigationController;
  User *user;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;

@end

