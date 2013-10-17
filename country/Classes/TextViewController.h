#import <UIKit/UIKit.h>
#import "BookingEnquiryTableViewController.h"

@interface TextViewController : UIViewController

@property(nonatomic, retain) UITextView *textview;
@property(nonatomic, assign) BookingEnquiryTableViewController *delegate;

@end
