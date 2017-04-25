//
//  NewUserLaunchViewController.m
//  shopn
//
//  Created by Frantzdy romain on 12/26/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import "NewUserLaunchViewController.h"

@interface NewUserLaunchViewController ()

@end

@implementation NewUserLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.array = @[@"Red and White shoes", @"navy blue dress", @"Nike Jordans", @"Michael Kors bag", @"Black jeans"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_array count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 300;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
    
    // Configure the cell.
    cell.textLabel.text =[self.array objectAtIndex:indexPath.row];//[NSString stringWithFormat:@"%ld", (long)indexPath.row];
    //cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width+1000, 0.f, 0.f);
    
    
    
    return cell;
}





@end
