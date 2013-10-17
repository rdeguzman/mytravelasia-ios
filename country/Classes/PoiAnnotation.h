#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface PoiAnnotation : NSObject<MKAnnotation>
{
	CLLocationCoordinate2D coordinate;
	int primaryKey;
	
	//index of poi record stored in arrayPoi
	int index; 
	
	NSString *name;
	NSString *address;
	NSString *poitype;
	NSString *distance;
	NSString *total_stars;
	NSString *total_ratings;
  NSString *total_likes;
  NSString *total_comments;
	NSString *min_rate;
	
	NSString *picture_thumb_path;
	NSString *picture_full_path;
	
	NSString *description;
	NSString *telephone;
	NSString *website;
	NSString *email;
  
  NSString *annotation_type;
  NSString *content;
  NSString *time_in_age_posted;
  NSString *facebook_id;
	
  BOOL bookable_;
  BOOL liked_;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *poitype;
@property (nonatomic, copy) NSString *distance;
@property (nonatomic, copy) NSString *total_stars;
@property (nonatomic, copy) NSString *total_ratings;
@property (nonatomic, copy) NSString *total_likes;
@property (nonatomic, copy) NSString *total_comments;
@property (nonatomic, copy) NSString *min_rate;

@property (nonatomic, copy) NSString *annotation_type;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *time_in_age_posted;
@property (nonatomic, copy) NSString *facebook_id;

@property(nonatomic, assign, getter=isBookable) BOOL bookable;
@property(nonatomic, assign, getter=isLiked) BOOL liked;

//We do not set a property for description because we need to set it as "No Description Available" if there isn't any
//@property (nonatomic, copy) NSString *description;

@property (nonatomic, copy) NSString *picture_thumb_path;
@property (nonatomic, copy) NSString *picture_full_path;

@property (nonatomic, copy) NSArray *partners;
@property (nonatomic, copy) NSArray *rooms;

@property (nonatomic, copy) NSArray *comments;

- (id) initWithPrimaryKey:(int)pk withIndex:(int)_index;

- (void) setLatitude:(NSString *)latitude setLongitude:(NSString *)longitude;

- (CLLocationCoordinate2D)coordinate;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

- (NSInteger)index;
- (NSInteger)primaryKey;

- (void)setDescription:(NSString *)_text;
- (NSString*)description;

- (void)setTelephone:(NSString *)_text;
- (NSString*)telephone;

- (void)setWebsite:(NSString *)_text;
- (NSString*)website;

- (void)setEmail:(NSString *)_text;
- (NSString*)email;

- (BOOL)hasMinRate;
- (BOOL)hasDistance;
- (BOOL)hasValidCoordinates;
- (BOOL)hasPartners;
- (BOOL)hasRooms;
- (BOOL)hasComments;

@end