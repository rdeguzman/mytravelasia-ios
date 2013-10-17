#import "PostCommentViewController.h"
#import "HelperDevice.h"
#import "UITableViewCellConstants.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "ApplicationConstants.h"
#import "UBAlertView.h"
#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@interface PostCommentViewController ()

@end

@implementation PostCommentViewController

RM_SYNTHESIZE(textview);
RM_SYNTHESIZE(poi_id);
RM_SYNTHESIZE(profile_id);
RM_SYNTHESIZE(buttonPost);
RM_SYNTHESIZE(delegate);
RM_SYNTHESIZE(comment_id);
RM_SYNTHESIZE(content);

- (void)dealloc {
  RM_RELEASE(textview);
  RM_RELEASE(poi_id);
  RM_RELEASE(profile_id);
  RM_RELEASE(buttonPost);
  RM_RELEASE(comment_id);
  RM_RELEASE(content);
  
  [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"New Comment";
  }
  return self;
}

- (void)loadView
{
  [super loadView];
  
  int contentWidth = 0;
  
  if([HelperDevice isDeviceAniPad])
    contentWidth = 540.0f - (PADDING_HORIZONTAL * 2);
  else
    contentWidth = self.view.bounds.size.width - (PADDING_HORIZONTAL * 2);
  
  self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
  
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
  
  if(self.comment_id != nil) {
    self.title = @"Edit Comment";
    textview_.text = self.content;

    buttonPost_ = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonEditPressed)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(buttonDeletePressed) forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Delete" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    button.layer.cornerRadius = 10;
    button.backgroundColor = [UIColor blackColor];
    button.frame = CGRectMake(PADDING_HORIZONTAL, 165.0f, contentWidth, 40.0f);
    [self.view addSubview:button];
  }
  else {
    buttonPost_ = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPostPressed)];
  }

  self.navigationItem.rightBarButtonItem = buttonPost_;
  
  UIBarButtonItem *buttonCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonCancelPressed)];
	self.navigationItem.leftBarButtonItem = buttonCancel;
  [buttonCancel release];

}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  DLog(@"poi_id: %@ profile_id: %@", self.poi_id, self.profile_id);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)buttonCancelPressed {
  [self.delegate dismissModalViewController];
}

- (void)buttonPostPressed {
  if(self.textview.text.length > 0)
    [self startNewRequest];
  else
    [UBAlertView showAlertWithTitle:@"Warning" message:@"Please add a comment before posting." executeBlock:nil];
}

- (void)buttonDeletePressed {
  UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Are you sure you want to delete this comment?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] autorelease];
  [alertView show];
}

- (void)buttonEditPressed {
  if([self.content isEqualToString:self.textview.text]){
    [UBAlertView showAlertWithTitle:@"Warning" message:@"Please change your comment before posting." executeBlock:nil];
  }
  else if(self.textview.text.length == 0)
    [UBAlertView showAlertWithTitle:@"Warning" message:@"Please add a comment before posting." executeBlock:nil];
  else
    [self startEditRequest];
}

- (void)startNewRequest {
  NSString *urlDirty = [NSString stringWithFormat:@"%@", HTTP_COMMENT_CREATE_URL];
	NSString *strURLClean = [urlDirty stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	DLog(@"strURLClean: %@", strURLClean);
  
	NSURL *url = [NSURL URLWithString:strURLClean];
  
  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
  [request setPostValue:self.poi_id forKey:@"poi_id"];
  [request setPostValue:self.profile_id forKey:@"profile_id"];
  [request setPostValue:self.textview.text forKey:@"content"];
  
  [self startRequest:request];
}

- (void)startDeleteRequest {
  NSString *urlDirty = [NSString stringWithFormat:@"%@/%@.json", HTTP_COMMENT_DELETE_URL, self.comment_id];
	NSString *strURLClean = [urlDirty stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	DLog(@"strURLClean: %@", strURLClean);
  
	NSURL *url = [NSURL URLWithString:strURLClean];

  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
  [request setRequestMethod:@"POST"];
  [request setPostValue:self.comment_id forKey:@"comment_id"];
  [request setPostValue:self.profile_id forKey:@"profile_id"];
  [request setPostValue:self.poi_id forKey:@"poi_id"];
  
  [self startRequest:request];
}

- (void)startEditRequest {
  DLog(@"%@", self.textview.text);
  
  NSString *urlDirty = [NSString stringWithFormat:@"%@/%@.json", HTTP_COMMENT_UPDATE_URL, self.comment_id];
	NSString *strURLClean = [urlDirty stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	DLog(@"strURLClean: %@", strURLClean);
  
	NSURL *url = [NSURL URLWithString:strURLClean];
  
  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
  [request setRequestMethod:@"PUT"];
  [request setPostValue:self.comment_id forKey:@"comment_id"];
  [request setPostValue:self.poi_id forKey:@"poi_id"];
  [request setPostValue:self.profile_id forKey:@"profile_id"];
  [request setPostValue:self.textview.text forKey:@"content"];

  [self startRequest:request];
}

- (void)startRequest:(ASIFormDataRequest *)request {
  [request setDelegate:self];
	[request setDidFinishSelector:@selector(requestFinished:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request setTimeOutSeconds:HTTP_TIMEOUT];
	
	[request startAsynchronous];
  
  [buttonPost_ setEnabled:NO];
  [SVProgressHUD showWithStatus:@"Please wait..."];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
  [SVProgressHUD dismiss];
  
  NSError *error = [request error];
  NSString *message = [error localizedDescription];
  
  if([error localizedDescription] == @"The request timed out")
    message = [NSString stringWithFormat:@"There is a network problem. (%@)", [error localizedDescription]];
  
  [UBAlertView showAlertWithTitle:@"Network Error" message:message executeBlock:nil];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	DLog(@"DetailsViewController.requestFinished");
  
  [SVProgressHUD dismiss];
  
  NSData *jsonData = [request responseData];
  id responseRoot = [jsonData objectFromJSONData];
  
  if([responseRoot isKindOfClass:[NSDictionary class]]) {
    if([[responseRoot objectForKey:@"valid"] boolValue]) {
      NSString *message = [NSString stringWithFormat:@"%@", [responseRoot objectForKey:@"message"]];
      [UBAlertView showAlertWithTitle:@"Info" message:message executeBlock:^(void){
        [self.delegate reload];
      }];
    }
    else
      [UBAlertView showAlertWithTitle:@"Warning" message:[responseRoot objectForKey:@"message"] executeBlock:nil];
  }
  else
    [UBAlertView showAlertWithTitle:@"Error" message:MESSAGE_APPLICATION_ERROR executeBlock:nil];
  
  [buttonPost_ setEnabled:YES];
}

#pragma mark alertview delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	DLog(@"buttonIndex: %d", buttonIndex);
  if(buttonIndex == 1){
    [self startDeleteRequest];
  }
}

@end
