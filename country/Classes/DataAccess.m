#import "DataAccess.h"
#import "HelperFileUtils.h"
#import "ApplicationConstants.h"

@interface DataAccess(private)
- (NSData*)getImageForPage:(NSString*)_page_id dataColumn:(NSString*)_column;
- (NSData*)getImageForPictureId:(NSString*)_picture_id dataColumn:(NSString*)_column;
- (NSString*)getBlankStringIfNull:(NSString*)_inputString;
@end


@implementation DataAccess

- (id)init{
	if((self = [super init]))
    {
		db = [[FMDatabase alloc] initWithPath:[HelperFileUtils directoryInDocuments:DB_NAME]];
		[db open];

	}
	
	return self;
}

- (id)initWithPath:(NSString*)_path{
	if((self = [super init]))
    {
		DLog(@"path: %@", _path);
		db = [[FMDatabase alloc] initWithPath:_path];
		[db open];
	}
	
	return self;
}

- (void)dealloc{
	[db close];
	[db release];

	[super dealloc];
}

- (void)insertRecentSearch:(NSString *)_text{
	DLog(@"DataAccess.insertFavorite");
	[db executeUpdate:@"INSERT INTO searches(keyword) values(?)", _text];
    
    if ([db hadError])
        DLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
}

- (void)insertFavoriteWithId:(NSString *)_poi_id withKeyword:(NSString*)_text{
	DLog(@"DataAccess.insertFavorite");
	[db executeUpdate:@"INSERT INTO favorites(poi_id, keyword) values(?, ?)", _poi_id, _text];

    if ([db hadError])
        DLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
}

- (NSMutableArray*)getRecentSearches{
	DLog(@"DataAccess.getRecentSearches");
	
	NSMutableArray *array = [[[NSMutableArray alloc] initWithObjects:nil] autorelease];
	
	rs = [db executeQuery:@"SELECT * FROM searches"];
	
	if ([db hadError]) {
        DLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
	
	while ([rs next]) {
		[array addObject:[rs stringForColumn:@"keyword"]];
	}
	
	DLog(@"DataAccess.getRecentSearches: %d found", [array count]);
	
	[rs close];
	
	return array;
}

- (NSMutableArray*)getFavorites{
	DLog(@"DataAccess.getFavorites");
	
	NSMutableArray *array = [[[NSMutableArray alloc] initWithObjects:nil] autorelease];
	
	rs = [db executeQuery:@"SELECT * FROM favorites"];
	
	if([db hadError])
    DLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
	
	while([rs next])
		[array addObject:[rs stringForColumn:@"keyword"]];
	
	DLog(@"DataAccess.getFavorites: %d found", [array count]);
	
	[rs close];
	
	return array;
}

- (NSDictionary*)getUser
{
  NSDictionary *user = nil;
  rs = [db executeQuery:@"SELECT * FROM user"];

  if([rs next])
  {
    NSString *first_name = [rs stringForColumn:@"first_name"];
    NSString *last_name = [rs stringForColumn:@"last_name"];
    NSString *email = [rs stringForColumn:@"email"];
    NSString *contact_no = [rs stringForColumn:@"contact_no"];

    NSArray *arrayObjects = [[NSArray alloc] initWithObjects:first_name, last_name, email, contact_no, nil];
    NSArray *arrayKeys = [[NSArray alloc] initWithObjects:@"first_name", @"last_name", @"email", @"contact_no", nil];

    user = [[[NSDictionary alloc] initWithObjects:arrayObjects forKeys:arrayKeys] autorelease];
    [arrayObjects release];
    [arrayKeys release];
  }

  return user;
}

- (void)insertUser:(NSDictionary*)user
{
	DLog(@"");
  [db executeUpdate:@"DELETE FROM user"];

	[db executeUpdate:@"INSERT INTO user(first_name, last_name, email, contact_no) values(?, ?, ?, ?)",
   [user objectForKey:@"first_name"],
   [user objectForKey:@"last_name"],
   [user objectForKey:@"email"],
   [user objectForKey:@"contact_no"]];

  if ([db hadError])
    DLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
}

@end
