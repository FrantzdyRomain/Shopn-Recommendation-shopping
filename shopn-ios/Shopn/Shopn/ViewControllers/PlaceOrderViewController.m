//
//  PlaceOrderViewController.m
//  Surprise
//
//  Created by Frantzdy romain on 8/17/15.
//  Copyright (c) 2015 Frantz. All rights reserved.
//

#import "PlaceOrderViewController.h"
#import "AppDelegate.h"
#import "OrderDetailsModel.h"

@interface PlaceOrderViewController ()

@end

@implementation PlaceOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    OrderDetailsModel *sharedDetails = [OrderDetailsModel sharedManager];
    NSLog(@"%@",sharedDetails);
     _text= [NSString stringWithFormat:@"%@", _rates];
    _textView.text = _text;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
