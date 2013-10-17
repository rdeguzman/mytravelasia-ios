#import "NameAddressCell.h"
#import "UITableViewCellConstants.h"
#import "HelperTextUtils.h"

@implementation NameAddressCell

- (id)initWithName:(NSString*)name
   initWithAddress:(NSString*)address
   reuseIdentifier:(NSString *)reuseIdentifier
      contentWidth:(int)contentWidth {
    
	UITableViewCellStyle style = UITableViewCellStyleDefault;
	
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

  if (self) {
    if(contentWidth == 0) {
      contentWidth = self.contentView.bounds.size.width;
    }
    
    contentWidth = contentWidth - (2 * PADDING_HORIZONTAL);

    UIFont* _font = [UIFont boldSystemFontOfSize:18.0];
    int _heightName = [HelperTextUtils getHeightForString:name forFont:_font forWidth:contentWidth];
    int _totalHeight = PADDING_VERTICAL;

    UILabel* labelName = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_HORIZONTAL, _totalHeight, contentWidth, _heightName)];
    DLog(@"labelName width: %f height: %f", labelName.frame.size.width, labelName.frame.size.height);

    labelName.textAlignment = UITextAlignmentLeft;
    labelName.numberOfLines = 999;
    labelName.font = _font;
    labelName.textColor = COLOR_NAME_LABEL;
    labelName.highlightedTextColor = [UIColor whiteColor];
    labelName.lineBreakMode = UILineBreakModeWordWrap;
    labelName.backgroundColor = COLOR_NAME_ADDRESS_BACKGROUND;
    labelName.text = name;

    [self.contentView addSubview:labelName];
    _totalHeight = _totalHeight + _heightName;

    _font = [UIFont systemFontOfSize:12.0];
    DLog(@"contentwidth: %d", contentWidth);

    int _heightAddress = [HelperTextUtils getHeightForString:address forFont:_font forWidth:contentWidth];
    
    UILabel* labelAddress = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_HORIZONTAL, _totalHeight, contentWidth, _heightAddress)];
    DLog(@"labelAddress width: %f height: %f", labelAddress.frame.size.width, labelAddress.frame.size.height);

    labelAddress.textAlignment = UITextAlignmentLeft;
    labelAddress.numberOfLines = 999;
    labelAddress.font = _font;
    labelAddress.textColor = COLOR_ADDRESS_LABEL;
    labelAddress.highlightedTextColor = [UIColor whiteColor];
    labelAddress.lineBreakMode = UILineBreakModeWordWrap;
    labelAddress.backgroundColor = COLOR_NAME_ADDRESS_BACKGROUND;
    labelAddress.text = address;
    
    [self.contentView addSubview:labelAddress];
    _totalHeight = _totalHeight + _heightAddress + PADDING_VERTICAL;
    
    [labelName release];
    [labelAddress release];
    
    //Adjust the height of the contentView
    CGRect newFrame = self.contentView.frame;
    newFrame.size.height = _totalHeight;
    self.contentView.frame = newFrame;
    
    self.contentView.backgroundColor = COLOR_NAME_ADDRESS_BACKGROUND;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    DLog(@"cellContentView.width: %f height: %f", self.contentView.frame.size.width, self.contentView.frame.size.height);
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)dealloc {
  [super dealloc];
}

@end
