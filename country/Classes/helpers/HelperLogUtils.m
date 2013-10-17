//
//  HelperLogUtils.m
//  Country
//
//  Created by rupert on 3/05/11.
//  Copyright 2011 2RMobile. All rights reserved.
//

#import "HelperLogUtils.h"
#import "DebugLog.h"
#import "DebugConstants.h"

@implementation HelperLogUtils

@end

@implementation HelperLogUtils (Log)
+ (void)logResponse:(NSString*)text{
	if( DEBUG_LOG_HTTP == YES){
		DebugLog(@"----------------------------------------");
		DebugLog(@"response: %@", text);
		DebugLog(@"----------------------------------------");
	}
}

+ (void)rowsInSection:(int)rows section:(int)section{
	if( DEBUG_TABLEVIEW_CELLS == YES){
		DebugLog(@"rows: %d section: %d", rows, section);
	}
}

+ (void)heightForRow:(CGFloat)_height indexPath:(int)row{
	if( DEBUG_TABLEVIEW_CELLS == YES){
		DebugLog(@"height: %f row: %d", _height, row);
	}
}
@end