// For License please refer to LICENSE file in the root of YALAnimatingTabBarController project
//TODO:
/*
 Get season and temperature to show product recommendations. http://stackoverflow.com/questions/13386716/how-to-find-the-current-season-through-any-ios-api
 https://api.forecast.io/forecast/102427fff1a59ac02a37ce77604f1fe4/37.8267,-122.423
 //ask user for current location. Make request to forecast.io, https://developer.forecast.io/
 //use wunderground
 */
/* 
 -Get
 
 */

#import "SearchViewController.h"
#import "ShopStyleAPIHelper.h"
#import "PlaceOrderViewController.h"
#import "ProductsViewController.h"
#import "ShopStyleJSONModel.h"
#import "SearchResultsTVCTableViewController.h"
#import "VoiceSearchTableViewCell.h"

#import "SearchResultsTableViewCell.h"
#import "SearchFilterCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SeasonCategoriesCell.h"
#import "ProductDetailsViewController.h"


#define debug 1
#define kfetchQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
@interface SearchViewController()<UISearchDisplayDelegate, UISearchResultsUpdating, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate>{
    
}
@property NSArray *trendOptions;
@property NSArray *trendSearchOptions;
@property NSTimer *myTimer;
@property (nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic)CLGeocoder* clGeocoder;
@property (strong, nonatomic) CLLocation *location;
@property  CLLocationCoordinate2D coord;

@end

@implementation SearchViewController
@synthesize mySearchBar,isLoggedin,photo, searchBarShown,userLocationEnabled, isDayTime, locationManager,clGeocoder, location, coord;

-(void)viewDidLoad{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Search page"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    //set trend options
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImage:)];
    self.tapGestureRecognizer.cancelsTouchesInView = NO;
    self.tapGestureRecognizer.delegate = self;
    //[self.view addGestureRecognizer:self.tapGestureRecognizer];
    self.trendOptions = @[@"Gifts for women(coming soon)", @"Gifts for men(coming soon)", @"Gift Cards(coming soon)", @"Cologne(coming soon)", @"Designer Purses(coming soon)"];
    self.trendSearchOptions = @[@"Red and White shoes", @"men casual shirts",@"women boots",@"navy blue dress", @"Nike Jordans", @"Michael Kors bag", @"Red khakis", @"Nike boots",@"dress pants",@"denim",@"chinos",@"casual shirts",@"men dress shirts",@"Women outerwear",@"women shirts",@"men boots",  @"levi jeans", @"basketball shorts", @"heels"];
    //[self.navigationController.navigationBar setHidden:YES];
    //self.viewToAnimate.layer.cornerRadius = _viewToAnimate.frame.size.width/2;
    self.viewToAnimate.layer.masksToBounds = YES;
    self.navigationController.navigationItem.title = @"Search";
    
    UIView *iv = [[UIView alloc] initWithFrame:CGRectMake(0,0,32,32)];
    [iv setBackgroundColor:[UIColor blackColor]];
    self.navigationController.navigationItem.titleView = iv;
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    
    //self.navigationItem.title =  @"Search";
    //self.extendedLayoutIncludesOpaqueBars = true;
    searchBarShown = NO;
    //set up search controller
    [self setUpSearchBar];
    
    self.logindefaults = [NSUserDefaults standardUserDefaults];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    userLocationEnabled = [self.logindefaults boolForKey:@"LocationAccessGranted"];
    NSLog(@"Location Enabled: %d",userLocationEnabled);
    self.shouldGetWeatherData = [self shouldgetCityStateWeatherLongLat];
    if (userLocationEnabled && self.shouldGetWeatherData) {
        //if both are true
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIEventCategory value:@"Location in use for app"];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
       
        [self getCityStateWeatherLongLat];
    }
    
    [self setUpCustomSearchFooter];
    //set up indicator
    
//    _activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallScaleRippleMultiple tintColor:[UIColor redColor] size:30.0f];
//    _activityIndicatorView.frame = CGRectMake(0.0f, 0.0f, 80.0f, 80.0f);
//    _activityIndicatorView.center=self.view.center;
     //[_activityIndicatorView startAnimating];
    //[self.tableView addSubview:_activityIndicatorView];
    
    
//    NSString *season = [self.logindefaults valueForKey:@"Season"];
//    if (userLocationEnabled) {
//        [self setProductsforSeason:season forGender:nil];
//    }
    
    //[self requestLocation];
    //set the background of the view
    //   self.viewToAnimate.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"microphone"]];
    
//        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5.0, 0.0, 320.0, 44.0)];
//        searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 310.0, 44.0)];
//        searchBarView.autoresizingMask = 0;
//        searchBar.delegate = self;
//        //[searchBarView addSubview:searchBar];
//        self.navigationItem.titleView = searchBarView; //works
//        self.navigationItem.title = @"Search";
        //[self.tabBarController setTitle:@"Title"];
    
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    //self.navigationController.navigationBar.translucent = NO;
    //if the user just logged in show this controller modally
    
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    isLoggedin = [self.logindefaults boolForKey:@"hasUserLoggedIn"];
    self.tabBarController.selectedIndex = 0;
    //get current daytime
    
    //[self getCityStateLongLat];
    
    self.isDayTime = [self.logindefaults boolForKey:@"IsDayTime"];
    userLocationEnabled = [self.logindefaults boolForKey:@"LocationAccessGranted"];
    if(userLocationEnabled){
        [self getCityState];
    }
    NSString *season = [self.logindefaults valueForKey:@"Season"];
    self.sJsonModel = nil;
    if (userLocationEnabled) {
        [self setProductsforSeason:season forGender:nil];
    }else{
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, queue, ^{
            NSLog(@"1: Adding indicator");
            //[_activityIndicatorView startAnimating];
            [self.tableView addSubview:_activityIndicatorView];
            [self getRandomProducts];
        });
        
        dispatch_group_notify(group, queue, ^{
           // NSLog(@"2: Removing indicator");
            //[_activityIndicatorView removeFromSuperview];
        });
        
        //[self.tableView addSubview:_activityIndicatorView];
        //[self getRandomProducts];
        //[_activityIndicatorView removeFromSuperview];
    }
    [self.tableView reloadData]; //why this again? when user 
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [_activityIndicatorView removeFromSuperview];
}
- (void)didTapImage:(UITapGestureRecognizer *)tap{
    [self getRandomProducts];
    
}

-(void)setUpSearchBar{
    UIStoryboard *storyboard = self.storyboard;
    self.searchTVController = [storyboard instantiateViewControllerWithIdentifier:@"SearchResultsTVCTableViewController"];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchTVController];
    self.searchController.searchResultsUpdater = self;
    //self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.definesPresentationContext = true;
    self.definesPresentationContext = YES;
    self.searchController.searchBar.scopeButtonTitles = nil;
    self.searchController.searchBar.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    //[self.view addSubview:self.searchController.searchBar];
    [self.searchController.searchBar sizeToFit];
    self.navigationItem.titleView = self.searchController.searchBar;
    self.searchController.searchBar.hidden =YES;
    self.searchController.searchBar.returnKeyType = UIReturnKeySearch;
    //
    
    
    //    self.navigationController.navigationItem.titleView = self.searchController.searchBar;
    //    [self.navigationController.navigationBar addSubview:self.searchController.searchBar];
    
    //add search bar to tableview header
    //self.tableView.tableHeaderView = self.searchController.searchBar;
    
}
-(void)setUpCustomSearchFooter{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4, 0, 360, 24)];
    //[button setImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
    [self.btnforViewForSearch setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    self.btnforViewForSearch.layer.cornerRadius = 2;
    self.btnforViewForSearch.layer.borderWidth = 1;
    self.btnforViewForSearch.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    //[self.btnforViewForSearch setContentEdgeInsets:UIEdgeInsetsMake(5.0, 5.0, 0.0, 0.0)];
    //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
    
    [self.btnforViewForSearch addTarget:self action:@selector(loadSearchView) forControlEvents:UIControlEventTouchUpInside];
    [self.viewForSearch addSubview:button];
    
    //    SearchFilterCell* myViewObject = [[[NSBundle mainBundle] loadNibNamed:@"SearchFilterCell" owner:self options:nil] objectAtIndex:0];
    //    [myViewObject setFrame:CGRectMake(100, 0, 320, self.viewForSearch.frame.size.height)];
    
    //[self.viewForSearch addSubview:myViewObject];
    
}



#pragma mark - search delegates
//- (void)willPresentSearchController:(UISearchController *)searchController
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        searchController.searchResultsController.view.hidden = NO;
//
//    });
//
//        self.tableView.backgroundColor = [UIColor whiteColor];
//
//
//}
//- (void)didPresentSearchController:(UISearchController *)searchController
//{
//    searchController.searchResultsController.view.hidden = NO;
//    self.searchTVController.searchResults = nil;
//}
#pragma mark - UISearchControllerDelegate & UISearchResultsDelegate

// Called when the search bar becomes first responder
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    // Set searchString equal to what's typed into the searchbar
    NSString *searchString = self.searchController.searchBar.text;
    
    [ShopStyleAPIHelper searchforProductReturnJson:searchString limit:@"12" completionHandler:^(id responseObject, NSError *error) {
        
        //
        
        
        
        NSLog(@"the response is %@",responseObject);
        //NSString *stringForResult = [NSString stringWithFormat:@"%@", responseObject];
        NSString *stringForResult=(NSString *)responseObject;
        //test
        UIStoryboard *storyboard = self.storyboard;
        
        ProductsViewController *productsVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductsViewController"];
        
        //convert response dict to json
        
        //NSString *rawJson = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        //rawJson = [rawJson stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
        
        //NSLog(@"JSON: %@",rawJson);
        NSError *err;
        
        
        self.sJsonModel = [[ShopStyleJSONModel alloc] initWithDictionary:responseObject error:&err];
        if (err) {
            NSLog(@"Unable to initialize PublicPhotosModel, %@", err.localizedDescription);
        }
        
        
        
        
        ///
        
        
        //productsVC.sJsonModel = self.sJsonModel;
        productsVC.array = [responseObject objectForKey:@"products"];
        self.searchResults = [responseObject objectForKey:@"products"];
        //productsVC.dictImages = [results valueForKey:@"images"];
        
        
        //orderDetails.rates = responseObject;
        //dismiss loading view and send user on if no errors were found and all forms copleted
        //[activityView stopAnimating];
        //searchBar.hidden = true;
        //[self.navigationController pushViewController:productsVC animated:YES];
        self.navigationItem.rightBarButtonItem = self.rightBarBtn;
        
        
        
    }];
    
    
    //[self updateFilteredContentForAirlineName:searchString];
    
    // If searchResultsController
    if (self.searchController.searchResultsController) {
        
        
        
        // Update searchResults
        self.searchTVController.searchResults = self.searchResults;
        self.searchTVController.sJsonModel = self.sJsonModel;
        
        // And reload the tableView with the new data
        [self.searchTVController.tableView reloadData];
    }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}
-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    
    //log how many times serch is clicked
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"search_button_press"  // Event action (required)
                                                           label:@"Search"          // Event label
                                                           value:nil] build]];    // Event value
    //This'll Show The cancelButton with Animation
    [searchBar setShowsCancelButton:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBarHidden = NO;
    //remaining Code'll go here
}
-(void) searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBarHidden = false;
}
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    if (searchText != nil && [searchText length] > 2) {
//        ///[self findSymbols:searchText];
//        NSLog(@"%@", searchText);
//
//
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(request) object:searchText];
//
//
//
//        [self performSelector:@selector(requestDataFromWS:) withObject:searchText afterDelay:0.001];
//    }
//
//}
//- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(request) object:text];
//
//
//
//    [self performSelector:@selector(requestDataFromWS:) withObject:text afterDelay:0.001];
//
//
//    return YES;
//}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //clicked, search into web service here. Load more content when user scrolls to bottom.
    
    [ShopStyleAPIHelper searchforProductReturnJson:searchBar.text limit:@"15" completionHandler:^(id responseObject, NSError *error) {
        
        
        
        
        
        NSLog(@"the response is %@",responseObject);
        //NSString *stringForResult = [NSString stringWithFormat:@"%@", responseObject];
        
        //test
        UIStoryboard *storyboard = self.storyboard;
        
        ProductsViewController *productsVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductsViewController"];
        
        //convert response dict to json
        
        //NSString *rawJson = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        //rawJson = [rawJson stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
        
        //NSLog(@"JSON: %@",rawJson);
        NSError *err;
        
        
        self.sJsonModel = [[ShopStyleJSONModel alloc] initWithDictionary:responseObject error:&err];
        if (err) {
            NSLog(@"Unable to initialize PublicPhotosModel, %@", err.localizedDescription);
        }
        
        
        
        
        ///
        
        
        productsVC.sJsonModel = self.sJsonModel;
        productsVC.array = [responseObject objectForKey:@"products"];
        //productsVC.dictImages = [results valueForKey:@"images"];
        
        
        //orderDetails.rates = responseObject;
        //dismiss loading view and send user on if no errors were found and all forms copleted
        //[activityView stopAnimating];
        //searchBar.hidden = true;
        //[self.navigationController pushViewController:productsVC animated:YES];
        //self.navigationItem.rightBarButtonItem = self.rightBarBtn;
        
        
        
    }];
    
    if (self.searchController.searchResultsController) {
        
        
        
        // Update searchResults
        self.searchTVController.searchResults = self.searchResults;
        self.searchTVController.sJsonModel = self.sJsonModel;
        
        // And reload the tableView with the new data
        [self.searchTVController.tableView reloadData];
    }
    //save the data response and move it to another controller.
    
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //self.navigationItem.rightBarButtonItem = self.rightBarBtn;
    [searchBar resignFirstResponder];
    //hide the bar
    self.searchController.searchBar.hidden = YES;
    searchBarShown = NO;
    self.tableView.hidden = NO;
    NSString *season = [self.logindefaults valueForKey:@"Season"];
    self.sJsonModel = nil;
    if (userLocationEnabled) {
        [self setProductsforSeason:season forGender:nil];
    }else{
        [self getRandomProducts];
    }
    [self.tableView reloadData];
    //searchBar.hidden = YES;
    //[self.navigationController.navigationBar setHidden:YES];
}
-(void)requestDataFromWS:(NSString *)searchText{
    
    [ShopStyleAPIHelper searchforProductReturnJson:searchText limit:@"10" completionHandler:^(id responseObject, NSError *error) {
        
        
        SearchResultsTVCTableViewController *svc = [[SearchResultsTVCTableViewController alloc]init];
        
        
        
        //NSLog(@"the response is %@",responseObject);
        //NSString *stringForResult = [NSString stringWithFormat:@"%@", responseObject];
        NSString *stringForResult=(NSString *)responseObject;
        //test
        UIStoryboard *storyboard = self.storyboard;
        
        ProductsViewController *productsVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductsViewController"];
        
        //convert response dict to json
        
        //NSString *rawJson = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        //rawJson = [rawJson stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
        
        //NSLog(@"JSON: %@",rawJson);
        
        NSDictionary *json = (NSDictionary *)responseObject;
        NSError *err;
        
        
        self.sJsonModel = [[ShopStyleJSONModel alloc] initWithDictionary:responseObject error:&err];
        if (err) {
            NSLog(@"Unable to initialize ShopStyleJSONModel, %@", err.localizedDescription);
        }
        
        
        
        
        ///
        svc.sJsonModel = self.sJsonModel;
        svc.isComingFromOtherController = YES;
        //productsVC.sJsonModel = self.sJsonModel;
        productsVC.array = [responseObject objectForKey:@"products"];
        self.searchResults = [responseObject objectForKey:@"products"];
        //productsVC.dictImages = [results valueForKey:@"images"];
        
        
        //orderDetails.rates = responseObject;
        //dismiss loading view and send user on if no errors were found and all forms copleted
        //[activityView stopAnimating];
        //searchBar.hidden = true;
        [self.navigationController pushViewController:svc animated:YES];
        self.navigationItem.rightBarButtonItem = self.rightBarBtn;
        
        
        
    }];
    // If searchResultsController
    if (self.searchController.searchResultsController) {
        
        
        
        // Update searchResults
        self.searchTVController.searchResults = self.searchResults;
        self.searchTVController.sJsonModel = self.sJsonModel;
        
        // And reload the tableView with the new data
        [self.searchTVController.tableView reloadData];
    }
    
    
    
}

-(void)requestDataFromWSForSeason:(NSString *)searchText{
    
    [ShopStyleAPIHelper searchforProductReturnJson:searchText limit:@"50" completionHandler:^(id responseObject, NSError *error) {
        
        
        NSDictionary *json = (NSDictionary *)responseObject;
        NSError *err;
        
        NSLog(@"WINTER: %@", json);
        self.sJsonModel = [[ShopStyleJSONModel alloc] initWithDictionary:responseObject error:&err];
        if (err) {
            NSLog(@"Unable to initialize ShopStyleJSONModel, %@", err.localizedDescription);
        }
        //Reload tableView with animation
        [self.tableView beginUpdates];
       
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
         [self.tableView endUpdates];
        //[self.tableView reloadData];

        
        
        
    }];
    
    
    
}



#pragma mark - Table


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(userLocationEnabled){
        return 2; //should be 2
    }
    
    return 1;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(userLocationEnabled){
        if (section == 0){
            return 1;
        }else if(section==1){
            //return json model count
            return self.sJsonModel.products.count;
            
        }else if(section==2){
            //return json model count
            return self.sJsonModel.products.count;
        }
        return 1;
    }else{
        if (section == 0){
            return self.sJsonModel.products.count;
//            return self.trendSearchOptions.count;
//            return 1;
        }
        return 1;
    }
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (userLocationEnabled) {
        if (indexPath.section==0) {
            return 0.01f;//return 240;
        }else if(indexPath.section==1){
            return 350; //row for products
        }
        return 75;
    }else{
        if (indexPath.section==0) {
            return 350;//return 240;
        }
    }
    return 75;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(userLocationEnabled){
        if (indexPath.section == 0){
            
            static NSString *CellIdentifier = @"CellIdentifier";
            
            // Dequeue or create a cell of the appropriate type.
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
            
            // Configure the cell.
            // cell.textLabel.text =[self.trendSearchOptions objectAtIndex:indexPath.row];
            
            return cell;
        }
        else if (indexPath.section==1){
//            static NSString *CellIdentifier = @"CellIdentifier";
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            if (cell == nil) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//                cell.accessoryType = UITableViewCellAccessoryNone;
//            }
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
//            
//            // Configure the cell.
//            ShopStyleProductsModel *product = self.sJsonModel.products[indexPath.row];
//            //        NSString *productUrl= photo.clickUrl;
//            NSString *nURL = [product valueForKeyPath:@"image.sizes.Best.url"];
//            
//            
//            cell.textLabel.text =[product valueForKey:@"brandedName"];
            
//            
//            return cell;
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
           
            
            
            
            
            
            
        }else{
            
            static NSString *CellIdentifier = @"CellIdentifier";
            
            // Dequeue or create a cell of the appropriate type.
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
            
            // Configure the cell.
            cell.textLabel.text =[self.trendSearchOptions objectAtIndex:indexPath.row];//[NSString stringWithFormat:@"%ld", (long)indexPath.row];
            //cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width+1000, 0.f, 0.f);
            return cell;
            
            
            
            
        }
    }else{
        //else not user location enabled.
        if (indexPath.section == 0){
            
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
        else if (indexPath.section==1){
            
            
            
            static NSString *CellIdentifier = @"CellIdentifier";
            
            // Dequeue or create a cell of the appropriate type.
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
            
            // Configure the cell.
            cell.textLabel.text =[self.trendSearchOptions objectAtIndex:indexPath.row];//[NSString stringWithFormat:@"%ld", (long)indexPath.row];
            //cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width+1000, 0.f, 0.f);
            
            
            
            return cell;
            
            
        }else{
            
            static NSString *CellIdentifier = @"CellIdentifier";
            
            // Dequeue or create a cell of the appropriate type.
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
            
            // Configure the cell.
            NSString *stringtoShow = [NSString stringWithFormat:@"Its currently %@ season in %@, %@", [self.logindefaults valueForKey:@"Season"], [self.logindefaults valueForKey:@"City"],[self.logindefaults valueForKey:@"State"]];
            cell.textLabel.text =stringtoShow;//[self.trendSearchOptions objectAtIndex:indexPath.row];//[NSString stringWithFormat:@"%ld", (long)indexPath.row];
            return cell;
            
            
        }
        
        
        
        
    }
    
    return nil;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    // height of the footer
    // this needs to be set, otherwise the height is zero and no footer will show
    if (userLocationEnabled) {
        
     
        if (section == 0) {
            return 50;
        }
    }
    return 0.01f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (userLocationEnabled) {
        
    
        if (section ==0) {
            
            
            UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 80)];
            footerView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
            // create a button with image and add it to the view
            //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
            //[button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(8, 10, 400, 30)];
            NSString *stringtoShow = [NSString stringWithFormat:@"Most Popular picks for %@", [[self.logindefaults valueForKey:@"Season"] uppercaseString]];
            label.text = stringtoShow;
            label.textColor    = [UIColor darkGrayColor];
            label.font = [UIFont fontWithName:@"Avenir-Book" size:20];
            label.textAlignment = NSTextAlignmentLeft;
            [footerView addSubview:label];
            /*
             
             
             footerView.layer.shadowColor = [[UIColor blackColor] CGColor];
             footerView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
             footerView.layer.shadowRadius = 0.5f;
             footerView.layer.shadowOpacity = 0.2f;
             footerView.layer.masksToBounds = NO;
             */
            
            
            
            
            return footerView;
        }
    }else{
        //user location not enabled
        if (section ==0) {
            
            
//            UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 80)];
//            footerView.backgroundColor = [UIColor colorWithRed:83/255.0f green:17/255.0f blue:142/255.0f alpha:1];
//            
//            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(8, 10, 400, 30)];
//            NSString *stringtoShow = @"Footer:Add Image Here(Instagram Integration)";
//            label.text = stringtoShow;
//            label.textColor    = [UIColor whiteColor];
//            label.font = [UIFont fontWithName:@"Avenir-Book" size:20];
//            label.textAlignment = NSTextAlignmentLeft;
//            [footerView addSubview:label];
//            /*
//             
//             
//             footerView.layer.shadowColor = [[UIColor blackColor] CGColor];
//             footerView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//             footerView.layer.shadowRadius = 0.5f;
//             footerView.layer.shadowOpacity = 0.2f;
//             footerView.layer.masksToBounds = NO;
//             */
//            
//            
//            
//            
//            return footerView;
        }
    
    
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(userLocationEnabled){
        if (section==0) {
            return 100;
        }
        else if (section == 1|| section==2 ) {
            return 0.01f;
        }
        return 0.01f;
    }else{
        if (section==0||section == 1|| section==2 ) {
            return 100;
        
        }
    }
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(userLocationEnabled){
        if (section==0) {
            static NSString *CellIdentifier = @"SeasonCategoriesCell";
            SeasonCategoriesCell *cellDetails = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"SeasonCategoriesCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            if(self.isDayTime==false){
                cellDetails.backgroundColor = [UIColor colorWithRed:83/255.0f green:17/255.0f blue:142/255.0f alpha:1]; //deep purple
                //                cellDetails.backgroundColor = [UIColor colorWithRed:212/255.0f green:122/255.0f blue:236/255.0f alpha:1];//too bright
                //                cellDetails.backgroundColor = [UIColor colorWithRed:138/255.0f green:94/255.0f blue:178/255.0f alpha:1];
                cellDetails.degreeLabel.textColor = [UIColor whiteColor];
                cellDetails.degreeSymbolLabel.textColor = [UIColor whiteColor];
                cellDetails.degreeMessage.textColor = [UIColor whiteColor];
                cellDetails.fahrenheitLabel.textColor =[UIColor whiteColor];
                //iconcontainer
                cellDetails.iconContainer.backgroundColor = [UIColor colorWithRed:138/255.0f green:94/255.0f blue:178/255.0f alpha:1];
            }
//            else{
//                //skyblue
//                cellDetails.iconContainer.backgroundColor = [UIColor colorWithRed:135/255.0f green:206/255.0f blue:235/255.0f alpha:1];
//            }
            //            NSString *stringtoShow = [NSString stringWithFormat:@"Its currently %@ in %@, %@", [self.logindefaults valueForKey:@"Season"], [self.logindefaults valueForKey:@"City"],[self.logindefaults valueForKey:@"State"]];
            NSString *degree = [NSString stringWithFormat:@"%.15f", self.forecastModel.currently.temperature]; //[self.forecastModel.currently objectForKey:@"temperature"]; //[NSString stringWithFormat:@"%@",[self.forecastModel.currently objectForKey:@"temperature"]];
            double d = [degree doubleValue];
            cellDetails.degreeLabel.text = [NSString stringWithFormat:@"%.0f%@",d,@"\u00B0"];
//            NSString *stringtoShow = [NSString stringWithFormat:@"Its currently %@ season in %@ ", [self.logindefaults valueForKey:@"Season"], [self.logindefaults valueForKey:@"City"] ];
            NSString *stringtoShow = [NSString stringWithFormat:@"Its currently %@ season", [self.logindefaults valueForKey:@"Season"]];
            cellDetails.iconImage.image = [UIImage imageNamed:[self.logindefaults valueForKey:@"Season"]];
            //[self.logindefaults valueForKey:@"Season"] season ICON [UIImage imageNamed: @"clear-day-light"]; [self.logindefaults valueForKey:@"Season"]
            NSLog(@"Current weather icon: %@", [self.logindefaults valueForKey:@"WeatherIcon"]);
            cellDetails.degreeMessage.text = stringtoShow;
            [cellDetails setSeparatorInset:UIEdgeInsetsZero];
            [cellDetails setLayoutMargins:UIEdgeInsetsZero];
            
            
            return cellDetails;
        }
        else if (section==1){
            // creates a custom view inside the footer
            UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
            footerView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
            // create a button with image and add it to the view
            //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
            //[button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 400, 30)];
            NSString *stringtoShow = [NSString stringWithFormat:@"Popular picks for %@", [[self.logindefaults valueForKey:@"Season"] uppercaseString]];
            label.text = stringtoShow;
            label.textColor    = [UIColor darkGrayColor];
            label.font = [UIFont fontWithName:@"Avenir-Book" size:20];
            label.textAlignment = NSTextAlignmentLeft;
            
            
            return footerView;
        
        }else if (section==2){
            // creates a custom view inside the footer
            UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 80)];
            footerView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
            // create a button with image and add it to the view
            //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
            //[button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 400, 30)];
            NSString *stringtoShow = [NSString stringWithFormat:@"Popular picks for %@", [[self.logindefaults valueForKey:@"Season"] uppercaseString]];
            //label.text = stringtoShow;
            label.textColor    = [UIColor darkGrayColor];
            label.font = [UIFont fontWithName:@"Avenir-Book" size:20];
            label.textAlignment = NSTextAlignmentLeft;
            
            /*
             
             
             footerView.layer.shadowColor = [[UIColor blackColor] CGColor];
             footerView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
             footerView.layer.shadowRadius = 0.5f;
             footerView.layer.shadowOpacity = 0.2f;
             footerView.layer.masksToBounds = NO;
             */
            
            [footerView addSubview:label];
            
            
            
            
            footerView.layer.shadowColor = [[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1] CGColor];
            footerView.layer.shadowOpacity = 0.5;
            footerView.layer.shadowOffset = CGSizeMake(0, 1);
            
            
            return footerView;
        }
    }else{
        //userlocation not enabled
         if (section==0){
             
//             UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 80)];
//             footerView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];//UIEdgeInsetsMake(5.0, 5.0, 0.0, 0.0)
//             // create a button with image and add it to the view
//             //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
//             //[button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
//             UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(8, 10, 400, 30)];
//             
//             label.text = @"Top Trending Searches";
//             label.textColor    = [UIColor darkGrayColor];
//             label.font = [UIFont fontWithName:@"Avenir-Book" size:20];
//             label.textAlignment = NSTextAlignmentLeft;
//             [footerView addSubview:label];
//             
//             
//             
//             
//             
//             return footerView;
             static NSString *CellIdentifier = @"SeasonCategoriesCell";
             SeasonCategoriesCell *cellDetails = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
             if(cellDetails ==nil){
                 [self.tableView registerNib:[UINib nibWithNibName:@"SeasonCategoriesCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                 cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
             }
             if(self.isDayTime==false){
                 cellDetails.backgroundColor = [UIColor colorWithRed:83/255.0f green:17/255.0f blue:142/255.0f alpha:1]; //deep purple
                 //                cellDetails.backgroundColor = [UIColor colorWithRed:212/255.0f green:122/255.0f blue:236/255.0f alpha:1];//too bright
                 //                cellDetails.backgroundColor = [UIColor colorWithRed:138/255.0f green:94/255.0f blue:178/255.0f alpha:1];
                 cellDetails.degreeLabel.textColor = [UIColor whiteColor];
                 cellDetails.degreeSymbolLabel.textColor = [UIColor whiteColor];
                 cellDetails.degreeMessage.textColor = [UIColor whiteColor];
                 cellDetails.fahrenheitLabel.textColor =[UIColor whiteColor];
                 //iconcontainer
                 cellDetails.iconContainer.backgroundColor = [UIColor colorWithRed:138/255.0f green:94/255.0f blue:178/255.0f alpha:1];
             }
             //            else{
             //                //skyblue
             //                cellDetails.iconContainer.backgroundColor = [UIColor colorWithRed:135/255.0f green:206/255.0f blue:235/255.0f alpha:1];
             //            }
             //            NSString *stringtoShow = [NSString stringWithFormat:@"Its currently %@ in %@, %@", [self.logindefaults valueForKey:@"Season"], [self.logindefaults valueForKey:@"City"],[self.logindefaults valueForKey:@"State"]];
             NSString *degree = [NSString stringWithFormat:@"%.15f", self.forecastModel.currently.temperature]; //[self.forecastModel.currently objectForKey:@"temperature"]; //[NSString stringWithFormat:@"%@",[self.forecastModel.currently objectForKey:@"temperature"]];
             double d = [degree doubleValue];
             cellDetails.degreeLabel.text = [NSString stringWithFormat:@"%.0f%@",d,@"\u00B0"];
             NSString *stringtoShow = @"Explore Trending Products";
             if([self.logindefaults valueForKey:@"Season"]){
             cellDetails.iconImage.image = [UIImage imageNamed:@"defaultseason"];
                 [cellDetails.iconContainer addGestureRecognizer:self.tapGestureRecognizer];
             }else{
             cellDetails.iconImage.image = [UIImage imageNamed:@"Summer"];
             }
             
             //[self.logindefaults valueForKey:@"Season"] season ICON [UIImage imageNamed: @"clear-day-light"]; [self.logindefaults valueForKey:@"Season"]
             NSLog(@"Current weather icon: %@", [self.logindefaults valueForKey:@"WeatherIcon"]);
             cellDetails.degreeMessage.text = stringtoShow;
             [cellDetails setSeparatorInset:UIEdgeInsetsZero];
             [cellDetails setLayoutMargins:UIEdgeInsetsZero];
             
             //self.tableView.tableHeaderView = cellDetails;
             
             return cellDetails;
        }
        
        
    }
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //send user to productDetailsViewcontroller
    
    
    
//    if (indexPath.section ==0)
//    {
//        [self loadSearchView];
//        
//        
//    }else{
//        
//        NSString *stringToSearch = [self.trendSearchOptions objectAtIndex:indexPath.row];
//        [self requestDataFromWS:stringToSearch];
//        
//        
//    }
    if (indexPath != nil)
    {
        //...
        NSLog(@"row % ldpped", (long)indexPath.row);
       
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        ProductDetailsViewController *pDetailsVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductDetailsViewController" ];
        
        
            pDetailsVC.shopStyleModel = self.sJsonModel.products[indexPath.row];
        
        
            
            [self.navigationController pushViewController:pDetailsVC animated:Nil];
            dispatch_async(dispatch_get_main_queue(), ^{});
         
        
        //navigationController.navigationItem.leftBarButtonItem = backButton;
        //pDetailsVC.productDetails = productDetails;
        
        //[sel:navigationController  animated:NO completion:nil  ];
        
    }



}

- (void)footerTapped {
    [self showWithoutFooter];
    NSLog(@"Footer tapped");
}

#pragma mark - YALTabBarInteracting

- (void)tabBarViewWillCollapse {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)tabBarViewWillExpand {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)tabBarViewDidCollapse {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)tabBarViewDidExpand {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}
-(void)extraLeftItemDidPress{
    
    
}
-(void)extraRightItemDidPress{
    
}

- (void) traitCollectionDidChange: (UITraitCollection *) previousTraitCollection {
    
    [super traitCollectionDidChange: previousTraitCollection];
    
    if(self.searchController.active && ![UIApplication sharedApplication].statusBarHidden && self.searchController.searchBar.frame.origin.y == 0)
    {
        UIView *container = self.searchController.searchBar.superview;
        
        container.frame = CGRectMake(container.frame.origin.x, container.frame.origin.y, container.frame.size.width, container.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
    }
}
-(void)callVoiceSearchMethod{
    //after using watson speech sdk..upgrade to watson Q&A API for further enhancement :D Use Watson speech sdk to listen for query to pass to this controller
    NSString *stringForResult = @"This feature is coming soon.";
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Start Voice Search"
                                          message:stringForResult
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)toggleSearch:(id)sender {
    
    if(!searchBarShown) {
        self.searchController.searchBar.hidden = NO;
        searchBarShown = YES;
        
        //[self.searchController.searchBar setActive:YES];
        [self.searchController.searchBar becomeFirstResponder];
        
        self.navigationItem.rightBarButtonItem = nil;
        
        
        
        
        
    }else {
        self.searchController.searchBar.hidden = YES;
        searchBarShown = NO;
        //[self.searchController setActive:NO];
        //[self.rightBarBtn setEnabled:NO];
        
        
        
    }
}
-(void)loadSearchView{
    if(!searchBarShown) {
        self.searchController.searchBar.hidden = NO;
        searchBarShown = YES;
        
        //[self.searchController.searchBar setActive:YES];
        [self.searchController.searchBar becomeFirstResponder];
        
        self.navigationItem.rightBarButtonItem = nil;
        self.tableView.hidden = YES;
        
    }else {
        self.searchController.searchBar.hidden = YES;
        searchBarShown = NO;
        //[self.searchController setActive:NO];
        //[self.rightBarBtn setEnabled:NO];
        self.tableView.hidden = NO;
        
        
        
    }
}
#pragma get current city state long lat
-(void)getCityStateWeatherLongLat{
    [self.locationManager startUpdatingLocation];
    self.clGeocoder = [CLGeocoder new];
    location = [locationManager location];
    coord = [location coordinate];
    [self.logindefaults setDouble:coord.longitude forKey:@"Longitude"];
    [self.logindefaults setDouble:coord.latitude forKey:@"Latitude"];
    //[self.logindefaults setObject:[ForecastIOHandler getCurrentDate] forKey:@"WeatherDate"];
    [ForecastIOHandler getWeatherIconForLocation:[self.logindefaults doubleForKey:@"Latitude"] longitude:[self.logindefaults doubleForKey:@"Longitude"] completionHandler:^(id responseObject, NSError *error) {
        
        //map the json to a model
        NSError *err;
        
        
        self.forecastModel = [[ForecastIOModel alloc] initWithDictionary:responseObject error:&err];
        if (err) {
            NSLog(@"Unable to initialize ForecastModel, %@", err.localizedDescription);
        }
        //Loop through and get objects in data array.
        ForecastIODailyDataModel *data;
        //        for (int i=0; i<[self.forecastModel.daily.data count]; i++){
        //            data = self.forecastModel.daily.data[i];
        //
        //        }
        [self.logindefaults setValue: self.forecastModel.currently.icon forKey:@"WeatherIcon"];
        
        //[self.logindefaults setObject:[ForecastIOHandler getCurrentDate] forKey:@"WeatherDate"];
        //[self.tableView reloadData];
        
        
    }];
    //next method gets it in viewwillappear
    //    [self.clGeocoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
    //
    //        CLPlacemark *placemark = [placemarks objectAtIndex:0];
    //        //[self.logindefaults setBool:YES forKey:@"LocationAccessGranted"];
    //        NSString *city = placemark.locality;
    //        NSString *state = placemark.administrativeArea;
    //        [self.logindefaults setValue:city forKey:@"City"];
    //        [self.logindefaults setValue:state forKey:@"State"];
    //        NSLog(@"city-state:%@,%@",[self.logindefaults valueForKey:@"City"],[self.logindefaults valueForKey:@"State"]);
    //        //[self.tableView reloadData];
    //        [self.locationManager stopUpdatingLocation];
    //    }];
}
-(void)getCityState{
    [self.locationManager startUpdatingLocation];
    self.clGeocoder = [CLGeocoder new];
    location = [locationManager location];
    coord = [location coordinate];
    [self.logindefaults setDouble:coord.longitude forKey:@"Longitude"];
    [self.logindefaults setDouble:coord.latitude forKey:@"Latitude"];
    [self.clGeocoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        //[self.logindefaults setBool:YES forKey:@"LocationAccessGranted"];
        NSString *city = placemark.locality;
        NSString *state = placemark.administrativeArea;
        [self.logindefaults setValue:city forKey:@"City"];
        [self.logindefaults setValue:state forKey:@"State"];
        NSLog(@"city-state:%@,%@",[self.logindefaults valueForKey:@"City"],[self.logindefaults valueForKey:@"State"]);
        //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        //[self.tableView reloadData];
        [self.locationManager stopUpdatingLocation];
    }];
    
    
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
    NSLog(@"%@ is chosen!", self.trendOptions[row]);
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



- (void)showWithoutFooter{
    CZPickerView *picker = [[CZPickerView alloc] initWithHeaderTitle:@"Gift Ideas" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
    picker.delegate = self;
    picker.dataSource = self;
    picker.needFooterView = NO;
    
    [picker show];
}

- (IBAction)showWithMultipleSelection:(id)sender {
    CZPickerView *picker = [[CZPickerView alloc] initWithHeaderTitle:@"Gift Ideas" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
    picker.delegate = self;
    picker.dataSource = self;
    picker.allowMultipleSelection = YES;
    [picker show];
}
#pragma mark - date time for weather operations
-(BOOL)shouldgetCityStateWeatherLongLat{
    //compare current date vs today
    BOOL shouldGet;
    NSDate *today = [ForecastIOHandler getCurrentDate];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-DD"];
    NSString *currentDate = [dateFormater stringFromDate:today];
    
    
    NSDate *storedDate = [self.logindefaults objectForKey:@"WeatherDate"];
    NSString *storedDateString = [dateFormater stringFromDate:storedDate];
    //convert back to NSDate lol
    NSDate *currentNSDate = [dateFormater dateFromString:currentDate];
    NSDate *storedNSDate = [dateFormater dateFromString:storedDateString];
    NSInteger dayspassed = [self daysBetweenDate:storedNSDate andDate:currentNSDate];
    if (storedDate) {
        if (dayspassed >= 7) {
            shouldGet = TRUE;
        }else{
            shouldGet = FALSE;
            
        }
        //if the days in between is greater than or equal to 7 get new
        
        //        switch ([currentNSDate compare:storedNSDate]) {
        //            case NSOrderedAscending:
        //                // current > storeddate. So therefore its the next day so we run
        //                [self.logindefaults setObject:currentNSDate forKey:@"WeatherDate"];
        //                shouldGet = FALSE;
        //                break;
        //            case NSOrderedSame:
        //                //same date. MEthod ran already
        //                shouldGet= FALSE;
        //                break;
        //            default:
        //                //in case we dont have an object for WeatherDate
        //                shouldGet = TRUE;
        //                break;
        //        }
    }else{
        //stored date was never filled if first time running. By default we should just return the date
        [self.logindefaults setObject:currentNSDate forKey:@"WeatherDate"];
        shouldGet = TRUE;
    }
    
    return shouldGet;
    
}
-(UIImage *)getRandomImageforSeason:(NSString *)season{
    UIImage *image;
    
    
    return image;
}

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

//get randm product
-(void)getRandomProducts{
    
    
    NSUInteger random = arc4random() % [self.trendSearchOptions count];
    NSString *randomString = [self.trendSearchOptions objectAtIndex:random];
    
    NSLog(@"Random String: %@", randomString);
    [ShopStyleAPIHelper searchforProductReturnJson:randomString limit:@"25" completionHandler:^(id responseObject, NSError *error) {
       
        NSError *err;
        self.sJsonModel = [[ShopStyleJSONModel alloc] initWithDictionary:responseObject error:&err];
        if (err) {
            NSLog(@"Unable to initialize ShopStyleJSONModel, %@", err.localizedDescription);
        }
        //Reload tableView with animation
//        [self.tableView beginUpdates];
//        
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//        [self.tableView endUpdates];
        [self.tableView reloadData];
        
        
        
        
    }];
}

-(void)setProductsforSeason:(NSString *)season forGender:(NSString *)gender{
    if(gender !=nil){
        //search example style: summer men style
        NSString *stringToSearchFor = [NSString stringWithFormat:@"%@%@ style",season,gender];
        [self requestDataFromWSForSeason:stringToSearchFor];
        
        
    }else{
        //gender is nil
        //make generic requeset
        NSLog(@"Making request for %@", season);
        
        NSString *stringToMakeRequest  = [NSString stringWithFormat:@"men women %@ clothes ",season];
        [self requestDataFromWSForSeason:stringToMakeRequest];
        
        }
    //[self.tableView reloadData];
    
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

- (void)showMessage:(NSString*)message{
    const CGFloat fontSize = 24;  // Or whatever.
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];  // Or whatever.
    label.text = message;
    label.textColor = [UIColor blueColor];  // Or whatever.
    [label sizeToFit];
    
    label.center = self.view.center;//point;
    
    [self.view addSubview:label];
    
    [UIView animateWithDuration:0.3 delay:1 options:0 animations:^{
        label.alpha = 0;
    } completion:^(BOOL finished) {
        label.hidden = YES;
        [label removeFromSuperview];
    }];
}

- (void)buttonViewForPinterestPressedAction:(id)sender
{
    /*
     when tappped ask user if they are logged in to save to their Pinterest Board.
     */
    //check if user is logged in with pinterest already.
    
        if(isLoggedin){
            [[PDKClient sharedInstance] silentlyAuthenticateWithSuccess:^(PDKResponseObject *responseObject) {
                //
                self.user = [responseObject user];
                
                [self.logindefaults setValue:self.user.username forKey:@"username"];
                NSString *userName =  self.user.username;
                NSLog(@"Silent log ine username: %@",userName);
                
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
                         [self showMessage:@"Pinned!"];
                     }
                                 andFailure:^(NSError *error)
                     {
                         //weakSelf.resultLabel.text = @"pin it failed";
                     }];
                    
                }

            
            
            
            
            } andFailure:^(NSError *error) {
                //
                NSLog(@"silent error: %@", error.description);
               
                
            }];
            
//                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//                
//                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
//                                                                      action:@"pinproduct_button_press"  // Event action (required)
//                                                                       label:@"Pin It Button"          // Event label
//                                                                       value:nil] build]];    // Event value
//                CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
//                NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
//                
//                
//                if (indexPath != nil)
//                {
//                    //...
//                    NSLog(@"row % ldpped", (long)indexPath.row);
//                    ShopStyleProductsModel *photo = self.sJsonModel.products[indexPath.row];
//                    NSString *productUrl= photo.clickUrl;
//                    NSString *photoURL = [photo valueForKeyPath:@"image.sizes.IPhone.url"];
//                    
//                    
//                    [PDKPin pinWithImageURL:[NSURL URLWithString:photoURL]
//                                       link:[NSURL URLWithString:productUrl]
//                         suggestedBoardName:@"Shopn"
//                                       note:photo.brandedName
//                                withSuccess:^
//                     {
//                         [self showMessage:@"Pinned!"];
//                     }
//                                 andFailure:^(NSError *error)
//                     {
//                         //weakSelf.resultLabel.text = @"pin it failed";
//                     }];
//                    
//                }
        
        }else{
           
            
            
            [[PDKClient sharedInstance]authenticateWithPermissions:@[PDKClientReadPublicPermissions,
                                                                     PDKClientReadPrivatePermissions,
                                                                     PDKClientReadRelationshipsPermissions,
                                                                     PDKClientWriteRelationshipsPermissions] withSuccess:^(PDKResponseObject *responseObject) {
                                                                         //
                                                                         self.user = [responseObject user];
                                                                         NSString *userName =  self.user.username;
                                                                         NSLog(@"%@",userName);
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
                                                                                  [self showMessage:@"Pinned!"];
                                                                              }
                                                                                          andFailure:^(NSError *error)
                                                                              {
                                                                                  //weakSelf.resultLabel.text = @"pin it failed";
                                                                              }];
                                                                             
                                                                         }

                                                                         
                                                                         
                                                                         
                                                                     } andFailure:^(NSError *error) {
                                                                         //error
                                                                     }];
        
        }
   
    
}




@end


//
//
////BEFORE MAKING THE CHANGE
//// For License please refer to LICENSE file in the root of YALAnimatingTabBarController project
////TODO:
///*
//Get season and temperature to show product recommendations. http://stackoverflow.com/questions/13386716/how-to-find-the-current-season-through-any-ios-api
//https://api.forecast.io/forecast/102427fff1a59ac02a37ce77604f1fe4/37.8267,-122.423
// //ask user for current location. Make request to forecast.io, https://developer.forecast.io/
// //use wunderground
// */
//
//#import "SearchViewController.h"
//#import "ShopStyleAPIHelper.h"
//#import "PlaceOrderViewController.h"
//#import "ProductsViewController.h"
//#import "ShopStyleJSONModel.h"
//#import "SearchResultsTVCTableViewController.h"
//#import "VoiceSearchTableViewCell.h"
//
//#import "SearchResultsTableViewCell.h"
//#import "SearchFilterCell.h"
//#import <QuartzCore/QuartzCore.h>
//#import "SeasonCategoriesCell.h"
//
//#define debug 1
//#define kfetchQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//@interface SearchViewController()<UISearchDisplayDelegate, UISearchResultsUpdating, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, CLLocationManagerDelegate>{
//
//}
//@property NSArray *trendOptions;
//@property NSArray *trendSearchOptions;
//@property NSTimer *myTimer;
//@property (nonatomic) CLLocationManager *locationManager;
//@property (strong, nonatomic)CLGeocoder* clGeocoder;
//@property (strong, nonatomic) CLLocation *location;
//@property  CLLocationCoordinate2D coord;
//
//@end
//
//@implementation SearchViewController
//@synthesize mySearchBar, searchBarShown,userLocationEnabled, isDayTime, locationManager,clGeocoder, location, coord;
//
//-(void)viewDidLoad{
//    
//    //set trend options
//    self.trendOptions = @[@"Gifts for women(coming soon)", @"Gifts for men(coming soon)", @"Gift Cards(coming soon)", @"Cologne(coming soon)", @"Designer Purses(coming soon)"];
//    self.trendSearchOptions = @[@"Red and White shoes", @"navy blue dress", @"Nike Jordans", @"Michael Kors bag", @"Black jeans"];
//    //[self.navigationController.navigationBar setHidden:YES];
//    //self.viewToAnimate.layer.cornerRadius = _viewToAnimate.frame.size.width/2;
//    self.viewToAnimate.layer.masksToBounds = YES;
//    self.navigationController.navigationItem.title = @"Search";
//    
//    UIView *iv = [[UIView alloc] initWithFrame:CGRectMake(0,0,32,32)];
//    [iv setBackgroundColor:[UIColor blackColor]];
//    self.navigationController.navigationItem.titleView = iv;
//    
//    
//    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    [self.tableView setShowsHorizontalScrollIndicator:NO];
//    [self.tableView setShowsVerticalScrollIndicator:NO];
//    //self.navigationItem.title =  @"Search";
//    //self.extendedLayoutIncludesOpaqueBars = true;
//    searchBarShown = NO;
//    //set up search controller
//    [self setUpSearchBar];
//     
//    self.logindefaults = [NSUserDefaults standardUserDefaults];
//    
//    locationManager = [[CLLocationManager alloc] init];
//    locationManager.delegate = self;
//    [self.logindefaults valueForKey:@"Season"];
//    userLocationEnabled = [self.logindefaults boolForKey:@"LocationAccessGranted"];
//    NSLog(@"Location Enabled: %d",userLocationEnabled);
//    self.shouldGetWeatherData = [self shouldgetCityStateWeatherLongLat];
//    if (userLocationEnabled && self.shouldGetWeatherData) {
//        //if both are true
//        [self getCityStateWeatherLongLat];
//    }
//    [self setUpCustomSearchFooter];
//        //[self requestLocation];
//    //set the background of the view
////   self.viewToAnimate.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"microphone"]];
//    
//    //    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5.0, 0.0, 320.0, 44.0)];
//    //    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    //    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 310.0, 44.0)];
//    //    searchBarView.autoresizingMask = 0;
//    //    searchBar.delegate = self;
//    //    [searchBarView addSubview:searchBar];
//    //    self.navigationItem.titleView = searchBarView;
//    
//    //self.edgesForExtendedLayout = UIRectEdgeNone;
//    //self.navigationController.navigationBar.translucent = NO;
//    //if the user just logged in show this controller modally
//   
//    
//    
//}
//-(void)viewWillAppear:(BOOL)animated{
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:@"Search page"];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
//    
//    self.tabBarController.selectedIndex = 0;
//    //get current daytime
//
//    //[self getCityStateLongLat];
//    
//    self.isDayTime = [self.logindefaults boolForKey:@"IsDayTime"];
//    userLocationEnabled = [self.logindefaults boolForKey:@"LocationAccessGranted"];
//    if(userLocationEnabled){
//        [self getCityState];
//    }
//    //[self.tableView reloadData];
//    
//
//}
//-(void)setUpSearchBar{
//    UIStoryboard *storyboard = self.storyboard;
//    self.searchTVController = [storyboard instantiateViewControllerWithIdentifier:@"SearchResultsTVCTableViewController"];
//    
//    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchTVController];
//    self.searchController.searchResultsUpdater = self;
//    //self.searchController.delegate = self;
//    self.searchController.dimsBackgroundDuringPresentation = YES;
//    self.searchController.definesPresentationContext = true;
//    self.definesPresentationContext = YES;
//    self.searchController.searchBar.scopeButtonTitles = nil;
//    self.searchController.searchBar.delegate = self;
//    self.searchController.hidesNavigationBarDuringPresentation = NO;
//    //[self.view addSubview:self.searchController.searchBar];
//    [self.searchController.searchBar sizeToFit];
//    self.navigationItem.titleView = self.searchController.searchBar;
//    self.searchController.searchBar.hidden =YES;
//    self.searchController.searchBar.returnKeyType = UIReturnKeySearch;
//    //
//    
//    
////    self.navigationController.navigationItem.titleView = self.searchController.searchBar;
////    [self.navigationController.navigationBar addSubview:self.searchController.searchBar];
//    
//    //add search bar to tableview header
//    //self.tableView.tableHeaderView = self.searchController.searchBar;
//
//}
//-(void)setUpCustomSearchFooter{
//        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 400, 34)];
//        [button setImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
//        //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
//        [self.viewForSearch addSubview:button];
//    
////    SearchFilterCell* myViewObject = [[[NSBundle mainBundle] loadNibNamed:@"SearchFilterCell" owner:self options:nil] objectAtIndex:0];
////    [myViewObject setFrame:CGRectMake(100, 0, 320, self.viewForSearch.frame.size.height)];
//    
//    //[self.viewForSearch addSubview:myViewObject];
//
//}
//
//
//
//#pragma mark - search delegates
////- (void)willPresentSearchController:(UISearchController *)searchController
////{
////    dispatch_async(dispatch_get_main_queue(), ^{
////        searchController.searchResultsController.view.hidden = NO;
////        
////    });
////    
////        self.tableView.backgroundColor = [UIColor whiteColor];
////        
////     
////}
////- (void)didPresentSearchController:(UISearchController *)searchController
////{
////    searchController.searchResultsController.view.hidden = NO;
////    self.searchTVController.searchResults = nil;
////}
//#pragma mark - UISearchControllerDelegate & UISearchResultsDelegate
//
//// Called when the search bar becomes first responder
//- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
//{
//    
//    // Set searchString equal to what's typed into the searchbar
//    NSString *searchString = self.searchController.searchBar.text;
//    
//    [ShopStyleAPIHelper searchforProductReturnJson:searchString limit:@"12" completionHandler:^(id responseObject, NSError *error) {
//        
//        //
//        
//        
//        
//        NSLog(@"the response is %@",responseObject);
//        //NSString *stringForResult = [NSString stringWithFormat:@"%@", responseObject];
//        NSString *stringForResult=(NSString *)responseObject;
//        //test
//        UIStoryboard *storyboard = self.storyboard;
//        
//        ProductsViewController *productsVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductsViewController"];
//        
//        //convert response dict to json
//        
//        //NSString *rawJson = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
//        //rawJson = [rawJson stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
//        
//        //NSLog(@"JSON: %@",rawJson);
//        NSError *err;
//        
//        
//        self.sJsonModel = [[ShopStyleJSONModel alloc] initWithDictionary:responseObject error:&err];
//        if (err) {
//            NSLog(@"Unable to initialize PublicPhotosModel, %@", err.localizedDescription);
//        }
// 
//        
//        
//        
//        ///
//        
//        
//        //productsVC.sJsonModel = self.sJsonModel;
//        productsVC.array = [responseObject objectForKey:@"products"];
//        self.searchResults = [responseObject objectForKey:@"products"];
//        //productsVC.dictImages = [results valueForKey:@"images"];
//        
//        
//        //orderDetails.rates = responseObject;
//        //dismiss loading view and send user on if no errors were found and all forms copleted
//        //[activityView stopAnimating];
//        //searchBar.hidden = true;
//        //[self.navigationController pushViewController:productsVC animated:YES];
//        self.navigationItem.rightBarButtonItem = self.rightBarBtn;
//        
//        
//        
//    }];
//
//    
//    //[self updateFilteredContentForAirlineName:searchString];
//    
//    // If searchResultsController
//    if (self.searchController.searchResultsController) {
//        
//        
//        
//        // Update searchResults
//        self.searchTVController.searchResults = self.searchResults;
//        self.searchTVController.sJsonModel = self.sJsonModel;
//        
//        // And reload the tableView with the new data
//        [self.searchTVController.tableView reloadData];
//    }
//}
//
//
////// Update self.searchResults based on searchString, which is the argument in passed to this method
////- (void)updateFilteredContentForAirlineName:(NSString *)airlineName
////{
////    
////    if (airlineName == nil) {
////        
////        // If empty the search results are the same as the original data
////        self.searchResults = [self.airlines mutableCopy];
////    } else {
////        
////        NSMutableArray *searchResults = [[NSMutableArray alloc] init];
////        
////        // Else if the airline's name is
////        for (NSDictionary *airline in self.airlines) {
////            if ([airline[@"Name"] containsString:airlineName]) {
////                
////                NSString *str = [NSString stringWithFormat:@"%@", airline[@"Name"] /*, airline[@"icao"]*/];
////                [searchResults addObject:str];
////            }
////            
////            self.searchResults = searchResults;
////        }
////    }
////}
//
////- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
////{
////    NSString *searchString = searchController.searchBar.text;
////    //[self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
////    NSLog(@"%@", searchString);
////    [self.tableView reloadData];
////}
//- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
//{
//    [self updateSearchResultsForSearchController:self.searchController];
//}
//-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    
//    //log how many times serch is clicked
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    
//    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
//                                                          action:@"search_button_press"  // Event action (required)
//                                                           label:@"Search"          // Event label
//                                                           value:nil] build]];    // Event value
//    //This'll Show The cancelButton with Animation
//    [searchBar setShowsCancelButton:YES animated:YES];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
//    self.navigationController.navigationBarHidden = NO;
//    //remaining Code'll go here
//}
//-(void) searchBarTextDidEndEditing:(UISearchBar *)searchBar{
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
//    self.navigationController.navigationBarHidden = false;
//}
////- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
////{
////    if (searchText != nil && [searchText length] > 2) {
////        ///[self findSymbols:searchText];
////        NSLog(@"%@", searchText);
////        
////        
////        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(request) object:searchText];
////        
////        
////        
////        [self performSelector:@selector(requestDataFromWS:) withObject:searchText afterDelay:0.001];
////    }
////    
////}
////- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
////    
////    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(request) object:text];
////    
////    
////    
////    [self performSelector:@selector(requestDataFromWS:) withObject:text afterDelay:0.001];
////    
////    
////    return YES;
////}
//-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//    //clicked, search into web service here. Load more content when user scrolls to bottom.
//   
//    [ShopStyleAPIHelper searchforProductReturnJson:searchBar.text limit:@"15" completionHandler:^(id responseObject, NSError *error) {
//        
//        
//        
//     
//
//        NSLog(@"the response is %@",responseObject);
//        //NSString *stringForResult = [NSString stringWithFormat:@"%@", responseObject];
//        
//        //test
//        UIStoryboard *storyboard = self.storyboard;
//   
//        ProductsViewController *productsVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductsViewController"];
//
//        //convert response dict to json
//        
//        //NSString *rawJson = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
//        //rawJson = [rawJson stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
//        
//        //NSLog(@"JSON: %@",rawJson);
//        NSError *err;
//        
//        
//        self.sJsonModel = [[ShopStyleJSONModel alloc] initWithDictionary:responseObject error:&err];
//        if (err) {
//            NSLog(@"Unable to initialize PublicPhotosModel, %@", err.localizedDescription);
//        }
//
//        
//        
//        
//        ///
//
//        
//        productsVC.sJsonModel = self.sJsonModel;
//        productsVC.array = [responseObject objectForKey:@"products"];
//        //productsVC.dictImages = [results valueForKey:@"images"];
//        
//        
//        //orderDetails.rates = responseObject;
//        //dismiss loading view and send user on if no errors were found and all forms copleted
//        //[activityView stopAnimating];
//        //searchBar.hidden = true;
//        //[self.navigationController pushViewController:productsVC animated:YES];
//        //self.navigationItem.rightBarButtonItem = self.rightBarBtn;
//        
//    
//    
//    }];
//    
//    if (self.searchController.searchResultsController) {
//        
//        
//        
//        // Update searchResults
//        self.searchTVController.searchResults = self.searchResults;
//        self.searchTVController.sJsonModel = self.sJsonModel;
//        
//        // And reload the tableView with the new data
//        [self.searchTVController.tableView reloadData];
//    }
//    //save the data response and move it to another controller.
//    
//    
//}
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
//{
//    self.navigationItem.rightBarButtonItem = self.rightBarBtn;
//    [searchBar resignFirstResponder];
//    //hide the bar
//    self.searchController.searchBar.hidden = YES;
//    searchBarShown = NO;
//    self.tableView.hidden = NO;
//    //searchBar.hidden = YES;
//    //[self.navigationController.navigationBar setHidden:YES];
//}
//-(void)requestDataFromWS:(NSString *)searchText{
//    
//    [ShopStyleAPIHelper searchforProductReturnJson:searchText limit:@"10" completionHandler:^(id responseObject, NSError *error) {
//        
//        
//        SearchResultsTVCTableViewController *svc = [[SearchResultsTVCTableViewController alloc]init];
//
//        
//        
//        //NSLog(@"the response is %@",responseObject);
//        //NSString *stringForResult = [NSString stringWithFormat:@"%@", responseObject];
//        NSString *stringForResult=(NSString *)responseObject;
//        //test
//        UIStoryboard *storyboard = self.storyboard;
//        
//        ProductsViewController *productsVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductsViewController"];
//        
//        //convert response dict to json
//        
//        //NSString *rawJson = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
//        //rawJson = [rawJson stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
//        
//        //NSLog(@"JSON: %@",rawJson);
//        
//        NSDictionary *json = (NSDictionary *)responseObject;
//        NSError *err;
//        
//        
//        self.sJsonModel = [[ShopStyleJSONModel alloc] initWithDictionary:responseObject error:&err];
//        if (err) {
//            NSLog(@"Unable to initialize PublicPhotosModel, %@", err.localizedDescription);
//        }
//        
//        
//        
//        
//        ///
//        svc.sJsonModel = self.sJsonModel;
//        svc.isComingFromOtherController = YES;
//        //productsVC.sJsonModel = self.sJsonModel;
//        productsVC.array = [responseObject objectForKey:@"products"];
//        self.searchResults = [responseObject objectForKey:@"products"];
//        //productsVC.dictImages = [results valueForKey:@"images"];
//        
//        
//        //orderDetails.rates = responseObject;
//        //dismiss loading view and send user on if no errors were found and all forms copleted
//        //[activityView stopAnimating];
//        //searchBar.hidden = true;
//        [self.navigationController pushViewController:svc animated:YES];
//        self.navigationItem.rightBarButtonItem = self.rightBarBtn;
//        
//        
//        
//    }];
//    // If searchResultsController
//    if (self.searchController.searchResultsController) {
//        
//        
//        
//        // Update searchResults
//        self.searchTVController.searchResults = self.searchResults;
//        self.searchTVController.sJsonModel = self.sJsonModel;
//        
//        // And reload the tableView with the new data
//        [self.searchTVController.tableView reloadData];
//    }
//
//
//
//}
//
//
//
//
//
//#pragma mark - Table
//
//
//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    
//    return 3;
//    
//}
//
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    
//    if(userLocationEnabled){
//        if (section == 0){
//            return 1;
//        }else if(section==1){
//            return 1;
//
//        }else if(section==2){
//            return self.trendSearchOptions.count;
//        }
//        return 1;
//    }else{
//        if (section == 0){
//            return 1;
//        }else if(section==1){
//            return self.trendSearchOptions.count;
//            
//        }
//        return 1;
//    }
//    return 1;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (userLocationEnabled) {
//        if (indexPath.section==0) {
//            return 50;//return 240;
//        }else if(indexPath.section==1){
//        return 100;
//        }
//        return 75;
//    }else{
//        if (indexPath.section==0) {
//            return 50;//return 240;
//        }
//    }
//    return 75;
//}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(userLocationEnabled){
//        if (indexPath.section == 0){
//
//                static NSString *CellIdentifier = @"searchfiltercell";
//                SearchFilterCell *cellDetails = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//                if(cellDetails ==nil){
//                    [self.tableView registerNib:[UINib nibWithNibName:@"SearchFilterCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
//                    cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//                }
//
//
//                //cellDetails.productLabel.text = [[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"brandedName"]; //[_array objectAtIndex:indexPath.row];
//                [cellDetails setSeparatorInset:UIEdgeInsetsZero];
//                [cellDetails setLayoutMargins:UIEdgeInsetsZero];
//            
//            
//            
//    //        cellDetails.layer.shadowColor = [[UIColor blackColor] CGColor];
//    //        cellDetails.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//    //        cellDetails.layer.shadowRadius = 3.0f;
//    //        cellDetails.layer.shadowOpacity = 1.0f;
//    //        cellDetails.layer.masksToBounds = NO;
//            
//                    return cellDetails;
//        }
//        else if (indexPath.section==1){
//            
//            
//            static NSString *CellIdentifier = @"SeasonCategoriesCell";
//            SeasonCategoriesCell *cellDetails = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            if(cellDetails ==nil){
//                [self.tableView registerNib:[UINib nibWithNibName:@"SeasonCategoriesCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
//                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            }
//            if(self.isDayTime==false){
//                cellDetails.backgroundColor = [UIColor colorWithRed:83/255.0f green:17/255.0f blue:142/255.0f alpha:1]; //deep purple
////                cellDetails.backgroundColor = [UIColor colorWithRed:212/255.0f green:122/255.0f blue:236/255.0f alpha:1];//too bright
////                cellDetails.backgroundColor = [UIColor colorWithRed:138/255.0f green:94/255.0f blue:178/255.0f alpha:1];
//                cellDetails.degreeLabel.textColor = [UIColor whiteColor];
//                cellDetails.degreeSymbolLabel.textColor = [UIColor whiteColor];
//                cellDetails.degreeMessage.textColor = [UIColor whiteColor];
//                cellDetails.fahrenheitLabel.textColor =[UIColor whiteColor];
//                //iconcontainer
//               cellDetails.iconContainer.backgroundColor = [UIColor colorWithRed:138/255.0f green:94/255.0f blue:178/255.0f alpha:1];
//            }else{
//                //skyblue
//                cellDetails.iconContainer.backgroundColor = [UIColor colorWithRed:135/255.0f green:206/255.0f blue:235/255.0f alpha:1];
//            }
//                //            NSString *stringtoShow = [NSString stringWithFormat:@"Its currently %@ in %@, %@", [self.logindefaults valueForKey:@"Season"], [self.logindefaults valueForKey:@"City"],[self.logindefaults valueForKey:@"State"]];
//            NSString *degree = [NSString stringWithFormat:@"%.15f", self.forecastModel.currently.temperature]; //[self.forecastModel.currently objectForKey:@"temperature"]; //[NSString stringWithFormat:@"%@",[self.forecastModel.currently objectForKey:@"temperature"]];
//            double d = [degree doubleValue];
//            cellDetails.degreeLabel.text = [NSString stringWithFormat:@"%.0f%@",d,@"\u00B0"];
//            NSString *stringtoShow = [NSString stringWithFormat:@"Its currently %@ season in %@ ", [self.logindefaults valueForKey:@"Season"], [self.logindefaults valueForKey:@"City"] ];
//            cellDetails.iconImage.image = [UIImage imageNamed: [self.logindefaults valueForKey:@"WeatherIcon"]];//[UIImage imageNamed: @"clear-day-light"];
//            cellDetails.degreeMessage.text = stringtoShow;
//            [cellDetails setSeparatorInset:UIEdgeInsetsZero];
//            [cellDetails setLayoutMargins:UIEdgeInsetsZero];
//
//            
//            return cellDetails;
//            
//            
////            static NSString *CellIdentifier = @"CellIdentifier";
////            
////            // Dequeue or create a cell of the appropriate type.
////            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
////            if (cell == nil) {
////                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
////                cell.accessoryType = UITableViewCellAccessoryNone;
////            }
////            cell.selectionStyle = UITableViewCellSelectionStyleNone;
////            [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
////            
////            // Configure the cell.
////            NSString *stringtoShow = [NSString stringWithFormat:@"Its currently %@ in %@, %@", [self.logindefaults valueForKey:@"Season"], [self.logindefaults valueForKey:@"City"],[self.logindefaults valueForKey:@"State"]];
////            cell.textLabel.text =stringtoShow;//[self.trendSearchOptions objectAtIndex:indexPath.row];//[NSString stringWithFormat:@"%ld", (long)indexPath.row];
////            return cell;
//            
//            
//            
//            
//           
//
//        }else{
//            
//            static NSString *CellIdentifier = @"CellIdentifier";
//            
//            // Dequeue or create a cell of the appropriate type.
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            if (cell == nil) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//                cell.accessoryType = UITableViewCellAccessoryNone;
//            }
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
//            
//            // Configure the cell.
//            cell.textLabel.text =[self.trendSearchOptions objectAtIndex:indexPath.row];//[NSString stringWithFormat:@"%ld", (long)indexPath.row];
//            //cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width+1000, 0.f, 0.f);
//            return cell;
//            
//            
//            
//            
//        }
//    }else{
//        //else not user location enabled.
//        if (indexPath.section == 0){
//            //    static NSString *cellIdentifier = @"voicesearchcell";
//            //    VoiceSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//            //
//            //
//            //    if(cell ==nil){
//            //        [self.tableView registerNib:[UINib nibWithNibName:@"VoiceSearchTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
//            //        cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//            //    }
//            //    cell.searchContainer.layer.cornerRadius = cell.searchContainer.frame.size.width/2;
//            //    cell.searchContainer.layer.masksToBounds = YES;
//            //    //add selector to button
//            //    [cell.cellVoiceSearchBtn addTarget:self action:@selector(callVoiceSearchMethod) forControlEvents:UIControlEventTouchUpInside];
//            //
//            //    return  cell;
//            static NSString *CellIdentifier = @"searchfiltercell";
//            SearchFilterCell *cellDetails = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            if(cellDetails ==nil){
//                [self.tableView registerNib:[UINib nibWithNibName:@"SearchFilterCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
//                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            }
//            
//            
//            //cellDetails.productLabel.text = [[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"brandedName"]; //[_array objectAtIndex:indexPath.row];
//            [cellDetails setSeparatorInset:UIEdgeInsetsZero];
//            [cellDetails setLayoutMargins:UIEdgeInsetsZero];
//            
//            
//            
//            //        cellDetails.layer.shadowColor = [[UIColor blackColor] CGColor];
//            //        cellDetails.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//            //        cellDetails.layer.shadowRadius = 3.0f;
//            //        cellDetails.layer.shadowOpacity = 1.0f;
//            //        cellDetails.layer.masksToBounds = NO;
//            
//            return cellDetails;
//        }
//        else if (indexPath.section==1){
//            
//            
//            
//            static NSString *CellIdentifier = @"CellIdentifier";
//            
//            // Dequeue or create a cell of the appropriate type.
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            if (cell == nil) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//                cell.accessoryType = UITableViewCellAccessoryNone;
//            }
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
//            
//            // Configure the cell.
//            cell.textLabel.text =[self.trendSearchOptions objectAtIndex:indexPath.row];//[NSString stringWithFormat:@"%ld", (long)indexPath.row];
//            //cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width+1000, 0.f, 0.f);
//            
//            
//            
//            return cell;
//            
//            
//        }else{
//            
//            static NSString *CellIdentifier = @"CellIdentifier";
//            
//            // Dequeue or create a cell of the appropriate type.
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            if (cell == nil) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//                cell.accessoryType = UITableViewCellAccessoryNone;
//            }
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
//            
//            // Configure the cell.
//            NSString *stringtoShow = [NSString stringWithFormat:@"Its currently %@ season in %@, %@", [self.logindefaults valueForKey:@"Season"], [self.logindefaults valueForKey:@"City"],[self.logindefaults valueForKey:@"State"]];
//            cell.textLabel.text =stringtoShow;//[self.trendSearchOptions objectAtIndex:indexPath.row];//[NSString stringWithFormat:@"%ld", (long)indexPath.row];
//            return cell;
//            
//            
//        }
//    
//    
//    
//    
//    }
//
//        return nil;
//
//}
////- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
////    
////    // height of the footer
////    // this needs to be set, otherwise the height is zero and no footer will show
//////    if (section == 1) {
//////        return 80;
//////    }
////    return 0.01f;
////}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    
//    if(userLocationEnabled){
//        if (section == 1|| section==2 ) {
//            return 44.5;
//        }
//        return 0.01f;
//    }else{ if (section == 1|| section==2 ) {
//        return 44.5;
//        
//        }
//    }
//        return 0.01f;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    
//    if(userLocationEnabled){
//        if (section==1){
//            // creates a custom view inside the footer
//            UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 80)];
//            footerView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
//            // create a button with image and add it to the view
//            //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
//            //[button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
//                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 400, 30)];
//                 NSString *stringtoShow = [NSString stringWithFormat:@"Popular picks for %@", [[self.logindefaults valueForKey:@"Season"] uppercaseString]];
//                label.text = stringtoShow;
//                label.textColor    = [UIColor darkGrayColor];
//                label.font = [UIFont fontWithName:@"Avenir-Book" size:20];
//                label.textAlignment = NSTextAlignmentLeft;
//            
//            /*
//            
//            
//                    footerView.layer.shadowColor = [[UIColor blackColor] CGColor];
//                    footerView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//                    footerView.layer.shadowRadius = 0.5f;
//                    footerView.layer.shadowOpacity = 0.2f;
//                    footerView.layer.masksToBounds = NO;
//            */
//            
//            
//            
//            
//            return footerView;
//        }else if (section==2){
//            // creates a custom view inside the footer
//            UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 80)];
//            footerView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
//            // create a button with image and add it to the view
//            //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
//            //[button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
//            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 400, 30)];
//            NSString *stringtoShow = [NSString stringWithFormat:@"Popular picks for %@", [[self.logindefaults valueForKey:@"Season"] uppercaseString]];
//            label.text = stringtoShow;
//            label.textColor    = [UIColor darkGrayColor];
//            label.font = [UIFont fontWithName:@"Avenir-Book" size:20];
//            label.textAlignment = NSTextAlignmentLeft;
//            
//            /*
//             
//             
//             footerView.layer.shadowColor = [[UIColor blackColor] CGColor];
//             footerView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//             footerView.layer.shadowRadius = 0.5f;
//             footerView.layer.shadowOpacity = 0.2f;
//             footerView.layer.masksToBounds = NO;
//             */
//            
//            [footerView addSubview:label];
//            
//            
//            
//            
//            footerView.layer.shadowColor = [[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1] CGColor];
//            footerView.layer.shadowOpacity = 0.5;
//            footerView.layer.shadowOffset = CGSizeMake(0, 1);
//            
//            
//            return footerView;
//        }
//    }else{
//        if (section==1){
//            // creates a custom view inside the footer
//            UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 80)];
//            footerView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
//            // create a button with image and add it to the view
//            //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
//            //[button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
//            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 400, 30)];
//            label.text = @"Example Searches";
//            label.textColor    = [UIColor darkGrayColor];
//            label.font = [UIFont fontWithName:@"Avenir-Book" size:20];
//            label.textAlignment = NSTextAlignmentLeft;
//            
//            /*
//             
//             
//             footerView.layer.shadowColor = [[UIColor blackColor] CGColor];
//             footerView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//             footerView.layer.shadowRadius = 0.5f;
//             footerView.layer.shadowOpacity = 0.2f;
//             footerView.layer.masksToBounds = NO;
//             */
//            
//            
//            
//            
//            return footerView;
//        }else if (section==2){
//            // creates a custom view inside the footer
//            UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 80)];
//            footerView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
//            // create a button with image and add it to the view
//            //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
//            //[button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
//            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 400, 30)];
//            label.text = @"";
//            label.textColor    = [UIColor darkGrayColor];
//            label.font = [UIFont fontWithName:@"Avenir-Book" size:20];
//            label.textAlignment = NSTextAlignmentLeft;
//            
//            /*
//             
//             
//             footerView.layer.shadowColor = [[UIColor blackColor] CGColor];
//             footerView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//             footerView.layer.shadowRadius = 0.5f;
//             footerView.layer.shadowOpacity = 0.2f;
//             footerView.layer.masksToBounds = NO;
//             */
//            
//            [footerView addSubview:label];
//            
//            
//            
//            
//            footerView.layer.shadowColor = [[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1] CGColor];
//            footerView.layer.shadowOpacity = 0.5;
//            footerView.layer.shadowOffset = CGSizeMake(0, 1);
//            
//            
//            return footerView;
//        }
//    
//    
//    }
//    return nil;
//    
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    //send user to productDetailsViewcontroller
//    
//    
//    
//    if (indexPath.section ==0)
//    {
//        [self loadSearchView];
//        
//        
//    }else{
//        
//        NSString *stringToSearch = [self.trendSearchOptions objectAtIndex:indexPath.row];
//        [self requestDataFromWS:stringToSearch];
//        
//    
//    }
//}
////- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
////    if (section ==1) {
////        
////        
////        // creates a custom view inside the footer
////        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
////        footerView.backgroundColor = [UIColor colorWithRed:255/255.0f green:103/255.0f blue:120/255.0f alpha:1];
////        // create a button with image and add it to the view
////        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 400, 80)];
////        [button setImage:[UIImage imageNamed:@"pinterestlogin"] forState:UIControlStateNormal];
////        //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
////        [button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
////        
////        [footerView addSubview:button];
////        
////        
////        
////        return footerView;
////    }
////    return nil;
////}
//- (void)footerTapped {
//    [self showWithoutFooter];
//    NSLog(@"Footer tapped");
//}
//
//#pragma mark - YALTabBarInteracting
//
//- (void)tabBarViewWillCollapse {
//    if (debug == 1) {
//        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//    }
//}
//
//- (void)tabBarViewWillExpand {
//    if (debug == 1) {
//        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//    }
//}
//
//- (void)tabBarViewDidCollapse {
//    if (debug == 1) {
//        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//    }
//}
//
//- (void)tabBarViewDidExpand {
//    if (debug == 1) {
//        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//    }
//}
//-(void)extraLeftItemDidPress{
//    
//
//}
//-(void)extraRightItemDidPress{
//
//}
//
//- (void) traitCollectionDidChange: (UITraitCollection *) previousTraitCollection {
//    
//    [super traitCollectionDidChange: previousTraitCollection];
//    
//    if(self.searchController.active && ![UIApplication sharedApplication].statusBarHidden && self.searchController.searchBar.frame.origin.y == 0)
//    {
//        UIView *container = self.searchController.searchBar.superview;
//        
//        container.frame = CGRectMake(container.frame.origin.x, container.frame.origin.y, container.frame.size.width, container.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
//    }
//}
//-(void)callVoiceSearchMethod{
//    //after using watson speech sdk..upgrade to watson Q&A API for further enhancement :D Use Watson speech sdk to listen for query to pass to this controller
//    NSString *stringForResult = @"This feature is coming soon.";
//    UIAlertController *alertController = [UIAlertController
//                                          alertControllerWithTitle:@"Start Voice Search"
//                                          message:stringForResult
//                                          preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancelAction = [UIAlertAction
//                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
//                                   style:UIAlertActionStyleCancel
//                                   handler:^(UIAlertAction *action)
//                                   {
//                                       NSLog(@"Cancel action");
//                                   }];
//    
//    UIAlertAction *okAction = [UIAlertAction
//                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction *action)
//                               {
//                                   NSLog(@"OK action");
//                               }];
//    
//    [alertController addAction:cancelAction];
//    [alertController addAction:okAction];
//    [self presentViewController:alertController animated:YES completion:nil];
//
//}
//
//- (IBAction)toggleSearch:(id)sender {
//    
//    if(!searchBarShown) {
//        self.searchController.searchBar.hidden = NO;
//        searchBarShown = YES;
//        
//        //[self.searchController.searchBar setActive:YES];
//        [self.searchController.searchBar becomeFirstResponder];
//        
//        self.navigationItem.rightBarButtonItem = nil;
//        
// 
//       
//        
// 
//    }else {
//        self.searchController.searchBar.hidden = YES;
//        searchBarShown = NO;
//        //[self.searchController setActive:NO];
//        //[self.rightBarBtn setEnabled:NO];
//        
//        
//        
//    }
//}
//-(void)loadSearchView{
//    if(!searchBarShown) {
//        self.searchController.searchBar.hidden = NO;
//        searchBarShown = YES;
//        
//        //[self.searchController.searchBar setActive:YES];
//        [self.searchController.searchBar becomeFirstResponder];
//        
//        self.navigationItem.rightBarButtonItem = nil;
//        self.tableView.hidden = YES;
//        
//    }else {
//        self.searchController.searchBar.hidden = YES;
//        searchBarShown = NO;
//        //[self.searchController setActive:NO];
//        //[self.rightBarBtn setEnabled:NO];
//        self.tableView.hidden = NO;
//
//        
//        
//    }
//}
//#pragma get current city state long lat
//-(void)getCityStateWeatherLongLat{
//    [self.locationManager startUpdatingLocation];
//    self.clGeocoder = [CLGeocoder new];
//     location = [locationManager location];
//     coord = [location coordinate];
//    [self.logindefaults setDouble:coord.longitude forKey:@"Longitude"];
//    [self.logindefaults setDouble:coord.latitude forKey:@"Latitude"];
//    //[self.logindefaults setObject:[ForecastIOHandler getCurrentDate] forKey:@"WeatherDate"];
//    [ForecastIOHandler getWeatherIconForLocation:[self.logindefaults doubleForKey:@"Latitude"] longitude:[self.logindefaults doubleForKey:@"Longitude"] completionHandler:^(id responseObject, NSError *error) {
//        
//        //map the json to a model
//        NSError *err;
//        
//        
//        self.forecastModel = [[ForecastIOModel alloc] initWithDictionary:responseObject error:&err];
//        if (err) {
//            NSLog(@"Unable to initialize ForecastModel, %@", err.localizedDescription);
//        }
//        //Loop through and get objects in data array.
//        ForecastIODailyDataModel *data;
////        for (int i=0; i<[self.forecastModel.daily.data count]; i++){
////            data = self.forecastModel.daily.data[i];
////            
////        }
//        [self.logindefaults setValue: self.forecastModel.currently.icon forKey:@"WeatherIcon"];
//        
//        //[self.logindefaults setObject:[ForecastIOHandler getCurrentDate] forKey:@"WeatherDate"];
//        [self.tableView reloadData];
//        
//        
//    }];
//    //next method gets it in viewwillappear
////    [self.clGeocoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
////        
////        CLPlacemark *placemark = [placemarks objectAtIndex:0];
////        //[self.logindefaults setBool:YES forKey:@"LocationAccessGranted"];
////        NSString *city = placemark.locality;
////        NSString *state = placemark.administrativeArea;
////        [self.logindefaults setValue:city forKey:@"City"];
////        [self.logindefaults setValue:state forKey:@"State"];
////        NSLog(@"city-state:%@,%@",[self.logindefaults valueForKey:@"City"],[self.logindefaults valueForKey:@"State"]);
////        //[self.tableView reloadData];
////        [self.locationManager stopUpdatingLocation];
////    }];
//}
//-(void)getCityState{
//    [self.locationManager startUpdatingLocation];
//    self.clGeocoder = [CLGeocoder new];
//    location = [locationManager location];
//    coord = [location coordinate];
//    [self.logindefaults setDouble:coord.longitude forKey:@"Longitude"];
//    [self.logindefaults setDouble:coord.latitude forKey:@"Latitude"];
//    [self.clGeocoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        
//        CLPlacemark *placemark = [placemarks objectAtIndex:0];
//        //[self.logindefaults setBool:YES forKey:@"LocationAccessGranted"];
//        NSString *city = placemark.locality;
//        NSString *state = placemark.administrativeArea;
//        [self.logindefaults setValue:city forKey:@"City"];
//        [self.logindefaults setValue:state forKey:@"State"];
//        NSLog(@"city-state:%@,%@",[self.logindefaults valueForKey:@"City"],[self.logindefaults valueForKey:@"State"]);
//        [self.tableView reloadData];
//        [self.locationManager stopUpdatingLocation];
//    }];
//
//
//}
//
//#pragma mark - CZPicker delegates
//- (NSAttributedString *)czpickerView:(CZPickerView *)pickerView
//               attributedTitleForRow:(NSInteger)row{
//    
//    NSAttributedString *att = [[NSAttributedString alloc]
//                               initWithString:self.trendOptions[row]
//                               attributes:@{
//                                            NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:18.0]
//                                            }];
//    return att;
//}
//
//- (NSString *)czpickerView:(CZPickerView *)pickerView
//               titleForRow:(NSInteger)row{
//    return self.trendOptions[row];
//}
//
//- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView{
//    return self.trendOptions.count;
//}
//
//- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row{
//    NSLog(@"%@ is chosen!", self.trendOptions[row]);
//}
//
//-(void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemsAtRows:(NSArray *)rows{
//    for(NSNumber *n in rows){
//        NSInteger row = [n integerValue];
//        NSLog(@"%@ is chosen!", self.trendOptions[row]);
//    }
//}
//
//- (void)czpickerViewDidClickCancelButton:(CZPickerView *)pickerView{
//    NSLog(@"Canceled.");
//}
//
// 
//
//- (void)showWithoutFooter{
//    CZPickerView *picker = [[CZPickerView alloc] initWithHeaderTitle:@"Gift Ideas" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
//    picker.delegate = self;
//    picker.dataSource = self;
//    picker.needFooterView = NO;
//    
//    [picker show];
//}
//
//- (IBAction)showWithMultipleSelection:(id)sender {
//    CZPickerView *picker = [[CZPickerView alloc] initWithHeaderTitle:@"Gift Ideas" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
//    picker.delegate = self;
//    picker.dataSource = self;
//    picker.allowMultipleSelection = YES;
//    [picker show];
//}
//#pragma mark - date time for weather operations
//-(BOOL)shouldgetCityStateWeatherLongLat{
//    //compare current date vs today
//    BOOL shouldGet;
//    NSDate *today = [ForecastIOHandler getCurrentDate];
//    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
//    [dateFormater setDateFormat:@"yyyy-MM-DD"];
//    NSString *currentDate = [dateFormater stringFromDate:today];
//    
//    
//    NSDate *storedDate = [self.logindefaults objectForKey:@"WeatherDate"];
//    NSString *storedDateString = [dateFormater stringFromDate:storedDate];
//    //convert back to NSDate lol
//    NSDate *currentNSDate = [dateFormater dateFromString:currentDate];
//     NSDate *storedNSDate = [dateFormater dateFromString:storedDateString];
//    NSInteger dayspassed = [self daysBetweenDate:storedNSDate andDate:currentNSDate];
//    if (storedDate) {
//        if (dayspassed >= 7) {
//            shouldGet = TRUE;
//        }else{
//            shouldGet = FALSE;
//        
//        }
//        //if the days in between is greater than or equal to 7 get new
//   
////        switch ([currentNSDate compare:storedNSDate]) {
////            case NSOrderedAscending:
////                // current > storeddate. So therefore its the next day so we run
////                [self.logindefaults setObject:currentNSDate forKey:@"WeatherDate"];
////                shouldGet = FALSE;
////                break;
////            case NSOrderedSame:
////                //same date. MEthod ran already
////                shouldGet= FALSE;
////                break;
////            default:
////                //in case we dont have an object for WeatherDate
////                shouldGet = TRUE;
////                break;
////        }
//    }else{
//        //stored date was never filled if first time running. By default we should just return the date
//        [self.logindefaults setObject:currentNSDate forKey:@"WeatherDate"];
//        shouldGet = TRUE;
//    }
//    
//    return shouldGet;
//
//}
//
//- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
//{
//    NSDate *fromDate;
//    NSDate *toDate;
//    
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    
//    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
//                 interval:NULL forDate:fromDateTime];
//    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
//                 interval:NULL forDate:toDateTime];
//    
//    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
//                                               fromDate:fromDate toDate:toDate options:0];
//    
//    return [difference day];
//}
//
//@end
