#import "EditableTextViewCell.h"
#import "UITableViewCellConstants.h"
#import "HelperDevice.h"

@implementation EditableTextViewCell

RM_SYNTHESIZE(textview);

- (void)dealloc
{
  RM_RELEASE(textview);
  [super dealloc];
}

- (id)initWithTitle:(NSString*)title initWithContent:(NSString*)content reuseIdentifier:(NSString *)reuseIdentifier delegate:(id)parent
{
  
  UITableViewCellStyle style = UITableViewCellStyleDefault;
  
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self)
  {
    int lengthLabel = 80.0f;
    int paddingHorizontal = PADDING_HORIZONTAL;
    
    UIFont* _font = [UIFont boldSystemFontOfSize:12.0];
    
    int _heightName = 34.0f;
    
    UILabel* labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(paddingHorizontal, PADDING_VERTICAL, lengthLabel, _heightName)];
    labelTitle.textAlignment = UITextAlignmentLeft;
    labelTitle.numberOfLines = 1;
    labelTitle.font = _font;
    labelTitle.textColor = COLOR_TITLE_LABEL;
    labelTitle.highlightedTextColor = [UIColor whiteColor];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.text = title;
    
    [self.contentView addSubview:labelTitle];
    [labelTitle release];
    
    _font = [UIFont systemFontOfSize:12.0];
    
    int contentWidth = 0;

    if([HelperDevice isDeviceAniPad])
      contentWidth = 500.0f - (paddingHorizontal + lengthLabel + CELL_ACESSORY_WIDTH + (PADDING_VERTICAL * 2));
    else
      contentWidth = self.contentView.bounds.size.width - (paddingHorizontal + lengthLabel + CELL_ACESSORY_WIDTH + (PADDING_VERTICAL * 2));
    
    int _heightDescription = 100.0f;
    
    textview_ = [[UITextView alloc] initWithFrame:CGRectMake(paddingHorizontal + lengthLabel, PADDING_VERTICAL, contentWidth, _heightDescription)];
    textview_.textAlignment = UITextAlignmentLeft;
    textview_.font = _font;
    textview_.textColor = COLOR_TEXT_LABEL;
    textview_.backgroundColor = UITABLEVIEWCELL_WHITE_BACKGROUND;
    textview_.text = content;
    textview_.editable = NO;
    textview_.scrollEnabled = YES;
    textview_.dataDetectorTypes = UIDataDetectorTypeAll;
    //textview.contentInset = UIEdgeInsetsMake(-11, -8, 0, 0);
    
    [self.contentView addSubview:textview_];
    
    int _totalHeight = PADDING_VERTICAL + _heightDescription + PADDING_VERTICAL;
    
    //Adjust the height of the contentView
    CGRect newFrame = self.contentView.frame;
    newFrame.size.height = _totalHeight;
    self.contentView.frame = newFrame;

    self.contentView.backgroundColor = [UIColor clearColor];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }

  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
}

@end
