//
//  ShopnWebViewController.m
//  shopn
//
//  Created by Frantzdy romain on 11/17/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import "ShopnWebViewController.h"
#import "AppDelegate.h"

@interface ShopnWebViewController ()<UIWebViewDelegate>

@end

@implementation ShopnWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webview.delegate = self;
    // Do any additional setup after loading the view.
    _activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallScaleRippleMultiple tintColor:[UIColor redColor] size:30.0f];
    
    _activityIndicatorView.center=self.view.center;
    _viewToHideLoad = [[UIView alloc]initWithFrame:self.view.frame];
    
    _viewToHideLoad.backgroundColor = [UIColor whiteColor];
    [self.webview addSubview:_viewToHideLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableURLRequest * request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
        [self.webview loadRequest:request];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_viewToHideLoad addSubview:_activityIndicatorView];
            [_activityIndicatorView startAnimating];
        });
    });
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma UIWEbviewdelegaes
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"Loading URL :%@",request.URL.absoluteString);
    
    //return FALSE; //to stop loading
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_viewToHideLoad removeFromSuperview];
    [_activityIndicatorView stopAnimating];
    [_activityIndicatorView removeFromSuperview];
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Failed to load with error :%@",[error debugDescription]);
    //add our method..to handle failed load
    
}


@end
