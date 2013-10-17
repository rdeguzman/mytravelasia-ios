#import "EditableTextFieldCell.h"
#import "UITableViewCellConstants.h"
#import "HelperDevice.h"

@implementation EditableTextFieldCell

RM_SYNTHESIZE(textfield);

- (void)dealloc
{
  RM_RELEASE(textfield);
  [super dealloc];
}

- (id)initWithTitle:(NSString*)title initWithContent:(NSString*)content reuseIdentifier:(NSString *)reuseIdentifier delegate:(id)parent keyboardType:(UIKeyboardType)keyboardType
{
  
  UITableViewCellStyle style = UITableViewCellStyleDefault;
  
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  if (self)
  {
    int lengthLabel = 80.0f;
    int paddingHorizontal = PADDING_HORIZONTAL;
    
    UIFont* _font = [UIFont boldSystemFontOfSize:12.0];
    
    UILabel* labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(paddingHorizontal, PADDING_VERTICAL, lengthLabel, UITEXTFIELD_HEIGHT)];
    labelTitle.textAlignment = UITextAlignmentLeft;
    labelTitle.numberOfLines = 1;
    labelTitle.font = _font;
    labelTitle.textColor = BLUE_DARKER_COLOR;
    labelTitle.highlightedTextColor = [UIColor whiteColor];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.text = title;
    
    [self.contentView addSubview:labelTitle];
    [labelTitle release];
    
    _font = [UIFont systemFontOfSize:14.0];

    int contentWidth = 0;

    if([HelperDevice isDeviceAniPad])
      contentWidth = 500.0f - (paddingHorizontal + lengthLabel + 30.0f);
    else
      contentWidth = self.contentView.bounds.size.width - (paddingHorizontal + lengthLabel + 30.0f);
    
    DLog(@"contentView: %d", contentWidth);
    
    textfield_ = [[UITextField alloc] initWithFrame:CGRectMake(paddingHorizontal + lengthLabel, PADDING_VERTICAL, contentWidth, UITEXTFIELD_HEIGHT)];
    DLog(@"textview width: %f height: %f", textfield_.frame.size.width, textfield_.frame.size.height);
    
    textfield_.textAlignment = UITextAlignmentLeft;
    textfield_.font = _font;
    textfield_.backgroundColor = UITABLEVIEWCELL_WHITE_BACKGROUND;
    textfield_.text = content;
    textfield_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textfield_.delegate = parent;
    
    if(keyboardType != UIKeyboardTypeDefault)
      textfield_.keyboardType = keyboardType;
    
    [self.contentView addSubview:textfield_];
    
    int _totalHeight = PADDING_VERTICAL + UITEXTFIELD_HEIGHT + PADDING_VERTICAL;
    
    //Adjust the height of the contentView
    CGRect newFrame = self.contentView.frame;
    newFrame.size.height = _totalHeight;
    self.contentView.frame = newFrame;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
}

@end
