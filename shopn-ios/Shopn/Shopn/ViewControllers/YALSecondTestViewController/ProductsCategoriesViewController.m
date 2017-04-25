//TODO: Add load more functionality

#import "ProductsCategoriesViewController.h"
#import "ProductDetailsCell.h"
#import "ProductDetailsViewController.h"
#import "CategoriesTableViewCell.h"
#import "ProductsCategoriesViewController.h"
#import "ShopStyleAPIHelper.h"
#import "SearchResultsTableViewCell.h"
#import "AppDelegate.h"
#import "SearchResultsTVCTableViewController.h"
#import "ProductsCategoriesResultsTVC.h"


#define debug 1
//#define kfetchQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kfetchQueue dispatch_queue_create("com.fitshakr.app.imageQueue", NULL)

@implementation ProductsCategoriesViewController
@synthesize trendOptions;
@synthesize isLoggedin;
@synthesize logindefaults;





-(void)viewDidLoad{
    _products = [NSMutableArray arrayWithObjects:@"Product 1",@"Product 2",@"Product 3",@"Product 4",@"Product 5",@"Product 6", nil];
    
    self.maleCatogeries = @[@"All Clothes", @"Men's Accessories", @"Men's Activewear", @"Men's Big And Tall Clothes", @"Men's Jeans", @"Men's Outerwear", @"Men's Pants",@"Men's Shirts", @"Men's Sleepwear",@"Men's Swimsuits",@"Men's Underwear And Socks"];
    
    self.femaleCatogeries = @[@"All Clothes", @"Women's Accessories", @"Handbags", @"Women's Outerwear", @"Women's Shoes",@"Women's Jeans", @"Women's Swimwear",@"Women's Intimates", @"Women's Jewelry"];
    
    //[self setUpProducts];
    //set up pfImageView
    _productImageView = [[PFImageView alloc]init];
    self.trendOptions = @[@"Gifts for women(coming soon)", @"Gifts for men(coming soon)", @"Gift Cards(coming soon)", @"Cologne(coming soon)", @"Designer Purses(coming soon)"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallScaleRippleMultiple tintColor:[UIColor redColor] size:30.0f];
    _activityIndicatorView.frame = CGRectMake(0.0f, 0.0f, 80.0f, 80.0f);
    _activityIndicatorView.center=self.view.center;
    //[_activityIndicatorView startAnimating];
    [AppDelegate testInternetConnection];
    _appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    _capStoneMode = [_appdelegate getCapstoneMode];;
     [self setUpHorizontalView];
    
}
-(void)viewWillAppear:(BOOL)animated{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Category-Page"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    self.tabBarController.selectedIndex = 1;
    
    if(!_maleCategorySelected || !_femaleCategorySelected){
        
        _femaleCategorySelected = YES;
        _maleCategorySelected = NO;
        [self.tableView reloadData];
        [self setUpHorizontalView];
        
    }else{
        _femaleCategorySelected = YES;
        [self.tableView reloadData];
        [self setUpHorizontalView];
        
    }
    
    //our horizontal view always goes back to women
//    if (!_capStoneMode) {
//        //[self requestCategory:@"women"];
//        //women is selected first
//        self.femaleCategorySelected = TRUE;
//        self.maleCategorySelected = FALSE;
//        [self.tableView reloadData];
//    }else{
//        //[self requestGiftsFor:@"Gifts for women"];
//    }
    
    
    //need loading icon when products are loading.


}
-(void)viewWillDisappear:(BOOL)animated{
    //in case activity indicator
    [_activityIndicatorView removeFromSuperview];
}
-(void)setUpHorizontalView{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.selectionList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    self.selectionList.delegate = self;
    self.selectionList.dataSource = self;
    
    self.selectionList.selectionIndicatorColor = [UIColor redColor];
    [self.selectionList setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.selectionList setTitleFont:[UIFont systemFontOfSize:13] forState:UIControlStateNormal];
    [self.selectionList setTitleFont:[UIFont boldSystemFontOfSize:13] forState:UIControlStateSelected];
    [self.selectionList setTitleFont:[UIFont boldSystemFontOfSize:13] forState:UIControlStateHighlighted];
    
    if(!_capStoneMode){
        self.optionsCategories =[NSMutableArray arrayWithObjects:@"WOMEN",
                                 @"MEN",
                                 @"GIFTS FOR MEN",
                                 @"GIFTS FOR WOMEN",nil];
    }else{
        self.optionsCategories = [NSMutableArray arrayWithObjects:@"Gifts for Women",
                                  @"Gifts for Men",
                                  @"Gift Cards",
                                  @"Funny Gifts",
                                  nil];
    }

    [self.view addSubview:self.selectionList];
    
    
    self.selectedLabel = [[UILabel alloc] init];
    self.selectedLabel.text = self.optionsCategories[self.selectionList.selectedButtonIndex];
    self.selectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //[self.view addSubview:self.selectedLabel];
    
    
    //    self.selectionList.snapToCenter = YES;    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedLabel
    //                                                                                                    attribute:NSLayoutAttributeCenterX
    //                                                                                                    relatedBy:NSLayoutRelationEqual
    //                                                                                                       toItem:self.view
    //                                                                                                    attribute:NSLayoutAttributeCenterX
    //                                                                                                   multiplier:1.0
    //                                                                                                     constant:0.0]];
    //
    //    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedLabel
    //                                                          attribute:NSLayoutAttributeCenterY
    //                                                          relatedBy:NSLayoutRelationEqual
    //                                                             toItem:self.view
    //                                                          attribute:NSLayoutAttributeCenterY
    //                                                         multiplier:1.0
    //                                                           constant:0.0]];
    
    //    self.edgesForExtendedLayout = UIRectEdgeAll;
    //    self.tableView.contentInset = UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    self.selectionList.snapToCenter = YES;
    self.topView = self.selectionList;
}
-(void)setUpProducts{
    //query parse products: Male
    PFQuery *queryForMaleProducts = [PFQuery queryWithClassName:@"Products"];
    [queryForMaleProducts whereKey:@"category" containsString:@"male"];
    //queryForMaleProducts.cachePolicy = kPFCachePolicyCacheThenNetwork;
    _array = nil;
    _array = [NSMutableArray new];
    _productImages = nil;
    _productImages = [NSMutableArray new];
    
    [queryForMaleProducts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for(PFObject *object in objects){
                [ _array addObject:object];
            }
            for(NSMutableArray *arr in _array){
                PFImageView *tempImage = [[PFImageView alloc]init];
                PFFile *imageFile = [arr valueForKey:@"productImage"];
                tempImage.file = imageFile;
                [tempImage loadInBackground];

                [_productImages addObject:tempImage];
                
            }
//            NSLog(@"Product Images: %@",_productImages);
//            NSLog(@"Product Images: %@",_array);

           // [self.tableView reloadData];
        }
    [self.tableView reloadData];
    }];
    //setup images
    


}



#pragma mark - tableview Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_maleCategorySelected) {
        return self.maleCatogeries.count;
    }else if(_femaleCategorySelected){
        return self.femaleCatogeries.count;
    }
    return [_array count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.maleCategorySelected|| self.femaleCategorySelected) {
        return 70;
    }
    return 350;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_maleCategorySelected) {
        
    
        static NSString *CellIdentifier = @"CellIdentifier";
        
        // Dequeue or create a cell of the appropriate type.
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
        
        // Configure the cell.
        cell.textLabel.text =[self.maleCatogeries objectAtIndex:indexPath.row];//[NSString stringWithFormat:@"%ld", (long)indexPath.row];
        return cell;
    
    
    }else if(_femaleCategorySelected){
    
        static NSString *CellIdentifier = @"CellIdentifier";
        
        // Dequeue or create a cell of the appropriate type.
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
        
        // Configure the cell.
        cell.textLabel.text =[self.femaleCatogeries objectAtIndex:indexPath.row];//[NSString stringWithFormat:@"%ld", (long)indexPath.row];
        return cell;
        
    
    
    }
    
            static NSString *CellIdentifier = @"SearchResultsTableViewCell";
            SearchResultsTableViewCell *cellDetails = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            
            
            //cellDetails.productLabel.text = [[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"brandedName"]; //[_array objectAtIndex:indexPath.row];
            //    [cellDetails setSeparatorInset:UIEdgeInsetsZero];
            //    [cellDetails setLayoutMargins:UIEdgeInsetsZero];
            ///
            ShopStyleProductsModel *photo = self.sJsonModel.products[indexPath.row];
            //        NSString *productUrl= photo.clickUrl;
            NSString *nURL = [photo valueForKeyPath:@"image.sizes.Best.url"];
            
            cellDetails.productLabel.text = [photo valueForKey:@"brandedName"];
            cellDetails.retailLabel.text =[photo valueForKeyPath:@"retailer.name"];
            //cellDetails.retailLabel.text =[photo valueForKeyPath:@"retailer.name"];
            cellDetails.productPrice.text = [photo valueForKey:@"priceLabel"];
            [cellDetails.btnView addTarget:self action:@selector(malebuttonViewForPinterestPressedAction:) forControlEvents:UIControlEventTouchUpInside];
            [cellDetails.btnShare addTarget:self action:@selector(malebuttonSharePressedAction:) forControlEvents:UIControlEventTouchUpInside];
            cellDetails.imageViewTemp.image = nil; //the image from the last cell should not be reused
            
            //http://stackoverflow.com/questions/16663618/async-image-loading-from-url-inside-a-uitableview-cell-image-changes-to-wrong
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
            
            
            return cellDetails;
}


//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 100.0f;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//
//    // creates a custom view inside the footer
//    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
//    footerView.backgroundColor = [UIColor colorWithRed:255/255.0f green:204/255.0f blue:68/255.0f alpha:1];
//    // create a button with image and add it to the view
//    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 400, 80)];
//    [button setImage:[UIImage imageNamed:@"categorytrends"] forState:UIControlStateNormal];
//    //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
//    //[button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
//    
//    [footerView addSubview:button];
//    
//    return footerView;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 0.01;
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //send user to productDetailsViewcontroller
//    //current arrays

//    
//    self.femaleCatogeries = @[@"All Clothes", @"Women's Accessories", @"Handbags", @"Women's Outerwear", @"Women's Shoes",@"Women's Jeans", @"Women's Swimwear",@"Women's Intimates", @"Women's Jewelry"];
    if (_femaleCategorySelected) {
        if (indexPath.row ==0) {
            
            [self requestCategoryAndGo:@"womens-clothes"];
            
        }else if(indexPath.row==1){
            [self requestCategoryAndGo:@"womens-accessories"];
        
        }else if(indexPath.row==2){
            [self requestCategoryAndGo:@"handbags"];
            
        }else if(indexPath.row==3){
            [self requestCategoryAndGo:@"womens-outerwear"];
            
        }else if(indexPath.row==4){
            [self requestCategoryAndGo:@"womens-shoes"];
            
        }else if(indexPath.row==5){
            [self requestCategoryAndGo:@"jeans"];
            
        }else if(indexPath.row==6){
            [self requestCategoryAndGo:@"swimsuits"];
            
        }else if(indexPath.row==7){
            [self requestCategoryAndGo:@"womens-intimates"];
            
        }else if(indexPath.row==8){
            [self requestCategoryAndGo:@"jewelry"];
            
        }
        
    
    }else if(_maleCategorySelected){
        //    self.maleCatogeries = @[@"All Clothes", @"Men's Accessories", @"Men's Activewear", @"Men's Big And Tall Clothes", @"Men's Jeans", @"Men's Outerwear", @"Men's Pants",@"Men's Shirts", @"Men's Sleepwear",@"Men's Swimsuits",@"Men's Underwear And Socks"];
        if (indexPath.row ==0) {
            
            [self requestCategoryAndGo:@"mens-clothes"];
            
        }else if(indexPath.row==1){
            [self requestCategoryAndGo:@"mens-accessories"];
            
        }else if(indexPath.row==2){
            [self requestCategoryAndGo:@"mens-athletic"];
            
        }else if(indexPath.row==3){
            [self requestCategoryAndGo:@"mens-big-and-tall"];
            
        }else if(indexPath.row==4){
            [self requestCategoryAndGo:@"mens-jeans"];
            
        }else if(indexPath.row==5){
            [self requestCategoryAndGo:@"mens-outerwear"];
            
        }else if(indexPath.row==6){
            [self requestCategoryAndGo:@"mens-pants"];
            
        }else if(indexPath.row==7){
            [self requestCategoryAndGo:@"mens-shirts"];
            
        }else if(indexPath.row==8){
            [self requestCategoryAndGo:@"mens-sleepwear"];
            
        }else if(indexPath.row==9){
            [self requestCategoryAndGo:@"mens-swimsuits"];
            
        }else if(indexPath.row==10){
            [self requestCategoryAndGo:@"Men's Underwear And Socks"];
            
        }
    
    }else{
                NSLog(@"row % ldpped", (long)indexPath.row);
        
        
                UIStoryboard *storyboard = self.storyboard;
                ProductDetailsViewController *pDetailsVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductDetailsViewController"];
        
         UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pDetailsVC];
        
                UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(backPressed:)];
        
        navigationController.navigationItem.leftBarButtonItem = backButton;
        //pDetailsVC.productDetails = productDetails;
                pDetailsVC.shopStyleModel = self.sJsonModel.products[indexPath.row];
                [self.navigationController pushViewController:pDetailsVC animated:Nil];
                //[self p:navigationController  animated:NO completion:nil  ];
    
    
    }
    
    
    
    
    
    
    
    
//    if (indexPath != nil)
//    {
//        //...
//        NSLog(@"row % ldpped", (long)indexPath.row);
//        
//        
//        UIStoryboard *storyboard = self.storyboard;
//        ProductDetailsViewController *pDetailsVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductDetailsViewController"];
    
       // UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pDetailsVC];
        
//        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
//                                                                       style:UIBarButtonItemStylePlain
//                                                                      target:self
//                                                                      action:@selector(backPressed:)];
        
        //navigationController.navigationItem.leftBarButtonItem = backButton;
        //pDetailsVC.productDetails = productDetails;
//        pDetailsVC.shopStyleModel = self.sJsonModel.products[indexPath.row];
//        [self.navigationController pushViewController:pDetailsVC animated:Nil];
//        //[self p:navigationController  animated:NO completion:nil  ];
//
//        
//    }

    
    

    
    
    
}

-(void)requestCategory:(NSString *)category{
    //move this to the background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
        //add a loading view
        
//        [self.view addSubview:_activityIndicatorView];
//        [_activityIndicatorView startAnimating];
    
    
        [ShopStyleAPIHelper searchforProductCategoryReturnJson:category limit:@"10" completionHandler:^(id responseObject, NSError *error) {
            
            //NSLog(@"the response is %@",responseObject);
            //NSString *stringForResult = [NSString stringWithFormat:@"%@", responseObject];
           
            NSError *err;
            
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"products.price"  ascending:YES];
            //responseObject = [responseObject sortedArrayUsingDescriptors:[NSMutableArray arrayWithObjects:descriptor, nil]];
            
            self.sJsonModel = [[ShopStyleJSONModel alloc] initWithDictionary:responseObject error:&err];
            if (err) {
                NSLog(@"Unable to initialize PublicPhotosModel, %@", err.localizedDescription);
            }
            //when done reload the view
            dispatch_async(dispatch_get_main_queue(), ^{
                //reload the table
                //productsVC.sJsonModel = self.sJsonModel;
                _array = [NSMutableArray new];
                NSArray *arrayToSort =[responseObject objectForKey:@"products"];

                //productsVC.array = [responseObject objectForKey:@"products"];
                //_array = [responseObject objectForKey:@"products"];
                
                //remove the loading view
                [_activityIndicatorView stopAnimating];
                 [_activityIndicatorView removeFromSuperview];
                
                //sort the array high to low
                NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"price"  ascending:YES];
                arrayToSort = [arrayToSort sortedArrayUsingDescriptors:[NSMutableArray arrayWithObjects:descriptor, nil]];
                //self.sJsonModel.products=[[self.sJsonModel.products sortedArrayUsingDescriptors:[NSMutableArray arrayWithObjects:descriptor, nil] ] mutableCopy ];
//                [self.sJsonModel.products removeAllObjects];
                _array = [arrayToSort mutableCopy];
                //self.sJsonModel.products = [arrayToSort mutableCopy];
                [self.tableView reloadData];
                
            });
            
            
            
        }];
    });

}
-(void)requestCategoryAndGo:(NSString *)category{
    //move this to the background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        //add a loading view
        
        //        [self.view addSubview:_activityIndicatorView];
        //        [_activityIndicatorView startAnimating];
        ProductsCategoriesResultsTVC *svc = [[ProductsCategoriesResultsTVC alloc]init];
        
        [ShopStyleAPIHelper searchforProductCategoryReturnJson:category limit:@"30" completionHandler:^(id responseObject, NSError *error) {
            
           
           
            
            NSError *err;
            
            //NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"products.price"  ascending:YES];
            
            
            self.sJsonModel = [[ShopStyleJSONModel alloc] initWithDictionary:responseObject error:&err];
            if (err) {
                NSLog(@"Unable to initialize PublicPhotosModel, %@", err.localizedDescription);
            }
            //when done reload the view
            dispatch_async(dispatch_get_main_queue(), ^{
                //reload the table
                //productsVC.sJsonModel = self.sJsonModel;
                _array = [NSMutableArray new];
                NSArray *arrayToSort =[responseObject objectForKey:@"products"];
                
                //productsVC.array = [responseObject objectForKey:@"products"];
                //_array = [responseObject objectForKey:@"products"];
                
                //remove the loading view
                [_activityIndicatorView stopAnimating];
                [_activityIndicatorView removeFromSuperview];
                
                //sort the array high to low
                NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"price"  ascending:YES];
                arrayToSort = [arrayToSort sortedArrayUsingDescriptors:[NSMutableArray arrayWithObjects:descriptor, nil]];
                //self.sJsonModel.products=[[self.sJsonModel.products sortedArrayUsingDescriptors:[NSMutableArray arrayWithObjects:descriptor, nil] ] mutableCopy ];
                //                [self.sJsonModel.products removeAllObjects];
                _array = [arrayToSort mutableCopy];
                //self.sJsonModel.products = [arrayToSort mutableCopy];
                svc.sJsonModel= self.sJsonModel;
                svc.isComingFromOtherController = TRUE;
                [self.navigationController pushViewController:svc animated:YES];
                //self.navigationItem.rightBarButtonItem = self.rightBarBtn;
                
                
                
                
                [self.tableView reloadData];
                
            });
            
            
            
        }];
    });
    
}
-(void)requestGiftsFor:(NSString *)recipient{
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        //add a loading view
        
        //        [self.view addSubview:_activityIndicatorView];
        //        [_activityIndicatorView startAnimating];
        
        
        [ShopStyleAPIHelper searchforProductReturnJson:recipient limit:@"15" completionHandler:^(id responseObject, NSError *error) {
            
            //NSLog(@"the response is %@",responseObject);
            //NSString *stringForResult = [NSString stringWithFormat:@"%@", responseObject];
            
            NSError *err;
            
            
            self.sJsonModel = [[ShopStyleJSONModel alloc] initWithDictionary:responseObject error:&err];
            if (err) {
                NSLog(@"Unable to initialize PublicPhotosModel, %@", err.localizedDescription);
            }
            //when done reload the view
            dispatch_async(dispatch_get_main_queue(), ^{
                //reload the table
                //productsVC.sJsonModel = self.sJsonModel;
                _array = [NSMutableArray new];
                //productsVC.array = [responseObject objectForKey:@"products"];
                _array = [responseObject objectForKey:@"products"];
                
                //remove the loading view
                [_activityIndicatorView stopAnimating];
                [_activityIndicatorView removeFromSuperview];
                
                [self.tableView reloadData];
                
            });
            
            
            
        }];
    });

}



#pragma mark - YALTabBarInteracting

- (void)tabBarViewWillCollapse {
    if (debug == 1) {
        //NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)tabBarViewWillExpand {
    if (debug == 1) {
       // NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)tabBarViewDidCollapse {
    if (debug == 1) {
      //  NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)tabBarViewDidExpand {
    if (debug == 1) {
      //  NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)extraLeftItemDidPress {
    //take user to search
    //MaleProductsViewController *mvc = [[MaleProductsViewController alloc]init];
    [self.tabBarController setSelectedIndex:0];
    if (debug == 1) {
      //  NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)extraRightItemDidPress {
    if (debug == 1) {
     //   NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}
- (void)malebuttonViewForPinterestPressedAction:(id)sender
{
    /*
     when tappped ask user if they are logged in to save to their Pinterest Board.
     */
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
        
        if (!isLoggedin){
        
        PDKClient *pk = [[PDKClient alloc]init];
            
            [[PDKClient sharedInstance]authenticateWithPermissions:@[PDKClientReadPublicPermissions,
                                                                     PDKClientReadPrivatePermissions,                                                             PDKClientReadRelationshipsPermissions,
                                                                     PDKClientWriteRelationshipsPermissions] withSuccess:^(PDKResponseObject *responseObject) {
                                                                         //
                                                                         //self.user = [responseObject user];
                                                                         //NSString *userName =  self.user.username;
                                                                         //NSLog(@"%@",userName);
                                                                         //[self getUserlikes];
                                                                         [self.logindefaults setBool:YES forKey:@"hasUserLoggedIn"];
                                                                         
                                                                         
                                                                         //[self getUserpins];
                                                                         isLoggedin = true;
                                                                         
                                                                     } andFailure:^(NSError *error) {
                                                                         //error
                                                                         
                                                                     }];
        //[pk createPinWithImageURL:[NSURL URLWithString:photoURL] link:[NSURL URLWithString:productUrl] onBoard:@"Shopn" description:photo.brandedName withSuccess:^(PDKResponseObject *responseObject) {
            //
        
//        } andFailure:^(NSError *error) {
//            //
//        }];
        }
        else{
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
        
        
//        [PDKClient createPinWithImageURL:]
    }
    
}
- (void)malebuttonSharePressedAction:(id)sender
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
       // NSLog(@"row % ldpped", (long)indexPath.row);
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


-(void)buttonBackPressed:(id)sender{
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)backPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    
//    // height of the footer
//    // this needs to be set, otherwise the height is zero and no footer will show
//    return 80;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    
//    // creates a custom view inside the footer
////    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
////    footerView.backgroundColor = [UIColor colorWithRed:255/255.0f green:103/255.0f blue:120/255.0f alpha:1];
////    // create a button with image and add it to the view
////    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 400, 80)];
////    [button setImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
////    //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
////    [button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
////    
////    [footerView addSubview:button];
//    ///
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.selectionList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
//    self.selectionList.delegate = self;
//    self.selectionList.dataSource = self;
//    self.selectionList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
//    self.selectionList.showsEdgeFadeEffect = YES;
//
//    
//    self.selectionList.selectionIndicatorColor = [UIColor redColor];
//    [self.selectionList setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//    [self.selectionList setTitleFont:[UIFont systemFontOfSize:13] forState:UIControlStateNormal];
//    [self.selectionList setTitleFont:[UIFont boldSystemFontOfSize:13] forState:UIControlStateSelected];
//    [self.selectionList setTitleFont:[UIFont boldSystemFontOfSize:13] forState:UIControlStateHighlighted];
//    
//    self.optionsCategories = @[@"WOMEN",
//                               @"MEN",
//                               @"PERFUME",
//                               @"COLOGNE",
//                               @"PURSES",
//                               @"SNEAKERS",
//                               @"BATH&BODY",
//                               ];
//    [self.view addSubview:self.selectionList];
//    
////    self.selectedLabel = [[UILabel alloc] init];
////    self.selectedLabel.text = self.optionsCategories[self.selectionList.selectedButtonIndex];
////    self.selectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    self.selectionList.snapToCenter = YES;
//    //return footerView;
//    return self.selectionList;
//}
- (void)giftfooterTapped {
    [self showWithoutFooter];
    //NSLog(@"Footer tapped");
}
- (void)showWithoutFooter{
    CZPickerView *picker = [[CZPickerView alloc] initWithHeaderTitle:@"Gift Ideas" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
    picker.delegate = self;
    picker.dataSource = self;
    picker.needFooterView = NO;
    
    [picker show];
}

#pragma mark - CZPicker delegates
- (NSAttributedString *)czpickerView:(CZPickerView *)pickerView
               attributedTitleForRow:(NSInteger)row{
    
    NSAttributedString *att = [[NSAttributedString alloc]
                               initWithString:self.trendOptions[row]
                               attributes:@{
                                            NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:18.0]
                                            }];
    return att;
}

- (NSString *)czpickerView:(CZPickerView *)pickerView
               titleForRow:(NSInteger)row{
    return self.trendOptions[row];
}

- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView{
    return self.trendOptions.count;
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row{
   // NSLog(@"%@ is chosen!", self.trendOptions[row]);
}

-(void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemsAtRows:(NSArray *)rows{
    for(NSNumber *n in rows){
        NSInteger row = [n integerValue];
        NSLog(@"%@ is chosen!", self.trendOptions[row]);
    }
}

- (void)czpickerViewDidClickCancelButton:(CZPickerView *)pickerView{
    NSLog(@"Canceled.");
}





- (IBAction)showWithMultipleSelection:(id)sender {
    CZPickerView *picker = [[CZPickerView alloc] initWithHeaderTitle:@"Gift Ideas" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
    picker.delegate = self;
    picker.dataSource = self;
    picker.allowMultipleSelection = YES;
    [picker show];
}
#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    return self.optionsCategories.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    return self.optionsCategories[index];
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    // update the view for the corresponding index
    NSLog(@"select %ld",index);
    NSString *SELECTED = self.optionsCategories[index];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    @"WOMEN",0
//    @"MEN",1
//    @"WOMEN'S SHOES",2
//    @"MEN'S SHOES",3
//    @"WOMEN'S JEWELRY",4
//    @"MEN'S JEWELRY",5
//    @"HANDBAGS",6
//    @"MAKEUP",7
//    @"GIFTS",8
//
    if(!_capStoneMode){
        switch (index) {
            case 0:
               
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                      action:@"women_category_selected"  // Event action (required)
                                                                       label:@"Women Category"          // Event label
                                                                       value:nil] build]];    // Event value
                //[self requestCategory:@"women"] ;
                self.maleCategorySelected = FALSE;
                self.femaleCategorySelected = TRUE;
                [self.view addSubview:_activityIndicatorView];
                //[_activityIndicatorView startAnimating];
                [self.tableView reloadData];
                break;
            
            case 1:
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                      action:@"men_category_selected"  // Event action (required)
                                                                       label:@"men Category"          // Event label
                                                                       value:nil] build]];    // Event value
                self.maleCategorySelected = TRUE;
                self.femaleCategorySelected = FALSE;
                //[self requestCategory:@"mens-clothes"];//@"mens-clothes"];
                [self.view addSubview:_activityIndicatorView];
               // [_activityIndicatorView startAnimating];
                [self.tableView reloadData];
                break;
            case 2:
                self.maleCategorySelected = FALSE;
                self.femaleCategorySelected = FALSE;
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                      action:@"men_gifts_category_selected"  // Event action (required)
                                                                       label:@"men gits Category"          // Event label
                                                                       value:nil] build]];    // Event value
                [self requestGiftsFor:@"Gifts for men"];//[self requestCategory:@"womens-shoes"];//@"diamond-jewelry"];
                [self.view addSubview:_activityIndicatorView];
               // [_activityIndicatorView startAnimating];
                //[self.tableView reloadData];
                break;
            case 3:
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                      action:@"women_gifts_category_selected"  // Event action (required)
                                                                       label:@"women gits Category"          // Event label
                                                                       value:nil] build]];    // Event value
                [self requestGiftsFor:@"Gifts for women"];//[self requestCategory:@"mens-shoes"];//@"diamond-jewelry"];
                [self.view addSubview:_activityIndicatorView];
              //  [_activityIndicatorView startAnimating];
                //[self.tableView reloadData];
                break;
                
            case 4:
                [self requestCategory:@"diamond-jewelry"];
                [self.view addSubview:_activityIndicatorView];
                [_activityIndicatorView startAnimating];
                //[self.tableView reloadData];
                break;
            case 5:
                [self requestCategory:@"mens-watches-and-jewelry"];
                [self.view addSubview:_activityIndicatorView];
                [_activityIndicatorView startAnimating];
                //[self.tableView reloadData];
                break;
            case 6:
                [self requestCategory:@"handbags"];
                [self.view addSubview:_activityIndicatorView];
                [_activityIndicatorView startAnimating];
                //[self.tableView reloadData];
                break;
            case 7:
                [self requestCategory:@"makeup"];
                [self.view addSubview:_activityIndicatorView];
                [_activityIndicatorView startAnimating];
                //[self.tableView reloadData];
                break;
            case 8:
                [self giftfooterTapped];
                //[self.tableView reloadData];
                break;
        }
    
    }else{
        
        switch (index) {
//                @"Gifts for women",
//                @"Gifts for men",
//                @"Gift Cards",
//                @"Cologne",
//                @"Designer Purses"
            case 0:
                [self requestGiftsFor:@"Gifts for women"] ;
                [self.view addSubview:_activityIndicatorView];
                //[_activityIndicatorView startAnimating];
                //[self.tableView reloadData];
                break;
                
            case 1:
                [self requestGiftsFor:@"Gifts for men"];//@"mens-clothes"];
                [self.view addSubview:_activityIndicatorView];
                //[_activityIndicatorView startAnimating];
                //[self.tableView reloadData];
                break;
            case 2:
                [self requestGiftsFor:@"Gift Cards"];//@"diamond-jewelry"];
                [self.view addSubview:_activityIndicatorView];
                //[_activityIndicatorView startAnimating];
                //[self.tableView reloadData];
                break;
            case 3:
                [self requestGiftsFor:@"Funny Gifts"];//@"diamond-jewelry"];
                [self.view addSubview:_activityIndicatorView];
                [_activityIndicatorView startAnimating];
                //[self.tableView reloadData];
                break;
                
            case 4:
                [self requestGiftsFor:@"diamond-jewelry"];
                [self.view addSubview:_activityIndicatorView];
                [_activityIndicatorView startAnimating];
                //[self.tableView reloadData];
                break;
            case 5:
                [self requestGiftsFor:@"mens-watches-and-jewelry"];
                [self.view addSubview:_activityIndicatorView];
                [_activityIndicatorView startAnimating];
                //[self.tableView reloadData];
                break;
    }
    }
    
        
    
    
}


@end
