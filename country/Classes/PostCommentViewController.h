#import <UIKit/UIKit.h>
#import "DetailsViewController.h"

@interface PostCommentViewController : UIViewController {
  NSString *poi_id;
  NSString *profile_id;
  NSString *comment_id;
  NSString *content;
}

@property(nonatomic, retain) UITextView *textview;
@property(nonatomic, copy) NSString *poi_id;
@property(nonatomic, copy) NSString *profile_id;
@property(nonatomic, copy) NSString *comment_id;
@property(nonatomic, copy) NSString *content;

@property(nonatomic, retain) UIBarButtonItem *buttonPost;

@property(nonatomic, assign) DetailsViewController *delegate;

@end
