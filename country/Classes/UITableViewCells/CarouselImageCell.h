#import <UIKit/UIKit.h>
#import "Carousel.h"

@interface CarouselImageCell : UITableViewCell {
  Carousel *carousel;
}

- (id)initWithArray:(NSArray*)arrayPictures
    reuseIdentifier:(NSString *)reuseIdentifier
       contentWidth:(int)contentWidth;

@end
