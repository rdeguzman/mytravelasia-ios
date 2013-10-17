#import "TextViewController.h"
#import "HelperDevice.h"
#import "UITableViewCellConstants.h"
#import <QuartzCore/QuartzCore.h>

@implementation TextViewController

RM_SYNTHESIZE(textview);
RM_SYNTHESIZE(delegate);

- (void)dealloc
{
  RM_RELEASE(textview);
  [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Comment";
  }
  return self;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
  [super loadView];

  int contentWidth = 0;

  if([HelperDevice isDeviceAniPad])
    contentWidth = 540.0f - (PADDING_HORIZONTAL * 2);
  else
  {
    contentWidth = self.view.bounds.size.width - (PADDING_HORIZONTAL * 2);
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
  }

  DLog(@"contentWidth:%d", contentWidth);

  textview_ = [[UITextView alloc] initWithFrame:CGRectMake(PADDING_HORIZONTAL, 5.0f, contentWidth, 150.0f)];
  DLog(@"textview width: %f height: %f", self.textview.frame.size.width, self.textview.frame.size.height);

  textview_.textAlignment = UITextAlignmentLeft;
  textview_.font = [UIFont systemFontOfSize:12.0f];
  textview_.backgroundColor = [UIColor whiteColor];
  textview_.backgroundColor = [UIColor whiteColor];
  textview_.editable = YES;
  textview_.scrollEnabled = YES;
  textview_.dataDetectorTypes = UIDataDetectorTypeAll;
  textview_.layer.cornerRadius = 10;
  textview_.clipsToBounds = YES;

  [self.view addSubview:textview_];    
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonDonePressed:)];
	self.navigationItem.rightBarButtonItem = buttonDone;
  [buttonDone release];
  
  [self.navigationItem setHidesBackButton:YES animated:YES];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return [HelperDevice shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)buttonDonePressed:(id)sender
{
  DLog(@"");
  [self.delegate didFinishTextViewWithComment:self.textview.text];
}

@end
