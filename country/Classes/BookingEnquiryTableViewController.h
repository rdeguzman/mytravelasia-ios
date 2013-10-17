#import <UIKit/UIKit.h>
#import "DetailsViewController.h"
#import "BookingEnquiryModel.h"
#import "KalViewController.h"

@interface BookingEnquiryTableViewController : UITableViewController<UITextFieldDelegate, KalViewControllerExternalDelegate>

@property NSInteger primaryKey;

@property(nonatomic, retain) UIAlertView *progressAlert;

@property(nonatomic, assign) DetailsViewController *delegate;

@property(nonatomic, retain) BookingEnquiryModel* bookingModel;

@property(nonatomic, retain) NSMutableArray* arraySections;

@property(nonatomic, retain) NSMutableArray* arrayContactCells;
@property(nonatomic, retain) NSMutableArray* arrayDateCells;
@property(nonatomic, retain) NSMutableArray* arrayBookingCells;

- (void)didFinishTextViewWithComment:(NSString*)text;

@end
