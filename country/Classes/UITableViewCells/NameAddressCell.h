//
//  NameAddressCell.h
//  Country
//
//  Created by rupert on 13/04/11.
//  Copyright 2011 2RMobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NameAddressCell : UITableViewCell {

}

- (id)initWithName:(NSString*)name
   initWithAddress:(NSString*)address
   reuseIdentifier:(NSString *)reuseIdentifier
      contentWidth:(int)contentWidth;

@end
