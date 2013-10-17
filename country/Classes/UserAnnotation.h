#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface UserAnnotation : NSObject<MKAnnotation>{
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (CLLocationCoordinate2D)coordinate;
- (void)setSubtitle:(NSString *)_text;
- (BOOL)hasValidCoordinates;

@end