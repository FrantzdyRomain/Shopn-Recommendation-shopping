//
//  PinterestImageTableViewCell.h
//  shopn
//
//  Created by Frantzdy romain on 11/1/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PinterestImageTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UITextView *hiThereLbl;
@property (strong, nonatomic) IBOutlet UITextView *weFoundLabels;

@property (strong, nonatomic) IBOutlet UIView *containerView;

@end
