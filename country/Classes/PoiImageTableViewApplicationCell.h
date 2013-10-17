#import <UIKit/UIKit.h>
#import "ApplicationCell.h"

@interface PoiImageTableViewApplicationCell : ApplicationCell {
	UIView *cellContentView;
	
	UILabel* labelName;
	UILabel* labelAddress;
	UILabel* labelDistance;
	UILabel* labelMinRate;
  
  UILabel* labelTotalLikes;
  UILabel* labelTotalComments;
	
  UIImageView* thumbImageView;
}

@end