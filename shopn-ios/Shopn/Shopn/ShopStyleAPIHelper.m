//
//  ShopStyleAPIHel[er.m
//  Surprise
//
//  Created by Frantzdy romain on 9/23/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import "ShopStyleAPIHelper.h"

@implementation ShopStyleAPIHelper

NSString * const SHOPSTYLE_APIKEY = @"uid2484-31450522-61"; //
NSString * const SHOPSTYLE_BASE_URL  = @"https://api.shopstyle.com/api/v2/products?pid=%@&fts=%@&offset=0&limit=%@&sort=PriceLoHi";
NSString * const SHOPSTYLE_BASE_CAT_URL  = @"https://api.shopstyle.com/api/v2/products?pid=%@&cat=%@&offset=0&limit=%@&sort=PriceLoHi";
//https://api.shopstyle.com/api/v2/products?pid=uid2484-31450522-61&cat=men&offset=0&limit=10
//http://api.shopstyle.com/api/v2/products?pid=YOUR_API_KEY&fts=red+dress&offset=0&limit=10
//http://api.shopstyle.com/api/v2/products/histogram?pid=YOUR_API_KEY&filters=Retailer&fts=red+dress
//sort price
//http://api.shopstyle.com/api/v2/products?pid=uid2484-31450522-61&fts=red+dress&sort=PriceLoHi&limit=50
/*
 categoriies
 http://api.shopstyle.com/api/v2/categories?pid=uid2484-31450522-61
 //with filter options retailer id 21 
 http://api.shopstyle.com/api/v2/products?pid=uid2484-31450522-61&fts=red+dress&limit=50&sort=PriceLoHi&fl=r21
 */

+(void)searchforProduct:(NSString *)searchParams limit:(NSString *)theLimit completionHandler:(void (^)(id responseObject, NSError *error))completionHandler{
    
    __block NSArray *results;
   // NSString *stringForURL = [NSString stringWithFormat:@"%@%@%@%@",SHOPSTYLE_BASE_URL];
    NSString *stringForURL = [NSString stringWithFormat:SHOPSTYLE_BASE_URL, [SHOPSTYLE_APIKEY stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[searchParams stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [theLimit stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] ];
    
    NSURL *url = [NSURL URLWithString:stringForURL];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        if (completionHandler){
        results = [responseObject valueForKey:@"products"];
        //NSLog(@"%@",responseObject);
        completionHandler(results, nil);
        }
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }
    
    
    ];
    [operation start];

}

+(void)searchforProductReturnJson:(NSString *)searchParams limit:(NSString *)theLimit completionHandler:(void (^)(id responseObject, NSError *error))completionHandler{
    
    
    //I mean this shit should return some kind of data right. Remember to come back and refactor cause u be forgetting
    
    // NSString *stringForURL = [NSString stringWithFormat:@"%@%@%@%@",SHOPSTYLE_BASE_URL];
    NSString *stringForURL = [NSString stringWithFormat:SHOPSTYLE_BASE_URL, [SHOPSTYLE_APIKEY stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[searchParams stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [theLimit stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] ];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:stringForURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             //NSLog(@"JSON: %@", responseObject);
             completionHandler(responseObject, nil);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
    
}

+(void)searchforProductCategoryReturnJson:(NSString *)catParams limit:(NSString *)theLimit completionHandler:(void (^)(id responseObject, NSError *error))completionHandler{
    //http://api.shopstyle.com/api/v2/products?pid=%@&cat=%@&offset=0&limit=%@
    
    // NSString *stringForURL = [NSString stringWithFormat:@"%@%@%@%@",SHOPSTYLE_BASE_URL];
    NSString *stringForURL = [NSString stringWithFormat:SHOPSTYLE_BASE_CAT_URL, [SHOPSTYLE_APIKEY stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],[catParams stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [theLimit stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] ];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:stringForURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             //NSLog(@"JSON: %@", responseObject);
             completionHandler(responseObject, nil);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
    
}

@end
