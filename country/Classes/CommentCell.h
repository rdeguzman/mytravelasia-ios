#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell

- (id)initWithName:(NSString*)name initWithContent:(NSString*)content profileId:(NSString*)facebookId timePosted:(NSString*)timeInWords reuseIdentifier:(NSString *)reuseIdentifier;

@end
