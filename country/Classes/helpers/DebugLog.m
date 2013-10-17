/*
 *  DebugLog.m
 *  DebugLog
 *
 *  Created by Karl Kraft on 3/22/09.
 *  Copyright 2009 Karl Kraft. All rights reserved.
 *
 */

#include "DebugLog.h"

void _DebugLog(const char *file, int lineNumber, const char *funcName, NSString *format,...) {
  va_list ap;
	
  va_start (ap, format);
  if (![format hasSuffix: @"\n"]) {
    format = [format stringByAppendingString: @"\n"];
	}
	NSString *body =  [[NSString alloc] initWithFormat: format arguments: ap];
	va_end (ap);
	const char *threadName = [[[NSThread currentThread] name] UTF8String];
  NSString *fileName=[[NSString stringWithUTF8String:file] lastPathComponent];
	if (threadName) {
		fprintf(stderr,"[thread:%s] %s:%d> %s %s",threadName,[fileName UTF8String],lineNumber,funcName,[body UTF8String]);
	} else {
		fprintf(stderr,"%s:%d> %s %s",[fileName UTF8String],lineNumber,funcName,[body UTF8String]);
	}
	[body release];	
}

