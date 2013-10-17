#import "CountryAppDelegate.h"
#import "ApplicationConstants.h"

#import "MainScrollViewController.h"
#import "HelperFileUtils.h"
#import "HelperDevice.h"
#import "HelperTextUtils.h"
#import "DebugLog.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "UBAlertView.h"

#import "Country.h"

@implementation CountryAppDelegate

@synthesize window, navigationController;


#pragma mark -
#pragma mark Application lifecycle

// FBSample logic
// If we have a valid session at the time of openURL call, we handle Facebook transitions
// by passing the url argument to handleOpenURL; see the "Just Login" sample application for
// a more detailed discussion of handleOpenURL
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  // attempt to extract a token from the url
  return [FBSession.activeSession handleOpenURL:url];
}

- (void)createImageCacheDirectory{
	NSString *imageCachePath = [HelperFileUtils directoryInDocuments:DIR_CACHE];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	BOOL success = [fileManager fileExistsAtPath:imageCachePath];
	if(success){
		DebugLog(@"imageCachePath exists.");
	}
	else{
		DebugLog(@"imageCachePath created.");
		[fileManager createDirectoryAtPath:imageCachePath withIntermediateDirectories:NO attributes:nil error:NULL];
	}
}

- (void)createDatabaseDirectory{
	NSString *writableDBPath = [HelperFileUtils directoryInDocuments:DB_NAME];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	BOOL success = [fileManager fileExistsAtPath:writableDBPath];
	if(success){
		DebugLog(@"dbPath exists.");
	}
	else{
		DebugLog(@"dbPath created.");
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_NAME];
		NSError *error;
		[fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  user = [User sharedInstance];
  
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  self.window = [[UIWindow alloc] initWithFrame: screenBounds];
  DLog(@"%f, %f", self.window.frame.size.width, self.window.frame.size.height);

	[self createImageCacheDirectory];
	[self createDatabaseDirectory];
	
	MainScrollViewController* mainview = [[MainScrollViewController alloc] initWithNibName:[HelperDevice nibNameForDevice:@"MainScrollViewController"] bundle:nil];

	self.navigationController = [[UINavigationController alloc] initWithRootViewController:mainview];
	
	[self.navigationController setToolbarHidden:YES];
	[self.navigationController setNavigationBarHidden:YES];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

  [self.window setRootViewController:navigationController];
	[mainview release];
    
  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
  DLog(@"");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
  DLog(@"");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
  
  NSArray *viewControllers = self.navigationController.viewControllers;
  int total = viewControllers.count;
  DLog(@"%d", total);
  
  if(total == 2 || total == 3){
    UIViewController *vc = [viewControllers objectAtIndex:total-1];
    if ([vc respondsToSelector: @selector(reload)]){
      [vc reload];
    }
  }
}

- (void)applicationDidBecomeActive:(UIApplication *)application	{
  // FBSample logic
  // We need to properly handle activation of the application with regards to SSO
  //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
  [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // FBSample logic
  // if the app is going away, we close the session object
  [FBSession.activeSession close];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
	[navigationController release];
  [window release];
  [super dealloc];
}

#pragma mark notifications
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSString *stringToken = [[[deviceToken description]
                            stringByReplacingOccurrencesOfString: @"<" withString: @""]
                           stringByReplacingOccurrencesOfString: @">" withString: @""];
  
  DLog(@"stringToken: %@",stringToken);
  user.device_token = stringToken;
  
  NSMutableString *strURLDirty = [[NSMutableString alloc] init];
  [strURLDirty appendFormat:@"%@", HTTP_APN_REGISTER_URL];
  [strURLDirty appendFormat:@"&country_name=%@", [Country getName]];
  [strURLDirty appendFormat:@"&token=%@", stringToken];

  NSString *strURLClean = [strURLDirty stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURL *url = [NSURL URLWithString:strURLClean];
  DLog(@"%@", strURLClean);
	
  ASIHTTPRequest* currentHTTPRequest = [ASIHTTPRequest requestWithURL:url];
  [currentHTTPRequest setDelegate:self];
  [currentHTTPRequest setDidFinishSelector:@selector(requestAPNRegisterFinished:)];
  [currentHTTPRequest setDidFailSelector:@selector(requestAPNRegisterFailed:)];
  [currentHTTPRequest setTimeOutSeconds:HTTP_TIMEOUT];

  [currentHTTPRequest startAsynchronous];
  [strURLDirty release];
}
- (void )application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
  DLog (@"Error in registration. Error: %@" , err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
  application.applicationIconBadgeNumber = 0;
  NSLog(@"Received remote notification");
}

- (void)requestAPNRegisterFinished:(ASIHTTPRequest *)request {
	DLog(@"");
  
  NSData *jsonData = [request responseData];
  id responseRoot = [jsonData objectFromJSONData];
  
  if([responseRoot isKindOfClass:[NSDictionary class]]) {
    DLog(@"message:%@", [responseRoot objectForKey:@"message"]);
  }
  else
    [UBAlertView showAlertWithTitle:@"Warning" message:MESSAGE_APPLICATION_ERROR executeBlock:nil];
}

- (void)requestAPNRegisterFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSString *message = [error localizedDescription];
	
	if( [error localizedDescription] == @"The request timed out" ) {
		message = [NSString stringWithFormat:@"%@ (%@)", MESSAGE_NETWORK_ERROR, [error localizedDescription]];
	}
	
	[UBAlertView showAlertWithTitle:@"Error" message:message executeBlock:nil];
  DLog(@"message:%@", message);
}

@end
