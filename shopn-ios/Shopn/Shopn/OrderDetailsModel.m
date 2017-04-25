//
//  OrderDetailsModel.m
//  Surprise
//
//  Created by Frantzdy romain on 8/6/15.
//  Copyright (c) 2015 Frantz. All rights reserved.
//Contains Details about the order..name location price shipping

#import "OrderDetailsModel.h"

@implementation OrderDetailsModel

@synthesize  firstname;
@synthesize  lastname;
@synthesize  streetaddr;
@synthesize  aptfloorunit;
@synthesize  city;
@synthesize  state;
@synthesize  zipcode;
@synthesize  phonenumber;
@synthesize  emailaddr;
@synthesize quantity;
@synthesize random;

@synthesize productDetails;



+ (id)sharedManager {
    static OrderDetailsModel *sharedOrderDetailsModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOrderDetailsModel = [[self alloc] init];
    });
    return sharedOrderDetailsModel;

}
- (id)init {
    if (self = [super init]) {
        random =  @"Default Property Value";
    }
    return self;
}

@end