//
//  ProductDetailsInfoCell.h
//  Surprise
//
//  Created by Frantzdy romain on 8/10/15.
//  Copyright (c) 2015 Frantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailsInfoCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UITextView *textViewDetails;
@property (strong, nonatomic) IBOutlet UIWebView *webviewForDetails;

@end
