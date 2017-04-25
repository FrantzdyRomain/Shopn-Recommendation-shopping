//
//  ShopStyleJSONModel.h
//  Surprise
//
//  Created by Frantzdy romain on 9/26/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import "JSONModel.h"
#import "ShopStyleImageJSONModel.h"
#import "ShopStyleProductsModel.h"
 

@interface ShopStyleJSONModel : JSONModel


//@property (nonatomic,strong) NSArray *metaData;
@property (nonatomic,strong) NSMutableArray<ShopStyleProductsModel> *products;


//create dictionary of images


@end
