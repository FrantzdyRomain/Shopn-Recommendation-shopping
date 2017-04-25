//
//  ForecastIOCurrentlyModel.h
//  shopn
//
//  Created by Frantzdy romain on 1/9/16.
//  Copyright © 2016 Frantz. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface ForecastIOCurrentlyModel : JSONModel
@property (strong, atomic) NSString *summary;
@property (strong, atomic) NSString *icon;


@property double nearestStormDistance;
@property double nearestStormBearing;
@property double precipIntensity;
@property double precipProbability;
@property double temperature;
@property double apparentTemperature;
@property double dewPoint;
@property double humidity;
@property double windSpeed;
@property double windBearing;
@property double visibility;
@property double cloudCover;
@property double pressure;
@property double ozone;

@end
