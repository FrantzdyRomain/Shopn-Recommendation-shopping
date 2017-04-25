//
//  NewUserLaunchViewController.h
//  shopn
//
//  Created by Frantzdy romain on 12/26/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewUserLaunchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>



@property (nonatomic) BOOL isMale;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *array;
@end
