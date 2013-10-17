#import <UIKit/UIKit.h>
#import "PoiAnnotation.h"
#import "SearchItemsModel.h"
#import <MessageUI/MessageUI.h>
#import "User.h"

@protocol ModalViewControllerDelegate;

@interface DetailsViewController : UITableViewController <MFMailComposeViewControllerDelegate>
{
	id<ModalViewControllerDelegate> delegate;
	
	PoiAnnotation* poiModel;

	NSArray *pictures;
	
	NSMutableArray* arrayCells;
	NSMutableArray* arrayCellIdentifiers;
	
	SearchItemsModel* modelSearch;
  User *user;
  BOOL fitEntireScreen;
}

- (id)initWithStyle:(UITableViewStyle)style withPoiModel:(PoiAnnotation *)_poiAnnotation;
- (id)initWithStyle:(UITableViewStyle)style withPrimaryKey:(int)_pk;

- (void)setSearchModel:(SearchItemsModel*)_model;
- (void)dismissModalViewController;

@property(assign) id<ModalViewControllerDelegate> delegate;

@end

@protocol ModalViewControllerDelegate <NSObject>

@optional
- (void)dismissModalViewController;
- (void)dismissAndPushViewController:(UIViewController*)vc;
- (void)reload;
@end