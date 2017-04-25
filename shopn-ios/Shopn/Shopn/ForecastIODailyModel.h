//
//  ForecastIODailyModel.h
//  shopn
//
//  Created by Frantzdy romain on 1/12/16.
//  Copyright © 2016 Frantz. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "ForecastIODailyDataModel.h"
@interface ForecastIODailyModel : JSONModel
@property (strong, atomic) NSString *summary;
@property (strong, atomic) NSString *icon;
@property (strong, nonatomic) NSArray <ForecastIODailyDataModel *>* data;



@end
