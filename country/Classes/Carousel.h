//
//  Carousel.h
//  SimpleCarousel
//
//  Created by rupert on 6/10/12.
//  Copyright (c) 2012 rupert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Carousel : UIView <UIScrollViewDelegate>
{
  UIPageControl *pageControl;
  NSArray *imageURLs;
}

@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) NSArray *imageURLs;

- (void)setup;

@end