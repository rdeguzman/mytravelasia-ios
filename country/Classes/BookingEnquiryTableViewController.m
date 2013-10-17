#import "BookingEnquiryTableViewController.h"
#import "UITableViewCellConstants.h"
#import "EditableTextViewCell.h"
#import "EditableTextFieldCell.h"
#import "NumberTextFieldCell.h"
#import "TextViewController.h"
#import "HelperDevice.h"
#import "Kal.h"
#import "UBAlertView.h"
#import "ApplicationConstants.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "NSString+Utilities.h"

@interface BookingEnquiryTableViewController()
- (void)createContactCells;
- (void)createDateCells;
- (void)createBookingCells;
- (void)dismissView:(id)sender;
- (void)sendEnquiry:(id)sender;
- (void)showKal:(NSDate*)date forTitle:(NSString*)calendarTitle;
- (void)showTextViewController;
- (void)updateModel;
- (void)sendHTTPRequest;
- (void)startHTTPRequest:(NSString *)urlDirty;
- (void)startAnimating:(NSString*)_message;
- (void)stopAnimating;
- (void)createProgressionAlertWithMessage:(NSString *)message;
- (void)hideProgressAlert;
@end

@implementation BookingEnquiryTableViewController

RM_SYNTHESIZE(bookingModel);
RM_SYNTHESIZE(arraySections);
RM_SYNTHESIZE(arrayContactCells);
RM_SYNTHESIZE(arrayDateCells);
RM_SYNTHESIZE(arrayBookingCells);
RM_SYNTHESIZE(delegate);
RM_SYNTHESIZE(progressAlert);
RM_SYNTHESIZE(primaryKey);

- (void)dealloc
{
  RM_RELEASE(bookingModel);
  RM_RELEASE(arraySections);
  RM_RELEASE(arrayContactCells);
  RM_RELEASE(arrayDateCells);
  RM_RELEASE(arrayBookingCells);
  RM_RELEASE(progressAlert);
  
	[super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  
  if (self)
  {
    self.title = @"Enquiry";

    arraySections_ = [[NSMutableArray alloc] initWithObjects:@"Contact Info", @"Dates", @"Booking Details", nil];

    arrayContactCells_ = [[NSMutableArray alloc] initWithObjects:nil];
    arrayDateCells_ = [[NSMutableArray alloc] initWithObjects:nil];
    arrayBookingCells_ = [[NSMutableArray alloc] initWithObjects:nil];

    bookingModel_ = [[BookingEnquiryModel alloc] init];
  }
  
  return self;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self createContactCells];
  [self createDateCells];
  [self createBookingCells];

  UIBarButtonItem *buttonDismiss = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissView:)];
	self.navigationItem.leftBarButtonItem = buttonDismiss;
  [buttonDismiss release];

  UIBarButtonItem *buttonSend = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(sendEnquiry:)];
	self.navigationItem.rightBarButtonItem = buttonSend;
  [buttonSend release];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return [HelperDevice shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark
#pragma private methods -- cell creation
- (void)createContactCells
{
  UITableViewCell* cell = nil;

  cell = [[EditableTextFieldCell alloc] initWithTitle:@"First Name" initWithContent:self.bookingModel.firstName reuseIdentifier:@"FirstName" delegate:self keyboardType:UIKeyboardTypeAlphabet];
  [self.arrayContactCells addObject:cell];
  [cell release];

  cell = [[EditableTextFieldCell alloc] initWithTitle:@"Last Name" initWithContent:self.bookingModel.lastName reuseIdentifier:@"LastName" delegate:self keyboardType:UIKeyboardTypeAlphabet];
  [self.arrayContactCells addObject:cell];
  [cell release];

  cell = [[EditableTextFieldCell alloc] initWithTitle:@"Contact No" initWithContent:self.bookingModel.contactNumber reuseIdentifier:@"ContactNo" delegate:self keyboardType:UIKeyboardTypeDefault];
  [self.arrayContactCells addObject:cell];
  [cell release];

  cell = [[EditableTextFieldCell alloc] initWithTitle:@"Email" initWithContent:self.bookingModel.email reuseIdentifier:@"Email" delegate:self keyboardType:UIKeyboardTypeEmailAddress];
  [self.arrayContactCells addObject:cell];
  [cell release];
}

- (void)createDateCells
{
  UITableViewCell* cell = nil;
  
  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Arrival"];
  cell.textLabel.text = @"Arrival";
  cell.detailTextLabel.text = self.bookingModel.dateArrivalAsFullString;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0f];
  cell.textLabel.textColor = BLUE_DARKER_COLOR;
  cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
  [self.arrayDateCells addObject:cell];
  [cell release];

  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Departure"];
  cell.textLabel.text = @"Departure";
  cell.detailTextLabel.text = self.bookingModel.dateDepartureAsFullString;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0f];
  cell.textLabel.textColor = BLUE_DARKER_COLOR;
  cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
  [self.arrayDateCells addObject:cell];
  [cell release];
}

- (void)createBookingCells
{
  UITableViewCell* cell = nil;

  cell = [[NumberTextFieldCell alloc] initWithTitle:@"Rooms" initWithNumber:self.bookingModel.rooms reuseIdentifier:@"Rooms"];
  [self.arrayBookingCells addObject:cell];
  [cell release];

  cell = [[NumberTextFieldCell alloc] initWithTitle:@"Adults" initWithNumber:self.bookingModel.adults reuseIdentifier:@"Adults"];
  [self.arrayBookingCells addObject:cell];
  [cell release];

  cell = [[NumberTextFieldCell alloc] initWithTitle:@"Children" initWithNumber:self.bookingModel.children reuseIdentifier:@"Children"];
  [self.arrayBookingCells addObject:cell];
  [cell release];

  cell = [[EditableTextViewCell alloc] initWithTitle:@"Comment" initWithContent:nil reuseIdentifier:@"TextField" delegate:self];
  [self.arrayBookingCells addObject:cell];
  [cell release];
}

#pragma mark
#pragma mark -- private methods
- (void)dismissView:(id)sender
{
  DLog(@"");
  [self.bookingModel save];
  [self.delegate dismissModalViewController];
}

- (void)sendEnquiry:(id)sender
{
  DLog(self.bookingModel.description);
  [self.bookingModel save];

  if([self.bookingModel isValid])
  {
    [self sendHTTPRequest];
  }
  else
    [UBAlertView showAlertWithTitle:@"Invalid" message:@"Please specify First Name, Last Name, Contact No and Email." executeBlock:nil];
}

- (void)updateModel
{
  /*  Every time the textfield returns we get the textfield and save it to the model.
   In this case, we capture the changes when the user tap on textfield to another
   without tapping the RETURN on the lower right */
  EditableTextFieldCell *cell = nil;

  cell = (EditableTextFieldCell*)[self.arrayContactCells objectAtIndex:0];
  self.bookingModel.firstName = cell.textfield.text;

  cell = (EditableTextFieldCell*)[self.arrayContactCells objectAtIndex:1];
  self.bookingModel.lastName = cell.textfield.text;

  cell = (EditableTextFieldCell*)[self.arrayContactCells objectAtIndex:2];
  self.bookingModel.contactNumber = cell.textfield.text;

  cell = (EditableTextFieldCell*)[self.arrayContactCells objectAtIndex:3];
  self.bookingModel.email = cell.textfield.text;

  DLog(self.bookingModel.description);
}

#pragma mark ---- delegate methods for the UITextViewDelegate class ----
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
  DLog(@"");
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	DLog(@"");
  [textField resignFirstResponder];

	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
	DLog(@"");
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	DLog(@"");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	DLog(@"");
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  DLog(@"");

  [textField resignFirstResponder];
  [self updateModel];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return [self.arraySections objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return [self.arraySections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section)
  {
    case 0:
    {
      return [self.arrayContactCells count];
      break;
    }
    case 1:
    {
      return [self.arrayDateCells count];
      break;
    }
    case 2:
    {
      return [self.arrayBookingCells count];
      break;
    }
    default:
    {
      return 0;
      break;
    }
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(indexPath.section == 2 && indexPath.row == 3)
  {
    EditableTextViewCell *cell = (EditableTextViewCell*)[self.arrayBookingCells objectAtIndex:3];
    return cell.contentView.frame.size.height;
  }
  else
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = nil;
  UITableViewCell* dequeuedCell = nil;

  switch ([indexPath section])
  {
    case 0:
    {
      cell = [self.arrayContactCells objectAtIndex:indexPath.row];
      break;
    }
    case 1:
    {
      cell = [self.arrayDateCells objectAtIndex:indexPath.row];
      break;
    }
    case 2:
    {
      cell = [self.arrayBookingCells objectAtIndex:indexPath.row];
      break;
    }
    default:
      break;
  }

  dequeuedCell = [tableView dequeueReusableCellWithIdentifier:cell.reuseIdentifier];

  if(dequeuedCell != nil)
    return dequeuedCell;
  else
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch ([indexPath section])
  {
    case 1:
    {
      if(indexPath.row == 0)
        [self showKal:self.bookingModel.dateArrival forTitle:@"Arrival"];
      else if(indexPath.row == 1)
        [self showKal:self.bookingModel.dateDeparture forTitle:@"Departure"];

      break;
    }
    case 2:
    {
      if(indexPath.row == 3)
        [self showTextViewController];

      break;
    }
    default:
      break;
  }
}

#pragma mark
#pragma mark -- Kal methods
- (void)showKal:(NSDate*)date forTitle:(NSString*)calendarTitle
{
  KalViewController *kal = nil;

  if([HelperDevice isDeviceAniPad])
  {
    CGRect frame = CGRectMake(0.0f, 0.0f, 540.0f, 620.0f);
    kal = [[KalViewController alloc] initWithFrame:frame initWithSelectedDate:date];
    kal.view.backgroundColor = UITABLEVIEWCELL_WHITE_BACKGROUND;
  }
  else
    kal = [[KalViewController alloc] initWithSelectedDate:date];

  kal.title = calendarTitle;
  kal.delegateExternal = self;

  [self.navigationController pushViewController:kal animated:YES];
  [kal release];
}

- (void)didSelectDate:(NSDate *)date forTitle:(NSString*)calendarTitle
{
  DLog(@"");

  if(calendarTitle == @"Arrival")
  {
    self.bookingModel.dateArrival = date;
    UITableViewCell *cell = [self.arrayDateCells objectAtIndex:0];
    cell.detailTextLabel.text = self.bookingModel.dateArrivalAsFullString;
  }
  else if(calendarTitle == @"Departure")
  {
    self.bookingModel.dateDeparture = date;
    UITableViewCell *cell = [self.arrayDateCells objectAtIndex:1];
    cell.detailTextLabel.text = self.bookingModel.dateDepartureAsFullString;
  }

  DLog(self.bookingModel.description);
}

#pragma mark
#pragma mark -- TextView methods
- (void)showTextViewController
{
  DLog(@"");
  self.navigationItem.backBarButtonItem = nil;

  TextViewController  *textViewVC = [[TextViewController alloc] initWithNibName:nil bundle:nil];
  textViewVC.delegate = self;
  [self.navigationController pushViewController:textViewVC animated:YES];
  [textViewVC release];
}

#pragma mark
#pragma mark--public methods
- (void)didFinishTextViewWithComment:(NSString*)text
{
  DLog(@"");
  [self.navigationController popViewControllerAnimated:YES];
  self.bookingModel.comment = text;

  EditableTextViewCell *cell = [self.arrayBookingCells objectAtIndex:3];
  cell.textview.text = self.bookingModel.comment;
}

#pragma mark
#pragma mark - booking http methods
- (void)sendHTTPRequest
{
  DLog(@"begin");
  NSString* _message = @"Sending your enquiry. Please wait...";

  NSMutableString *strURLDirty = [[NSMutableString alloc] init];
  [strURLDirty appendFormat:@"%@", HTTP_BOOKING_CREATE_URL];
  [strURLDirty appendFormat:@"?booking[poi_id]=%d", self.primaryKey];
  [strURLDirty appendFormat:@"&booking[first_name]=%@", self.bookingModel.firstName];
  [strURLDirty appendFormat:@"&booking[last_name]=%@", self.bookingModel.lastName];
  [strURLDirty appendFormat:@"&booking[contact_no]=%@", self.bookingModel.contactNumber];
  [strURLDirty appendFormat:@"&booking[email]=%@", self.bookingModel.email];
  [strURLDirty appendFormat:@"&booking[rooms]=%d", self.bookingModel.rooms];
  [strURLDirty appendFormat:@"&booking[adults]=%d", self.bookingModel.adults];
  [strURLDirty appendFormat:@"&booking[children]=%d", self.bookingModel.children];
  [strURLDirty appendFormat:@"&booking[arrival]=%@", self.bookingModel.dateArrivalAsShortString];
  [strURLDirty appendFormat:@"&booking[departure]=%@", self.bookingModel.dateDepartureAsShortString];

  if([self.bookingModel.comment isWithAnyText])
    [strURLDirty appendFormat:@"&booking[comment]=%@", self.bookingModel.comment];

  [self startHTTPRequest:strURLDirty];
  [strURLDirty release];

  [self startAnimating:_message];
}

- (void)startHTTPRequest:(NSString *)urlDirty
{
  DLog(@"");
  NSString *strURLClean = [urlDirty stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURL *url = [NSURL URLWithString:strURLClean];

  ASIHTTPRequest* currentHTTPRequest = [ASIHTTPRequest requestWithURL:url];
  [currentHTTPRequest setDelegate:self];
  [currentHTTPRequest setDidFinishSelector:@selector(requestFinished:)];
  [currentHTTPRequest setDidFailSelector:@selector(requestFailed:)];
  [currentHTTPRequest setTimeOutSeconds:HTTP_TIMEOUT];

  [currentHTTPRequest startAsynchronous];
  DLog(urlDirty);
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
  DLog(@"begin");
  [self stopAnimating];

  NSData *jsonData = [request responseData];
  id result = [jsonData objectFromJSONData];

  if([result isKindOfClass:[NSDictionary class]])
  {
    BOOL valid = [[result objectForKey:@"valid"] boolValue];
    NSString *message = [result objectForKey:@"message"];

    if(valid)
    {
      [UBAlertView showAlertWithTitle:@"Successful" message:message executeBlock:nil];
      [self.delegate dismissModalViewController];
    }
    else
      [UBAlertView showAlertWithTitle:@"Warning" message:message executeBlock:nil];
  }
  else
    [UBAlertView showAlertWithTitle:@"Error" message:MESSAGE_APPLICATION_ERROR executeBlock:nil];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
  NSError *error = [request error];
  NSString *message = [error localizedDescription];

  if([error localizedDescription] == @"The request timed out")
    message = [NSString stringWithFormat:@"There is a network problem. (%@)", [error localizedDescription]];

  [UBAlertView showAlertWithTitle:@"Network Error" message:message executeBlock:nil];

  [self stopAnimating];
}

#pragma mark progress methods
- (void)startAnimating:(NSString*)_message
{
  DLog(@"");
  [self createProgressionAlertWithMessage:_message];
}

- (void)stopAnimating
{
  DLog(@"");
  [self hideProgressAlert];
}
- (void)createProgressionAlertWithMessage:(NSString *)message
{
  if(self.progressAlert == nil)
  {
    self.progressAlert = [[UIAlertView alloc] initWithTitle: @"" message: message
                                            delegate: self
                                   cancelButtonTitle: nil
                                   otherButtonTitles: nil];

    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.frame = CGRectMake(139.0f-18.0f, 55.0f, 37.0f, 37.0f);
    [self.progressAlert addSubview:activityView];
    [activityView startAnimating];
    [activityView release];

    [self.progressAlert show];
  }
}

- (void)hideProgressAlert
{
	if(self.progressAlert != nil)
  {
    [self.progressAlert dismissWithClickedButtonIndex:0 animated:NO];
    RM_RELEASE(progressAlert);
  }
}


@end
