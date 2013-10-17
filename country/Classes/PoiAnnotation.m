#import "PoiAnnotation.h"

@implementation PoiAnnotation

RM_SYNTHESIZE(bookable);
RM_SYNTHESIZE(liked);

@synthesize annotation_type;
@synthesize name, address, poitype, distance, total_stars, total_ratings, total_likes, total_comments, min_rate, partners, rooms, comments;
@synthesize picture_thumb_path, picture_full_path;
@synthesize content, time_in_age_posted, facebook_id;

- (void)dealloc
{
  [annotation_type release];
  
	[name release];
	[address release];
	[description release];

	[poitype release];
	[distance release];
	[total_stars release];
	[total_ratings release];
  [total_likes release];
  [total_comments release];
	[min_rate release];

	[picture_thumb_path release];
	[picture_full_path release];

  [partners release];
  [rooms release];
  [comments release];
  
  [content release];
  [time_in_age_posted release];
  [facebook_id release];

	[super dealloc];
}

- (id) initWithPrimaryKey:(int)pk withIndex:(int)_index
{
	if(self = [super init])
  {
		primaryKey = pk;
		index = _index;
	}
	return self;
}

- (NSInteger)primaryKey
{
    return primaryKey;
}

- (NSInteger)index
{
    return index;
}

- (NSString *)title
{
	return name;
}

- (NSString *)subtitle
{
	return address;
}

- (void) setLatitude:(NSString *)latitude setLongitude:(NSString *)longitude
{
	coordinate.latitude = [latitude doubleValue];
	coordinate.longitude = [longitude doubleValue];
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
	coordinate = newCoordinate;
}

- (CLLocationCoordinate2D)coordinate
{
	return coordinate;
}


- (void)setDescription:(NSString *)_text
{
	
	if( [_text isKindOfClass:[NSString class]] && [(NSString*)_text length] > 0)
		description = [_text copy];
	else
		description = [[[NSString alloc] initWithString:@"No Description Available"] autorelease];
}

- (NSString*)description
{
	return description;
}

- (void)setTelephone:(NSString *)_text
{
	if( [_text isKindOfClass:[NSString class]] && [(NSString*)_text length] > 0)
  	telephone = [_text copy];
	else
		telephone = [[[NSString alloc] initWithString:@"-"] autorelease];
}

- (NSString*)telephone
{
	return telephone;
}

- (void)setWebsite:(NSString *)_text
{
	if( [_text isKindOfClass:[NSString class]] && [(NSString*)_text length] > 0)
		website = [_text copy];
	else
		website = [[[NSString alloc] initWithString:@"-"] autorelease];
}

- (NSString*)website
{
	return website;
}

- (void)setEmail:(NSString *)_text{
	if( [_text isKindOfClass:[NSString class]] && [(NSString*)_text length] > 0)
		email = [_text copy];
	else
		email = [[[NSString alloc] initWithString:@"-"] autorelease];
}

- (NSString*)email
{
	return email;
}

- (BOOL)hasPartners
{
  if([partners isKindOfClass:[NSArray class]] && [partners count] > 0)
    return YES;
  else
    return NO;
}

- (BOOL)hasRooms
{
  if([rooms isKindOfClass:[NSArray class]] && [rooms count] > 0)
    return YES;
  else
    return NO;
}

- (BOOL)hasComments
{
  if([comments isKindOfClass:[NSArray class]] && [comments count] > 0)
    return YES;
  else
    return NO;
}

- (BOOL)hasMinRate
{
	if([min_rate isKindOfClass:[NSString class]] && [(NSString*)min_rate length] > 0 && [poitype isEqualToString:@"Hotel"])
  {
		DLog(@"poitype: %@ min_rate: %@", poitype, min_rate);
		return YES;
	}
	else
		return NO;
}

- (BOOL)hasDistance
{
	if([distance isKindOfClass:[NSString class]] && [(NSString*)distance length] > 0 && [distance intValue] > 0)
  {
		DLog(@"distance: %@", distance);
		return YES;
	}
	else
		return NO;
}

- (BOOL)hasValidCoordinates
{
	if(coordinate.latitude > -90.0f || coordinate.latitude < 90.0f || coordinate.longitude > -180.0f || coordinate.longitude < 180.0f)
		return YES;
	else
		return NO;
}
@end
