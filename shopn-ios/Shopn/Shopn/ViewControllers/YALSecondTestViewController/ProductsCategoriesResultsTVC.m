//
//  ProductsCategoriesResultsTVC.m
//  shopn
//
//  Created by Frantzdy romain on 2/6/16.
//  Copyright © 2016 Frantz. All rights reserved.
//

#import "ProductsCategoriesResultsTVC.h"

#import "ProductDetailsCell.h"
#import "SearchResultsTableViewCell.h"
#import "ProductDetailsViewController.h"
#import "AppDelegate.h"

@interface ProductsCategoriesResultsTVC ()<UIGestureRecognizerDelegate, UIAlertViewDelegate>

@end

@implementation ProductsCategoriesResultsTVC
@synthesize photo;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //dismiss keyboard when tableview accessed
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTableView:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    //[tapGestureRecognizer release];
    [AppDelegate testInternetConnection];
    
    _activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallScaleRippleMultiple tintColor:[UIColor redColor] size:30.0f];
    
    //    [self.view addSubview:_activityIndicatorView];
    //    [_activityIndicatorView startAnimating];
    //    [self.view.superview addSubview:_activityIndicatorView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(void)viewWillAppear:(BOOL)animated{
    if(_activityIndicatorView){
        [_activityIndicatorView removeFromSuperview];
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    if(_activityIndicatorView){
        [_activityIndicatorView removeFromSuperview];
    }
}

- (void)didTapTableView:(UITapGestureRecognizer *)tap{
    [self.view endEditing:YES];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sJsonModel.products.count;
    //return [self.searchResults count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 350;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    static NSString *CellIdentifier = @"CellIdentifier";
    
//    // Dequeue or create a cell of the appropriate type.
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
//    
//    // Configure the cell.
//    cell.textLabel.text =[[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"brandedName"]; //[_array objectAtIndex:indexPath.row];;//[NSString stringWithFormat:@"%ld", (long)indexPath.row];
//    //cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width+1000, 0.f, 0.f);
//    return cell;
    
    
    
    
     static NSString *CellIdentifier = @"SearchResultsTableViewCell";
     SearchResultsTableViewCell *cellDetails = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if(cellDetails ==nil){
     [self.tableView registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
     cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     }
     
     
     cellDetails.productLabel.text = [[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"brandedName"]; //[_array objectAtIndex:indexPath.row];
     [cellDetails setSeparatorInset:UIEdgeInsetsZero];
     [cellDetails setLayoutMargins:UIEdgeInsetsZero];
     ///
     photo = self.sJsonModel.products[indexPath.row];
     
     NSString *nURL = [photo valueForKeyPath:@"image.sizes.XLarge.url"]; // //@"image.sizes.Large.url" //loads faster? //image.sizes.best
     cellDetails.imageViewTemp.image = nil; // or cell.poster.image = [UIImage imageNamed:@"placeholder.png"];
     NSURL *urlforimage = [NSURL URLWithString:nURL];
     //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://myurl.com/%@.jpg", self.myJson[indexPath.row][@"movieId"]]];
     
     NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:urlforimage completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
     if (data) {
     UIImage *image = [UIImage imageWithData:data];
     if (image) {
     dispatch_async(dispatch_get_main_queue(), ^{
     SearchResultsTableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
     if (updateCell)
     updateCell.imageViewTemp.image = image;
     });
     }
     }
     }];
     [task resume];
     
     NSString *retailName  =[photo valueForKeyPath:@"retailer.name"];//;
     NSString *brandname = photo.brandedName;
     
     cellDetails.productLabel.text = brandname;
     cellDetails.productPrice.text = photo.priceLabel;
     cellDetails.retailLabel.text = retailName;
     //NSLog(@"barnd name: %@ : Photo URL: %@ Place URL: %@ retail: %@",brandname, nURL, productUrl,retailName);
     
     //add button targets
     [cellDetails.btnView addTarget:self action:@selector(buttonViewForPinterestPressedAction:) forControlEvents:UIControlEventTouchUpInside];
     [cellDetails.btnShare addTarget:self action:@selector(buttonSharePressedAction:) forControlEvents:UIControlEventTouchUpInside];
     
     
     
     
     
     return cellDetails;
     
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    //NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    //    CGRect rectInTableView = [_tableview rectForRowAtIndexPath:indexPath];
    //    CGRect rectInSuperview = [_tableview convertRect:rectInTableView toView:[tableView superview]];
    //    _activityIndicatorView.frame = CGRectMake(rectInTableView.origin.x, rectInTableView.origin.y, rectInTableView.size.width, rectInTableView.size.height);//CGRectMake(0.0f, 0.0f, 80.0f, 80.0f);
    //    _activityIndicatorView.center=self.view.center;
    
    //ProductDetailsViewController *productsVC = [[ProductDetailsViewController alloc]init];
    //NSMutableDictionary *productDetails  = [[NSMutableDictionary alloc]init];
    //    [self.view addSubview:_activityIndicatorView];
    //    [_activityIndicatorView startAnimating];
    
    
    if (indexPath != nil)
    {
        //...
        NSLog(@"row % ldpped", (long)indexPath.row);
        //ShopStyleProductsModel *photo = self.sJsonModel.products[indexPath.row];
        //NSString *productUrl= photo.clickUrl;
        //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"URL" message:productUrl delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"OK", nil];
        //       // [alert show];
        //build dictionary of things to send
        //        NSString *nURL = [photo valueForKeyPath:@"image.sizes.IPhone.url"];
        //        NSMutableDictionary* productDetails = [NSMutableDictionary new];
        //        [productDetails setObject:[[self.sJsonModel.products objectAtIndex:indexPath.row]valueForKey:@"brandedName" ] forKey:@"brandedName"];
        //        [productDetails setObject:[[self.sJsonModel.products objectAtIndex:indexPath.row]valueForKeyPath:@"image.sizes.IPhone.url"] forKey:@"image"];
        //        [productDetails setObject:[[self.sJsonModel.products objectAtIndex:indexPath.row]valueForKeyPath:@"id"] forKey:@"objId"];
        //        ;
        
        //theviewcontroller to present
        
        //UIStoryboard *storyboard = self.storyboard;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        ProductDetailsViewController *pDetailsVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductDetailsViewController" ];
        
        if (!self.isComingFromOtherController){
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pDetailsVC];
            
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(backPressed:)];
            
            navigationController.navigationItem.leftBarButtonItem = backButton;
            
            //pDetailsVC.productDetails = productDetails;
            pDetailsVC.shopStyleModel = self.sJsonModel.products[indexPath.row];
            [self presentViewController:navigationController  animated:YES completion:nil  ];
            dispatch_async(dispatch_get_main_queue(), ^{});
        }else{
            
            pDetailsVC.shopStyleModel = self.sJsonModel.products[indexPath.row];
            pDetailsVC.activityIndicatorView = _activityIndicatorView;
            [self.view addSubview:_activityIndicatorView];
            
            [self.navigationController pushViewController:pDetailsVC animated:Nil];
            dispatch_async(dispatch_get_main_queue(), ^{});
        }
        
        //navigationController.navigationItem.leftBarButtonItem = backButton;
        //pDetailsVC.productDetails = productDetails;
        
        //[sel:navigationController  animated:NO completion:nil  ];
        
    }
    
}
//

- (void)buttonViewForPinterestPressedAction:(id)sender
{
    /*
     when tappped ask user if they are logged in to save to their Pinterest Board.
     */
    //check if user is logged in with pinterest already.
    //[self.logindefaults setBool:NO forKey:@"hasUserLoggedIn"];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"pinproduct_button_press"  // Event action (required)
                                                           label:@"Pin It Button"          // Event label
                                                           value:nil] build]];    // Event value
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    
    if (indexPath != nil)
    {
        //...
        NSLog(@"row % ldpped", (long)indexPath.row);
        ShopStyleProductsModel *photo = self.sJsonModel.products[indexPath.row];
        NSString *productUrl= photo.clickUrl;
        NSString *photoURL = [photo valueForKeyPath:@"image.sizes.IPhone.url"];
        
        
        [PDKPin pinWithImageURL:[NSURL URLWithString:photoURL]
                           link:[NSURL URLWithString:productUrl]
             suggestedBoardName:@"Shopn"
                           note:photo.brandedName
                    withSuccess:^
         {
#warning implement success message
         }
                     andFailure:^(NSError *error)
         {
             //weakSelf.resultLabel.text = @"pin it failed";
         }];
        
    }
    
}
- (void)buttonSharePressedAction:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"share_button_press"  // Event action (required)
                                                           label:@"Share Button"          // Event label
                                                           value:nil] build]];    // Event value
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    NSString *productUrl;
    ShopStyleProductsModel *product;
    if (indexPath != nil)
    {
        //...
        NSLog(@"row % ldpped", (long)indexPath.row);
        product = self.sJsonModel.products[indexPath.row];
        productUrl = product.pageUrl;
    }
    NSString *textToShare = [NSString stringWithFormat:@"Check this %@ out!",product.brandedName];//@"Check this out!";
    NSURL *myWebsite = [NSURL URLWithString:productUrl];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}



- (void)backPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
