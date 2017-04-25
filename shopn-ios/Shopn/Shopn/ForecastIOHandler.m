//
//  ForecastIOHandler.m
//  shopn
//
//  Created by Frantzdy romain on 1/9/16.
//  Copyright © 2016 Frantz. All rights reserved.
//

#import "ForecastIOHandler.h"

@implementation ForecastIOHandler


+(void)getWeatherIconForLocation:(double )latitude longitude:(double)longitude completionHandler:(void (^)(id responseObject, NSError *error))completionHandler{
    Forecastr *forecastr;
    forecastr=[Forecastr sharedManager];

    forecastr.apiKey = forecastAPIKey;
   
    [forecastr getForecastForLatitude:latitude longitude:longitude time:nil exclusions:nil extend:nil language:nil success:^(id JSON) {
        NSLog(@" Forecast IO JSON Response was: %@", JSON);
        completionHandler(JSON, nil);
    } failure:^(NSError *error, id response) {
        NSLog(@"Error while retrieving forecast: %@", [forecastr messageForError:error withResponse:response]);
    
    }];
    
}

+(NSDate *)getCurrentDate{
    NSDate *now;
    now  = [NSDate date];
    
    return now;
}

@end
