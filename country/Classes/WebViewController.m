//
//  WebViewController.m
//  Country
//
//  Created by rupert on 26/04/11.
//  Copyright 2011 2RMobile. All rights reserved.
//
#import "DebugLog.h"
#import "WebViewController.h"

@interface WebViewController(private)
- (void)openReferralURL:(NSURL *)referralURL;
@end

@implementation WebViewController

@synthesize webViewer, spinner, buttonAppStore, iTunesURL;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		progressAlert = nil;
		spinner = nil;
		urlStringAppStore = nil;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	buttonAppStore.hidden = YES;
	webViewer.accessibilityLabel = @"WebView";
	webViewer.hidden = YES;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	DebugLog(@"dealloc");
	[spinner release];
	[webViewer release];
	[buttonAppStore release];
	
	if(urlStringAppStore != nil){
		[urlStringAppStore release];
	}
	
    [super dealloc];
}

- (void)showAlert:(NSString *)message title:title{
	
	if( !isAlertMessageCurrentlyShown ){
		UIAlertView *errorAlertView = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[errorAlertView show];
		
		isAlertMessageCurrentlyShown = YES;
	}
	
}

- (IBAction)goBack{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)loadRequest:(NSString*)_urlString{
	DebugLog(@"urlString: %@", _urlString);
	NSString* urlStringClean = [[NSString alloc] initWithString:[_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	NSURL* _url = [NSURL URLWithString:urlStringClean];
	NSURLRequest *_request = [NSURLRequest requestWithURL:_url];
	webViewer.hidden = NO;
	[webViewer loadRequest:_request];
	[urlStringClean release];
}

- (void)setAppStoreURL:(NSString*)_urlStringAppStore{
	DebugLog(@"_urlStringAppStore: %@", _urlStringAppStore);
	if(urlStringAppStore != nil){
		[urlStringAppStore release];
	}

	urlStringAppStore = [_urlStringAppStore retain];
}

#pragma mark webview delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	
//	NSString* urlPath = [[request URL] path];

//	DebugLog(@"Started loading: %@", urlPath);
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
	DebugLog(@"Started loading");
	
	[spinner startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
	DebugLog(@"Finished loading");
	
	[spinner stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	DebugLog(@"Error found");
	
	[spinner stopAnimating];
}

#pragma mark appstore methods
- (IBAction)buttonAppStorePressed{
	NSURL *url = [NSURL URLWithString:urlStringAppStore];
	[self openReferralURL:url];
}

// Process a LinkShare/TradeDoubler/DGM URL to something iPhone can handle
- (void)openReferralURL:(NSURL *)referralURL{
	DebugLog(@"referralURL: %@", [referralURL standardizedURL]);
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:referralURL] delegate:self startImmediately:YES];
    [conn release];
}

// Save the most recent URL in case multiple redirects occur
// "iTunesURL" is an NSURL property in your class declaration
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    self.iTunesURL = [response URL];
	DebugLog(@"self.iTunesURL: %@", self.iTunesURL);
    return request;
}

// No more redirects; use the last URL saved
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[[UIApplication sharedApplication] openURL:self.iTunesURL];
}


@end
