//
//  PlaceOrderViewController.h
//  Surprise
//
//  Created by Frantzdy romain on 8/17/15.
//  Copyright (c) 2015 Frantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceOrderViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property NSString *text;
@property NSArray *rates;

@end
