#import "ApplicationCell.h"

@implementation ApplicationCell

@synthesize useDarkBackground, address, name, total_stars, total_ratings, distance, min_rate, thumb_path;
@synthesize content, time_in_age_posted, facebook_id;
@synthesize total_likes, total_comments;

- (void)setUseDarkBackground:(BOOL)flag
{
  if (flag != useDarkBackground || !self.backgroundView)
  {
    useDarkBackground = flag;

    NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:useDarkBackground ? @"DarkBackground" : @"LightBackground" ofType:@"png"];
    UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
    self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.frame = self.bounds;
  }
}

- (void)dealloc
{
  [name release];
  [address release];
  [total_stars release];
  [total_ratings release];
  [distance release];
  [min_rate release];
  [thumb_path release];
  
  [content release];
  [time_in_age_posted release];
  [facebook_id release];
  [total_likes release];
  [total_comments release];

  [super dealloc];
}

@end