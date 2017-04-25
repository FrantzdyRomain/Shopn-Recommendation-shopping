//
//  VoiceSearchTableViewCell.m
//  Surprise
//
//  Created by Frantzdy romain on 10/3/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import "VoiceSearchTableViewCell.h"

@implementation VoiceSearchTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.searchContainer.layer.cornerRadius = self.searchContainer.frame.size.width/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
