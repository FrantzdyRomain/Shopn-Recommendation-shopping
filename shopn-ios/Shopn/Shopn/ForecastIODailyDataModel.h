//
//  ForecastIODailyDataModel.h
//  shopn
//
//  Created by Frantzdy romain on 1/12/16.
//  Copyright © 2016 Frantz. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface ForecastIODailyDataModel : JSONModel
@property double time;
@property (strong, atomic) NSString * summary;
@property (strong, atomic) NSString *icon;
@property double sunriseTime;
@property double sunsetTime;
@property double moonPhase;
@property double precipIntensity;
@property double precipIntensityMax;
@property double precipIntensityMaxTime;
@property double precipProbability;
@property double precipType;
@property double temperatureMin;
@property double temperatureMinTime;
@property double temperatureMax;
@property double temperatureMaxTime;
@property double apparentTemperatureMin;
@property double apparentTemperatureMinTime;
@property double apparentTemperatureMax; 
@property double apparentTemperatureMaxTime;
@property double dewPoint;
@property double humidity;
@property double windSpeed;
@property double windBearing;
@property double visibility;
@property double cloudCover;
@property double pressure;
@property double ozone;
@end
