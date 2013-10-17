/*
 *  ApplicationConstants.h
 *  Philippines
 *
 *  Created by rupert on 11/01/11.
 *  Copyright 2010 2RMobile. All rights reserved.
 *
 */
#import <Foundation/Foundation.h>

@interface HelperAlert : NSObject
@end

@interface HelperAlert (Alert)
+ (void)showTitle:(NSString*)alertTitle message:(NSString*)alertMessage;
+ (void)showTitle:(NSString*)alertTitle message:(NSString*)alertMessage delegate:(id)object;
@end