#import <Foundation/Foundation.h>

@interface BookingEnquiryModel : NSObject

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *contactNumber;
@property (nonatomic, copy) NSString *email;

@property (nonatomic, retain) NSDate *dateArrival;
@property (nonatomic, retain) NSDate *dateDeparture;

@property int rooms;
@property int adults;
@property int children;

@property (nonatomic, copy) NSString *comment;

- (NSString*)dateArrivalAsFullString;
- (NSString*)dateDepartureAsFullString;
- (NSString*)dateArrivalAsShortString;
- (NSString*)dateDepartureAsShortString;

- (BOOL)isValid;
- (void)save;

@end
