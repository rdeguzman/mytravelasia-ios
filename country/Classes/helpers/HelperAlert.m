//
//  HelperDevice.m
//  IpadCountry
//
//  Created by rupert on 26/04/11.
//  Copyright 2011 2RMobile. All rights reserved.
//

#import "HelperAlert.h"
#import "DebugLog.h"

@implementation HelperAlert

@end

@implementation HelperAlert (Alert)

+ (void)showTitle:(NSString*)alertTitle message:(NSString*)alertMessage{
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease]; 
	alertView.tag = 5000; 
	[alertView show]; 
	DebugLog(@"title: %@ message: %@", alertTitle, alertMessage);
}

+ (void)showTitle:(NSString*)alertTitle message:(NSString*)alertMessage delegate:(id)object{
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:object cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease]; 
	alertView.tag = 5000; 
	[alertView show]; 
	DebugLog(@"title: %@ message: %@", alertTitle, alertMessage);
}

@end