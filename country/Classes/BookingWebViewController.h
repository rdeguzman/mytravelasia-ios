#import <UIKit/UIKit.h>

@interface BookingWebViewController : UIViewController<UIWebViewDelegate, UIAlertViewDelegate>
{
	UIWebView *webViewer;
	
	BOOL isAlertMessageCurrentlyShown;
	
	UIAlertView *progressAlert;
	
	NSString *urlStringClean;

	UIActivityIndicatorView* spinner;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withURLString:(NSString*)_urlString;

@end
