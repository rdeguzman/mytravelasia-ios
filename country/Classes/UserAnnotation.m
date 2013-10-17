#import "UserAnnotation.h"

@implementation UserAnnotation

@synthesize title, subtitle, coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord{
	if(self = [super init]){
		coordinate = coord;
	}
	return self;
}

- (CLLocationCoordinate2D)coordinate{
	return coordinate;
}

- (void)dealloc{
	[super dealloc];
}

- (void)setSubtitle:(NSString *)_text{
	subtitle = _text;
}

- (BOOL)hasValidCoordinates
{
	if(coordinate.latitude > -90.0f || coordinate.latitude < 90.0f || coordinate.longitude > -180.0f || coordinate.longitude < 180.0f)
		return YES;
	else
		return NO;
}

@end
