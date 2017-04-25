//
//  ShopStyleImageJSONModel.h
//  Surprise
//
//  Created by Frantzdy romain on 9/27/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import "JSONModel.h"
#import "ShopStyleJSONImageSizeModel.h"

@protocol ShopStyleImageJSONModel
@end

@interface ShopStyleImageJSONModel : JSONModel

//@property (nonatomic, assign) int id;
@property (strong, nonatomic) NSDictionary *sizes;


@end
