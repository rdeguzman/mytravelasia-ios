#import <UIKit/UIKit.h>
#import "SearchItemsModel.h"
#import "WebViewController.h"

@interface MainScrollViewController : UIViewController<UIWebViewDelegate>
{
	IBOutlet UIScrollView *scrollview;
	IBOutlet UIActivityIndicatorView *spinner;
  IBOutlet UIButton *buttonTopLink;
	
	NSMutableArray* arrayCategories;
  NSMutableArray* arrayButtons;
  NSMutableArray* arrayAds;
	
	SearchItemsModel *modelSearch;
	
	CGFloat currentOriginY;
	CGFloat bottomPadding;
  CGFloat webviewHeight;
	
	IBOutlet UIView* coverView;
	
	WebViewController* webController;
  NSString *frontPageURL;
}

@property(nonatomic, retain) IBOutlet UIScrollView* scrollview;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic, retain) IBOutlet UIButton *buttonTopLink;

@property(nonatomic, readonly) NSMutableArray* arrayCategories;
@property(nonatomic, readonly) NSMutableArray* arrayButtons;
@property(nonatomic, readonly) NSMutableArray* arrayAds;

@property(nonatomic, readonly) IBOutlet UIView* coverView;

- (IBAction)buttonNearbyPressed:(id)sender;
- (IBAction)buttonTopLinkPressed:(id)sender;

@end
