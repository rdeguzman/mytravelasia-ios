//
//  HelperLogUtils.h
//  Country
//
//  Created by rupert on 3/05/11.
//  Copyright 2011 2RMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelperLogUtils : NSObject
@end

@interface HelperLogUtils (Log)
+ (void)logResponse:(NSString*)text;
+ (void)rowsInSection:(int)rows section:(int)section;
+ (void)heightForRow:(CGFloat)_height indexPath:(int)row;
@end