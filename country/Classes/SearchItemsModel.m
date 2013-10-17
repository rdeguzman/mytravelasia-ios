#import "DebugLog.h"

#import "SearchItemsModel.h"
#import "DataAccess.h"
#import "HelperFileUtils.h"
#import "ApplicationConstants.h"

@implementation SearchItemsModel

- (id)init{
	self = [super init];
	if(self){
		DataAccess *da = [[DataAccess alloc] initWithPath:[HelperFileUtils directoryInDocuments:DB_NAME]];
		
		arrayLocations = [[NSMutableArray alloc] initWithObjects:@"Current GPS Location", nil];
		
		arrayRecentSearches = [[NSMutableArray alloc] initWithArray:[da getRecentSearches]];
		arrayFavorites = [[NSMutableArray alloc] initWithArray:[da getFavorites]];
		[da release];

		arrayTopDestinations = [[NSMutableArray alloc] initWithObjects:nil];
		arrayDestinations = [[NSMutableArray alloc] initWithObjects:nil];
		
		NSArray* arrayObjects = [[NSArray alloc] initWithObjects:
								 arrayLocations,
								 arrayRecentSearches,
								 arrayFavorites,
								 arrayTopDestinations,
								 arrayDestinations, 
								 nil];
		NSArray* arrayValues = [[NSArray alloc] initWithObjects:@"1-Nearby", @"2-Recent Searches", @"3-Favorites", @"4-Top Destinations", @"5-Destinations", nil];
		
		searchItems = [[NSDictionary alloc] initWithObjects:arrayObjects forKeys:arrayValues];
		arraySections = [[NSArray alloc] initWithArray:[[searchItems allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
		
		[arrayObjects release];
		[arrayValues release];
	}
	return self;
}

- (void)setTopDestinations:(NSArray*)_arrayTopDestinations{
	[arrayTopDestinations release];
	arrayTopDestinations = [[NSMutableArray alloc] initWithArray:_arrayTopDestinations];
	DebugLog(@"arrayTopDestinations count:%d", [arrayTopDestinations count]);
}

- (void)setDestinations:(NSArray*)_arrayDestinations{
	[arrayDestinations release];
	arrayDestinations = [[NSMutableArray alloc] initWithArray:_arrayDestinations];
	DebugLog(@"arrayDestinations count:%d", [arrayDestinations count]);
}

- (NSArray*)arraySections{
	return arraySections;
}

- (NSArray*)arrayObjectForKey:(NSString*)_key{
	if([_key isEqualToString:@"1-Nearby"]){
		return arrayLocations;
	}
	else if([_key isEqualToString:@"2-Recent Searches"]){
		return arrayRecentSearches;
	}
	else if([_key isEqualToString:@"3-Favorites"]){
		return arrayFavorites;
	}
	else if([_key isEqualToString:@"4-Top Destinations"]){
		return arrayTopDestinations;
	}
	else if([_key isEqualToString:@"5-Destinations"]){
		return arrayDestinations;
	}
	else{
		return nil;
	}
}

- (void)addVirtualLocation{
	NSString* item = @"Virtual Location";
	if( [arrayLocations containsObject:item] == NO && [item length] > 0 && [arrayLocations containsObject:item] == NO){
		[arrayLocations addObject:item];
		DebugLog(@"Added %@", item);
	}
	else{
		DebugLog(@"%@ already exists", item);
	}
}

- (void)addToRecentSearch:(NSString*)keyword{
	DebugLog(@"keyword: %@", keyword);
	
	NSString* item = [[NSString alloc] initWithString:keyword];
	
	if( [arrayRecentSearches containsObject:item] == NO && [item length] > 0 && [arrayFavorites containsObject:item] == NO){
		[arrayRecentSearches addObject:item];
		
		DataAccess *da = [[DataAccess alloc] initWithPath:[HelperFileUtils directoryInDocuments:DB_NAME]];
		[da insertRecentSearch:item];
		[da release];
	}
	
	[item release];
}

- (void)addToFavorites:(NSString*)text withId:(NSString*)_poi_id{
	DebugLog(@"text:%@ poi_id:%@", text, _poi_id);
	
	NSString* item = [[NSString alloc] initWithString:text];
	
	if( [arrayFavorites containsObject:item] == NO && [item length] > 0){
		[arrayFavorites addObject:item];
		
		DataAccess *da = [[DataAccess alloc] initWithPath:[HelperFileUtils directoryInDocuments:DB_NAME]];
		[da insertFavoriteWithId:_poi_id withKeyword:item];
		[da release];
	}
	
	[item release];
}

- (void)dealloc {
	DebugLog(@"dealloc");
	[arrayLocations release];
	[arrayRecentSearches release];
	[arrayFavorites release];
	[arrayTopDestinations release];
	[arrayDestinations release];
	
	[arraySections release];
	[searchItems release];
	
	[super dealloc];
}

@end
