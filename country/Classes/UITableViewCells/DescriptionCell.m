#import "DescriptionCell.h"
#import "UITableViewCellConstants.h"
#import "HelperTextUtils.h"

@implementation DescriptionCell

- (id)initWithTitle:(NSString*)title
    initWithContent:(NSString*)content
    reuseIdentifier:(NSString *)reuseIdentifier
       contentWidth:(int)contentWidth {
  
	UITableViewCellStyle style = UITableViewCellStyleDefault;

  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    if(contentWidth == 0) {
      contentWidth = self.contentView.bounds.size.width;
    }

    contentWidth = contentWidth - (2 * PADDING_HORIZONTAL);
    
		UIFont* _font = [UIFont boldSystemFontOfSize:12.0];
		
		UILabel* labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_HORIZONTAL, PADDING_VERTICAL, contentWidth, HEIGHT_STATIC_LABEL)];
		DLog(@"labelTitle width: %f height: %f", labelTitle.frame.size.width, labelTitle.frame.size.height);
		
    labelTitle.textAlignment = UITextAlignmentLeft;
    labelTitle.numberOfLines = 1;
    labelTitle.font = _font;
    labelTitle.textColor = COLOR_DESCRIPTION_LABEL;
    labelTitle.highlightedTextColor = [UIColor whiteColor];
    labelTitle.text = title;
		
		[self.contentView addSubview:labelTitle];
		[labelTitle release];
		
		int _totalHeight = PADDING_VERTICAL + HEIGHT_STATIC_LABEL;
		
		_font = [UIFont systemFontOfSize:12.0];
		int _heightDescription = [HelperTextUtils getHeightForString:content forFont:_font forWidth:contentWidth];
		
		UILabel* labelDescription = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_HORIZONTAL, _totalHeight, contentWidth, _heightDescription)];
		DLog(@"labelDescription width: %f height: %f", labelDescription.frame.size.width, labelDescription.frame.size.height);
		
    labelDescription.textAlignment = UITextAlignmentLeft;
    labelDescription.numberOfLines = 999;
    labelDescription.font = _font;
    labelDescription.textColor = COLOR_DESCRIPTION_TEXT;
    labelDescription.highlightedTextColor = [UIColor whiteColor];
    labelDescription.lineBreakMode = UILineBreakModeWordWrap;
    labelDescription.text = content;
		
		[self.contentView addSubview:labelDescription];
		[labelDescription release];
		
		_totalHeight = _totalHeight + _heightDescription + PADDING_VERTICAL;
		
		//Adjust the height of the contentView
		CGRect newFrame = self.contentView.frame;
		newFrame.size.height = _totalHeight;
		self.contentView.frame = newFrame;
		
    self.selectionStyle = UITableViewCellSelectionStyleNone;

		DLog(@"cellContentView width: %f height: %f", self.contentView.frame.size.width, self.contentView.frame.size.height);
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
