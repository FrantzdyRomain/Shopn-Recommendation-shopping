//
//  SearchResultsTVCTableViewController.h
//  Surprise
//
//  Created by Frantzdy romain on 9/29/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopStyleJSONModel.h"
#import "PDKBoard.h"

#import "PDKClient.h"
#import "PDKPin.h"
#import "PDKResponseObject.h"
#import "PDKUser.h"
#import "DGActivityIndicatorView.h"

@interface SearchResultsTVCTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *searchResults;
@property (strong, nonatomic) ShopStyleJSONModel *sJsonModel;
@property BOOL isComingFromOtherController;
@property (strong, nonatomic)DGActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong) ShopStyleProductsModel *photo;
@end
