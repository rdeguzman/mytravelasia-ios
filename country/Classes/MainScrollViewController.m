#import "ASIHTTPRequest.h"
#import "JSONKit.h"

#import "ApplicationConstants.h"
#import "Country.h"

#import "HelperDevice.h"
#import "HelperLogUtils.h"

#import "MainScrollViewController.h"
#import "SearchViewController.h"
#import "MapListViewController.h"
#import "WebViewController.h"

#import "NSString+Utilities.h"
#import "UBAlertView.h"
#import "UIImageView+AFNetworking.h"

#import "DetailsViewController.h"

#define MAIN_VIEW_BUTTONS_ORIGIN_Y	300.0f
#define METTALIC_HEIGHT	20.0f

@interface MainScrollViewController(private)
- (void)doMobileUpdate;
- (void)startAnimating;
- (void)stopAnimating;
- (void)moveCoverViewOffScreen;
- (void)createSearchDictionary:(NSDictionary*)_responseRoot;
- (void)createButtons:(NSArray*)_arrayButtons;
- (void)startMobileUpdatesHTTPRequest:(NSString *)urlDirty;
- (void)showWebViewController:(NSString*)urlString;
- (void)addMetallicBackground;
- (void)showAppStoreWebViewController:(NSString*)urlString withAppStoreURL:(NSString*)urlStringAppStore;
- (void)buttonPressed:(id)sender;
@end

@implementation MainScrollViewController

@synthesize arrayCategories, arrayButtons, arrayAds;
@synthesize scrollview, spinner, coverView, buttonTopLink;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

  if(self) {
    arrayCategories = nil;
    arrayButtons = nil;
    arrayAds = nil;
    modelSearch = nil;
    webController = nil;
    frontPageURL = nil;
  }

  return self;
}

- (void)dealloc {
	DLog(@"dealloc");
	[arrayCategories release];
  [arrayButtons release];
	[modelSearch release];
  [arrayAds release];
	[coverView release];
  [frontPageURL release];
	
	if(webController != nil)
		[webController release];
  
  if(frontPageURL != nil)
    [frontPageURL release];
	
	[scrollview release];
	[spinner release];
  [buttonTopLink release];

  [super dealloc];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	DLog(@"");
  [super viewDidUnload];
  [arrayCategories release], arrayCategories = nil;
  [arrayButtons release], arrayButtons = nil;
  [arrayAds release], arrayAds = nil;
  [webController release], webController = nil;
}

- (void)viewDidLoad {
	DLog(@"");
	[super viewDidLoad];
	
	if([HelperDevice isDeviceAniPad] && webController == nil) {
		DLog(@"Adding WebViewController for iPad");
		webController = [[WebViewController alloc] initWithNibName:[HelperDevice nibNameForDevice:@"WebViewController"] bundle:nil];
		webController.view.frame = CGRectMake(320.0f, 0, 704.0f, 748.0f);
		[self.view addSubview:webController.view];
	}

	if(arrayCategories ==  nil)
		arrayCategories = [[NSMutableArray alloc] initWithObjects:nil];
	
	if(arrayButtons ==  nil)
		arrayButtons = [[NSMutableArray alloc] initWithObjects:nil];

	if(modelSearch == nil)
		modelSearch = [[SearchItemsModel alloc] init];
  
  if(arrayAds == nil){
    arrayAds = [[NSMutableArray alloc] initWithObjects:nil];
  }
	
	currentOriginY = MAIN_VIEW_BUTTONS_ORIGIN_Y;
	bottomPadding = METTALIC_HEIGHT;
  webviewHeight = ADSENSE_HEIGHT;
  
	[self.scrollview setClipsToBounds:NO];
	self.scrollview.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	[self.scrollview setContentSize:CGSizeMake(320.0f, 480.0f)];
	[self.scrollview setScrollEnabled:YES];
  
  [self.buttonTopLink setHidden:true];
	
	[self doMobileUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
	DLog(@"begin");
	
	self.navigationController.wantsFullScreenLayout = YES;
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	[super viewWillAppear:animated];
}

- (void)startAnimating {
	DLog(@"begin");
	[spinner startAnimating];
}

- (void)stopAnimating {
	[spinner stopAnimating];
}

- (void)moveCoverViewOffScreen {
	DLog(@"begin");
  [self.scrollview setContentSize:CGSizeMake(320.0f, currentOriginY + bottomPadding)];
  [self.scrollview setNeedsLayout];

  CGRect newFrame = coverView.frame;
  newFrame.origin.y = self.scrollview.bounds.size.height;

  [UIView beginAnimations:@"moveCoverViewOffScreen" context:NULL];
  [UIView setAnimationDuration:0.5];
  coverView.frame = newFrame;
  [self.buttonTopLink setHidden:false];
  [UIView commitAnimations];
  
  [self registerAPN];
}

- (void)addMetallicBackground {
	UIImageView* mettalicView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mettalic_bg.png"]];
	mettalicView.frame = CGRectMake(0.0f, currentOriginY, self.scrollview.frame.size.width, METTALIC_HEIGHT);
  currentOriginY = currentOriginY + METTALIC_HEIGHT;

	[self.scrollview addSubview:mettalicView];
	[mettalicView release];
}

- (void)doMobileUpdate {
  NSString *urlString = [NSString stringWithFormat:@"%@&country_name=%@", HTTP_MOBILEUPDATES_URL, [Country getName]];
	DLog(@"%@", urlString);
    
	[self startMobileUpdatesHTTPRequest:urlString];
	[self startAnimating];
}

#pragma mark
#pragma mark -- HTTP Request Methods
- (void)startMobileUpdatesHTTPRequest:(NSString *)urlDirty {
	NSString *strURLClean = [urlDirty stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:strURLClean];
	
	ASIHTTPRequest* currentHTTPRequest = [ASIHTTPRequest requestWithURL:url];
	[currentHTTPRequest setDelegate:self];
	[currentHTTPRequest setDidFinishSelector:@selector(requestMobileUpdatesFinished:)];
	[currentHTTPRequest setDidFailSelector:@selector(requestFailed:)];
	[currentHTTPRequest setTimeOutSeconds:HTTP_TIMEOUT];
	
	[currentHTTPRequest startAsynchronous];
	DLog(@"urlDirty: %@", urlDirty);
}

- (void)requestMobileUpdatesFinished:(ASIHTTPRequest *)request {
	DLog(@"");

  NSData *jsonData = [request responseData];
  id responseRoot = [jsonData objectFromJSONData];

  if([responseRoot isKindOfClass:[NSDictionary class]])
  {
    webviewHeight = [[responseRoot objectForKey:@"webview_height"] floatValue];
		[self createSearchDictionary:responseRoot];

		for(NSDictionary* button in (NSArray*)[responseRoot objectForKey:@"categories"])
			[arrayCategories addObject:button];

		//buttons
		for(NSDictionary* button in (NSArray*)[responseRoot objectForKey:@"buttons"])
			[arrayButtons addObject:button];

    [self createButtons:arrayButtons];
    
    //ads
    for(NSDictionary* ad in (NSArray*)[responseRoot objectForKey:@"ads"])
      [arrayAds addObject:ad];

    [self createAds:arrayAds];

    frontPageURL = [[NSString alloc] initWithFormat:@"%@", [responseRoot objectForKey:@"front_page"]];

    if([HelperDevice isDeviceAniPad]) {
      [self showWebViewController:frontPageURL];
    }
  }
  else
    [UBAlertView showAlertWithTitle:@"Error" message:MESSAGE_APPLICATION_ERROR executeBlock:nil];

	[self stopAnimating];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSString *message = [error localizedDescription];
	
	if( [error localizedDescription] == @"The request timed out" ){
		message = [NSString stringWithFormat:@"%@ (%@)", MESSAGE_NETWORK_ERROR, [error localizedDescription]];
	}
	
	[UBAlertView showAlertWithTitle:@"Error" message:message executeBlock:nil];

	[self stopAnimating];
}

#pragma mark model methods
- (void)createSearchDictionary:(NSDictionary*)_responseRoot{
	DLog(@"begin");
	
	[modelSearch setTopDestinations:[_responseRoot objectForKey:@"top_destinations"]];
	[modelSearch setDestinations:[_responseRoot objectForKey:@"destinations"]];
}

- (void)createButtons:(NSArray*)_arrayButtons {
	DLog(@"arrayButtons count: %d", [_arrayButtons count]);
  if([_arrayButtons count] > 0)
    [self addMetallicBackground];

	CGFloat buttonWidth = self.scrollview.frame.size.width;
	CGFloat buttonHeight = 44.0f;
	
	UIFont* buttonFont = [UIFont boldSystemFontOfSize:14.0f];
	
	UIImage* buttonImage = [UIImage imageNamed:@"button_black_gr.png"];
	
	for(int i=0;i < _arrayButtons.count; i++) {
		NSDictionary* description = (NSDictionary*)[_arrayButtons objectAtIndex:i];
		NSString* title = [description objectForKey:@"title"];
		
		UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(0.0f, currentOriginY, buttonWidth, buttonHeight);
		[button setBackgroundImage:buttonImage forState:UIControlStateNormal];
		
		[button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
		[button setTitle:title forState:UIControlStateNormal];
		[button setTag:i];
		
		button.titleLabel.font = buttonFont;
		button.titleLabel.textAlignment = UITextAlignmentRight;
		
		[self.scrollview addSubview:button];
		
		currentOriginY = currentOriginY + buttonHeight;
	}
  
//  [self createAdsense];
//  
//  [self moveCoverViewOffScreen];
}

- (void)createAds:(NSArray*)_arrayAds
{
  DLog(@"arrayAds count: %d", [_arrayAds count]);
  [self addMetallicBackground];

  for(int i=0;i < _arrayAds.count; i++) {
    NSDictionary* ad = (NSDictionary*)[_arrayAds objectAtIndex:i];

    CGFloat adHeight = [[ad objectForKey:@"height"] floatValue];
    CGFloat adWidth = [[ad objectForKey:@"width"] floatValue];

    DLog(@"poi_id: %@", [ad objectForKey:@"poi_id"]);
    DLog(@"image_link: %@", [ad objectForKey:@"image_link"]);
    DLog(@"height: %f", adHeight);

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, currentOriginY, adWidth, adHeight)];
    [imageView setImageWithURL:[NSURL URLWithString:[ad objectForKey:@"image_link"]]
              placeholderImage:[UIImage imageNamed:@"loading_ad.png"]];
    [self.scrollview addSubview:imageView];
    [imageView release];

    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0f, currentOriginY, adWidth, adHeight);
    button.backgroundColor = [UIColor clearColor];
    [button setTag:[[ad objectForKey:@"poi_id"] intValue]];
    [button addTarget:self action:@selector(buttonAdPressed:) forControlEvents:UIControlEventTouchDown];
    [self.scrollview addSubview:button];

    currentOriginY = currentOriginY + adHeight;
  }

  [self createAdsense];

  [self moveCoverViewOffScreen];
}

#pragma mark
#pragma mark Button Pressed Methods
- (void)buttonPressed:(id)sender {
	DLog(@"begin");

	UIButton* button = (UIButton*)sender;
	NSDictionary* description = (NSDictionary*)[arrayButtons objectAtIndex:button.tag];
	NSString* urlString = [description objectForKey:@"path"];
	[self showWebViewController:urlString];
}

- (void)buttonAdPressed:(id)sender {
  int poi_id = [sender tag];

  DLog(@"button.tag %d", poi_id);
  DetailsViewController *detailsVC = [[DetailsViewController alloc] initWithStyle:UITableViewStylePlain withPrimaryKey:poi_id];
  [detailsVC setSearchModel:modelSearch];

  [self.navigationController pushViewController:detailsVC animated:YES];
  [detailsVC release];
}

- (void)showWebViewController:(NSString*)urlString
{
	if([HelperDevice isDeviceAniPad])
		[webController loadRequest:urlString];
	else {
    DLog(@"%@", urlString);
		WebViewController *webview = [[WebViewController alloc] initWithNibName:[HelperDevice nibNameForDevice:@"WebViewController"] bundle:nil];

		[self.navigationController pushViewController:webview animated:YES];
		[webview loadRequest:urlString];

		[webview release];	
	}
}

#pragma mark
#pragma mark Interface Button Methods
-(IBAction)buttonNearbyPressed:(id)sender {
	DLog(@"begin");
	MapListViewController *mapListView = [[MapListViewController alloc] initWithNibName:[HelperDevice nibNameForDevice:@"MapListViewController"] bundle:nil withMenus:arrayCategories];
	
	[mapListView setSearchModel:modelSearch];
	
	[self.navigationController pushViewController:mapListView animated:YES];
	[mapListView nearby];
	
	[mapListView release];
}

- (IBAction)buttonTopLinkPressed:(id)sender{
  [self showWebViewController:frontPageURL];
}

#pragma mark orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return [HelperDevice shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark
#pragma mark Google Adsense
- (void)createAdsense {
  DLog(@"");
  [self addMetallicBackground];
  
  CGRect adsenseFrame = CGRectMake(0.0f, currentOriginY, self.scrollview.frame.size.width, webviewHeight);
  UIWebView *webView = [[UIWebView alloc] initWithFrame:adsenseFrame];
  webView.delegate = self;
  [self.scrollview addSubview:webView];

  NSString *urlAddress = HTTP_ADSENSE_URL;
  NSURL *url = [NSURL URLWithString:urlAddress];
  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
  [webView loadRequest:requestObj];

  currentOriginY = currentOriginY + webviewHeight;
  [webView release];
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
  DLog(@"");
  if ( inType == UIWebViewNavigationTypeLinkClicked ) {
    [[UIApplication sharedApplication] openURL:[inRequest URL]];
    return NO;
  }
  else
    return YES;
}

#pragma mark
#pragma mark APN
- (void)registerAPN {
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes :(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound )];
}


@end