#import <UIKit/UIKit.h>
#import "ApplicationCell.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FeedImageTableViewApplicationCell : ApplicationCell {
  UIView *cellContentView;

  UILabel* labelName;
	UILabel* labelContent;
	UILabel* labelTimeAgePosted;
	
  UIImageView* thumbImageView;
  FBProfilePictureView *profilePictureView;
  
  UILabel* labelTotalLikes;
  UILabel* labelTotalComments;
}

@end
