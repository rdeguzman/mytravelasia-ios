#import "DetailsViewController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "ApplicationConstants.h"
#import "UITableViewCellConstants.h"
#import "UBAlertView.h"
#import "HelperFileUtils.h"
#import "HelperText.h"
#import "HelperDevice.h"
#import "CarouselImageCell.h"
#import "NameAddressCell.h"
#import "DescriptionCell.h"
#import "ClickableDescriptionCell.h"
#import "PriceCell.h"
#import "RatingCell.h"
#import "LikeCell.h"
#import "CommentCell.h"
#import "BookingWebViewController.h"
#import "BookingEnquiryTableViewController.h"
#import "PostCommentViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface DetailsViewController()
- (void)startHTTPRequest;
- (void)initPoiModel:(NSDictionary*)_poi;
- (void)createRows;
- (void)showBookingWebViewController:(NSString*)urlString;
- (void)showBookingEnquiry;
- (void)showEmailComposer;
@end

@implementation DetailsViewController

@synthesize delegate;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style withPoiModel:(PoiAnnotation *)_poiAnnotation {
  self = [super initWithStyle:style];
  if (self) {
		self.title = @"mytravel-asia.com";
    user = [User sharedInstance];
		
		int primaryKey = [_poiAnnotation primaryKey];
		int index = [_poiAnnotation index];
		
		poiModel = [[PoiAnnotation alloc] initWithPrimaryKey:primaryKey withIndex:index];
		poiModel.name = _poiAnnotation.name;
		poiModel.address = _poiAnnotation.address;
		poiModel.poitype = _poiAnnotation.poitype;
		poiModel.distance = _poiAnnotation.distance;
		poiModel.total_stars = _poiAnnotation.total_stars;
		poiModel.total_ratings = _poiAnnotation.total_ratings;
		poiModel.min_rate = _poiAnnotation.min_rate;
		[poiModel setCoordinate:_poiAnnotation.coordinate];
		
		pictures = [[NSArray alloc] init];
		
		arrayCells = [[NSMutableArray alloc] initWithObjects:nil];
		arrayCellIdentifiers = [[NSMutableArray alloc] initWithObjects:nil];
    
    fitEntireScreen = NO;
  }
  return self;
}

- (id)initWithStyle:(UITableViewStyle)style withPrimaryKey:(int)_pk{
  self = [super initWithStyle:style];
  if (self) {
    self.title = @"mytravel-asia.com";
    user = [User sharedInstance];
    
    int primaryKey = _pk;
    
    poiModel = [[PoiAnnotation alloc] initWithPrimaryKey:primaryKey withIndex:_pk];
    pictures = [[NSArray alloc] init];
    
    arrayCells = [[NSMutableArray alloc] initWithObjects:nil];
    arrayCellIdentifiers = [[NSMutableArray alloc] initWithObjects:nil];
    
    fitEntireScreen = YES;
  }
  return self;
}

- (void)setSearchModel:(SearchItemsModel*)_model {
	modelSearch = _model;
}

- (void)dealloc {
	[arrayCells release];
	[arrayCellIdentifiers release];
	[poiModel release];
	[pictures release];
	
  [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
	self.tableView.alpha = 0;
	self.tableView.backgroundColor = UITABLEVIEWCELL_LIGHTER_BACKGROUND;
	
  [self startHTTPRequest];
  [super viewDidLoad];

  if([HelperDevice isDeviceAniPad])
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 680.0f);

  UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
  self.navigationItem.backBarButtonItem = backButton;
  [backButton release];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:NO animated:YES];
  [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return [HelperDevice shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark
#pragma mark HTTP methods
- (void)startHTTPRequest {
	NSString *urlDirty = [NSString stringWithFormat:@"%@/%d?format=json", HTTP_POI_URL, poiModel.primaryKey];

  if(IsStringWithAnyText(user.profile_id))
    urlDirty = [urlDirty stringByAppendingFormat:@"&profile_id=%@", user.profile_id];
  
	NSString *strURLClean = [urlDirty stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *url = [NSURL URLWithString:strURLClean];	
	ASIHTTPRequest *currentHTTPRequest = [ASIHTTPRequest requestWithURL:url];
	[currentHTTPRequest setDelegate:self];
	[currentHTTPRequest setDidFinishSelector:@selector(requestFinished:)];
	[currentHTTPRequest setDidFailSelector:@selector(requestFailed:)];
	[currentHTTPRequest setTimeOutSeconds:HTTP_TIMEOUT];
	
	[currentHTTPRequest startAsynchronous];
	DLog(@"urlDirty:%@", urlDirty);
}

- (void)requestFailed:(ASIHTTPRequest *)request {
  NSError *error = [request error];
  NSString *message = [error localizedDescription];

  if([error localizedDescription] == @"The request timed out")
    message = [NSString stringWithFormat:@"There is a network problem. (%@)", [error localizedDescription]];

  [UBAlertView showAlertWithTitle:@"Network Error" message:message executeBlock:nil];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	DLog(@"DetailsViewController.requestFinished");
  NSData *jsonData = [request responseData];
  id responseRoot = [jsonData objectFromJSONData];

  if([responseRoot isKindOfClass:[NSDictionary class]]) {
		NSDictionary *poiRoot = (NSDictionary *)[responseRoot objectForKey:@"poi"];
		
		[self initPoiModel:[poiRoot objectForKey:@"poi"]];
		
		NSArray *_pictures = (NSArray *)[responseRoot objectForKey:@"pictures"];
		DLog(@"pictures count: %d", [_pictures count]);
		
		if( [_pictures count] > 0) {
			[pictures release];
			pictures = [[NSArray alloc] initWithArray:_pictures];
			DLog(@"pictures released and allocated");
		}
		else
			DLog(@"NO pictures found");
		
		[self createRows];
  }
  else
    [UBAlertView showAlertWithTitle:@"Error" message:MESSAGE_APPLICATION_ERROR executeBlock:nil];
}

- (void)initPoiModel:(NSDictionary*)_poi{
  poiModel.name = [_poi objectForKey:@"name"];
  poiModel.address = [_poi objectForKey:@"full_address"];
  poiModel.poitype = [_poi objectForKey:@"poi_type_name"];

  poiModel.distance = [_poi objectForKey:@"distance"];
  poiModel.total_stars = [_poi objectForKey:@"total_stars"];
  poiModel.total_ratings = [_poi objectForKey:@"total_ratings"];
  poiModel.min_rate = [_poi objectForKey:@"min_rate"];
	
  poiModel.picture_full_path = [_poi objectForKey:@"picture_full_path"];
	[poiModel setDescription:[_poi objectForKey:@"description"]];
	[poiModel setTelephone:[_poi objectForKey:@"tel_no"]];
	[poiModel setWebsite:[_poi objectForKey:@"web_url"]];
	[poiModel setEmail:[_poi objectForKey:@"email"]];
	
  if([[_poi objectForKey:@"partners"] isKindOfClass:[NSArray class]]) {
    NSArray *partners_ = (NSArray *)[_poi objectForKey:@"partners"];
    poiModel.partners = [[[NSArray alloc] initWithArray:partners_] autorelease];
    
    NSArray *rooms_ = (NSArray *)[_poi objectForKey:@"rooms"];
    poiModel.rooms = [[[NSArray alloc] initWithArray:rooms_] autorelease];
  }

  poiModel.comments = [[[NSArray alloc] initWithArray:[_poi objectForKey:@"comment_entries"]] autorelease];

  poiModel.bookable = [[_poi objectForKey:@"bookable"] boolValue];
  poiModel.liked = [[_poi objectForKey:@"liked"] boolValue];
  poiModel.total_likes = [_poi objectForKey:@"total_likes"];
  poiModel.total_comments = [_poi objectForKey:@"total_comments"];
}

- (void)createRows {
	DLog(@"begin");

  [arrayCells removeAllObjects];
  [arrayCellIdentifiers removeAllObjects];
  
  UITableViewCell* cell = nil;
  
  int contentWidth = 0;
  
  if(fitEntireScreen && ![HelperDevice isDeviceAniPhone]){
    contentWidth = [[UIScreen mainScreen] bounds].size.height;
    DLog(@"%d", contentWidth);
  }
	
  int totalImages = (int)[pictures count];
  
	if (totalImages > 0) {
		cell = [[CarouselImageCell alloc] initWithArray:pictures reuseIdentifier:@"Image" contentWidth:contentWidth];
		[arrayCells addObject:cell];
		[arrayCellIdentifiers addObject:@"Image"];
		[cell release];
	}
	
	cell = [[NameAddressCell alloc] initWithName:poiModel.name
                               initWithAddress:poiModel.address
                               reuseIdentifier:@"NameAddress"
                                  contentWidth:contentWidth];
	[arrayCells addObject:cell];
	[arrayCellIdentifiers addObject:@"NameAddress"];
	[cell release];
	
  int total_comments = [poiModel.total_comments intValue];
  int total_likes = [poiModel.total_likes intValue];
  
	cell = [[LikeCell alloc] initWithNumberOfComments:total_comments
                                      numberOfLikes:total_likes
                                    reuseIdentifier:@"Likes"
                                       contentWidth:contentWidth];
  cell.accessoryType = [poiModel isLiked] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	[arrayCells addObject:cell];
	[arrayCellIdentifiers addObject:@"Likes"];
	[cell release];
	
	if([poiModel hasDistance]) {
		cell = [[ClickableDescriptionCell alloc] initWithTitle:@"Distance"
                                           initWithContent:poiModel.distance
                                           reuseIdentifier:@"Distance"
                                              contentWidth:contentWidth];
		[arrayCells addObject:cell];
		[arrayCellIdentifiers addObject:@"Distance"];
		[cell release];
	}
	
	cell = [[ClickableDescriptionCell alloc] initWithTitle:@"Telephone"
                                         initWithContent:poiModel.telephone
                                         reuseIdentifier:@"Telephone"
                                            contentWidth:contentWidth];
	[arrayCells addObject:cell];
	[arrayCellIdentifiers addObject:@"Telephone"];
	[cell release];
	
	cell = [[ClickableDescriptionCell alloc] initWithTitle:@"Website"
                                         initWithContent:poiModel.website
                                         reuseIdentifier:@"Website"
                                            contentWidth:contentWidth];
	[arrayCells addObject:cell];
	[arrayCellIdentifiers addObject:@"Website"];
	[cell release];
	
	cell = [[ClickableDescriptionCell alloc] initWithTitle:@"Email"
                                         initWithContent:poiModel.email
                                         reuseIdentifier:@"Email"
                                            contentWidth:contentWidth];
	[arrayCells addObject:cell];
	[arrayCellIdentifiers addObject:@"Email"];
	[cell release];
	
	cell = [[DescriptionCell alloc] initWithTitle:@"Description"
                                initWithContent:poiModel.description
                                reuseIdentifier:@"Description"
                                   contentWidth:contentWidth];
	[arrayCells addObject:cell];
	[arrayCellIdentifiers addObject:@"Description"];
	[cell release];
  
  if([poiModel hasPartners]) {
    
    for (int i = 0; i < [poiModel.partners count]; i++)
    {
      NSDictionary *partner = [poiModel.partners objectAtIndex:i];
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Booking Partner"];
      cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14.0f];
      cell.detailTextLabel.text = [NSString stringWithFormat:@"Check Rates on %@", [partner objectForKey:@"name"]];
      cell.detailTextLabel.textAlignment = UITextAlignmentRight;
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      cell.tag = i;
      [arrayCells addObject:cell];
      [arrayCellIdentifiers addObject:@"Booking Partner"];
      [cell release];
    }
    
    if([poiModel hasRooms]) {
      
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"IndicativeRates"];
      cell.textLabel.text = @"Warning: The rates below are indicative only.";
      cell.detailTextLabel.text = @"To get the current rates, click on the provider link.";
      cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0f];
      cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0f];
      cell.textLabel.textColor = DARKER_GRAY_COLOR;
      cell.detailTextLabel.textColor = DARKER_GRAY_COLOR;
      cell.accessoryType = UITableViewCellAccessoryNone;
      [arrayCells addObject:cell];
      [arrayCellIdentifiers addObject:@"IndicativeRates"];
      [cell release];
      
      for (int i = 0; i < [poiModel.rooms count]; i++)
      {
        NSDictionary *partner = [poiModel.rooms objectAtIndex:i];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Room"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@", [partner objectForKey:@"currency_code"], [partner objectForKey:@"rate"], [partner objectForKey:@"partner"]];
        cell.textLabel.textColor = PINK_PASTEL_COLOR;
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ as of %@", [partner objectForKey:@"room_type"], [partner objectForKey:@"date_from"]];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.textColor = DARK_GRAY_COLOR;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.tag = i;
        [arrayCells addObject:cell];
        [arrayCellIdentifiers addObject:@"Room"];
        [cell release];
      }
      
    }
    
  }
  
  if([poiModel isBookable]) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Booking Enquiry"];
    cell.textLabel.textColor = BLUE_DARKER_COLOR;

    cell.imageView.image = [UIImage imageNamed:@"button_calendar.png"];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    cell.textLabel.text = @"Need Booking Assistance";
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    cell.detailTextLabel.text = @"Specify your dates and notifies the provider.";
    cell.detailTextLabel.textColor = DARKER_GRAY_COLOR;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [arrayCells addObject:cell];
    [arrayCellIdentifiers addObject:@"Booking Enquiry"];
    [cell release];
  }
  
	cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Add to Favorites"];
  cell.textLabel.textColor = BLUE_DARKER_COLOR;
  cell.imageView.image = [UIImage imageNamed:@"button_star.png"];
  cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
  cell.textLabel.text = @"Add to Favorites";
  cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
  cell.detailTextLabel.text = @"Go to Search and select entry from Favorites.";
  cell.detailTextLabel.textColor = DARKER_GRAY_COLOR;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[arrayCells addObject:cell];
	[arrayCellIdentifiers addObject:@"Add to Favorites"];
	[cell release];
	
	cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Email to a Friend"];
  cell.textLabel.textColor = BLUE_DARKER_COLOR;
  cell.imageView.image = [UIImage imageNamed:@"button_email.png"];
  cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
  cell.textLabel.text = @"Email to a Friend";
  cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
  cell.detailTextLabel.text = @"Composes a mail with the description and link.";
  cell.detailTextLabel.textColor = DARKER_GRAY_COLOR;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[arrayCells addObject:cell];
	[arrayCellIdentifiers addObject:@"Email to a Friend"];
	[cell release];
  
  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Post a Comment"];
  cell.textLabel.textColor = BLUE_DARKER_COLOR;
  cell.imageView.image = [UIImage imageNamed:@"button_comment.png"];
  cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
  cell.textLabel.text = @"Post a Comment";
  cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0f];
  cell.detailTextLabel.text = @"Need advice? Ask away and interact with others.";
  cell.detailTextLabel.textColor = DARKER_GRAY_COLOR;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[arrayCells addObject:cell];
	[arrayCellIdentifiers addObject:@"Post a Comment"];
	[cell release];
  
  if([poiModel hasComments]) {
    for (int i = 0; i < [poiModel.comments count]; i++){
      NSString *reuseIdentifier = [NSString stringWithFormat:@"comment_%d", i];
      NSDictionary *comment = [poiModel.comments objectAtIndex:i];
      NSString *name = [NSString stringWithFormat:@"%@", [comment objectForKey:@"name"]];
      NSString *content = [NSString stringWithFormat:@"%@", [comment objectForKey:@"content"]];
      NSString *profile_id = [NSString stringWithFormat:@"%@", [comment objectForKey:@"profile_id"]];
      NSString *age = [NSString stringWithFormat:@"%@", [comment objectForKey:@"age"]];
      DLog(@"name: %@ content: %@", name, content);
      
      cell = [[CommentCell alloc] initWithName:name initWithContent:content profileId:profile_id timePosted:age reuseIdentifier:reuseIdentifier];
      
      if([profile_id isEqualToString:user.profile_id])
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      
      [arrayCells addObject:cell];
      [arrayCellIdentifiers addObject:@"Comment"];
      [cell release];
    }
  }
  
	[self.tableView reloadData];
	
	[UIView beginAnimations:@"fadeTableView" context:NULL];
	[UIView setAnimationDuration:0.5];
	self.tableView.alpha = 1;
	[UIView commitAnimations];

	DLog(@"end");
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return arrayCells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat _height = 44.0f;
	
	if( indexPath.row < [arrayCells count]) {
		UITableViewCell* cell = [arrayCells objectAtIndex:indexPath.row];
		_height = cell.contentView.frame.size.height;
	}
  
//  DLog(@"%d %f", indexPath.row, _height);
	return _height;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* CellIdentifier = [arrayCellIdentifiers objectAtIndex:indexPath.row];
	
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil)
		cell = [arrayCells objectAtIndex:indexPath.row];

	return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString* cellIdentifier = [arrayCellIdentifiers objectAtIndex:indexPath.row];
  if([cellIdentifier isEqualToString:@"Likes"] ||
     [cellIdentifier isEqualToString:@"Booking Enquiry"] ||
     [cellIdentifier isEqualToString:@"Add to Favorites"] ||
     [cellIdentifier isEqualToString:@"Email to a Friend"] ||
     [cellIdentifier isEqualToString:@"Post a Comment"]) {
    cell.backgroundColor = UITABLEVIEWCELL_LIGHTER_BACKGROUND;
  }
  else
    cell.backgroundColor = [UIColor whiteColor];
}

#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = [arrayCells objectAtIndex:indexPath.row];
  
  if([cell reuseIdentifier] == @"Booking Enquiry") {
    [self showBookingEnquiry];
  }
  else if([cell reuseIdentifier] == @"Booking Partner") {
    NSDictionary *partner = [poiModel.partners objectAtIndex:cell.tag];
    NSString *urlString = [partner objectForKey:@"url"];
    [self showBookingWebViewController:urlString];
  }
  else if([cell reuseIdentifier] == @"Room") {
    NSDictionary *room = [poiModel.rooms objectAtIndex:cell.tag];
    NSString *urlString = [room objectForKey:@"url"];
    [self showBookingWebViewController:urlString];
  }
	else if([cell reuseIdentifier] == @"Add to Favorites") {
		NSString* text = [NSString stringWithFormat:@"%@, %@", poiModel.name, poiModel.address ];
		NSString* message = [NSString stringWithFormat:@"%@ was added to your favorites", poiModel.name];
		NSString* _poi_id = [NSString stringWithFormat:@"%d", poiModel.primaryKey];
		[modelSearch addToFavorites:text withId:_poi_id];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
    [UBAlertView showAlertWithTitle:@"Successful" message:message executeBlock:nil];
	}
	else if([cell reuseIdentifier] == @"Email to a Friend") {
		[self showEmailComposer];
  }
	else if([cell reuseIdentifier] == @"Post a Comment") {
		if (FBSession.activeSession.isOpen)
      [self showCommentComposer];
    else
      [UBAlertView showAlertWithTitle:@"Warning" message:MESSAGE_LOGIN_REQUIRED_ERROR executeBlock:nil];
  }
  else if([cell reuseIdentifier] == @"Likes") {
    if (FBSession.activeSession.isOpen) {
      if(cell.accessoryType == UITableViewCellAccessoryNone) { //like it
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        poiModel.total_likes = [NSString stringWithFormat:@"%d", [poiModel.total_likes intValue] + 1];
        
        [self startHTTPRequestLike:@"like"];
      }
      else { //unlike
        cell.accessoryType = UITableViewCellAccessoryNone;
        poiModel.total_likes = [NSString stringWithFormat:@"%d", [poiModel.total_likes intValue] - 1];
        
        [self startHTTPRequestLike:@"unlike"];
      }
      
      RatingCell *ratingCell = (RatingCell*)cell;
      ratingCell.labelLikes.text = [NSString stringWithFormat:@"%@ Likes", poiModel.total_likes];
      [self.tableView reloadInputViews];
    }
    else {
      [UBAlertView showAlertWithTitle:@"Warning" message:MESSAGE_LOGIN_REQUIRED_ERROR executeBlock:nil];
    }
  }
  else if([[cell reuseIdentifier] hasPrefix:@"comment_"]){
    NSString *cellIdentifier = [cell reuseIdentifier];
    int index = [[[cellIdentifier componentsSeparatedByString:@"_"] objectAtIndex:1] intValue];
    
    NSDictionary *comment = [poiModel.comments objectAtIndex:index];
    NSString *profile_id = [comment objectForKey:@"profile_id"];
    NSString *comment_id = [NSString stringWithFormat:@"%d", [[comment objectForKey:@"comment_id"] intValue]];
    NSString *content = [comment objectForKey:@"content"];
    
    if([profile_id isEqualToString:user.profile_id]){
      [self showEditCommentComposer:comment_id withContent:content];
    }
  }
}

- (void)showBookingWebViewController:(NSString*)urlString {
	DLog(@"begin");
	BookingWebViewController *webController = [[BookingWebViewController alloc] initWithNibName:nil bundle:nil withURLString:urlString];
	
	if([HelperDevice isDeviceAniPad])
		[self.delegate dismissAndPushViewController:webController];
	else
		[self.navigationController pushViewController:webController animated:YES];

	[webController release];
}

- (void)showBookingEnquiry {
  DLog(@"begin");
  BookingEnquiryTableViewController *vc = [[BookingEnquiryTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
  vc.delegate = self;
  vc.primaryKey = poiModel.primaryKey;
  [self showModalViewController:vc];
  [vc release];
}

#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
}

#pragma mark Mail methods
- (void)showEmailComposer {
	NSString* _message = nil;
	NSString* _subject = nil;
	
	NSString* urlString = [NSString stringWithFormat:@"%@/%d", HTTP_POI_URL, poiModel.primaryKey];
	
	_message = [NSString stringWithFormat:@"<p><b>%@</b> <br/>%@ </p> <p>%@</p> <p>%@</p>", poiModel.name, poiModel.address, urlString, poiModel.description];
	_subject = [NSString stringWithFormat:@"%@ from mytravel-asia.com", poiModel.name];
	
	if ([MFMailComposeViewController canSendMail])
  {
		MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
		controller.mailComposeDelegate = self;
		[controller setSubject: _subject];
		[controller setMessageBody:_message isHTML:YES];
		[self presentModalViewController:controller animated:YES];
		[controller release];
	}
	else
    [UBAlertView showAlertWithTitle:@"Warning" message:@"Please make sure that you have configured your email settings" executeBlock:nil];
}

#pragma mark MFMailComposeViewControllerDelegate methods
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Like
- (void)startHTTPRequestLike:(NSString*)action {
  NSString *urlDirty = [NSString stringWithFormat:@"%@/%d/%@?format=json&profile_id=%@", HTTP_POI_URL, poiModel.primaryKey, action, user.profile_id];
	NSString *strURLClean = [urlDirty stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *url = [NSURL URLWithString:strURLClean];
	ASIHTTPRequest *currentHTTPRequest = [ASIHTTPRequest requestWithURL:url];
	[currentHTTPRequest setDelegate:self];
	[currentHTTPRequest setDidFinishSelector:@selector(requestFinishedLike:)];
	[currentHTTPRequest setDidFailSelector:@selector(requestFailed:)];
	[currentHTTPRequest setTimeOutSeconds:HTTP_TIMEOUT];
	
	[currentHTTPRequest startAsynchronous];
	DLog(@"urlDirty:%@", urlDirty);
}

- (void)requestFinishedLike:(ASIHTTPRequest *)request {
	DLog(@"DetailsViewController.requestFinished");
  NSData *jsonData = [request responseData];
  id responseRoot = [jsonData objectFromJSONData];
  
  if([responseRoot isKindOfClass:[NSDictionary class]]) {
		poiModel.total_likes = [responseRoot objectForKey:@"likes"];
    poiModel.liked = [[responseRoot objectForKey:@"liked"] boolValue];
  }
  else
    [UBAlertView showAlertWithTitle:@"Error" message:MESSAGE_APPLICATION_ERROR executeBlock:nil];
}

#pragma mark Post a Comment methods
- (void)showCommentComposer {
  PostCommentViewController *vc = [[PostCommentViewController alloc] initWithNibName:nil bundle:nil];
  vc.profile_id = user.profile_id;
  vc.poi_id = [NSString stringWithFormat:@"%d", poiModel.primaryKey];
  vc.delegate = self;
  [self showModalViewController:vc];
  [vc release];
}

- (void)showEditCommentComposer:(NSString *)_comment_id withContent:(NSString *)_content{
  DLog(@"comment_id: %@ content: %@", _comment_id, _content);
  PostCommentViewController *vc = [[PostCommentViewController alloc] initWithNibName:nil bundle:nil];
  vc.profile_id = user.profile_id;
  vc.poi_id = [NSString stringWithFormat:@"%d", poiModel.primaryKey];
  vc.comment_id = _comment_id;
  vc.content = _content;
  vc.delegate = self;
  [self showModalViewController:vc];
  [vc release];
}

#pragma mark Modal View Controller methods
- (void)showModalViewController:(UIViewController*)vc {
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
  navController.navigationBar.barStyle = UIBarStyleBlack;
  
	if([HelperDevice isDeviceAniPad]) {
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentModalViewController:navController animated:YES];
  }
	else
    [self presentModalViewController:navController animated:YES];
  
  [navController release];
}

- (void)dismissModalViewController {
  DLog(@"");
  
	if(self.modalViewController != nil)
		[self dismissModalViewControllerAnimated:YES];
}

- (void)reload{
  [self dismissModalViewController];
  [self startHTTPRequest];
}

@end
