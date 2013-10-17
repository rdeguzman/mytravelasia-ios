#import "User.h"

static User *sharedMyManager = nil;

@implementation User

@synthesize profile_id, username, first_name, last_name, device_token, email;

#pragma mark Singleton Methods
+ (id)sharedInstance {
  @synchronized(self) {
    if(sharedMyManager == nil)
      sharedMyManager = [[super allocWithZone:NULL] init];
  }
  return sharedMyManager;
}

+ (id)allocWithZone:(NSZone *)zone {
  return [[self sharedInstance] retain];
}
- (id)copyWithZone:(NSZone *)zone {
  return self;
}
- (id)retain {
  return self;
}
- (unsigned)retainCount {
  return UINT_MAX; //denotes an object that cannot be released
}
- (oneway void)release {
  // never release
}
- (id)autorelease {
  return self;
}
- (id)init {
  if (self = [super init]) {
  }
  return self;
}

- (void)dealloc {
  // Should never be called, but just here for clarity really.
  [super dealloc];
}

- (void)description{
  DLog(@"user.id: %@", self.profile_id);
  DLog(@"user.device_token: %@", self.device_token);
  DLog(@"user.usernname: %@", self.username);
  DLog(@"user.first_name: %@", self.first_name);
  DLog(@"user.last_name: %@", self.last_name);
  DLog(@"user.email: %@", self.email);
}

@end
