#import "HelperDevice.h"

@implementation HelperDevice

@end

@implementation HelperDevice (Device)

+(BOOL)isDeviceAniPad{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		return YES;
	}
	else{
		return NO;
	}
}

+(BOOL)isDeviceAniPhone{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		return YES;
	}
	else{
		return NO;
	}
}

+ (NSString *)nibNameForDevice:(NSString*)_nibName{
	NSString* _newNibName = nil;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		_newNibName = [NSString stringWithFormat:@"%@_iPad", _nibName];
		DLog(@"iPad: %@", _newNibName);
	}
	else{
		_newNibName = [NSString stringWithFormat:@"%@_iPhone", _nibName];
		DLog(@"iPhone: %@", _newNibName);
	}
	
	return _newNibName;
}

+ (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if( [HelperDevice isDeviceAniPad] && (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)){
		return YES;
	}
	else if([HelperDevice isDeviceAniPad] == NO && (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
		return YES;
	}
	else{
		return NO;
	}
}

@end