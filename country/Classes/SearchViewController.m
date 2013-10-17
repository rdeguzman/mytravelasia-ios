//
//  SearchViewController.m
//  Country
//
//  Created by rupert on 4/04/11.
//  Copyright 2011 2RMobile. All rights reserved.
//
#import "DebugLog.h"
#import "SearchViewController.h"
#import "HelperAlert.h"
#import "HelperLogUtils.h"

@implementation SearchViewController

@synthesize tableview, delegate, textfield, buttonCancel, buttonHideKB;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withSearchModel:(SearchItemsModel*)_modelSearch{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization.
    modelSearch = _modelSearch;
    DLog(@"arraySections count: %d", [[modelSearch arraySections] count]);
  }
  return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
  self.buttonHideKB.hidden = YES;
	
	self.contentSizeForViewInPopover = CGSizeMake(320.0, 680.0f);
}

- (void)viewWillAppear:(BOOL)animated{
	DebugLog(@"begin");
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
	DebugLog(@"begin");
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)dealloc {
	DebugLog(@"dealloc");
	[tableview release];
  
  [textfield release];
  [buttonCancel release];
  [buttonHideKB release];
	
  [super dealloc];
}

#pragma mark button methods
- (IBAction)buttonCancelPressed{
	DLog(@"");
	[self.delegate cancelSearchViewController];
}

- (IBAction)buttonHideKeyboardPressed{
  [self.textfield resignFirstResponder];
}

#pragma mark UITextViewDelegate Class
#pragma mark ---- delegate methods for the UITextViewDelegate class ----
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	NSString* _keyword = [NSString stringWithFormat:@"%@", [textField text]];
	
	//Let's check for minimum keyword before passing the request
	if( _keyword.length < 3)
		[HelperAlert showTitle:@"Reminder" message:@"Search keyword should be greater than 3 characters"];
	else
		[self.delegate receivedSearchKeyword:_keyword];
  
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField{
	DLog(@"");
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
  self.buttonHideKB.hidden = NO;
	DLog(@"");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
	DLog(@"");
  self.buttonHideKB.hidden = YES;
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *substring = [NSString stringWithString:textField.text];
  substring = [[substring stringByReplacingCharactersInRange:range withString:string] lowercaseString];
  [self searchAutocompleteEntriesWithSubstring:substring];
  return YES;
}

#pragma mark UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [modelSearch.arraySections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return [modelSearch.arraySections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString*key = [modelSearch.arraySections objectAtIndex:section];
	NSArray* arrayRecords = (NSArray *)[modelSearch arrayObjectForKey:key];

	[HelperLogUtils rowsInSection:[arrayRecords count] section:section];
	
	return [arrayRecords count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 30.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int section = indexPath.section;
	
	NSString*key = [modelSearch.arraySections objectAtIndex:section];
	NSArray* arrayRecords = (NSArray *)[modelSearch arrayObjectForKey:key];
	
  static NSString *CellIdentifier = @"Cell";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil)
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

	cell.textLabel.text = [arrayRecords objectAtIndex:indexPath.row];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];

	switch (section) {
		case 0: //Current Location
			cell.textLabel.textColor = [UIColor redColor];
			break;
		case 1: //Recent Searches
			cell.textLabel.textColor = [UIColor blueColor];
			break;
		case 2: //Favorites
			cell.textLabel.textColor = [UIColor blueColor];
			break;
		default:
			cell.textLabel.textColor = [UIColor blackColor];
			break;
	}
	
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int section = indexPath.section;
	
	NSString*key = [modelSearch.arraySections objectAtIndex:section];
	NSArray* arrayRecords = (NSArray *)[modelSearch arrayObjectForKey:key];
	
	NSString* _keyword = [arrayRecords objectAtIndex:indexPath.row];
	[self.delegate receivedSearchKeyword:_keyword];
}

#pragma mark Autocomplete Search
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
  NSArray *arrayRecordsTopDestinations = [modelSearch arrayObjectForKey:@"4-Top Destinations"];
  bool firstTry = [self autoCompleteSearch:substring fromArray:arrayRecordsTopDestinations inSection:3];

  if(!firstTry){
    NSArray *arrayRecordsDestinations = [modelSearch arrayObjectForKey:@"5-Destinations"];
    [self autoCompleteSearch:substring fromArray:arrayRecordsDestinations inSection:4];
  }
}

- (BOOL)autoCompleteSearch:(NSString *)substring fromArray:(NSArray *)arrayRecords inSection:(int)section {
  bool bContinueSearch = YES;

  for(int i = 0; i < [arrayRecords count]; i++) {

    NSString *record = [arrayRecords objectAtIndex:i];
    NSString *curString = [record lowercaseString];
    NSRange substringRange = [curString rangeOfString:substring];

    if(substringRange.location == 0){ //strings that match
      //DLog(@"curString: %@ substringRange: %d", curString, substringRange.location);

      NSIndexPath* _indexPath = [NSIndexPath indexPathForRow:i inSection:section];
      [self.tableview scrollToRowAtIndexPath:_indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
      bContinueSearch = NO;
      break;
    }
  }

  return bContinueSearch;
}

@end
