//
//  SeasonCategoriesCell.m
//  shopn
//
//  Created by Frantzdy romain on 12/28/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import "SeasonCategoriesCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation SeasonCategoriesCell

- (void)awakeFromNib {
    // Initialization code
    //st border
//    self.iconContainer.frame = CGRectInset(self.iconContainer.frame, -1.0f, -1.0f);
//    self.iconContainer.layer.borderWidth = 1.0f;
//    self.iconContainer.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
//    //
    self.iconContainer.layer.cornerRadius = self.iconContainer.frame.size.width / 2;
    self.iconContainer.clipsToBounds = YES;
 
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
