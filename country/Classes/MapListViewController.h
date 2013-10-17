#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "SearchViewController.h"
#import "RMGPSController.h"
#import "PoiAnnotation.h"
#import "UserAnnotation.h"

#import "SearchItemsModel.h"
#import "DetailsViewController.h"
#import "PaperFoldView.h"
#import "PopoverView.h"

#import "User.h"

@interface MapListViewController : UIViewController <RMGPSControllerDelegate, SearchViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UIPopoverControllerDelegate, ModalViewControllerDelegate, UIAlertViewDelegate, PaperFoldViewDelegate, PopoverViewDelegate>{
	BOOL boolMapFullScreen;
	
  MKMapView* mapview;
	UITableView* tableviewContent;
  UITableView* tableviewMenu;
	
  IBOutlet UISegmentedControl* segmentedControlSortBy;
	
  IBOutlet UIButton *buttonHome;
  IBOutlet UIButton *buttonMap;
  IBOutlet UIButton *buttonTableview;
  IBOutlet UIButton* buttonSearch;
  IBOutlet UILabel* labelSearch;
	
  NSMutableArray *arrayMenus;
	NSMutableArray* arrayPoiAnnotations;
	PoiAnnotation* currentAnnotation;	//Current Poi Selected
	UserAnnotation* userAnnotation;		//Current User Location whether actual or fixed
  User *user; // Singleton
	
	int lastPage;
	int lastKnownPage;
	int totalPages;
	int lastKnownTotalPages;
	BOOL boolPendingRequestForNearbySearchHTTPRequest;
  BOOL boolPendingRequestForRecentWithKeywordSearchHTTPRequest;
	IBOutlet UIActivityIndicatorView *spinner;
	NSMutableString* lastURLString;
	NSMutableString* lastKnownURLString;
  NSMutableString* poiType;

	//used for appending to Recent Searches
	NSMutableString* lastKeyword;
	
	//For Map Extent Calculations
	CLLocationCoordinate2D topLeftCoord;
	CLLocationCoordinate2D bottomRightCoord;
	
	//For deselecting a table row
	int lastKnownIndexSelected;
	
	//For Destinations
	SearchItemsModel* modelSearch;
	
	//For iPad Only
	UIPopoverController* popoverController;
	IBOutlet UIToolbar* toolbar;
	
	//Used to store the state of More Results when a popover is displayed
	BOOL stateBoolMoreResults;
	
	//Used for setting the GPS manually, we display an alertView;
	UIAlertView* gpsNotificationAlertView;
	BOOL boolGPSTimeoutActive;
	BOOL boolGPSAlertShown;
  BOOL boolShowCurrentLocation;
	
  NSDictionary *mapPlist_;

  CGRect paperFoldFrame;
  CGRect mapviewFrame;
  CGRect tableviewContentFrame;
}

@property(nonatomic, retain) MKMapView* mapview;
@property(nonatomic, retain) UITableView* tableviewContent;
@property(nonatomic, retain) UITableView* tableviewMenu;

@property(nonatomic, retain) IBOutlet UISegmentedControl* segmentedControlSortBy;

@property(nonatomic, retain) IBOutlet UIActivityIndicatorView* spinner;

@property(nonatomic, retain) IBOutlet UIToolbar* toolbar;

@property(nonatomic, retain) IBOutlet UIButton* buttonHome;
@property(nonatomic, retain) IBOutlet UIButton *buttonMap;
@property(nonatomic, retain) IBOutlet UIButton *buttonTableview;
@property(nonatomic, retain) IBOutlet UIButton* buttonSearch;

@property(nonatomic, retain) IBOutlet UILabel* labelSearch;

@property (nonatomic, strong) PaperFoldView *paperFoldView;

- (IBAction)buttonSlideMenuPressed:(id)sender;
- (IBAction)buttonSearchPressed:(id)sender;
- (IBAction)buttonSlideMapviewPressed;
- (IBAction)buttonSlideTableviewPressed;

//Called by MapScrollView. Triggers startGPS, boolPendingRequestForNearbySearchHTTPRequest = YES;
- (void)nearby;

- (void)setSearchModel:(SearchItemsModel*)_model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withMenus:(NSArray *)menus;

- (void)reload;

@end
