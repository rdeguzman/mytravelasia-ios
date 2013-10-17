#import <UIKit/UIKit.h>

@interface LikeCell : UITableViewCell {
  UILabel *labelLikes;  
}

@property (nonatomic, retain) UILabel *labelLikes;

- (id)initWithNumberOfComments:(int)comments
                 numberOfLikes:(int)likes
               reuseIdentifier:(NSString *)reuseIdentifier
                  contentWidth:(int)contentWidth;

@end
