#import "ClickableDescriptionCell.h"
#import "UITableViewCellConstants.h"
#import "HelperTextUtils.h"

@implementation ClickableDescriptionCell

- (id)initWithTitle:(NSString*)title
    initWithContent:(NSString*)content
    reuseIdentifier:(NSString *)reuseIdentifier
       contentWidth:(int)contentWidth {

  UITableViewCellStyle style = UITableViewCellStyleDefault;

  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    int lengthLabel = 70.0f;
    int paddingHorizontal = PADDING_HORIZONTAL * 2;

    UIFont* _font = [UIFont boldSystemFontOfSize:12.0];

    int _heightName = [HelperTextUtils getHeightForString:title forFont:_font forWidth:lengthLabel];

    UILabel* labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(paddingHorizontal, PADDING_VERTICAL, lengthLabel, _heightName)];
    DLog(@"labelTitle width: %f height: %f", labelTitle.frame.size.width, labelTitle.frame.size.height);

    labelTitle.textAlignment = UITextAlignmentLeft;
    labelTitle.numberOfLines = 1;
    labelTitle.font = _font;
    labelTitle.textColor = COLOR_TITLE_LABEL;
    labelTitle.highlightedTextColor = [UIColor whiteColor];
    labelTitle.backgroundColor = UITABLEVIEWCELL_WHITE_BACKGROUND;
    //labelTitle.backgroundColor = [UIColor redColor];
    labelTitle.text = title;

    [self.contentView addSubview:labelTitle];
    [labelTitle release];

    _font = [UIFont systemFontOfSize:12.0];

    if(contentWidth == 0) {
      contentWidth = self.contentView.bounds.size.width;
    }
    
    contentWidth = contentWidth - (paddingHorizontal + lengthLabel);

    int _heightDescription = [HelperTextUtils getHeightForString:content forFont:_font forWidth:contentWidth];

    UITextView* textview = [[UITextView alloc] initWithFrame:CGRectMake(paddingHorizontal + lengthLabel, PADDING_VERTICAL, contentWidth, _heightDescription)];

    textview.textAlignment = UITextAlignmentRight;
    textview.font = _font;
    textview.textColor = COLOR_TEXT_LABEL;
    textview.backgroundColor = UITABLEVIEWCELL_WHITE_BACKGROUND;
    //textview.backgroundColor = [UIColor whiteColor];
    textview.text = content;
    textview.editable = NO;
    textview.scrollEnabled = NO;
    textview.dataDetectorTypes = UIDataDetectorTypeAll;
    textview.contentInset = UIEdgeInsetsMake(-11, -8, 0, 0);

    [self.contentView addSubview:textview];
    [textview release];

    int _totalHeight = PADDING_VERTICAL + _heightDescription + PADDING_VERTICAL;

    //Adjust the height of the contentView
    CGRect newFrame = self.contentView.frame;
    newFrame.size.height = _totalHeight;
    self.contentView.frame = newFrame;

    self.contentView.backgroundColor = UITABLEVIEWCELL_WHITE_BACKGROUND;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    DLog(@"cellContentView width: %f height: %f", self.contentView.frame.size.width, self.contentView.frame.size.height);
  }

  return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
}

- (void)dealloc
{
  [super dealloc];
}

@end