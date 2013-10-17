#import "DebugLog.h"
#import "RatingCell.h"
#import "UITableViewCellConstants.h"
#import "RatingView.h"

@implementation RatingCell

@synthesize labelLikes;

- (id)initNumberOfStars:(CGFloat)totalStars numberOfRatings:(int)numberRatings numberOfLikes:(int)likes reuseIdentifier:(NSString *)reuseIdentifier{
  UITableViewCellStyle style = UITableViewCellStyleDefault;

  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    int lengthRating = 75.0f;
    int likeRating = 75.0f;
    int lengthAccessory = CELL_ACESSORY_WIDTH;
    
    //switch "No Rating", "1 Rating", "2 Ratings"
    NSString* title = nil;
    
    if(numberRatings == 0)
      title = [NSString stringWithFormat:@"No Rating"];
    else if(numberRatings == 1)
      title = [NSString stringWithFormat:@"1 Rating"];
    else
      title = [NSString stringWithFormat:@"%d Ratings", numberRatings];
    
    UIFont* _font = [UIFont boldSystemFontOfSize:12.0];
    int paddingLeft = PADDING_HORIZONTAL;
    
    UILabel* labelRating = [[UILabel alloc] initWithFrame:CGRectMake(paddingLeft, 2.0f, lengthRating, HEIGHT_STATIC_LABEL)];
    DLog(@"labelRating width: %f height: %f", labelRating.frame.size.width, labelRating.frame.size.height);
    
    labelRating.textAlignment = UITextAlignmentLeft;
    labelRating.numberOfLines = 1;
    labelRating.font = _font;
    labelRating.textColor = COLOR_RATING_LABEL;
    labelRating.highlightedTextColor = [UIColor whiteColor];
    
    //Note: the background should be the same for UITableView background as not to distort backgroundColor of CellAccessory
    labelRating.backgroundColor = UITABLEVIEWCELL_LIGHTER_BACKGROUND;
    //labelRating.backgroundColor = [UIColor redColor];
    labelRating.text = title;
    
    [self.contentView addSubview:labelRating];
    [labelRating release];

    CGRect ratingRect = CGRectMake(lengthRating + PADDING_HORIZONTAL, PADDING_VERTICAL, 65.0f, 23.0f);
    RatingView* ratingView = [[RatingView alloc] initWithFrame:ratingRect];
    [ratingView setRating: totalStars];
    [self.contentView addSubview:ratingView];
    [ratingView release];
    
    CGRect likesRect = CGRectMake(self.contentView.bounds.size.width - lengthAccessory - likeRating, 2.0f, likeRating, 23.0f);
    labelLikes = [[UILabel alloc] initWithFrame:likesRect];
    
    labelLikes.textAlignment = UITextAlignmentRight;
    labelLikes.numberOfLines = 1;
    labelLikes.font = _font;
    labelLikes.textColor = COLOR_RATING_LABEL;
    labelLikes.highlightedTextColor = [UIColor whiteColor];
    
    //Note: the background should be the same for UITableView background as not to distort backgroundColor of CellAccessory
    labelLikes.backgroundColor = UITABLEVIEWCELL_LIGHTER_BACKGROUND;
    //labelLikes_.backgroundColor = [UIColor redColor];
    labelLikes.text = [NSString stringWithFormat:@"%d Likes", likes];
    
    [self.contentView addSubview:labelLikes];

    
    int _totalHeight = PADDING_VERTICAL + HEIGHT_STATIC_LABEL + PADDING_VERTICAL;
    
    //Adjust the height of the contentView
    CGRect newFrame = self.contentView.frame;
    newFrame.size.height = _totalHeight;
    self.contentView.frame = newFrame;
    
    self.contentView.backgroundColor = UITABLEVIEWCELL_LIGHTER_BACKGROUND;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    DLog(@"cellContentView width: %f height: %f", self.contentView.frame.size.width, self.contentView.frame.size.height);
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)dealloc {
  [labelLikes release];
  [super dealloc];
}

@end