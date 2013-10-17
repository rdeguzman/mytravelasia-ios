#import <UIKit/UIKit.h>

@interface EditableTextViewCell : UITableViewCell

@property(nonatomic, retain) UITextView *textview;

- (id)initWithTitle:(NSString*)title initWithContent:(NSString*)content reuseIdentifier:(NSString *)reuseIdentifier delegate:(id)parent;

@end
