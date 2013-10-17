#import "CommentCell.h"
#import "UITableViewCellConstants.h"
#import "HelperTextUtils.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation CommentCell

- (id)initWithName:(NSString*)name initWithContent:(NSString*)content profileId:(NSString*)facebookId timePosted:(NSString*)timeInWords reuseIdentifier:(NSString *)reuseIdentifier {
	UITableViewCellStyle style = UITableViewCellStyleDefault;
  
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
		int contentWidth = self.contentView.bounds.size.width - (2 * PADDING_HORIZONTAL);
    int imageWidth = 32.0f;
    int imageHeight = 32.0f;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    //self.contentView.backgroundColor = UITABLEVIEWCELL_LIGHT_BACKGROUND;
    
    FBProfilePictureView *profilePictureView = [[FBProfilePictureView alloc] initWithProfileID:facebookId pictureCropping:FBProfilePictureCroppingSquare];
    profilePictureView.frame = CGRectMake(PADDING_HORIZONTAL, PADDING_VERTICAL, imageWidth, imageHeight);
    DLog(@"profilePictureView width: %f height: %f", profilePictureView.frame.size.width, profilePictureView.frame.size.height);
    [self.contentView addSubview:profilePictureView];
		
    CGFloat labelOriginX = PADDING_HORIZONTAL + imageWidth + PADDING_HORIZONTAL;
    CGFloat labelContentWidth = contentWidth - (imageWidth + CELL_ACESSORY_WIDTH);
		UILabel* labelName = [[UILabel alloc] initWithFrame:CGRectMake(labelOriginX, PADDING_VERTICAL, labelContentWidth, HEIGHT_STATIC_LABEL)];
		DLog(@"labelTitle width: %f height: %f", labelName.frame.size.width, labelName.frame.size.height);
		
    labelName.textAlignment = UITextAlignmentLeft;
		labelName.numberOfLines = 1;
    labelName.font = [UIFont boldSystemFontOfSize:14.0f];
		labelName.textColor = COLOR_DESCRIPTION_LABEL;
    labelName.highlightedTextColor = [UIColor whiteColor];
    //labelName.backgroundColor = UITABLEVIEWCELL_LIGHT_BACKGROUND;
    //labelName.backgroundColor = [UIColor redColor];
		labelName.text = name;
		
		[self.contentView addSubview:labelName];
		[labelName release];

    int _totalHeight = PADDING_VERTICAL + HEIGHT_STATIC_LABEL;
    
    UILabel* labelTime = [[UILabel alloc] initWithFrame:CGRectMake(labelOriginX, _totalHeight, labelContentWidth, HEIGHT_STATIC_LABEL/2.0f)];
    labelTime.textAlignment = UITextAlignmentLeft;
		labelTime.numberOfLines = 1;
    labelTime.font = [UIFont systemFontOfSize:10.0f];
		labelTime.textColor = COLOR_DESCRIPTION_LABEL;
    labelTime.highlightedTextColor = [UIColor whiteColor];
    //labelTime.backgroundColor = UITABLEVIEWCELL_LIGHT_BACKGROUND;
    //labelTime.backgroundColor = [UIColor yellowColor];
		labelTime.text = timeInWords;

    [self.contentView addSubview:labelTime];
		[labelTime release];

		_totalHeight = _totalHeight + labelTime.frame.size.height + 5.0f;
		
		UIFont* _font = [UIFont systemFontOfSize:12.0];
		int _heightDescription = [HelperTextUtils getHeightForString:content forFont:_font forWidth:labelContentWidth];
		
		UILabel* labelContent = [[UILabel alloc] initWithFrame:CGRectMake(labelOriginX, _totalHeight, labelContentWidth, _heightDescription)];
    labelContent.textAlignment = UITextAlignmentLeft;
		labelContent.numberOfLines = 999;
    labelContent.font = _font;
		labelContent.textColor = COLOR_DESCRIPTION_TEXT;
    labelContent.highlightedTextColor = [UIColor whiteColor];
		labelContent.lineBreakMode = UILineBreakModeWordWrap;
    //labelContent.backgroundColor = [UIColor yellowColor];
		labelContent.text = content;
		
		[self.contentView addSubview:labelContent];
		[labelContent release];
		
		_totalHeight = _totalHeight + _heightDescription + PADDING_VERTICAL;
		
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
}

@end
