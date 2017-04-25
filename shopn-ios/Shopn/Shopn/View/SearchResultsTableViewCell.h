//
//  SearchResultsTableViewCell.h
//  Surprise
//
//  Created by Frantzdy romain on 10/6/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageViewTemp;
@property (strong, nonatomic) IBOutlet UILabel *productLabel;

@property (strong, nonatomic) IBOutlet UILabel *productPrice;
@property (strong, nonatomic) IBOutlet UILabel *retailLabel;

@property (strong, nonatomic) IBOutlet UIButton *btnView;
@property (strong, nonatomic) IBOutlet UIButton *btnShare;

@end
