//
//  ProductDetailsCell.m
//  Example
//
//  Created by Romain Frantzdy (LVX0SHP) on 8/4/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//

#import "ProductDetailsCell.h"

@implementation ProductDetailsCell

- (void)awakeFromNib {
    // Initialization code
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)prepareForReuse
{
    [super prepareForReuse];
    

    self.productImage.image = nil;
}

@end
