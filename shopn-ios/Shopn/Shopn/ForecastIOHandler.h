//
//  ForecastIOHandler.h
//  shopn
//
//  Created by Frantzdy romain on 1/9/16.
//  Copyright © 2016 Frantz. All rights reserved.
//
//
//API Key

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "Forecastr.h"

static NSString * const forecastAPIKey = @"102427fff1a59ac02a37ce77604f1fe4";
@interface ForecastIOHandler : NSObject

typedef void (^CompletionHandlerBlock)(NSError *error, NSDictionary *result);

+(void)getWeatherIconForLocation:(double)latitude longitude:(double )longitude completionHandler:(void (^)(id responseObject, NSError *error))completionHandler;
+(NSDate *)getCurrentDate;


@end
