//
//  SearchViewController.h
//  Country
//
//  Created by rupert on 4/04/11.
//  Copyright 2011 2RMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchItemsModel.h"

@protocol SearchViewControllerDelegate;

@interface SearchViewController : UIViewController <UITableViewDelegate, UITextFieldDelegate>{
	id<SearchViewControllerDelegate> delegate;
	IBOutlet UITableView* tableview;

  IBOutlet UITextField* textfield;
  IBOutlet UIButton* buttonCancel;
  IBOutlet UIButton* buttonHideKB;
	
	SearchItemsModel* modelSearch;
}

@property(nonatomic, retain) IBOutlet UITableView* tableview;

@property(nonatomic, retain) IBOutlet UITextField* textfield;
@property(nonatomic, retain) IBOutlet UIButton* buttonCancel;
@property(nonatomic, retain) IBOutlet UIButton* buttonHideKB;

@property(assign) id<SearchViewControllerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withSearchModel:(SearchItemsModel*)_modelSearch;

- (IBAction)buttonCancelPressed;
- (IBAction)buttonHideKeyboardPressed;

@end

@protocol SearchViewControllerDelegate <NSObject>
- (void)cancelSearchViewController;
- (void)receivedSearchKeyword:(NSString*)_text;
@end