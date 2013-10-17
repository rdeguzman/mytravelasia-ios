#import "BookingEnquiryModel.h"
#import "NSString+Utilities.h"
#import "DataAccess.h"
#import "HelperFileUtils.h"
#import "ApplicationConstants.h"

@interface BookingEnquiryModel()
- (NSString*)dateString:(NSDate*)date;
- (NSString*)formatDate:(NSDate*)date formatString:(NSString*)formatString;
@end

@implementation BookingEnquiryModel

RM_SYNTHESIZE(firstName);
RM_SYNTHESIZE(lastName);
RM_SYNTHESIZE(contactNumber);
RM_SYNTHESIZE(email);

RM_SYNTHESIZE(rooms);
RM_SYNTHESIZE(adults);
RM_SYNTHESIZE(children);

RM_SYNTHESIZE(dateArrival);
RM_SYNTHESIZE(dateDeparture);

RM_SYNTHESIZE(comment);

- (void)dealloc
{
  RM_RELEASE(firstName);
  RM_RELEASE(lastName);
  RM_RELEASE(contactNumber);
  RM_RELEASE(email);

  RM_RELEASE(dateArrival)
  RM_RELEASE(dateDeparture)

  RM_RELEASE(comment);

  [super dealloc];
}

- (id) init
{
  if(self = [super init])
  {
    DataAccess *da = [[DataAccess alloc] initWithPath:[HelperFileUtils directoryInDocuments:DB_NAME]];

    NSDictionary *user = [da getUser];
    if(user != nil)
    {
      firstName_ = [[NSString alloc] initWithFormat:@"%@", [user objectForKey:@"first_name"]];
      lastName_ = [[NSString alloc] initWithFormat:@"%@", [user objectForKey:@"last_name"]];
      email_ = [[NSString alloc] initWithFormat:@"%@", [user objectForKey:@"email"]];
      contactNumber_ = [[NSString alloc] initWithFormat:@"%@", [user objectForKey:@"contact_no"]];
    }

    [da release];

    dateArrival_ = [[NSDate alloc] init];
    CGFloat timeIntervalInSecsPerDay = 86400;
    CGFloat days = 3;
    dateDeparture_ = [[NSDate alloc] initWithTimeIntervalSinceNow:timeIntervalInSecsPerDay * days];

    rooms_ = 1;
    adults_ = 2;
    children_ = 0;
  }
  return self;
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"BookingEnquiryModel:\n firstName:%@\n lastName:%@\n contactNumber:%@\n email:%@\n arrival:%@\n departure:%@\n arrival:%@\n departure:%@\n rooms:%d\n adults:%d\n children:%d\n comment:%@\n",
          self.firstName,
          self.lastName,
          self.contactNumber,
          self.email,
          self.dateArrivalAsFullString,
          self.dateDepartureAsFullString,
          self.dateArrivalAsShortString,
          self.dateDepartureAsShortString,
          self.rooms,
          self.adults,
          self.children,
          self.comment];
}

- (NSString*)dateArrivalAsFullString
{
  return [self dateString:self.dateArrival];
}

- (NSString*)dateDepartureAsFullString
{
  return [self dateString:self.dateDeparture];
}

- (NSString*)dateArrivalAsShortString
{
  return [self formatDate:self.dateArrival formatString:@"yyyy-MM-dd"];
}

- (NSString*)dateDepartureAsShortString
{
  return [self formatDate:self.dateDeparture formatString:@"yyyy-MM-dd"];
}

- (NSString*)dateString:(NSDate*)date
{
  NSDateFormatter *f = [[[NSDateFormatter alloc] init] autorelease];
   [f setDateStyle:kCFDateFormatterFullStyle];
  NSString *dateStr = [f stringFromDate:date];
  return dateStr;
}

- (NSString*)formatDate:(NSDate*)date formatString:(NSString*)formatString
{
  NSDateFormatter *f = [[[NSDateFormatter alloc] init] autorelease];
  [f setDateFormat:formatString];
  NSString *dateStr = [f stringFromDate:date];
  return dateStr;
}


- (BOOL)isValid
{
  return ([self.firstName isWithAnyText] && [self.lastName isWithAnyText] && [self.contactNumber isWithAnyText] && [self.email isWithAnyText]);
}

- (void)save
{
  DLog(@"");
  if([self isValid])
  {
    NSString *first_name = self.firstName;
    NSString *last_name = self.lastName;
    NSString *email = self.email;
    NSString *contact_no = self.contactNumber;

    NSArray *arrayObjects = [[NSArray alloc] initWithObjects:first_name, last_name, email, contact_no, nil];
    NSArray *arrayKeys = [[NSArray alloc] initWithObjects:@"first_name", @"last_name", @"email", @"contact_no", nil];

    NSDictionary *user = [[[NSDictionary alloc] initWithObjects:arrayObjects forKeys:arrayKeys] autorelease];
    [arrayObjects release];
    [arrayKeys release];

    DataAccess *da = [[DataAccess alloc] initWithPath:[HelperFileUtils directoryInDocuments:DB_NAME]];
    [da insertUser:user];
    [da release];
  }
}

@end
