//
//  OrderDetailsModel.h
//  Surprise
//
//  Created by Frantzdy romain on 8/6/15.
//  Copyright (c) 2015 Frantz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderDetailsModel : NSObject{
   NSString *firstname;
    NSString *lastname;
    NSString *streetaddr;
   NSString *aptfloorunit;
   NSString *city;
    NSString *state;
    NSString *zipcode;
   NSString *phonenumber;
    NSString *emailaddr;
    NSNumber *quantity;
    NSMutableDictionary *productDetails;
    
    NSString *random;

}

@property (nonatomic, retain)NSString *firstname;
@property (nonatomic, retain)NSString *lastname;
@property (nonatomic, retain)NSString *streetaddr;
@property (nonatomic, retain)NSString *aptfloorunit;
@property (nonatomic, retain)NSString *city;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain)NSString *zipcode;
@property (nonatomic, retain)NSString *phonenumber;
@property (nonatomic, retain)NSString *emailaddr;
@property (nonatomic, retain)NSNumber *quantity;
@property (nonatomic, retain)NSString *random;
@property (nonatomic) NSMutableDictionary *productDetails;

//set up single ton
+ (id)sharedManager;



@end
