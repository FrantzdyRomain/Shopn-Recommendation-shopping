//
//  ForecastIOModel.h
//  shopn
//
//  Created by Frantzdy romain on 1/9/16.
//  Copyright © 2016 Frantz. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "ForecastIOCurrentlyModel.h"
#import "ForecastIODailyModel.h"

@interface ForecastIOModel : JSONModel

//@property (strong, nonatomic) NSMutableDictionary *currently;
@property (strong, nonatomic) ForecastIOCurrentlyModel *currently;
//get the summary for the day here and display to user
@property (strong, nonatomic) NSMutableDictionary *hourly;
//get the summary for the week here and display to user
@property (strong, nonatomic) ForecastIODailyModel *daily;
@end
