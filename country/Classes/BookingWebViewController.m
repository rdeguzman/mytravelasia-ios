#import "BookingWebViewController.h"
#import "HelperDevice.h"

#define BUTTON_HEIGHT 25.0f

@interface BookingWebViewController()
- (void)showAlert:(NSString *)message title:title;
- (void)createCloseButton;
- (void)createWebView;
- (CGSize)sizeForDevice;
@end

@implementation BookingWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withURLString:(NSString*)_urlString
{
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
  {
    urlStringClean = [[NSString alloc] initWithString:[_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    isAlertMessageCurrentlyShown = NO;

    //This will set the User-Agent to Mobile
//    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Mobile", @"UserAgent", nil];
//    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
//    [dict release];
  }
  return self;
}

- (void)viewDidLoad
{
  DLog(@"begin"); 
  [super viewDidLoad];

  [self createCloseButton];
  [self createWebView];
}

- (void)viewWillAppear:(BOOL)animated
{
	DLog(@"begin"); 
	self.navigationController.wantsFullScreenLayout = YES;
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	[super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return [HelperDevice shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)dealloc
{
	DLog(@"dealloc");
	[urlStringClean release];
	[spinner release];
	[webViewer release];
	
  [super dealloc];
}

#pragma mark close button
- (void)createCloseButton
{
	DLog(@"begin");
	
	CGSize size = [self sizeForDevice];
	
	int buttonWidth = size.width;
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchDown];
	[button setTitle:@"Close" forState:UIControlStateNormal];
	
	button.frame = CGRectMake(0.0f, 0.0f, buttonWidth, BUTTON_HEIGHT);
	button.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
	
	[self.view addSubview:button];
	
	//Create a spinner on the top left
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	spinner.frame = CGRectMake(2.0f, 2.0f, 20.0f, 20.0f);
	spinner.hidesWhenStopped = YES;
	[self.view addSubview:spinner];
}

- (void)close
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIWebView
- (void)createWebView
{
	DLog(@"begin");
	NSURL* _url = [NSURL URLWithString:urlStringClean];
	NSURLRequest *_request = [NSURLRequest requestWithURL:_url];

	CGSize size = [self sizeForDevice];
	CGFloat width = size.width;
	CGFloat height = size.height - BUTTON_HEIGHT;
	int origin_y = BUTTON_HEIGHT;
	
	CGRect frame = CGRectMake(0.0f, origin_y, width, height);
	DLog(@"createWebView w:%f h:%f", width, height);
	webViewer = [[UIWebView alloc] initWithFrame:frame];
	webViewer.delegate = self;
	
	[webViewer setScalesPageToFit:YES];
	[webViewer loadRequest:_request];
	[self.view addSubview:webViewer];
	
	progressAlert = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark private methods
- (void)showAlert:(NSString *)message title:title
{
	
	if( !isAlertMessageCurrentlyShown )
  {
		UIAlertView *errorAlertView = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[errorAlertView show];
		
		isAlertMessageCurrentlyShown = YES;
	}
}

#pragma mark UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  NSString* urlPath = [[request URL] path];
  NSLog(@"http headers = %@", [request allHTTPHeaderFields]);
  NSLog(@"user agent = %@", [request valueForHTTPHeaderField: @"User-Agent"]);

  DLog(@"urlPath: %@", urlPath);
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//	DLog(@"begin");
	[spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//	DLog(@"begin");
	[spinner stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//	DLog(@"begin");
	[spinner stopAnimating];
}

- (CGSize)sizeForDevice
{
	//This will return the proper size of the screen for the device
	if([HelperDevice isDeviceAniPad])
		return CGSizeMake(1024.0f, 748.0f);
	else
		return self.view.bounds.size;
}

@end