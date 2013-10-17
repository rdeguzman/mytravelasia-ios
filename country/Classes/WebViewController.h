//
//  WebViewController.h
//  Country
//
//  Created by rupert on 26/04/11.
//  Copyright 2011 2RMobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController {
	IBOutlet UIWebView* webViewer;

	BOOL isAlertMessageCurrentlyShown;
	
	UIAlertView *progressAlert;
	
	IBOutlet UIActivityIndicatorView *spinner;
	
	IBOutlet UIButton *buttonAppStore;
	NSURL *iTunesURL;
	NSString *urlStringAppStore;
}

@property(nonatomic, retain) IBOutlet UIWebView* webViewer;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic, retain) IBOutlet UIButton* buttonAppStore;
@property(nonatomic, retain) NSURL* iTunesURL;

- (IBAction)goBack;
- (IBAction)buttonAppStorePressed;
	
- (void)loadRequest:(NSString*)_urlString;

- (void)setAppStoreURL:(NSString*)_urlStringAppStore;

@end
