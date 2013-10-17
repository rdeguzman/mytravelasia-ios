#import "JSONKit.h"
#import	"ASIHTTPRequest.h"

#import "Country.h"
#import "CountryAppDelegate.h"
#import "ApplicationConstants.h"
#import "MainTableViewConstants.h"

#import "HelperFileUtils.h"
#import "HelperText.h"
#import "HelperDevice.h"
#import "HelperLogUtils.h"

#import "MapListViewController.h"
#import "ApplicationCell.h"
#import "PoiImageTableViewApplicationCell.h"
#import "FeedImageTableViewApplicationCell.h"

#import "SearchViewController.h"
#import "DetailsViewController.h"

#import "NSString+Utilities.h"
#import "UBAlertView.h"
#import "HelperAlert.h"

#import "RMCoreLocation.h"

#import "SVProgressHUD.h"
#import "UIScrollView+AH3DPullRefresh.h"

#import "User.h"

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

#define HEADER_HEIGHT 50.0f
#define TABLEVIEWMENU_WIDTH 150.0f
#define MAPBUTTON_HEIGHT 35.0f
#define MAPBUTTON_WIDTH 30.0f
#define THUMBNAIL_WIDTH 70.0f
#define MAP_PADDING 1.1
#define MINIMUM_VISIBLE_LATITUDE 0.01

@interface MapListViewController(private)
- (void)initMapRegion;
- (void)initMBR;
- (void)dismissPopoverViewController;
- (void)createGPSNotification;
- (void)hideGPSAlert;
- (void)startGPS;
- (void)stopGPS;
- (void)timeOutGPS;
- (void)showGPSAlert:(NSString*)alertTitle message:(NSString*)_message;
- (BOOL)checkLocationIfWithinBounds:(CLLocationCoordinate2D)_coordinate;
- (void)addUserAnnotation:(CLLocationCoordinate2D)_coordinate;
- (void)initiateNearbySearchHTTPRequest;
- (void)initiateKeywordSearchHTTPRequest:(NSString*)_keyword;
- (void)initiateRecentSearchHTTPRequest:(NSString*)_poiType;
- (void)initiateFeaturedSearchHTTPRequest:(NSString*)_poiType;
- (void)initiateMostViewedSearchHTTPRequest:(NSString*)_poiType;
- (void)startHTTPRequest:(NSString *)urlDirty;
- (void)createDataModel:(NSMutableArray*)_poiArray;
- (void)appendDataModel:(NSMutableArray*)_poiArray;
- (void)addAnnotations:(NSMutableArray*)_poiArray;
- (void)addPoiAnnotations:(NSMutableArray*)_poiArray startIndex:(int)_lastCount;
- (void)zoomToFitPoiAnnotations;
- (void)startAnimating;
- (void)startAnimating:(NSString*)_message;
- (void)stopAnimating;
- (void)showDetailsViewController:(PoiAnnotation*)_annotation;
- (void)showDetailsViewController:(PoiAnnotation*)_annotation withCellFrame:(CGRect)frame;
@end

@implementation MapListViewController

@synthesize mapview, tableviewContent, tableviewMenu, segmentedControlSortBy;
@synthesize spinner, toolbar;
@synthesize buttonHome, buttonMap, buttonTableview, buttonSearch, labelSearch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withMenus:(NSArray *)menus{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

  if (self) {
    arrayMenus = [[NSMutableArray alloc] initWithObjects:@"Home", @"Login", @"Near Me", @"News Feed", @"Featured", @"Most Viewed", @"Recent", nil];
    [arrayMenus addObjectsFromArray:menus];
    boolMapFullScreen = NO;
    
    user = [User sharedInstance];

    [RMGPSController sharedInstance].delegate = self;
    [RMGPSController sharedInstance].locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [RMGPSController sharedInstance].locationManager.distanceFilter = 100;

    userAnnotation = nil;

    arrayPoiAnnotations = [[NSMutableArray alloc] initWithObjects:nil];

    [self initVariables];
    
    poiType = [[NSMutableString alloc] init];

    lastURLString = [[NSMutableString alloc] init];
    lastKnownURLString = [[NSMutableString alloc] init];

    lastKeyword = [[NSMutableString alloc] init];

    lastKnownIndexSelected = 0;

    popoverController = nil;
    gpsNotificationAlertView = nil;

    boolGPSTimeoutActive = NO;
    boolGPSAlertShown = NO;
    boolShowCurrentLocation = NO;

    mapPlist_ = nil;
    
    [self initMBR];
  }

  return self;
}

- (void)initVariables {
  lastPage = 1;
  lastKnownPage = 1;
  totalPages = 0;
  lastKnownTotalPages = 0;
  
  boolPendingRequestForNearbySearchHTTPRequest = NO;
  boolPendingRequestForRecentWithKeywordSearchHTTPRequest = NO;
}

- (void)initMapPList {
  if(mapPlist_ == nil)
    mapPlist_ = [[NSDictionary alloc] initWithContentsOfFile:[HelperFileUtils fileInBundle:@"Map.plist"]];
}

- (void)printFrames {
  DLog(@"screenBounds: %f, %f", [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height);
  DLog(@"paperFoldView: %f %f", self.paperFoldView.frame.size.width, self.paperFoldView.frame.size.height);
  DLog(@"paperFoldFrame: %f %f", paperFoldFrame.size.width, paperFoldFrame.size.height);
  DLog(@"mapview: %f %f", mapview.frame.size.width, mapview.frame.size.height);
  DLog(@"mapviewFrame: %f %f", mapviewFrame.size.width, mapviewFrame.size.height);
  DLog(@"tableviewContentFrame: %f %f", tableviewContentFrame.size.width, tableviewContentFrame.size.height);
  DLog(@"tableviewMenu: %f %f", tableviewMenu.frame.size.width, tableviewMenu.frame.size.height);
}

- (void)initFrames {
  CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
  
  if([HelperDevice isDeviceAniPad]){
    paperFoldFrame = CGRectMake(0.0f, HEADER_HEIGHT, 320.0f, applicationFrame.size.width - HEADER_HEIGHT);
    mapviewFrame = CGRectMake(320.0f, 0.0f, applicationFrame.size.height - 320.0f, applicationFrame.size.width);
    tableviewContentFrame = CGRectMake(0.0f, 0.0f, 320.0f, paperFoldFrame.size.height);
  }
  else{
    paperFoldFrame = CGRectMake(0.0f, HEADER_HEIGHT, applicationFrame.size.width, applicationFrame.size.height - HEADER_HEIGHT);
    mapviewFrame = CGRectMake(0.0f, 0.0f, paperFoldFrame.size.width - THUMBNAIL_WIDTH, paperFoldFrame.size.height);
    tableviewContentFrame = CGRectMake(0.0f, 0.0f, paperFoldFrame.size.width, paperFoldFrame.size.height);
  }

  self.tableviewContent = [[UITableView alloc] initWithFrame:tableviewContentFrame];
  [tableviewContent setDelegate:self];
  [tableviewContent setDataSource:self];

  self.mapview = [[MKMapView alloc] initWithFrame:mapviewFrame];
  self.mapview.showsUserLocation = YES;
  [mapview setDelegate:self];

  CGFloat tableviewMenuHeight = 0;
  
  if([HelperDevice isDeviceAniPhone]){
    /* height of tableviewMenu is hardcoded to 410 to satisfy iphone, iphone4 and iphone5 heights. */
    tableviewMenuHeight = 410.0f;
  }
  else if([HelperDevice isDeviceAniPad]){
    tableviewMenuHeight = applicationFrame.size.width - HEADER_HEIGHT;
  }
  
  CGRect tableviewMenuFrameInPFV = CGRectMake(0.0f, 0.0f, TABLEVIEWMENU_WIDTH, tableviewMenuHeight);
  
  self.tableviewMenu = [[UITableView alloc] initWithFrame:tableviewMenuFrameInPFV];
  self.tableviewMenu.backgroundColor = MENU_CELL_BACKGROUND;
  [tableviewMenu setDelegate:self];
  [tableviewMenu setDataSource:self];
  
//  [self printFrames];
}

- (void)initMapButtons {
  int i = 0;
  CGFloat originX = mapviewFrame.size.width - MAPBUTTON_HEIGHT;
  
  if([HelperDevice isDeviceAniPhone]){
    UIButton *buttonMapFullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonMapFullScreen.frame = CGRectMake(originX, i++, MAPBUTTON_HEIGHT, MAPBUTTON_WIDTH);
    [buttonMapFullScreen setImage:[UIImage imageNamed:@"button_map_fullscreen.png"] forState:UIControlStateNormal];
    [buttonMapFullScreen addTarget:self action:@selector(toggleMapFullScreen) forControlEvents:UIControlEventTouchDown];
    [self.mapview addSubview:buttonMapFullScreen];
  }

  UIButton *buttonMapGPS = [UIButton buttonWithType:UIButtonTypeCustom];
  buttonMapGPS.frame = CGRectMake(originX, MAPBUTTON_HEIGHT * i++, MAPBUTTON_HEIGHT, MAPBUTTON_WIDTH);
  [buttonMapGPS setImage:[UIImage imageNamed:@"button_map_gps.png"] forState:UIControlStateNormal];
  [buttonMapGPS addTarget:self action:@selector(showCurrentLocation) forControlEvents:UIControlEventTouchDown];
  [self.mapview addSubview:buttonMapGPS];

  UIButton *buttonMapLayers = [UIButton buttonWithType:UIButtonTypeCustom];
  buttonMapLayers.frame = CGRectMake(originX, MAPBUTTON_HEIGHT * i++, MAPBUTTON_HEIGHT, MAPBUTTON_WIDTH);
  [buttonMapLayers setImage:[UIImage imageNamed:@"button_map_layers.png"] forState:UIControlStateNormal];
  [buttonMapLayers addTarget:self action:@selector(popoverMapLayers) forControlEvents:UIControlEventTouchDown];
  [self.mapview addSubview:buttonMapLayers];
  
  UIButton *buttonMapDropGPS = [UIButton buttonWithType:UIButtonTypeCustom];
  buttonMapDropGPS.frame = CGRectMake(originX, MAPBUTTON_HEIGHT * i++, MAPBUTTON_HEIGHT, MAPBUTTON_WIDTH);
  [buttonMapDropGPS setImage:[UIImage imageNamed:@"button_map_dropgps.png"] forState:UIControlStateNormal];
  [buttonMapDropGPS addTarget:self action:@selector(showVirtualLocation) forControlEvents:UIControlEventTouchDown];
  [self.mapview addSubview:buttonMapDropGPS];
}

- (void)initPaperFold {
  self.paperFoldView = [[PaperFoldView alloc] initWithFrame:paperFoldFrame];
  self.paperFoldView.contentView.backgroundColor = MENU_CELL_BACKGROUND;
  [self.view addSubview:self.paperFoldView];
  
  [self.paperFoldView setLeftFoldContentView:tableviewMenu];
  [self.paperFoldView setCenterContentView:tableviewContent];
  
  if([HelperDevice isDeviceAniPhone])
    [self.paperFoldView setRightFoldContentView:mapview rightViewFoldCount:3 rightViewPullFactor:0.9];

  if([HelperDevice isDeviceAniPad])
    [self.view addSubview:mapview];
  
  [self.paperFoldView setDelegate:self];
//  [self printFrames];
}

- (void)viewDidLoad {
  DLog(@"begin");
  DLog(@"device_token: %@", user.device_token);
  [super viewDidLoad];
  [self checkSession];
  
  self.view.backgroundColor = MENU_CELL_BACKGROUND;

  [self initFrames];
  [self initMapButtons];
  [self initPaperFold];
 
  if (![[RMGPSController sharedInstance] isLocationServicesEnabled])
    DLog(@"NoLocationServices User disabled location services");

  //Get the settings from the Map.plist
  [self initMapPList];

  //Create a GPS Alert but don't show it yet
  [self createGPSNotification];

  [self initMapRegion];

  //this will set the default view to a map. Used only in the iPhone
  buttonTableview.hidden = YES;
  buttonMap.hidden = NO;

  //in case we came from a memory warning and it loads again
  if([arrayPoiAnnotations count] > 0) {
    DLog(@"arrayPoiAnnotations count:%d", [arrayPoiAnnotations count]);
    [mapview addAnnotations:arrayPoiAnnotations];
    [self zoomToFitPoiAnnotations];
  }

  [tableviewContent setPullToLoadMoreHandler:^{
    [self loadMoreResults];
  }];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  [gpsNotificationAlertView release], gpsNotificationAlertView = nil;
  [mapPlist_ release], mapPlist_ = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	DLog(@"begin");
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[super viewWillAppear:animated];
}

- (void)dealloc {
	DLog(@"dealloc");
	
	[lastURLString release];
	[lastKnownURLString release];
  [poiType release];
	
	[lastKeyword release];
	
	[mapview release];
	[tableviewContent release];
  [tableviewMenu release];
  [arrayMenus release];
	
	[userAnnotation release];
	[arrayPoiAnnotations release];
	
  [segmentedControlSortBy release];

	[buttonHome release];
  [buttonMap release];
  [buttonTableview release];
	[buttonSearch release];
  [labelSearch release];
	
	[toolbar release];
	[gpsNotificationAlertView release];
	
	if(popoverController != nil)
		[popoverController release];
  
  [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return [HelperDevice shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)didReceiveMemoryWarning {
  DLog(@"begin");
  [super didReceiveMemoryWarning];
}

#pragma mark public methods
- (void)setSearchModel:(SearchItemsModel*)_model {
	modelSearch = _model;
}

- (void)nearby {
	boolPendingRequestForNearbySearchHTTPRequest = YES;
  labelSearch.text = @"Near Me";
	[self startGPS];
}

#pragma mark private methods
- (void)createGPSNotification {
	DLog(@"begin");

	if(gpsNotificationAlertView == nil) {
		gpsNotificationAlertView = [[UIAlertView alloc] initWithTitle:@"GPS Notification" message:MESSAGE_GPS_NOTIFICATION delegate:self cancelButtonTitle:@"I will wait" otherButtonTitles:@"CANCEL", nil];

		UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityView.frame = CGRectMake(139.0f-18.0f, 65.0f, 37.0f, 37.0f);
		[activityView startAnimating];
		[gpsNotificationAlertView addSubview:activityView];
		[activityView release];
	}
}

- (void)hideGPSAlert {
	DLog(@"begin");

  if(gpsNotificationAlertView != nil)
    [gpsNotificationAlertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)dismissAnyViewControllerPresent {
  [self dismissModalViewController];
  [self dismissPopoverViewController];
}

- (void)dismissModalViewController {
	if(self.modalViewController != nil)
		[self dismissModalViewControllerAnimated:YES];
}

- (void)dismissPopoverViewController {
	if(popoverController != nil) {
		[popoverController dismissPopoverAnimated:YES];
		[popoverController release], popoverController = nil;
	}
}

- (void)startAnimating {
	[self startAnimating:@"Please wait..."];
}

- (void)startAnimating:(NSString*)_message {
  [spinner startAnimating];
  [SVProgressHUD showWithStatus:_message];
}

- (void)stopAnimating {
  [spinner stopAnimating];
  [SVProgressHUD dismiss];
}

#pragma mark button (IBActions) and public methods
- (IBAction)buttonSearchPressed:(id)sender {
	if([HelperDevice isDeviceAniPad]){
		SearchViewController *searchView = [[SearchViewController alloc] initWithNibName:@"SearchViewController_iPhone" bundle:nil withSearchModel:modelSearch];

		if(popoverController != nil) {
			if([popoverController isPopoverVisible])
				[popoverController dismissPopoverAnimated:YES];	

			[popoverController release], popoverController = nil;
		}
		
		popoverController = [[UIPopoverController alloc] initWithContentViewController:searchView];
		searchView.delegate = self;
		popoverController.delegate = self;
		
    [popoverController presentPopoverFromRect:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
		[searchView release];
	}
	else {
		SearchViewController *searchView = [[SearchViewController alloc] initWithNibName:@"SearchViewController_iPhone" bundle:nil withSearchModel:modelSearch];
		searchView.delegate = self;
		[self.navigationController presentModalViewController:searchView animated:YES];
		[searchView release];
	}
}

- (void)loadMoreResults {
  lastKnownPage = lastKnownPage + 1;
	lastPage = lastKnownPage;
	
	[lastURLString setString:lastKnownURLString];
	[lastKnownURLString appendFormat:@"&page=%d", lastKnownPage];
	
	DLog(@"lastKnownURLString: %@", lastKnownURLString);
	[self startHTTPRequest:lastKnownURLString];
	[self startAnimating:@"Showing more results..."];
}

- (void)toggleMapFullScreen {
	DLog(@"begin");
  if(boolMapFullScreen){
    boolMapFullScreen = NO;
    [UIView beginAnimations:@"toggleMinimize" context:NULL];
    [UIView setAnimationDuration:0.3];
    self.paperFoldView.frame = paperFoldFrame;
    self.mapview.frame = mapviewFrame;
    self.tableviewContent.frame = CGRectMake(self.paperFoldView.frame.size.width - THUMBNAIL_WIDTH, 0.0f, THUMBNAIL_WIDTH, tableviewContentFrame.size.height);
    [UIView commitAnimations];
  }
  else {
    boolMapFullScreen = YES;
    [UIView beginAnimations:@"toggleMinimize" context:NULL];
    [UIView setAnimationDuration:0.3];
    self.paperFoldView.frame = [[UIScreen mainScreen] bounds];
    self.mapview.frame = CGRectMake(0.0f, 0.0f, self.paperFoldView.frame.size.width - THUMBNAIL_WIDTH, self.paperFoldView.frame.size.height);
    self.tableviewContent.frame = CGRectMake(self.paperFoldView.frame.size.width - THUMBNAIL_WIDTH, 0.0f, THUMBNAIL_WIDTH, self.paperFoldView.frame.size.height);
    [UIView commitAnimations];
  }
  [self printFrames];
}

- (void)popoverMapLayers {
  NSArray *a = [NSArray arrayWithObjects:@"Standard", @"Satellite", @"Hybrid", nil];
  CGFloat x = mapviewFrame.size.width - (MAPBUTTON_WIDTH/2.0f);
  CGFloat y = [HelperDevice isDeviceAniPad] ? MAPBUTTON_HEIGHT * 1.5f : MAPBUTTON_HEIGHT * 2.5f;
  [PopoverView showPopoverAtPoint:CGPointMake(x, y) inView:self.mapview withTitle:@"Map Layers" withStringArray:a delegate:self];
}

#pragma mark popoverController delegate Methods
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
	DLog(@"begin");
	return YES;
}

/* Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
 */
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	DLog(@"begin");
}

#pragma mark MapSettingsViewController delegate methods
- (void)changeMapType:(int)_index {
	DLog(@"index: %d", _index);
	[self dismissModalViewController];
	mapview.mapType = _index;
}

- (void)showCurrentLocation{
	DLog(@"begin");
  boolShowCurrentLocation = YES;
	[self startGPS];
}

- (void)showVirtualLocation {
	DLog(@"begin");
	
	CLLocationCoordinate2D _coordinate = mapview.centerCoordinate;
	if(userAnnotation == nil)
		[self addUserAnnotation:_coordinate];
	else
		[userAnnotation setCoordinate:_coordinate];
	
	[modelSearch addVirtualLocation];
}

#pragma mark SearchViewControllerDelegate methods
- (void)receivedSearchKeyword:(NSString*)_text {
	DLog(@"_text: %@", _text);
  [labelSearch setText:_text];
  
  [self dismissAnyViewControllerPresent];
  
	lastPage = 1;
	
	if([_text isEqualToString:@"Current GPS Location"])
		[self nearby];
	else if([_text isEqualToString:@"Virtual Location"])
		[self initiateNearbySearchHTTPRequest];
	else
		[self initiateKeywordSearchHTTPRequest:_text];
}

- (void)cancelSearchViewController {
	DLog(@"begin");
	[self.navigationController dismissModalViewControllerAnimated:YES];
  [self dismissPopoverViewController];
}

#pragma mark HTTP methods
- (void)initiateNearbySearchHTTPRequest
{
	DLog(@"begin");
  labelSearch.text = [NSString stringWithFormat:@"Nearby (%f,%f)", userAnnotation.coordinate.latitude, userAnnotation.coordinate.longitude];
  NSString* _message = @"Showing nearby records... ";
  
	NSMutableString *strURLDirty = [[NSMutableString alloc] init];
	[strURLDirty appendFormat:@"%@", HTTP_NEARBY_URL];
  [strURLDirty appendFormat:@"&country_name=%@", [Country getName]];
	[strURLDirty appendFormat:@"&latitude=%f&longitude=%f", userAnnotation.coordinate.latitude, userAnnotation.coordinate.longitude];
	
	[lastURLString setString:strURLDirty];
	[strURLDirty appendFormat:@"&page=%d", lastPage];
	
	[self startHTTPRequest:strURLDirty];
	[strURLDirty release];
	
	[self startAnimating:_message];
}

- (void)initiateNearbyPoiTypeSearchHTTPRequest:(NSString*)_poiType
{
	DLog(@"begin");
  labelSearch.text = [NSString stringWithFormat:@"Nearby (%f,%f)", userAnnotation.coordinate.latitude, userAnnotation.coordinate.longitude];
  NSString* _message = @"Showing nearby records... ";
  
	NSMutableString *strURLDirty = [[NSMutableString alloc] init];
	[strURLDirty appendFormat:@"%@", HTTP_SEARCH_URL];
  [strURLDirty appendFormat:@"&country_name=%@", [Country getName]];

  if(_poiType != nil){
    labelSearch.text = [NSString stringWithFormat:@"Nearby %@", _poiType];
    [strURLDirty appendFormat:@"&poi_type_name=%@", _poiType];
    _message = [NSString stringWithFormat:@"Showing nearby %@...", _poiType];
  }

	[strURLDirty appendFormat:@"&latitude=%f&longitude=%f", userAnnotation.coordinate.latitude, userAnnotation.coordinate.longitude];

	[lastURLString setString:strURLDirty];
	[strURLDirty appendFormat:@"&page=%d", lastPage];

	[self startHTTPRequest:strURLDirty];
	[strURLDirty release];

  [self startAnimating:_message];  
}

- (void)initiateKeywordSearchHTTPRequest:(NSString*)_keyword
{
	DLog(@"_keyword: %@", _keyword);
  NSString* _message = @"Searching";
  labelSearch.text = _keyword;
  
	[lastKeyword setString:_keyword];
	
	NSMutableString *strURLDirty = [[NSMutableString alloc] init];
	[strURLDirty appendFormat:@"%@", HTTP_SEARCH_URL];
  [strURLDirty appendFormat:@"&country_name=%@", [Country getName]];
	[strURLDirty appendFormat:@"&keyword=%@", _keyword];
  _message = [NSString stringWithFormat:@"Searching for %@", _keyword];
	
	if(userAnnotation != nil)
  {
		[strURLDirty appendFormat:@"&latitude=%f&longitude=%f", userAnnotation.coordinate.latitude, userAnnotation.coordinate.longitude];
    _message = [NSString stringWithFormat:@"Searching for nearby %@", _keyword];
  }
	
	[lastURLString setString:strURLDirty];
	[strURLDirty appendFormat:@"&page=%d", lastPage];

	[self startHTTPRequest:strURLDirty];
	[strURLDirty release];
	
	[self startAnimating:_message];
}

- (void)initiateRecentSearchHTTPRequest:(NSString*)_poiType
{
	DLog(@"begin");
  labelSearch.text = @"Recent";
  NSString* _message = @"Showing recent records... ";

	NSMutableString *strURLDirty = [[NSMutableString alloc] init];
	[strURLDirty appendFormat:@"%@", HTTP_RECENT_URL];
  [strURLDirty appendFormat:@"&country_name=%@", [Country getName]];
    
  if(_poiType != nil)
  {
    labelSearch.text = [NSString stringWithFormat:@"Recent %@", _poiType];
    [strURLDirty appendFormat:@"&poi_type_name=%@", _poiType];
    _message = [NSString stringWithFormat:@"Showing recent %@...", _poiType];
  }
	
	[lastURLString setString:strURLDirty];
	[strURLDirty appendFormat:@"&page=%d", lastPage];
	
	[self startHTTPRequest:strURLDirty];
	[strURLDirty release];
	
  [self startAnimating:_message];
}

- (void)initiateFeaturedSearchHTTPRequest:(NSString*)_poiType
{
	DLog(@"begin");
  labelSearch.text = @"Featured";
  NSString* _message = @"Showing featured records... ";

	NSMutableString *strURLDirty = [[NSMutableString alloc] init];
	[strURLDirty appendFormat:@"%@", HTTP_FEATURED_URL];
  [strURLDirty appendFormat:@"&country_name=%@", [Country getName]];

  if(_poiType != nil)
  {
    labelSearch.text = [NSString stringWithFormat:@"Featured %@", _poiType];
    [strURLDirty appendFormat:@"&poi_type_name=%@", _poiType];
    _message = [NSString stringWithFormat:@"Showing featured %@...", _poiType];
  }

	[lastURLString setString:strURLDirty];
	[strURLDirty appendFormat:@"&page=%d", lastPage];
	
	[self startHTTPRequest:strURLDirty];
	[strURLDirty release];
	
  [self startAnimating:_message];
}

- (void)initiateMostViewedSearchHTTPRequest:(NSString*)_poiType
{
	DLog(@"begin");
  labelSearch.text = @"Most Viewed";
  NSString* _message = @"Showing most viewed records... ";

	NSMutableString *strURLDirty = [[NSMutableString alloc] init];
	[strURLDirty appendFormat:@"%@", HTTP_MOST_VIEWED_URL];
  [strURLDirty appendFormat:@"&country_name=%@", [Country getName]];

  if(_poiType != nil)
  {
    labelSearch.text = [NSString stringWithFormat:@"Most Viewed %@", _poiType];
    [strURLDirty appendFormat:@"&poi_type_name=%@", _poiType];
    _message = [NSString stringWithFormat:@"Showing most viewed %@...", _poiType];
  }
	
	[lastURLString setString:strURLDirty];
	[strURLDirty appendFormat:@"&page=%d", lastPage];

	[self startHTTPRequest:strURLDirty];
	[strURLDirty release];

  [self startAnimating:_message];
}

- (void)initiateFeedHTTPRequest {
	DLog(@"begin");
  labelSearch.text = @"News Feed";
  NSString* _message = @"Showing recent news feed... ";
  
	NSMutableString *strURLDirty = [[NSMutableString alloc] init];
	[strURLDirty appendFormat:@"%@", HTTP_FEED_URL];
  [strURLDirty appendFormat:@"?country_name=%@", [Country getName]];
  
	[lastURLString setString:strURLDirty];
	[strURLDirty appendFormat:@"&page=%d", lastPage];
  
	[self startHTTPRequest:strURLDirty];
	[strURLDirty release];
  
  [self startAnimating:_message];
}

- (void)startHTTPRequest:(NSString *)urlDirty
{
	DLog(@"begin");
	NSString *strURLClean = [urlDirty stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:strURLClean];	
	
	ASIHTTPRequest* currentHTTPRequest = [ASIHTTPRequest requestWithURL:url];
	[currentHTTPRequest setDelegate:self];
	[currentHTTPRequest setDidFinishSelector:@selector(requestFinished:)];
	[currentHTTPRequest setDidFailSelector:@selector(requestFailed:)];
	[currentHTTPRequest setTimeOutSeconds:HTTP_TIMEOUT];
	
	[currentHTTPRequest startAsynchronous];
	DLog(@"urlDirty: %@", urlDirty);
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	DLog(@"");
  [tableviewContent loadMoreFinished];
  NSData *jsonData = [request responseData];
  id responseRoot = [jsonData objectFromJSONData];

  if([responseRoot isKindOfClass:[NSDictionary class]]) {
		totalPages = (int)[[responseRoot objectForKey:@"total_pages"] intValue];

    NSArray *dataArray = (NSArray *)[responseRoot objectForKey:@"data"];

		//If there are records
		if( totalPages > 0 && [dataArray count] > 0) {
			//used for appending to searchDictionary item
			[modelSearch addToRecentSearch:lastKeyword];
			
			[lastKnownURLString setString:lastURLString];
			lastKnownPage = lastPage;
			lastKnownTotalPages = totalPages;
			
			DLog(@"lastKnownURLString: %@", lastKnownURLString);
			NSMutableArray *arrayData = [[NSMutableArray alloc] initWithArray:dataArray];
			
			if(lastPage == 1)
				[self createDataModel:arrayData];
			else
				[self appendDataModel:arrayData];
			
			[arrayData release];
		}
		else {
			[lastKeyword setString:@""];
      [UBAlertView showAlertWithTitle:@"Warning" message:@"Sorry, there were no records found." executeBlock:nil];
		}
  }
  else
    [UBAlertView showAlertWithTitle:@"Error" message:MESSAGE_APPLICATION_ERROR executeBlock:nil];

	[self stopAnimating];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
  [tableviewContent loadMoreFinished];
	NSError *error = [request error];
	NSString *message = [error localizedDescription];
	
	if( [error localizedDescription] == @"The request timed out" )
		message = [NSString stringWithFormat:@"%@ (%@)", MESSAGE_NETWORK_ERROR, [error localizedDescription]];
	
	[UBAlertView showAlertWithTitle:@"Error" message:message executeBlock:nil];

	[self stopAnimating];
}

- (void)createDataModel:(NSMutableArray*)_poiArray {
	[mapview removeAnnotations:arrayPoiAnnotations];
	[arrayPoiAnnotations removeAllObjects];
	
	[self initMBR];

	[self addAnnotations:_poiArray];

	[self zoomToFitPoiAnnotations];
	
	[tableviewContent reloadData];
}

- (void)appendDataModel:(NSMutableArray*)_poiArray {
	//Get the lastCount of the dataModel. We will use this in the indexPath below.
	int lastCount = (int)[arrayPoiAnnotations count];

	//Update the dataModel. Now we should have 20 objects
	[self addPoiAnnotations:_poiArray startIndex:lastCount];
	
	//Create the arrayIndexPaths
	NSMutableArray* arrayIndexPaths = [[NSMutableArray	alloc] initWithObjects:nil];
	
	NSIndexPath* visibleIndexPath = nil;

	for(int i=0;i<[_poiArray count]; i++)
  {
		int _index = lastCount + i;

    DLog(@"index: %d", _index);
		[arrayIndexPaths addObject:[NSIndexPath	indexPathForRow:_index inSection:0]];

    if(i==0)
			visibleIndexPath = [NSIndexPath indexPathForRow:_index inSection:0];
	}
	
	//Insert the indexPaths to the TableView. Note numberOfRowsInSection will be called prior to inserting the indexPaths. This means we should have the dataModel to have the correct number already, prior to inserting the indexPaths.
	[tableviewContent insertRowsAtIndexPaths:arrayIndexPaths withRowAnimation:UITableViewRowAnimationTop];
	[arrayIndexPaths release];
	
	[self zoomToFitPoiAnnotations];
	
	[tableviewContent scrollToRowAtIndexPath:visibleIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)addAnnotations:(NSMutableArray*)dataArray {
	[self addPoiAnnotations:dataArray startIndex:0];
}

- (void)addPoiAnnotations:(NSMutableArray*)_poiArray startIndex:(int)_lastCount {
	for (int i=0;i<[_poiArray count];i++)
  {
		NSDictionary *_poi = [[NSDictionary alloc] initWithDictionary:[_poiArray objectAtIndex:i]];
		
		NSString* _strLatitude = [NSString stringWithFormat:@"%@", [_poi objectForKey:@"latitude"]];
		NSString* _strLongitude = [NSString stringWithFormat:@"%@", [_poi objectForKey:@"longitude"]];
		
		int index = _lastCount + i;
		
		PoiAnnotation* annotation = [[PoiAnnotation alloc] initWithPrimaryKey:(int)[[_poi objectForKey:@"id"] intValue] withIndex:index];
    annotation.annotation_type = [_poi objectForKey:@"annotation_type"];
    annotation.address = [_poi objectForKey:@"address"];
    
    annotation.poitype = [_poi objectForKey:@"poi_type"];
    [annotation setLatitude:_strLatitude setLongitude:_strLongitude];
    annotation.picture_thumb_path = [_poi objectForKey:@"picture_thumb_path"];
    
    int total_likes = [[_poi objectForKey:@"total_likes"] intValue];
    int total_comments = [[_poi objectForKey:@"total_comments"] intValue];
    annotation.total_likes = [NSString stringWithFormat:@"%d", total_likes];
    annotation.total_comments = [NSString stringWithFormat:@"%d", total_comments];

    if([annotation.annotation_type isEqualToString:@"poi"]) {
      annotation.name = [_poi objectForKey:@"name"];
      annotation.distance = [_poi objectForKey:@"distance"];
      //poiAnnotation.distance = @"999.999 km";
      
      annotation.total_stars = [_poi objectForKey:@"total_stars"];
      annotation.total_ratings = [_poi objectForKey:@"total_ratings"];
      annotation.min_rate = [_poi objectForKey:@"min_rate"];
      //poiAnnotation.min_rate = @"VND 9,000,000";
    }
    else if([annotation.annotation_type isEqualToString:@"feed"]) {
      annotation.name = [_poi objectForKey:@"poi_name"];
      annotation.time_in_age_posted = [_poi objectForKey:@"age"];
      annotation.facebook_id = [NSString stringWithFormat:@"%@", [_poi objectForKey:@"profile_id"]];
      
      NSString *feed_type = [_poi objectForKey:@"feed_type"];
      NSString *fbuser = [_poi objectForKey:@"user"];
      NSString *content = [_poi objectForKey:@"content"];
      
      if([feed_type isEqualToString:@"comment"])
        annotation.content = [NSString stringWithFormat:@"by %@ \"%@\"", fbuser, content];
      else
        annotation.content = [NSString stringWithFormat:@"%@ %@", fbuser, content];
    }
		
		[arrayPoiAnnotations addObject:annotation];
		[_poi release];
		
		[mapview addAnnotation:annotation];
		
		if([annotation hasValidCoordinates]) {
      //DLog(@"%d poiAnnotation.coordinate (%f, %f)", poiAnnotation.primaryKey, poiAnnotation.coordinate.latitude, poiAnnotation.coordinate.longitude);

			topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
			topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
			bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
			bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);

      //DLog(@"topLeftCoord.latitude: %f", topLeftCoord.latitude);
      //DLog(@"topLeftCoord.longitude: %f", topLeftCoord.longitude);
      //DLog(@"bottomRightCoord.latitude: %f", bottomRightCoord.latitude);
      //DLog(@"bottomRightCoord.longitude: %f", bottomRightCoord.longitude);
		}
		
		//DLog(@"addPoiAnnotations id:%@", [NSString stringWithFormat:@"%@ %d", [_poi objectForKey:@"id"], ]);
		[annotation release];
	}
}


- (void)zoomToFitPoiAnnotations {
//	DLog(@"begin");
//	DLog(@"topLeftCoord.latitude: %f", topLeftCoord.latitude);
//  DLog(@"topLeftCoord.longitude: %f", topLeftCoord.longitude);
//  DLog(@"bottomRightCoord.latitude: %f", bottomRightCoord.latitude);
//  DLog(@"bottomRightCoord.longitude: %f", bottomRightCoord.longitude);

  CGFloat minLatitude = fmin(bottomRightCoord.latitude, topLeftCoord.latitude);
  CGFloat maxLatitude = fmax(topLeftCoord.latitude, bottomRightCoord.latitude);

  CGFloat minLongitude = fmin(topLeftCoord.longitude, bottomRightCoord.longitude);
  CGFloat maxLongitude = fmax(bottomRightCoord.longitude, topLeftCoord.longitude);

  CGFloat centerLatitude = (minLatitude + maxLatitude) / 2;
  CGFloat centerLongitude = (minLongitude + maxLongitude) / 2;

  if(RMCLLocationCoordinate2DIsValid(centerLatitude, centerLongitude)) {
    DLog(@"Coordinate is valid");

    // we'll make sure that our minimum vertical span is about a kilometer
    // there are ~111km to a degree of latitude. regionThatFits will take care of
    // longitude, which is more complicated, anyway.
    MKCoordinateRegion region;
    region.center.latitude = centerLatitude;
    region.center.longitude = centerLongitude;

    region.span.latitudeDelta = (maxLatitude - minLatitude) * MAP_PADDING;
    region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE) ? MINIMUM_VISIBLE_LATITUDE : region.span.latitudeDelta;

    region.span.longitudeDelta = (maxLongitude - minLongitude) * MAP_PADDING;

    MKCoordinateRegion scaledRegion = [mapview regionThatFits:region];
    [mapview setRegion:scaledRegion animated:YES];
  }
  else
    DLog(@"Invalid coordinate");
}

- (void)zoomToFitUserAnnotationAndCountry {
  if(userAnnotation != nil) {
		topLeftCoord.longitude = fmin(topLeftCoord.longitude, userAnnotation.coordinate.longitude);
		topLeftCoord.latitude = fmax(topLeftCoord.latitude, userAnnotation.coordinate.latitude);

		bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, [[mapPlist_ objectForKey:@"regionCenterLongitude"] floatValue]);
		bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, [[mapPlist_ objectForKey:@"regionCenterLatitude"] floatValue]);
	}

  [self zoomToFitPoiAnnotations];
}

#pragma mark GPSControllerDelegate delegate methods
- (void)startGPS {
	DLog(@"begin");
	boolGPSTimeoutActive = YES;
	[[RMGPSController sharedInstance].locationManager startUpdatingLocation];
	[self performSelector:@selector(timeOutGPS) withObject:nil afterDelay:GPS_TIMEOUT];
	[gpsNotificationAlertView show];
}

-(void)didUpdateToAGoodLocation:(CLLocationCoordinate2D)coordinate {
  [self newLocationUpdate:coordinate];
  [self updateAPNWithLocation];
}

- (void)newLocationUpdate:(CLLocationCoordinate2D)_coordinate {
  DLog(@"coordinate: %f %f", _coordinate.latitude, _coordinate.longitude);
  [self stopGPS];

	//Add the userAnnotation if there is nothing yet else move the userAnnotation
	if(userAnnotation == nil)
		[self addUserAnnotation:_coordinate];
	else
		[userAnnotation setCoordinate:_coordinate];

  if(boolShowCurrentLocation) {
    [mapview setCenterCoordinate:_coordinate animated:YES];

    boolShowCurrentLocation = NO;
    return;
  }
	
	if([self checkLocationIfWithinBounds:_coordinate]) {
		[mapview setCenterCoordinate:_coordinate animated:YES];

    //This will trigger the HTTP request to get the nearby records
    if(boolPendingRequestForNearbySearchHTTPRequest) {
      boolPendingRequestForNearbySearchHTTPRequest = NO;
      [self initiateNearbySearchHTTPRequest];
    }
    else if(boolPendingRequestForRecentWithKeywordSearchHTTPRequest) {
      boolPendingRequestForRecentWithKeywordSearchHTTPRequest = NO;

      if([poiType isNotEmpty])
        [self initiateNearbyPoiTypeSearchHTTPRequest:poiType];
    }
    
  }
	else {
    [self zoomToFitUserAnnotationAndCountry];
		[self showGPSAlert:@"GPS Alert" message:MESSAGE_GPS_TOO_FAR];
	}
}

-(void)newLocationFailedWithMessage:(NSString*)errorString withCode:(NSInteger)code {
	DLog(@"errorString: %@", errorString);
	[self stopGPS];

  NSString *message = [NSString stringWithFormat:@"%@ %@", errorString, MESSAGE_LOCATION_FAILED];
  [self showGPSAlert:@"GPS Alert" message:message];
}

- (void)stopGPS {
	DLog(@"begin");
	[[RMGPSController sharedInstance].locationManager stopUpdatingLocation];
	[spinner stopAnimating];
	boolGPSTimeoutActive = NO;

  [self hideGPSAlert];
}

- (void)timeOutGPS {
	if(boolGPSTimeoutActive) {
		DLog(@"boolGPSTimeoutActive: YES. Need to show GPS_TIMEOUT alert");
		[self stopGPS];
		[self showGPSAlert:@"GPS Alert" message:MESSAGE_GPS_TIMEOUT];
	}
	else
		DLog(@"boolGPSTimeoutActive: NO. will not show GPS_TIMEOUT alert");
}

- (void)showGPSAlert:(NSString*)alertTitle message:(NSString*)_message {
	
	if(boolGPSAlertShown == NO) {
		DLog(@"boolGPSAlertShown: NO");
		[HelperAlert showTitle:alertTitle message:_message delegate:self];
		
		boolGPSAlertShown = YES;
	}
	else
		DLog(@"boolGPSAlertShown: YES");
}

#pragma mark alertview delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	DLog(@"buttonIndex: %d", buttonIndex);
	boolGPSAlertShown = NO;
	
	if([alertView.title isEqualToString:@"GPS Notification"]) {
		if(buttonIndex == 0){
			[self startAnimating:@"Waiting for location.."];
			boolGPSTimeoutActive = YES;
		}
		else if(buttonIndex == 1){
			DLog(@"CANCEL");
			[self stopGPS];
			[self showVirtualLocation];
		}
	}
  else if([alertView.title isEqualToString:@"GPS Alert"]) {
    if(boolPendingRequestForRecentWithKeywordSearchHTTPRequest) {
      boolPendingRequestForRecentWithKeywordSearchHTTPRequest = NO;

      if([poiType isNotEmpty])
        [self initiateRecentSearchHTTPRequest:poiType];
    }
    else
      [self initiateFeedHTTPRequest];
  }
}

#pragma mark private mapview delegate methods
- (BOOL)checkLocationIfWithinBounds:(CLLocationCoordinate2D)_coordinate {
  DLog(@"");
  CGFloat minimumLatitude = [[mapPlist_ objectForKey:@"minimumLatitude"] floatValue];
  CGFloat maximumLatitude = [[mapPlist_ objectForKey:@"maximumLatitude"] floatValue];
  CGFloat minimumLongitude = [[mapPlist_ objectForKey:@"minimumLongitude"] floatValue];
  CGFloat maximumLongitude = [[mapPlist_ objectForKey:@"maximumLongitude"] floatValue];

  return _coordinate.latitude > minimumLatitude && _coordinate.latitude < maximumLatitude && _coordinate.longitude > minimumLongitude && _coordinate.longitude < maximumLongitude ? YES : NO;
}

- (void)addUserAnnotation:(CLLocationCoordinate2D)_coordinate {
  if(RMCLLocationCoordinate2DIsValid(_coordinate.latitude, _coordinate.longitude)) {
    userAnnotation = [[UserAnnotation alloc] initWithCoordinate:_coordinate];
    userAnnotation.title = @"Current Location";
    [mapview addAnnotation:userAnnotation];
  }
}

- (void)initMapRegion {
	DLog(@"initMapRegion");
	MKCoordinateRegion _region;

  _region.span.latitudeDelta = [[mapPlist_ objectForKey:@"regionSpanLatitude"] floatValue];
	_region.span.longitudeDelta = [[mapPlist_ objectForKey:@"regionSpanLongitude"] floatValue];
	_region.center.latitude = [[mapPlist_ objectForKey:@"regionCenterLatitude"] floatValue];
	_region.center.longitude = [[mapPlist_ objectForKey:@"regionCenterLongitude"] floatValue];

	[mapview setRegion:_region animated:YES];	
	[mapview regionThatFits:_region];
}

- (void)initMBR {
  topLeftCoord.latitude = -90;
  topLeftCoord.longitude = 180;
  bottomRightCoord.latitude = 90;
  bottomRightCoord.longitude = -180;
}

#pragma mark MKMapViewDelegate delegate methods
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
	//DLog(@"mapViewWillStartLoadingMap");
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
	//DLog(@"mapViewDidFinishLoadingMap");
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
	//DLog(@"mapViewDidFailLoadingMap");
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
//	MKCoordinateRegion region = mapView.region;
//	DLog(@"latitude: %f, longitude: %f spanLatitude: %f spanLongitude: %f", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    //DLog(@"viewForAnnotation");
    if ([annotation isKindOfClass:[UserAnnotation class]]) {
      // Try to dequeue an existing pin view first.
      MKAnnotationView* pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"UserAnnotationView"];
		
      UserAnnotation *_annotation = (UserAnnotation*)annotation;
		
      if(!pinView) {
        pinView = [[[MKAnnotationView alloc] initWithAnnotation:_annotation reuseIdentifier:@"UserAnnotationView"] autorelease];
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.enabled = YES;
        pinView.canShowCallout = YES;
        pinView.centerOffset = CGPointMake(1,-19);
        pinView.rightCalloutAccessoryView = nil;
        pinView.image = [UIImage imageNamed:@"blue_gps_person.png"];
        pinView.centerOffset = CGPointMake(0, -19.5f);

        if([pinView respondsToSelector:@selector(setDraggable:)]) {
          pinView.draggable = YES;
          _annotation.subtitle = @"Hold and Drag to Move";
        }
        else
          _annotation.subtitle = @"Use Drop Pin to recenter";

        _annotation.title = @"Virtual Location";
      }
      else
        pinView.annotation = annotation;

      return pinView;
    }
    else if ([annotation isKindOfClass:[PoiAnnotation class]]) {
      NSString *poiAnnotationViewIdentifier = nil;
		
      PoiAnnotation *_annotation = (PoiAnnotation*)annotation;
      poiAnnotationViewIdentifier = _annotation.poitype;
		
      // Try to dequeue an existing pin view first.
      MKAnnotationView* pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:poiAnnotationViewIdentifier];
		
      if (!pinView) {
        // If an existing pin view was not available, create one.
        pinView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PoiAnnotationView"] autorelease];
			
        //DLog(@"annotation poitype:%@", [annotation poitype]);
        if( [_annotation respondsToSelector:@selector(poitype)] && [_annotation.poitype isEqualToString:@"Attraction"])
          pinView.image = [UIImage imageNamed:@"pin_attraction.png"];
        else if( [_annotation respondsToSelector:@selector(poitype)] && [_annotation.poitype isEqualToString:@"Hotel"])
          pinView.image = [UIImage imageNamed:@"pin_hotel.png"];
        else if( [_annotation respondsToSelector:@selector(poitype)] && [_annotation.poitype isEqualToString:@"Restaurant"])
          pinView.image = [UIImage imageNamed:@"pin_restaurant.png"];
        else if( [_annotation respondsToSelector:@selector(poitype)] && [_annotation.poitype isEqualToString:@"Tour"])
          pinView.image = [UIImage imageNamed:@"pin_tour.png"];
        else if( [_annotation respondsToSelector:@selector(poitype)] && [_annotation.poitype isEqualToString:@"Promo"])
          pinView.image = [UIImage imageNamed:@"pin_promo.png"];
        else
          pinView.image = [UIImage imageNamed:@"pin_info.png"];
        
        pinView.canShowCallout = YES;
        //Set to half of the image height
        pinView.centerOffset = CGPointMake(0, -16);
			
        // Add a detail disclosure button to the callout if iOS > 4
        if( [pinView respondsToSelector:@selector(setDraggable:)]) {
          UIButton* rightButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
          pinView.rightCalloutAccessoryView = rightButton;
        }
      }
      else
        pinView.annotation = annotation;
		
      return pinView;
    }
	
    return nil;
}

- (void)moveAnnotation:(CLLocationCoordinate2D)_annotation {
  CGPoint currentPoint = [mapview convertCoordinate:_annotation toPointToView:self.view];

  CGFloat imaginaryY = currentPoint.y - (320.0f - 230.0f);
  CGPoint imaginaryPoint = CGPointMake(currentPoint.x, imaginaryY);
  DLog(@"didSelectAnnotationView: currentPoint.x: %f currentPoint.y: %f imaginary.x: %f, imaginary.y: %f", currentPoint.x, currentPoint.y, currentPoint.x, imaginaryY);
  CLLocationCoordinate2D c = [mapview convertPoint:imaginaryPoint toCoordinateFromView:self.view];
  [mapview setCenterCoordinate:c animated:YES];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	DLog(@"begin");
	
	if(currentAnnotation == view.annotation && [currentAnnotation isKindOfClass:[PoiAnnotation class]])
  {
		DLog(@"didDeselectAnnotationView currentAnnotation:%d", currentAnnotation.index);
		NSIndexPath* _indexPath = [NSIndexPath indexPathForRow:lastKnownIndexSelected inSection:0];
		[tableviewContent deselectRowAtIndexPath:_indexPath animated:NO];
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	DLog(@"begin");
	
	if([HelperDevice isDeviceAniPad]){
		int index = (int)currentAnnotation.index;
		NSIndexPath* _indexPath = [NSIndexPath indexPathForRow:index inSection:0];
		[self showDetailsViewController:currentAnnotation indexPath:_indexPath];
	}
	else
		[self showDetailsViewController:view.annotation];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	DLog(@"begin");
	currentAnnotation = view.annotation;
	
	if([currentAnnotation isKindOfClass:[PoiAnnotation class]])
  {
		int index = (int)currentAnnotation.index;
		NSIndexPath* _indexPath = [NSIndexPath indexPathForRow:index inSection:0];
		DLog(@"didSelectAnnotationView %d", index);
		
		//Scroll to the indexpath if it is not visible
		UITableViewCell*cell = (UITableViewCell*)[tableviewContent cellForRowAtIndexPath:_indexPath];
		
		if( [cell isSelected] || [cell isHighlighted] ){
			DLog(@"cell is already selected");
		}
		else{
			DLog(@"tableView scrollToRowAtIndexPath: %d", _indexPath.row);
			[tableviewContent scrollToRowAtIndexPath:_indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
			
			[tableviewContent selectRowAtIndexPath:_indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
			lastKnownIndexSelected = index;
		}
	}
}

#pragma mark UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if(tableView == self.tableviewContent) {
    [HelperLogUtils rowsInSection:[arrayPoiAnnotations count] section:section];
    return [arrayPoiAnnotations count];
  }
  else {
    return [arrayMenus count];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if(tableView == self.tableviewContent)
    return TABLEVIEW_CELL_HEIGHT;
  else
    return MENU_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if(tableView == self.tableviewContent) {

    ApplicationCell *cell;
    NSString *cellIdentifier;

    PoiAnnotation *poi = (PoiAnnotation *)[arrayPoiAnnotations objectAtIndex:indexPath.row];

    if ([poi.annotation_type isEqualToString:@"poi"]){
      cellIdentifier = [NSString stringWithFormat:@"%@_cell", poi.annotation_type];
      cell = (ApplicationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
      
      if(cell == nil)
        cell = [[[PoiImageTableViewApplicationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    else if([poi.annotation_type isEqualToString:@"feed"]){
      cellIdentifier = [NSString stringWithFormat:@"%@_cell_%@", poi.annotation_type, poi.facebook_id];
      cell = (ApplicationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
      
      if(cell == nil)
        cell = [[[FeedImageTableViewApplicationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }

    cell.useDarkBackground = (indexPath.row % 2 == 0);
    cell.total_likes = poi.total_likes;
    cell.total_comments = poi.total_comments;

    if ([poi.annotation_type isEqualToString:@"poi"]) {
      cell.name = poi.name;
      cell.address = poi.address;
      cell.distance = poi.distance;
      cell.total_stars = poi.total_stars;
      cell.total_ratings = poi.total_ratings;
      cell.min_rate = poi.min_rate;
      cell.thumb_path = poi.picture_thumb_path;
    }
    else if([poi.annotation_type isEqualToString:@"feed"]) {
      cell.name = poi.name;
      cell.content = poi.content;
      cell.time_in_age_posted = poi.time_in_age_posted;
      cell.thumb_path = poi.picture_thumb_path;
      cell.facebook_id = poi.facebook_id;
    }

//    if([HelperDevice isDeviceAniPad])
//      cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

    return cell;
  }
  else {
    UITableViewCell *cell = nil;
    static NSString *cellIdentifier = @"Menu";

    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil)
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];

    cell.textLabel.text = [arrayMenus objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];

    return cell;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if(tableView == self.tableviewContent) {
    PoiAnnotation *poi = (PoiAnnotation *)[arrayPoiAnnotations objectAtIndex:indexPath.row];

    if([poi hasValidCoordinates])
      [mapview selectAnnotation:poi animated:YES];
   
    if([HelperDevice isDeviceAniPhone])
      [self.paperFoldView setPaperFoldState:PaperFoldStateRightUnfolded animated:YES];
  }
  else {
    //initialize variables lastPage = 1 or records will append
    [self initVariables];
    
    switch (indexPath.row) {
      case 0: // Home
        [self.navigationController popToRootViewControllerAnimated:YES];
        break;
      case 1: // Login
        [self authenticate];
        break;
      case 2: // Near Me
        [self nearby];
        break;
      case 3: //@"Feed"
        [self initiateFeedHTTPRequest];
        break;
      case 4: //@"Featured"
        [self initiateFeaturedSearchHTTPRequest:nil];
        break;
      case 5: //@"Most Viewed"
        [self initiateMostViewedSearchHTTPRequest:nil];
        break;
      case 6:
        [self initiateRecentSearchHTTPRequest:nil];
        break;
      default:
        [self initiateRecentSearchHTTPRequest:[arrayMenus objectAtIndex:indexPath.row]];
        break;
    }
  }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  if (tableView == self.tableviewContent) {
    //Select the cell first so that it won't go to the middle when the didSelectAnnotation triggers
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

    PoiAnnotation *poi = (PoiAnnotation *)[arrayPoiAnnotations objectAtIndex:indexPath.row];

    if( poi.coordinate.latitude > 0 && poi.coordinate.longitude > 0)
      [mapview selectAnnotation:poi animated:YES];

    if([HelperDevice isDeviceAniPad])
      [self showDetailsViewController:poi indexPath:indexPath];
    else
      [self showDetailsViewController:poi];
  }
}

//Used for iPhone only
- (void)showDetailsViewController:(PoiAnnotation*)_annotation {
  DLog(@"");
	DetailsViewController *detailsVC = [[DetailsViewController alloc] initWithStyle:UITableViewStylePlain withPoiModel:_annotation];
	[detailsVC setSearchModel:modelSearch];
	
	[self.navigationController pushViewController:detailsVC animated:YES];
	[detailsVC release];
}

//Used for iPad only, determine the origin_y of current cell to show popover arrow
- (void)showDetailsViewController:(PoiAnnotation*)_annotation indexPath:(NSIndexPath *)indexPath {
  UITableViewCell*cell = (UITableViewCell*)[tableviewContent cellForRowAtIndexPath:indexPath];
  CGFloat yOffset = abs(tableviewContent.contentOffset.y - cell.frame.origin.y) + HEADER_HEIGHT;
  CGRect frame = CGRectMake(cell.frame.origin.x, yOffset, cell.frame.size.width, cell.frame.size.height);
  DLog(@"cell.frame x:%f y:%f", cell.frame.origin.x, cell.frame.origin.y);
  DLog(@"tableView.contentOffset x: %f y: %f", tableviewContent.contentOffset.x, tableviewContent.contentOffset.y);

	DetailsViewController *detailsVC = [[DetailsViewController alloc] initWithStyle:UITableViewStylePlain withPoiModel:_annotation];
	detailsVC.delegate = self;
	[detailsVC setSearchModel:modelSearch];
	
	if(popoverController != nil) {
		if([popoverController isPopoverVisible])
			[popoverController dismissPopoverAnimated:YES];	

		[popoverController release], popoverController = nil;
	}
	
	popoverController = [[UIPopoverController alloc] initWithContentViewController:detailsVC];
	popoverController.delegate = self;
	
	DLog(@"frame: x:%f y:%f width:%f height:%f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	[popoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
	
	[detailsVC release];
}

#pragma mark DetailsViewControllerDelegate methods
- (void)dismissAndPushViewController:(UIViewController*)vc {
	DLog(@"begin");
	[self dismissModalViewController];
  [self dismissPopoverViewController];
	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark paper fold delegate
- (void)paperFoldView:(id)paperFoldView didFoldAutomatically:(BOOL)automated toState:(PaperFoldState)paperFoldState {
  DLog(@"did transition to state %i", paperFoldState);
  if([HelperDevice isDeviceAniPhone]) {
    if(paperFoldState == 0){
      buttonTableview.hidden = YES;
      buttonMap.hidden = NO;
      
      [UIView beginAnimations:@"moveTableviewLeft" context:NULL];
      [UIView setAnimationDuration:0.3];
      if(boolMapFullScreen)
        self.tableviewContent.frame = self.paperFoldView.frame;
      else
        self.tableviewContent.frame = tableviewContentFrame;
      [UIView commitAnimations];
    }
    else if(paperFoldState == 2) {
      buttonTableview.hidden = NO;
      buttonMap.hidden = YES;
      
      CGRect originalFrame = self.tableviewContent.frame;
      if(originalFrame.size.width != THUMBNAIL_WIDTH){
        CGRect newFrame = CGRectMake(originalFrame.size.width - THUMBNAIL_WIDTH, 0.0f, THUMBNAIL_WIDTH, originalFrame.size.height);
        [UIView beginAnimations:@"moveTableviewRight" context:NULL];
        [UIView setAnimationDuration:0.3];
        self.tableviewContent.frame = newFrame;
        [UIView commitAnimations];
      }
    }
    else if(paperFoldState == 1){
      [UIView beginAnimations:@"moveTableviewLeft" context:NULL];
      [UIView setAnimationDuration:0.3];
      if(boolMapFullScreen)
        self.tableviewContent.frame = self.paperFoldView.frame;
      else
        self.tableviewContent.frame = tableviewContentFrame;
      [UIView commitAnimations];
    }
  }
  else{
    if(paperFoldState == 0) {
      [UIView beginAnimations:@"moveMapviewLeft" context:NULL];
      [UIView setAnimationDuration:0.1];
      self.mapview.frame = mapviewFrame;
      self.paperFoldView.frame = paperFoldFrame;
      [UIView commitAnimations];
    }
    else if(paperFoldState == 1) {
      CGRect newMapFrame = CGRectMake(mapviewFrame.origin.x + TABLEVIEWMENU_WIDTH, mapviewFrame.origin.y, mapviewFrame.size.width - TABLEVIEWMENU_WIDTH, mapviewFrame.size.height);
      
      CGRect newPaperfoldFrame = CGRectMake(0.0f, HEADER_HEIGHT, 320.0f + TABLEVIEWMENU_WIDTH, paperFoldFrame.size.height);
      
      [UIView beginAnimations:@"moveMapviewRight" context:NULL];
      [UIView setAnimationDuration:0.1];
      self.mapview.frame = newMapFrame;
      self.paperFoldView.frame = newPaperfoldFrame;
      [UIView commitAnimations];
    }
    else if(paperFoldState == 2) {
      [UIView beginAnimations:@"moveMapviewLeft" context:NULL];
      [UIView setAnimationDuration:0.1];
      self.mapview.frame = mapviewFrame;
      self.paperFoldView.frame = paperFoldFrame;
      [UIView commitAnimations];
    }
    
  }
//  [self printFrames];
}

- (IBAction)buttonSlideMenuPressed:(id)sender {
  if (self.paperFoldView.state == PaperFoldStateLeftUnfolded)
    [self.paperFoldView setPaperFoldState:PaperFoldStateDefault animated:YES];
  else
    [self.paperFoldView setPaperFoldState:PaperFoldStateLeftUnfolded animated:YES];
}

- (IBAction)buttonSlideMapviewPressed {
  buttonTableview.hidden = NO;
  buttonMap.hidden = YES;
  [self.paperFoldView setPaperFoldState:PaperFoldStateRightUnfolded animated:YES];
}

- (IBAction)buttonSlideTableviewPressed {
  buttonTableview.hidden = YES;
  buttonMap.hidden = NO;
  [self.paperFoldView setPaperFoldState:PaperFoldStateDefault animated:YES];
}

#pragma mark popover delegate methods
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index {
  NSLog(@"item:%d", index);
  mapview.mapType = index;
  [popoverView dismiss];
}

#pragma facebook
- (void)updateAuthText:(NSString*)text {
  [arrayMenus replaceObjectAtIndex:1 withObject:text];
  
  NSArray *arrayIndexPaths = [[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], nil] autorelease];
  [self.tableviewMenu reloadRowsAtIndexPaths:arrayIndexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)printSession {
  DLog(@"appId: %@", FBSession.activeSession.appID);
  DLog(@"accessToken: %@", FBSession.activeSession.accessToken);
  DLog(@"expirationDate: %@", FBSession.activeSession.expirationDate);
}

- (void)checkSession {
  if (FBSession.activeSession.isOpen) {
    [self printSession];
    [self updateAuthText:@"Logout"];
  }
  else {
    // if the user previously logged in and the session is not yet open, ensure we login
    if(FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
      [self sessionLogin];
    else
      [self updateAuthText:@"Login"];
  }

}

- (void)authenticate {
  if (FBSession.activeSession.isOpen)
    [self sessionLogout];
  else
    [self sessionLogin];
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error {
  switch (state) {
    case FBSessionStateOpen:
      DLog(@"FBSessionStateOpen");
      [self printSession];
      [self getUser];

      if(IsStringWithAnyText(user.first_name)){
        NSString *message = [NSString stringWithFormat:@"Login Successful. Welcome %@!", user.first_name];
        [UBAlertView showAlertWithTitle:@"Info" message:message executeBlock:nil];
      }

      [self updateAuthText:@"Logout"];
      break;
    case FBSessionStateClosed:
      [self printSession];
      [self updateAuthText:@"Login"];
      [UBAlertView showAlertWithTitle:@"Info" message:@"You logged out." executeBlock:nil];
      DLog(@"FBSessionStateClosed");
      break;
    case FBSessionStateClosedLoginFailed:
      DLog(@"FBSessionStateClosedLoginFailed");
      [self updateAuthText:@"Login"];
      break;
    default:
      break;
  }
  
  if (error)
    [UBAlertView showAlertWithTitle:@"Error" message:error.localizedDescription executeBlock:nil];
}

- (void)sessionLogin {
  NSArray *permissions = [[NSArray alloc] initWithObjects:@"user_location", @"email", nil];
  
  [FBSession openActiveSessionWithReadPermissions:permissions
                                     allowLoginUI:YES
                                completionHandler: ^(FBSession *session, FBSessionState state, NSError *error) {
                                  [self sessionStateChanged:session state:state error:error];
                                }
  ];
}

- (void)sessionLogout {
  [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)getUser {
  if (FBSession.activeSession.isOpen){
    [FBRequestConnection startWithGraphPath:@"me" completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
      {
        if (!error) {
          NSLog(@"Result: %@", result);
          user.profile_id = [result objectForKey:@"id"];
          user.first_name = [result objectForKey:@"first_name"];
          user.last_name = [result objectForKey:@"last_name"];
          user.username = [result objectForKey:@"username"];
          user.email = [result objectForKey:@"email"];
          
          [user description];
          [self registerDeviceUser];

        } else {
          NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
  }
}

#pragma mark
#pragma mark APN 
- (void)updateAPNWithLocation {
  CLLocationCoordinate2D coord = [userAnnotation coordinate];
  DLog(@"coordinate: %f %f", coord.latitude, coord.longitude);
  
  NSMutableString *strURLDirty = [[NSMutableString alloc] init];
  [strURLDirty appendFormat:@"%@", HTTP_APN_REGISTER_URL];
  [strURLDirty appendFormat:@"&country_name=%@", [Country getName]];
  [strURLDirty appendFormat:@"&token=%@", user.device_token];
  [strURLDirty appendFormat:@"&latitude=%f&longitude=%f", coord.latitude, coord.longitude];
  
  [self startAPNHTTPRequest:strURLDirty];
  [strURLDirty release];
}

- (void)registerDeviceUser {
  NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"%@", HTTP_APN_REGISTER_URL];
  
  if(IsStringWithAnyText(user.device_token))
    [urlString appendFormat:@"&token=%@", user.device_token];

  if(IsStringWithAnyText(user.profile_id))
    [urlString appendFormat:@"&profile_id=%@", user.profile_id];
  
  if(IsStringWithAnyText(user.first_name))
    [urlString appendFormat:@"&first_name=%@", user.first_name];
  
  if(IsStringWithAnyText(user.last_name))
    [urlString appendFormat:@"&last_name=%@", user.last_name];

  if(IsStringWithAnyText(user.email))
    [urlString appendFormat:@"&email=%@", user.email];

  [self startAPNHTTPRequest:urlString];
  [urlString release];
}

- (void)startAPNHTTPRequest:(NSString*)urlString{
  DLog(@"urlString: %@", urlString);

  NSString *strURLClean = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURL *url = [NSURL URLWithString:strURLClean];
	
  ASIHTTPRequest* currentHTTPRequest = [ASIHTTPRequest requestWithURL:url];
  [currentHTTPRequest setDelegate:self];
  [currentHTTPRequest setDidFinishSelector:@selector(requestAPNRegisterFinished:)];
  [currentHTTPRequest setDidFailSelector:@selector(requestFailed:)];
  [currentHTTPRequest setTimeOutSeconds:HTTP_TIMEOUT];
  
  [currentHTTPRequest startAsynchronous];
}

- (void)requestAPNRegisterFinished:(ASIHTTPRequest *)request {
	DLog(@"");
  
  NSData *jsonData = [request responseData];
  id responseRoot = [jsonData objectFromJSONData];
  
  if([responseRoot isKindOfClass:[NSDictionary class]]) {
    DLog(@"message:%@", [responseRoot objectForKey:@"message"]);
  }
  else
    [UBAlertView showAlertWithTitle:@"Warning" message:MESSAGE_APPLICATION_ERROR executeBlock:nil];
}

- (void)reload{
  [self dismissAnyViewControllerPresent];
  [self initiateFeedHTTPRequest];
}

@end
