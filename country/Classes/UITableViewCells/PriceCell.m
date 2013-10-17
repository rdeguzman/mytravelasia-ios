#import "PriceCell.h"
#import "HelperTextUtils.h"
#import "UITableViewCellConstants.h"

@implementation PriceCell

- (id)initWithTitle:(NSString*)title initWithContent:(NSString*)content reuseIdentifier:(NSString *)reuseIdentifier
{
  UITableViewCellStyle style = UITableViewCellStyleDefault;

  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self)
  {
    NSString* titleRight = @"Check Now";

    int _lengthContentLeft = 75.0f;
    int _lengthCellAccessory = CELL_ACESSORY_WIDTH;
    int _lengthTitleRight = 75.0f + _lengthCellAccessory;

    UIFont* _fontContent = [UIFont systemFontOfSize:18.0];

    int _widthContent = self.contentView.bounds.size.width - PADDING_HORIZONTAL - _lengthContentLeft - PADDING_HORIZONTAL - _lengthTitleRight;
    int _heightContent = [HelperTextUtils getHeightForString:content forFont:_fontContent forWidth:_widthContent];

    int labelTitleY = PADDING_VERTICAL + (_heightContent - HEIGHT_STATIC_LABEL)/2.0f;
    UILabel*
    labelTitleLeft = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_HORIZONTAL,labelTitleY, _lengthContentLeft, HEIGHT_STATIC_LABEL)];
    DLog(@"labelTitle width: %f height: %f", labelTitleLeft.frame.size.width, labelTitleLeft.frame.size.height);

    labelTitleLeft.textAlignment = UITextAlignmentLeft;
    labelTitleLeft.numberOfLines = 1;
    labelTitleLeft.font = [UIFont systemFontOfSize:10];
    labelTitleLeft.textColor = COLOR_PRICE_LABEL;
    labelTitleLeft.highlightedTextColor = [UIColor whiteColor];

    //Note: the background should be the same for UITableView background as not to distort backgroundColor of CellAccessory
    labelTitleLeft.backgroundColor = UITABLEVIEWCELL_LIGHTER_BACKGROUND;
    //labelTitle.backgroundColor = [UIColor redColor];
    labelTitleLeft.text = title;

    [self.contentView addSubview:labelTitleLeft];
    [labelTitleLeft release];

    UILabel* labelPrice = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_HORIZONTAL + _lengthContentLeft, PADDING_VERTICAL, _widthContent, _heightContent)];
    DLog(@"labelPrice width: %f height: %f", labelPrice.frame.size.width, labelPrice.frame.size.height);

    labelPrice.adjustsFontSizeToFitWidth = NO;
    labelPrice.textAlignment = UITextAlignmentCenter;
    labelPrice.numberOfLines = 2;
    labelPrice.font = _fontContent;
    labelPrice.textColor = COLOR_PRICE;
    labelPrice.highlightedTextColor = [UIColor whiteColor];
    labelPrice.backgroundColor = UITABLEVIEWCELL_LIGHTER_BACKGROUND;
    labelPrice.text = content;

    [self.contentView addSubview:labelPrice];
    [labelPrice release];

    UILabel* labelTitleRight = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_HORIZONTAL + _lengthContentLeft + _widthContent, labelTitleY, _lengthTitleRight, HEIGHT_STATIC_LABEL)];
    DLog(@"labelTitleRight width: %f height: %f", labelTitleRight.frame.size.width, labelTitleRight.frame.size.height);

    labelTitleRight.textAlignment = UITextAlignmentCenter;
    labelTitleRight.numberOfLines = 1;
    labelTitleRight.font = [UIFont boldSystemFontOfSize:14.0];
    labelTitleRight.textColor = COLOR_PRICE_BUTTON_LABEL;
    labelTitleRight.highlightedTextColor = [UIColor whiteColor];
    labelTitleRight.backgroundColor = UITABLEVIEWCELL_LIGHTER_BACKGROUND;
    labelTitleRight.text = titleRight;

    [self.contentView addSubview:labelTitleRight];
    [labelTitleRight release];

    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    CGFloat _totalHeight = PADDING_VERTICAL + _heightContent + PADDING_VERTICAL;

    //Adjust the height of the contentView
    CGRect newFrame = self.contentView.frame;
    newFrame.size.height = _totalHeight;
    self.contentView.frame = newFrame;

    DLog(@"cellContentView width: %f height: %f", self.contentView.frame.size.width, self.contentView.frame.size.height);
  }
  
  return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
