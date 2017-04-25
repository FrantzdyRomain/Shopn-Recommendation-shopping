//
//  SeasonCategoriesCell.h
//  shopn
//
//  Created by Frantzdy romain on 12/28/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeasonCategoriesCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *degreeLabel;
@property (strong, nonatomic) IBOutlet UILabel *degreeMessage;

@property (strong, nonatomic) IBOutlet UILabel *degreeSymbolLabel;


@property (strong, nonatomic) IBOutlet UIView *iconContainer;
@property (strong, nonatomic) IBOutlet UIImageView *iconImage;
@property (strong, nonatomic) IBOutlet UILabel *fahrenheitLabel;

@end
