#import "LikeCell.h"
#import "UITableViewCellConstants.h"

@implementation LikeCell

@synthesize labelLikes;

- (id)initWithNumberOfComments:(int)comments
                 numberOfLikes:(int)likes
               reuseIdentifier:(NSString *)reuseIdentifier
                  contentWidth:(int)contentWidth {
  
  UITableViewCellStyle style = UITableViewCellStyleDefault;
  
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    int commentWidth = 85.0f;
    int likeWidth = 50.0f;
    int lengthAccessory = CELL_ACESSORY_WIDTH;
    
    UIFont* _font = [UIFont boldSystemFontOfSize:12.0];
    int paddingLeft = PADDING_HORIZONTAL;
    
    UIImageView *imageComment = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_comment.png"]];
    imageComment.frame = CGRectMake(paddingLeft, 4.0f, 16.0f, 16.0f);
    [self.contentView addSubview:imageComment];
    [imageComment release];

    UILabel* labelComments = [[UILabel alloc] initWithFrame:CGRectMake(paddingLeft + 20.0f, 2.0f, commentWidth, HEIGHT_STATIC_LABEL)];
    labelComments.textAlignment = UITextAlignmentLeft;
    labelComments.numberOfLines = 1;
    labelComments.font = _font;
    labelComments.textColor = COLOR_RATING_LABEL;
    labelComments.highlightedTextColor = [UIColor whiteColor];
    labelComments.backgroundColor = UITABLEVIEWCELL_LIGHTER_BACKGROUND;
    //labelComments.backgroundColor = [UIColor yellowColor];
    labelComments.text = [NSString stringWithFormat:@"%d Comments", comments];
    
    [self.contentView addSubview:labelComments];
    [labelComments release];
    
    if(contentWidth == 0) {
      contentWidth = self.contentView.bounds.size.width;
    }
    contentWidth = contentWidth - lengthAccessory - likeWidth;

    UIImageView *imageLike = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_like.png"]];
    imageLike.frame = CGRectMake(contentWidth - 20.0f, 4.0f, 16.0f, 16.0f);
    [self.contentView addSubview:imageLike];
    [imageLike release];
    
    CGRect likesRect = CGRectMake(contentWidth, 2.0f, likeWidth, 23.0f);
    labelLikes = [[UILabel alloc] initWithFrame:likesRect];
    labelLikes.textAlignment = UITextAlignmentRight;
    labelLikes.numberOfLines = 1;
    labelLikes.font = _font;
    labelLikes.textColor = COLOR_RATING_LABEL;
    labelLikes.highlightedTextColor = [UIColor whiteColor];
    labelLikes.backgroundColor = UITABLEVIEWCELL_LIGHTER_BACKGROUND;
    //labelLikes.backgroundColor = [UIColor redColor];
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