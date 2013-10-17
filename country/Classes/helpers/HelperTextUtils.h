//
//  HelperTextUtils.h
//  Country
//
//  Created by rupert on 13/04/11.
//  Copyright 2011 2RMobile. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HelperTextUtils : NSObject
@end

@interface HelperTextUtils (Text)
+ (CGFloat)getHeightForString:(NSString*)text forFont:(UIFont*)font forWidth:(CGFloat)width;
+ (CGFloat)getWidthForString:(NSString*)text forFont:(UIFont*)font forWidth:(CGFloat)width;
@end
