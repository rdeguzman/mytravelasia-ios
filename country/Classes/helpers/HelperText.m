//
//  HelperText.m
//  Country
//
//  Created by rupert on 6/04/11.
//  Copyright 2011 2RMobile. All rights reserved.
//

#import "HelperText.h"

BOOL IsStringWithAnyText(id object) {
	return [object isKindOfClass:[NSString class]] && [(NSString*)object length] > 0;
}