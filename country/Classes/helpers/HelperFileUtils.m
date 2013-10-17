//
//  HelperFileUtils.m
//  Country
//
//  Created by rupert on 7/04/11.
//  Copyright 2011 2RMobile. All rights reserved.
//

#import "HelperFileUtils.h"
#import "DebugLog.h"

@implementation HelperFileUtils

@end

@implementation HelperFileUtils (Files)
+ (NSString *)directoryInDocuments:(NSString *)dirName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	DebugLog(@"dirName:\n %@", documentsDirectory);
	
	NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:dirName];
	DebugLog(@"finalPath:\n %@", finalPath);
	
	return finalPath;
}

+ (NSString *)fileInBundle:(NSString *)fileName
{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
}

@end
