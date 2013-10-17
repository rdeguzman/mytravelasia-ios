//
//  Carousel.m
//  SimpleCarousel
//
//  Created by rupert on 6/10/12.
//  Copyright (c) 2012 rupert. All rights reserved.
//

#import "Carousel.h"
#import "UIImageView+AFNetworking.h"

@implementation Carousel

@synthesize pageControl;
@synthesize imageURLs;

#pragma mark - Override images setter

- (void)setImageURLs:(NSArray *)newImages
{
  if (newImages != imageURLs)
  {
    [newImages retain];
    [imageURLs release];
    imageURLs = newImages;
    
    [self setup];
  }
}

#pragma mark - Carousel setup

- (void)setup
{
  UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
  [scrollView setDelegate:self];
  [scrollView setShowsHorizontalScrollIndicator:NO];
  [scrollView setPagingEnabled:YES];
  [scrollView setBounces:NO];
  
  CGSize scrollViewSize = scrollView.frame.size;
  
  for (NSInteger i = 0; i < [self.imageURLs count]; i++) {
    CGRect slideRect = CGRectMake(scrollViewSize.width * i, 0, scrollViewSize.width, scrollViewSize.height);
    
    UIView *slide = [[UIView alloc] initWithFrame:slideRect];
    [slide setBackgroundColor:[UIColor blackColor]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.frame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGFloat spinnerX = (slideRect.size.width/2.0f);
    CGFloat spinnerY = (slideRect.size.height/2.0f);
    spinner.center = CGPointMake(spinnerX, spinnerY);
    [spinner startAnimating];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.imageURLs objectAtIndex:i]]];
    [imageView setImageWithURLRequest:request
                     placeholderImage:nil
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                [spinner stopAnimating];
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                [spinner stopAnimating];
                                NSLog(@"failure");
                              }];
    
    
    [slide addSubview:imageView];
    [imageView release];
    
    [slide addSubview:spinner];
    [spinner release];

    [scrollView addSubview:slide];
    [slide release];
  }
  
  UIPageControl *tempPageControll = [[UIPageControl alloc] initWithFrame:CGRectMake(0, scrollViewSize.height - 20, scrollViewSize.width, 20)];
  [self setPageControl:tempPageControll];
  [tempPageControll release];
  [self.pageControl setNumberOfPages:[self.imageURLs count]];
  [scrollView setContentSize:CGSizeMake(scrollViewSize.width * [self.imageURLs count], scrollViewSize.height)];
  
  [self addSubview:scrollView];
  [scrollView release];
  [self addSubview:self.pageControl];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat pageWidth = scrollView.frame.size.width;
  int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	[self.pageControl setCurrentPage:page];
}

#pragma mark - Cleanup

- (void)dealloc
{
  [pageControl release];
  [imageURLs release];
  [super dealloc];
}

@end