//
//  CategoriesTableViewCell.h
//  shopn
//
//  Created by Frantzdy romain on 10/15/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface CategoriesTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *celLabel;

@property (strong, nonatomic) IBOutlet PFImageView *roundView;
@end
