#import <UIKit/UIKit.h>

@interface EditableTextFieldCell : UITableViewCell

@property(nonatomic, retain) UITextField *textfield;

- (id)initWithTitle:(NSString*)title initWithContent:(NSString*)content reuseIdentifier:(NSString *)reuseIdentifier delegate:(id)parent keyboardType:(UIKeyboardType)keyboardType;

@end
