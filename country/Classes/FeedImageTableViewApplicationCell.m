#import "FeedImageTableViewApplicationCell.h"
#import "MainTableViewConstants.h"
#import "UIImageView+AFNetworking.h"

@interface FeedImageTableViewApplicationCellContentView : UIView {
  ApplicationCell *_cell;
  BOOL _highlighted;
}

@end

@implementation FeedImageTableViewApplicationCellContentView

- (id)initWithFrame:(CGRect)frame cell:(ApplicationCell *)cell {
  if (self = [super initWithFrame:frame]) {
    _cell = cell;
    
    self.opaque = YES;
    self.backgroundColor = _cell.backgroundColor;
  }
  
  return self;
}

- (void)setHighlighted:(BOOL)highlighted {
  //  DLog(@"");
  _highlighted = highlighted;
  [self setNeedsDisplay];
}

- (BOOL)isHighlighted {
  return _highlighted;
}
@end

#pragma mark -
@implementation FeedImageTableViewApplicationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    cellContentView = [[FeedImageTableViewApplicationCellContentView alloc] initWithFrame:CGRectInset(self.contentView.bounds, 0.0, 1.0) cell:self];
    //DLog(@"%f %f content_text_width:%f", cellContentView.frame.size.width, cellContentView.frame.size.height, CONTENT_TEXT_WIDTH);
    
    cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cellContentView.contentMode = UIViewContentModeLeft;
    [self.contentView addSubview:cellContentView];
    
    CGRect photoFrame = CGRectMake(PADDING_LEFT-1.0f, PADDING_TOP-1.0f, TABLEVIEW_CELL_THUMB_BACKGROUND_WIDTH, TABLEVIEW_CELL_THUMB_BACKGROUND_HEIGHT);
    
    thumbImageView = [[UIImageView alloc] initWithFrame:photoFrame];
    thumbImageView.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:thumbImageView];
    
    int imageWidth = 32.0f;
    int imageHeight = 32.0f;
    
    CGFloat contentWidth = 320.0f - (CONTENT_TEXT_ORIGIN_X + PADDING_RIGHT);
    //DLog(@"CONTENT_TEXT_ORIGIN_X:%f contentWidth:%f", CONTENT_TEXT_ORIGIN_X, contentWidth);
    
    labelName = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_TEXT_ORIGIN_X, 2.0f, contentWidth, 18.0f)];
    labelName.textAlignment = UITextAlignmentLeft;
    labelName.font = [UIFont boldSystemFontOfSize:12.0];
    labelName.textColor = [UIColor blackColor];
    labelName.highlightedTextColor = [UIColor whiteColor];
    labelName.backgroundColor = [UIColor clearColor];
    //labelName.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:labelName];
    
    profilePictureView = [[FBProfilePictureView alloc] init];
    profilePictureView.frame = CGRectMake(CONTENT_TEXT_ORIGIN_X, 22.0f, imageWidth, imageHeight);
    [self.contentView addSubview:profilePictureView];

    labelContent = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_TEXT_ORIGIN_X + imageWidth + 2.0f, 22.0f, contentWidth - (imageWidth + 2.0f), 30.0f)];
    labelContent.textAlignment = UITextAlignmentLeft;
    labelContent.font = [UIFont systemFontOfSize:12.0];
    labelContent.textColor = [UIColor blackColor];
    labelContent.numberOfLines = 2;
    labelContent.highlightedTextColor = [UIColor whiteColor];
    labelContent.backgroundColor = [UIColor clearColor];
    //labelContent.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:labelContent];
    
    UIImageView *imageLike = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_like.png"]];
    imageLike.frame = CGRectMake(CONTENT_TEXT_ORIGIN_X, 55.0f, 16.0f, 16.0f);
    [self.contentView addSubview:imageLike];
    [imageLike release];
    
    labelTotalLikes = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_TEXT_ORIGIN_X + 20.0f, 55.0f, 25.0f, 16.0f)];
    labelTotalLikes.textAlignment = UITextAlignmentLeft;
    labelTotalLikes.font = [UIFont boldSystemFontOfSize:12.0f];
    labelTotalLikes.textColor = [UIColor colorWithWhite:0.23 alpha:1.0];
    labelTotalLikes.backgroundColor = [UIColor clearColor];
    labelTotalLikes.highlightedTextColor = [UIColor whiteColor];
    //labelTotalLikes.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:labelTotalLikes];
    
    UIImageView *imageComment = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_comment.png"]];
    imageComment.frame = CGRectMake(CONTENT_TEXT_ORIGIN_X + 50.0f, 55.0f, 16.0f, 16.0f);
    [self.contentView addSubview:imageComment];
    [imageComment release];
    
    labelTotalComments = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_TEXT_ORIGIN_X + 50.0f + 20.0f, 55.0f, 25.0f, 16.0f)];
    labelTotalComments.textAlignment = UITextAlignmentLeft;
    labelTotalComments.font = [UIFont boldSystemFontOfSize:12.0f];
    labelTotalComments.textColor = [UIColor colorWithWhite:0.23 alpha:1.0];
    labelTotalComments.backgroundColor = [UIColor clearColor];
    labelTotalComments.highlightedTextColor = [UIColor whiteColor];
    //labelTotalComments.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:labelTotalComments];
    
    labelTimeAgePosted = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_TEXT_ORIGIN_X + 50.0f + 20.0f + 25.0f, 55.0f, contentWidth, 16.0f)];
    labelTimeAgePosted.textAlignment = UITextAlignmentLeft;
    labelTimeAgePosted.font = [UIFont systemFontOfSize:11.0];
    labelTimeAgePosted.textColor = [UIColor colorWithWhite:0.23 alpha:1.0];
    labelTimeAgePosted.numberOfLines = 1;
    labelTimeAgePosted.highlightedTextColor = [UIColor whiteColor];
    labelTimeAgePosted.backgroundColor = [UIColor clearColor];
    //labelTimeAgePosted.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:labelTimeAgePosted];
    
  }
  
  return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
  cellContentView.backgroundColor = [UIColor clearColor];
}

- (void)setName:(NSString *)_name {
  [super setName:_name];
  labelName.text = _name;
}

- (void)setContent:(NSString *)_content {
  [super setContent:_content];
  labelContent.text = _content;
}

- (void)setTime_in_age_posted:(NSString *)_time_in_age_posted {
  [super setTime_in_age_posted:_time_in_age_posted];
  labelTimeAgePosted.text = _time_in_age_posted;
}

- (void)setThumb_path:(NSString *)thumb_path {
//  DLog(@"thumb_path: %@", thumb_path);
  [thumbImageView setImageWithURL:[NSURL URLWithString:thumb_path] placeholderImage:[UIImage imageNamed:@"loading.png"]];
}

- (void)setFacebook_id:(NSString *)_facebook_id {
  [profilePictureView setProfileID:_facebook_id];
}

- (void)setTotal_likes:(NSString *)_total_likes {
  [super setTotal_likes:_total_likes];
  labelTotalLikes.text = _total_likes;
}

- (void)setTotal_comments:(NSString *)_total_comments {
  [super setTotal_comments:_total_comments];
  labelTotalComments.text =  _total_comments;
}

- (void)dealloc {
  [cellContentView release];
  [labelName release];
  [thumbImageView release];
  
  [labelContent release];
  [labelTimeAgePosted release];
  [profilePictureView release];
  
  [labelTotalLikes release];
  [labelTotalComments release];
  
  [super dealloc];
}

@end
