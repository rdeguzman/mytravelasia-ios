#import <UIKit/UIKit.h>

@interface RatingCell : UITableViewCell {
  UILabel *labelLikes;
}

@property (nonatomic, retain) UILabel *labelLikes;

- (id)initNumberOfStars:(CGFloat)totalStars
        numberOfRatings:(int)numberRatings
          numberOfLikes:(int)likes
        reuseIdentifier:(NSString *)reuseIdentifier;

@end