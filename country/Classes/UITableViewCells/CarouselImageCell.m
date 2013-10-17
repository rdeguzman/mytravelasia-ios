#import "CarouselImageCell.h"

@implementation CarouselImageCell

- (id)initWithArray:(NSArray*)arrayPictures
    reuseIdentifier:(NSString *)reuseIdentifier
       contentWidth:(int)contentWidth {
  UITableViewCellStyle style = UITableViewCellStyleDefault;
	
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  if (self) {
    
    NSMutableArray *arrayURLImages = [[NSMutableArray alloc] initWithObjects:nil];
    
    for(NSDictionary *dict in arrayPictures){
      NSString *fullURL = [dict objectForKey:@"full"];
      [arrayURLImages addObject:fullURL];
		}
    
    if(contentWidth == 0) {
      contentWidth = self.contentView.bounds.size.width;
    }
    
    CGRect frame = CGRectMake(0, 0, contentWidth, 320.0f);
    carousel = [[Carousel alloc] initWithFrame:frame];
    
    // Add some images to carousel, we are passing autoreleased NSArray
    [carousel setImageURLs:arrayURLImages];
    [arrayURLImages release];
    
    [self.contentView addSubview:carousel];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.contentView.frame = frame;
  }
  
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)dealloc {
  [carousel release];
  [super dealloc];
}


@end
