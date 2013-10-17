#import <Foundation/Foundation.h>

@interface User : NSObject {
  NSString *device_token;
  NSString *profile_id;
  NSString *username;
  NSString *first_name;
  NSString *lastName;
  NSString *email;
}

@property (nonatomic, retain) NSString *device_token;
@property (nonatomic, retain) NSString *profile_id;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic, retain) NSString *email;

+ (id)sharedInstance;

- (void)description;

@end
