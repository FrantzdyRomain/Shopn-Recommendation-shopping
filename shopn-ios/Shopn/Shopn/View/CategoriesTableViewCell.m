//
//  CategoriesTableViewCell.m
//  shopn
//
//  Created by Frantzdy romain on 10/15/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import "CategoriesTableViewCell.h"

@implementation CategoriesTableViewCell


- (void)awakeFromNib {
    // Initialization code
    self.roundView.layer.cornerRadius = self.roundView.frame.size.width/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
