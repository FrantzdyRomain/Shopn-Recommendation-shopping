//
//  ShopStyleProductsModel.h
//  Surprise
//
//  Created by Frantzdy romain on 9/27/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import "JSONModel.h"
#import "ShopStyleImageJSONModel.h"

@protocol ShopStyleProductsModel

@end

@interface ShopStyleProductsModel : JSONModel


@property (nonatomic, assign) int id;
//@property (strong, nonatomic) NSMutableDictionary *brand;
@property (nonatomic,strong) NSString *brandedName;
@property (nonatomic,strong) NSString *priceLabel;
@property (nonatomic,strong) NSString <Optional> *description;
@property (nonatomic,strong) NSString *clickUrl, *pageUrl;  //clickURL is for the webview. Page is for sharing

@property (strong, nonatomic) NSMutableDictionary *retailer;
//@property (nonatomic,strong) NSString<Optional>* salePriceLabel;
@property (strong, nonatomic) NSMutableDictionary *image; //issue creating this. when commented out it works

//@property (strong, nonatomic) NSMutableDictionary *retailer;


@end
