//
//  CheckoutOrderViewController.h
//  Surprise
//
//  Created by Frantzdy romain on 8/13/15.
//  Copyright (c) 2015 Frantz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneNumberTableViewCell.h"
#import "NameTableViewCell.h"
#import "AddressDetailsTableViewCell.h"
#import "ProductOrderButtonCell.h"
#import "OrderDetailsModel.h"
#import "AppDelegate.h"

#define FIRSTNAME_TAG 0
#define LASTNAME_TAG 1
#define ADDRESS_TAG 2
#define APT_TAG 3
#define CITY_TAG 4
#define STATE_TAG 5
#define ZIPCODE_TAG 6
#define PHONE_TAG 7
#define EMAIL_TAG 8
@interface CheckoutOrderViewController : UIViewController
{
    NSMutableArray  *arr_state;

}
@property(nonatomic, strong) NSIndexPath *editingIndexPath;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property OrderDetailsModel *orderDetailsModel;
@property OrderDetailsModel *sharedDetails;
@property UIActivityIndicatorView *activityView;

@property NSNumber* quantitySelected;

@property (nonatomic, retain) UIPickerView *pickerUserState;
@end
