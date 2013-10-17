#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ApplicationCell : UITableViewCell
{
  BOOL useDarkBackground;

  NSString *name;
  NSString *address;
  NSString *distance;
  NSString *min_rate;

  NSString *total_stars;
  NSString *total_ratings;
  NSString *thumbPath;
  
  NSString *content;
  NSString *time_in_age_posted;
  NSString *facebook_id;
  
  NSString *total_likes;
  NSString *total_comments;
}

@property(nonatomic) BOOL useDarkBackground;

@property(retain) NSString *address;
@property(retain) NSString *name;
@property(retain) NSString *total_stars;
@property(retain) NSString *total_ratings;
@property(retain) NSString *distance;
@property(retain) NSString *min_rate;
@property(retain) NSString *thumb_path;

@property(retain) NSString *content;
@property(retain) NSString *time_in_age_posted;
@property(retain) NSString *facebook_id;

@property(retain) NSString *total_likes;
@property(retain) NSString *total_comments;

@end
