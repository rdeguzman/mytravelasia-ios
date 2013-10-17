//
//  HelperFileUtils.h
//  Country
//
//  Created by rupert on 7/04/11.
//  Copyright 2011 2RMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelperFileUtils : NSObject
@end

@interface HelperFileUtils (Files)
+ (NSString *)directoryInDocuments:(NSString *)dirName;
+ (NSString *)fileInBundle:(NSString *)fileName;

@end
