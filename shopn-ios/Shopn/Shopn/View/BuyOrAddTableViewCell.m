//
//  BuyOrAddTableViewCell.m
//  Surprise
//
//  Created by Frantzdy romain on 8/19/15.
//  Copyright (c) 2015 Frantz. All rights reserved.
//

#import "BuyOrAddTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
@implementation BuyOrAddTableViewCell
 

- (void)awakeFromNib {
    // Initialization code
    //set the frame
    [[_btnBuy layer] setBorderWidth:0.8f];
    [[_btnBuy layer] setBorderColor:[UIColor colorWithRed:242/255.0f green:151/255.0f blue:167/255.0f alpha:1].CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
