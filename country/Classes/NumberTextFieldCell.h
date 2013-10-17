#import <UIKit/UIKit.h>

@interface NumberTextFieldCell : UITableViewCell

@property(nonatomic, retain) UILabel *labelValue;

@property(nonatomic) int currentCount;

- (id)initWithTitle:(NSString*)title initWithNumber:(int)count reuseIdentifier:(NSString *)reuseIdentifier;
@end
