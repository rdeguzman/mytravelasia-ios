#import "PoiImageTableViewApplicationCell.h"
#import "MainTableViewConstants.h"
#import "UIImageView+AFNetworking.h"

#define MAX_RATING 5.0

@interface PoiImageTableViewApplicationCellContentView : UIView {
    ApplicationCell *_cell;
    BOOL _highlighted;
}

@end

@implementation PoiImageTableViewApplicationCellContentView

- (id)initWithFrame:(CGRect)frame cell:(ApplicationCell *)cell {
  if (self = [super initWithFrame:frame]) {
    _cell = cell;

    self.opaque = YES;
    self.backgroundColor = _cell.backgroundColor;
  }

  return self;
}

- (void)drawRect:(CGRect)rect {
//  DLog(@"");
//  [[NSString stringWithFormat:@"%@ Ratings", _cell.total_ratings] drawAtPoint:CGPointMake(150.0, 50.0) withFont:[UIFont systemFontOfSize:10.0]];

//  CGPoint ratingImageOrigin = CGPointMake(75.0f, 48.0);
//  UIImage *ratingBackgroundImage = [UIImage imageNamed:@"StarsBackground.png"];
//  [ratingBackgroundImage drawAtPoint:ratingImageOrigin];
//  UIImage *ratingForegroundImage = [UIImage imageNamed:@"StarsForeground.png"];
//
//  CGFloat total_stars = [[_cell total_stars] floatValue];
//  UIRectClip(CGRectMake(ratingImageOrigin.x, ratingImageOrigin.y, ratingForegroundImage.size.width * (total_stars / MAX_RATING), ratingForegroundImage.size.height));
//
//  [ratingForegroundImage drawAtPoint:ratingImageOrigin];
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
@implementation PoiImageTableViewApplicationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    cellContentView = [[PoiImageTableViewApplicationCellContentView alloc] initWithFrame:CGRectInset(self.contentView.bounds, 0.0, 1.0) cell:self];
//    DLog(@"%f %f content_text_width:%f", cellContentView.frame.size.width, cellContentView.frame.size.height, CONTENT_TEXT_WIDTH);

    cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cellContentView.contentMode = UIViewContentModeLeft;
    [self.contentView addSubview:cellContentView];
    
    CGRect photoFrame = CGRectMake(PADDING_LEFT-1.0f, PADDING_TOP-1.0f, TABLEVIEW_CELL_THUMB_BACKGROUND_WIDTH, TABLEVIEW_CELL_THUMB_BACKGROUND_HEIGHT);

    thumbImageView = [[UIImageView alloc] initWithFrame:photoFrame];
    thumbImageView.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:thumbImageView];

    CGFloat contentWidth = 320.0f - (CONTENT_TEXT_ORIGIN_X + PADDING_RIGHT);
    //DLog(@"CONTENT_TEXT_ORIGIN_X:%f contentWidth:%f", CONTENT_TEXT_ORIGIN_X, contentWidth);

    labelName = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_TEXT_ORIGIN_X, 8.0f, contentWidth, 20.0f)];
    labelName.textAlignment = UITextAlignmentLeft;
    labelName.font = [UIFont boldSystemFontOfSize:14.0];
    labelName.textColor = [UIColor blackColor];
    //labelName.highlightedTextColor = [UIColor whiteColor];
    labelName.backgroundColor = [UIColor clearColor];
    //labelName.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:labelName];

    labelAddress = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_TEXT_ORIGIN_X, 29.0f, contentWidth - CELL_ACCESSORY_WIDTH, 15.0f)];
    labelAddress.textAlignment = UITextAlignmentLeft;
    labelAddress.font = [UIFont boldSystemFontOfSize:11.0];
    labelAddress.textColor = [UIColor colorWithWhite:0.23 alpha:1.0];
    //labelAddress.highlightedTextColor = [UIColor whiteColor];
    labelAddress.backgroundColor = [UIColor clearColor];
    //labelAddress.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:labelAddress];
    
    UIImageView *imageLike = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_like.png"]];
    imageLike.frame = CGRectMake(CONTENT_TEXT_ORIGIN_X, 48.0f, 16.0f, 16.0f);
    [self.contentView addSubview:imageLike];
    [imageLike release];

    labelTotalLikes = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_TEXT_ORIGIN_X + 20.0f, 48.0f, 25.0f, 16.0f)];
    labelTotalLikes.textAlignment = UITextAlignmentLeft;
    labelTotalLikes.font = [UIFont boldSystemFontOfSize:12.0f];
    labelTotalLikes.textColor = [UIColor colorWithWhite:0.23 alpha:1.0];
    labelTotalLikes.backgroundColor = [UIColor clearColor];
    //labelTotalLikes.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:labelTotalLikes];
    
    UIImageView *imageComment = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_comment.png"]];
    imageComment.frame = CGRectMake(CONTENT_TEXT_ORIGIN_X + 50.0f, 48.0f, 16.0f, 16.0f);
    [self.contentView addSubview:imageComment];
    [imageComment release];
    
    labelTotalComments = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_TEXT_ORIGIN_X + 50.0f + 20.0f, 48.0f, 25.0f, 16.0f)];
    labelTotalComments.textAlignment = UITextAlignmentLeft;
    labelTotalComments.font = [UIFont boldSystemFontOfSize:12.0f];
    labelTotalComments.textColor = [UIColor colorWithWhite:0.23 alpha:1.0];
    labelTotalComments.backgroundColor = [UIColor clearColor];
    //labelTotalComments.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:labelTotalComments];

    labelMinRate = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_TEXT_ORIGIN_X + 50.0f + 50.0f, 48.0f, 75.0f, 16.0f)];
    labelMinRate.textAlignment = UITextAlignmentLeft;
    labelMinRate.font = [UIFont boldSystemFontOfSize:12.0f];
    labelMinRate.textColor = [UIColor yellowColor];
    labelMinRate.highlightedTextColor = [UIColor orangeColor];
    labelMinRate.backgroundColor = [UIColor clearColor];
    //labelMinRate.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:labelMinRate];

    CGFloat distanceCellWidth = 60.0f;
    labelDistance = [[UILabel alloc] initWithFrame:CGRectMake(320.0f - distanceCellWidth - PADDING_RIGHT, 48.0f, distanceCellWidth, 16.0f)];
    labelDistance.textAlignment = UITextAlignmentRight;
    labelDistance.font = [UIFont boldSystemFontOfSize:11.0];
    labelDistance.textColor = [UIColor colorWithWhite:0.23 alpha:1.0];
    //labelDistance.highlightedTextColor = [UIColor whiteColor];
    labelDistance.backgroundColor = [UIColor clearColor];
    //labelDistance.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:labelDistance];
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

- (void)setAddress:(NSString *)_address {
  [super setAddress:_address];
  labelAddress.text = _address;
}

- (void)setDistance:(NSString *)_distance {
	[super setDistance:_distance];
	labelDistance.text = _distance;
}

- (void)setMin_rate:(NSString*)_rate {
  if([_rate isEqualToString:@"0"]){
    [super setMin_rate:@""];
    labelMinRate.text = @"";
  }
  else{
    [super setMin_rate:_rate];
    labelMinRate.text = _rate;
  }
}

- (void)setThumb_path:(NSString *)thumb_path {
  NSLog(@"thumb_path: %@", thumb_path);
  [thumbImageView setImageWithURL:[NSURL URLWithString:thumb_path] placeholderImage:[UIImage imageNamed:@"loading.png"]];
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
  [labelAddress release];
  [labelDistance release];
  [labelMinRate release];
  [thumbImageView release];
  
  [labelTotalLikes release];
  [labelTotalComments release];

  [super dealloc];
}

@end
