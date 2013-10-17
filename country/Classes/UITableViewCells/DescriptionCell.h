//
//  DescriptionCell.h
//  Country
//
//  Created by rupert on 13/04/11.
//  Copyright 2011 2RMobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DescriptionCell : UITableViewCell {

}

- (id)initWithTitle:(NSString*)title
    initWithContent:(NSString*)content
    reuseIdentifier:(NSString *)reuseIdentifier
       contentWidth:(int)contentWidth;

@end
