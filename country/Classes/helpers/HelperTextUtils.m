//
//  HelperTextUtils.m
//  Country
//
//  Created by rupert on 13/04/11.
//  Copyright 2011 2RMobile. All rights reserved.
//

#import "HelperTextUtils.h"
#import "DebugLog.h"

@implementation HelperTextUtils

@end

@implementation HelperTextUtils (Text)
+ (CGFloat)getHeightForString:(NSString*)text forFont:(UIFont*)font forWidth:(CGFloat)width{
	struct CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, 4000) lineBreakMode:UILineBreakModeWordWrap];
	return size.height;
}

+ (CGFloat)getWidthForString:(NSString*)text forFont:(UIFont*)font forWidth:(CGFloat)width{
	struct CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, 4000) lineBreakMode:UILineBreakModeWordWrap];
	return size.width;
}

@end