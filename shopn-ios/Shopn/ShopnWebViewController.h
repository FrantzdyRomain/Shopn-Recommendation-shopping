//
//  ShopnWebViewController.h
//  shopn
//
//  Created by Frantzdy romain on 11/17/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGActivityIndicatorView.h"
@interface ShopnWebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) NSString* urlString;

@property (strong, nonatomic)DGActivityIndicatorView *activityIndicatorView;
@property (strong) UIView *viewToHideLoad;
@end
