#import <Foundation/Foundation.h>


@interface SearchItemsModel : NSObject {
	NSDictionary* searchItems;
	NSArray* arraySections;
	
	NSMutableArray* arrayLocations;
	NSMutableArray* arrayRecentSearches;
	NSMutableArray* arrayFavorites;
	NSMutableArray* arrayTopDestinations;
	NSMutableArray* arrayDestinations;
}

- (void)setTopDestinations:(NSArray*)_arrayTopDestinations;
- (void)setDestinations:(NSArray*)_arrayDestinations;
- (NSArray*)arraySections;
- (NSArray*)arrayObjectForKey:(NSString*)_key;

- (void)addVirtualLocation;

- (void)addToRecentSearch:(NSString*)keyword;

- (void)addToFavorites:(NSString*)text withId:(NSString*)_poi_id;

@end
