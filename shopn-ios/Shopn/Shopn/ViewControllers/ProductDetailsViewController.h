//
//  ProductDetailsViewController.h
//  Surprise
//
//  Created by Frantzdy romain on 8/5/15.
//  Copyright (c) 2015 Frantz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CheckoutOrderViewController.h"
#import "ShopStyleJSONModel.h"
#import "DGActivityIndicatorView.h"

@interface ProductDetailsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *detailsTableView;
@property(nonatomic, strong) NSIndexPath *editingIndexPath;

@property (nonatomic) NSMutableDictionary *productDetails;
@property (nonatomic, retain) UIPickerView *pickerForQuantity;
@property NSNumber *quantity;
@property NSNumber* quantitySelected;
@property NSMutableArray *arrQuantity;
//create shopstylemodel
@property(strong,nonatomic) ShopStyleProductsModel *shopStyleModel;
@property BOOL comingFromManagedObject;
@property NSManagedObject *recordNSManagedObject;

@property (strong, nonatomic)DGActivityIndicatorView *activityIndicatorView;

@end
