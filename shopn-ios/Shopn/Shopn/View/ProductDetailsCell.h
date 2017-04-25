//
//  ProductDetailsCell.h
//  Example
//
//  Created by Romain Frantzdy (LVX0SHP) on 8/4/15.
//  Copyright (c) 2015 
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface ProductDetailsCell : PFTableViewCell
@property (strong, nonatomic) IBOutlet UILabel *productLabel;
@property (strong, nonatomic) IBOutlet PFImageView *productImage;
@property (strong, nonatomic) IBOutlet PFImageView *imageViewTemp;

@end
