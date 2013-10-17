#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DataAccess : NSObject
{
	FMDatabase *db;
	FMResultSet *rs;
}

- (id)initWithPath:(NSString*)_path;

- (void)insertRecentSearch:(NSString *)_text;
- (void)insertFavoriteWithId:(NSString *)_poi_id withKeyword:(NSString*)_text;
- (NSMutableArray*)getFavorites;
- (NSMutableArray*)getRecentSearches;
- (NSDictionary*)getUser;
- (void)insertUser:(NSDictionary*)user;

@end
