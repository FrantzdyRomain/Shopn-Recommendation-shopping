//
//  ShopStyleAPIHel[er.h
//  Surprise
//
//  Created by Frantzdy romain on 9/23/15.
//  Copyright © 2015 Frantz. All rights reserved.
//http://api.shopstyle.com/api/VERSION/METHOD_NAME?pid=YOUR_API_KEY&format=FORMAT&...
//API/UID uid2484-31450522-61
//password: Fr040791$ username:fromain email:frantzdy@frantzdy.com
//example: http://api.shopstyle.com/api/v2/products/histogram?pid=YOUR_API_KEY&filters=Retailer&fts=red+dress
//http://api.shopstyle.com/api/v2/products/histogram?pid=uid2484-31450522-61&filters=Retailer&fts=red+dress
//can also query http://api.shopstyle.com/api/v2/products?pid=uid2484-31450522-61&filters=Retailer&fts=blue+shoes+men
//http://api.shopstyle.com/api/v2/products?pid=uid2484-31450522-61&filters=Retailer&fts=blue+dress
//http://api.shopstyle.com/api/v2/products?pid=YOUR_API_KEY&fts=red+dress&offset=0&limit=10
//GET Indivudual Product
//http://api.shopstyle.com/api/v2/products/483118948?pid=uid2484-31450522-61
//http://api.shopstyle.com/api/v2/products/%@?pid=uid2484-31450522-61
//////price LO to HI
//http://api.shopstyle.com/api/v2/products?pid=uid2484-31450522-61&fts=blue+shoes+men&sort=PriceLoHi

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "ShopStyleJSONModel.h"

typedef void (^CompletionHandlerBlock)(NSError *error, NSDictionary *result);




@interface ShopStyleAPIHelper : NSObject

@property(nonatomic, strong) ShopStyleJSONModel *shopJsonModel;


+(void)searchforProduct:(NSString *)searchParams limit:(NSString *)theLimit completionHandler:(void (^)(id responseObject, NSError *error))completionHandler;
+(void)searchforProductReturnJson:(NSString *)searchParams limit:(NSString *)theLimit completionHandler:(void (^)(id responseObject, NSError *error))completionHandler;
+(void)searchforProductCategoryReturnJson:(NSString *)catParams limit:(NSString *)theLimit completionHandler:(void (^)(id responseObject, NSError *error))completionHandler;
@end
