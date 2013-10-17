#import "NumberTextFieldCell.h"
#import "UITableViewCellConstants.h"

@interface NumberTextFieldCell()
- (void)updateLabel;
@end

@implementation NumberTextFieldCell

RM_SYNTHESIZE(labelValue);
RM_SYNTHESIZE(currentCount);

- (void)dealloc
{
  RM_RELEASE(labelValue);

  [super dealloc];
}

- (id)initWithTitle:(NSString*)title initWithNumber:(int)count reuseIdentifier:(NSString *)reuseIdentifier
{
  UITableViewCellStyle style = UITableViewCellStyleDefault;
  
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  if (self)
  {
    self.currentCount = count;
    
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
    
    int contentWidth = 50.0f;
    
    labelValue_ = [[UILabel alloc] initWithFrame:CGRectMake(paddingHorizontal + lengthLabel, PADDING_VERTICAL, contentWidth, UITEXTFIELD_HEIGHT)];
    labelValue_.font = _font;
    labelValue_.textAlignment = UITextAlignmentRight;
    labelValue_.numberOfLines = 1;
    labelValue_.backgroundColor = UITABLEVIEWCELL_WHITE_BACKGROUND;
    labelValue_.text = [NSString stringWithFormat:@"%d", self.currentCount];
    
    [self.contentView addSubview:labelValue_];
    
    UIButton *buttonPlus = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonPlus setFrame:CGRectMake(paddingHorizontal + lengthLabel + labelValue_.frame.size.width + PADDING_HORIZONTAL, PADDING_VERTICAL + 3.0f, BUTTON_PLUS_MINUS, BUTTON_PLUS_MINUS)];
    [buttonPlus setTitle:@"+" forState:UIControlStateNormal];
    [buttonPlus addTarget:self action:@selector(add)
     forControlEvents:UIControlEventTouchUpInside];
    [buttonPlus setImage:[UIImage imageNamed:@"button_plus.png"] forState:UIControlStateNormal];
    [self.contentView addSubview:buttonPlus]; 
    
    UIButton *buttonMinus = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonMinus setFrame:CGRectMake(paddingHorizontal + lengthLabel + labelValue_.frame.size.width + PADDING_HORIZONTAL + BUTTON_PLUS_MINUS + 5.0f, PADDING_VERTICAL + 3.0f, BUTTON_PLUS_MINUS, BUTTON_PLUS_MINUS)];
    [buttonMinus setTitle:@"+" forState:UIControlStateNormal];
    [buttonMinus addTarget:self action:@selector(subtract)
     forControlEvents:UIControlEventTouchUpInside];
    [buttonMinus setImage:[UIImage imageNamed:@"button_minus.png"] forState:UIControlStateNormal];
    [self.contentView addSubview:buttonMinus];    
    
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

- (void)add
{
  if(self.currentCount < 100)
  {
    self.currentCount = self.currentCount + 1;
    [self updateLabel];
  }
}

- (void)subtract
{
  if(self.currentCount > 0)
  {
    self.currentCount = self.currentCount - 1;
    [self updateLabel];
  }
}

- (void)updateLabel
{
  self.labelValue.text = [NSString stringWithFormat:@"%d", self.currentCount];
}


@end
