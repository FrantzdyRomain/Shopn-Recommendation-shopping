// For License please refer to LICENSE file in the root of YALAnimatingTabBarController project
/*
 
 men boots
 women’s boots
 shoes
 dresses
 men jeans
 women jeans
 jewelry
 accessories
 women accessories
 dresses
 jackets
 intimates
 pants
 skirts
 men shorts
 shorts
 makeup
 nike
 Forever21
 gucci
 prada
 sweaters
 hoodies
 */
#import "ProductsViewController.h"
#import "ProductDetailsCell.h"
#import "ProductDetailsViewController.h"
 #define debug 1
#define kfetchQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//view
#import "YALChatDemoCollectionViewCell.h"

#import "SearchResultsTableViewCell.h"
#import "ShopStyleAPIHelper.h"
#import "PinterestImageTableViewCell.h"
#import "ShopStyleAPIHelper.h"
#import "PinterestLoggedOutTableViewCell.h"
#import "AppDelegate.h"


@implementation ProductsViewController

@synthesize isLoggedin,  algoDidRun, locationManager, location, coord;
@synthesize debugMode;
//@synthesize managedObjectContext;

//TODO: use this object giantArayResponseObjectForJsonModel for count and for loading the image/product name label.
//also lowercase the stuff in predicates
//TODO: Run the algorithm daily. Destroy the sqlite table and fill with new daily.

#pragma mark - View & LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self askUserForLocationUse];
    [AppDelegate testInternetConnection];
    self.giantDicResponseObjectForJsonModel = [[NSMutableDictionary alloc]init];
    self.giantArayResponseObjectForJsonModel = [NSMutableArray new];
    //[self getModel];
    
    //NSLog(@"%@", self.sJsonModel);
    
    //show different cells if user is logged etc.
    //isLoggedin = FALSE;
    debugMode = FALSE;
    //if the user is logged in change the self.view.backgroundcolor = [UIColor whitecolor];
//    if (isLoggedin) {
//        self.view.backgroundColor = [UIColor whiteColor];
//    }

    //_array = [self.sJsonModel.products object:@"products"];
    //[self setUpProducts];
    BOOL userLocationEnabled = [self.logindefaults boolForKey:@"LocationAccessGranted"];
    if(userLocationEnabled == true){
        [self getCityState];
    }
    
    
    _productImageView = [[PFImageView alloc]init];
    self.sJsonModel = [[ShopStyleJSONModel alloc] init];
    self.dataFromPinterest = [[NSMutableArray alloc]init];
    self.giantRecommendationContainer = [[NSMutableArray alloc]init];
    self.currentProductCategories = [[NSMutableArray alloc]initWithArray:@[@"Nike",@"Sweater",@"dresses",@"jewelry",@"intimates",@"skirts",@"makeup",@"prada",@"shoes",@"adidas",@"reebok",@"scarf",@"scarves",@"sportswear",@"jackets",@"shorts",@"cardigan",@"blazers",@"men jackets",@"short dresses",@"makeup", @"pokemon",@"socks",@"belts",@"party dresses",@"blouses",@"Jackete"]];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = app.managedObjectContext;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    if(!isLoggedin){
        self.barButtonLogout.tintColor = [UIColor clearColor];
        self.barButtonLogout.enabled = NO;
        [self LoadLoggedOutView ];
    }
    
   
   //nsuserdefaults to save whether user is logged in or not
//    self.logindefaults = [NSUserDefaults standardUserDefaults];
//    isLoggedin = [self.logindefaults boolForKey:@"hasUserLoggedIn"];
    
    //create logout button
//    if(!isLoggedin){
//    self.barButtonLogout.tintColor = [UIColor clearColor];
//    self.barButtonLogout.enabled = NO;
//    }
    
    
    
    //check if someone is logged in
    //[self checkIfUserLoggedIn];
    
    //[self loadRandomProducts];
    //self.dictImages
//    self.sJsonModel = [[ShopStyleJSONModel alloc] init];
//    for (int i=0; i< [_array count]; i++){
//        NSLog(@"[%d]:%@",i,_array[i]);
//
//        NSMutableDictionary *images = [[_array objectAtIndex:i] objectForKey:@"image"];
//
//        self.sJsonModel.image = images;
//
//        NSDictionary *sizesImages = [images objectForKey:@"sizes"];
//        NSDictionary *xlImage = [sizesImages objectForKey:@"IPhone"];
//        NSString *url = [xlImage objectForKey:@"url"];
//
//    }
    
    }

- (void)viewWillAppear:(BOOL)animated {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Pinterest-Login-Page"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [super viewWillAppear:animated];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tabBarController.selectedIndex = 2;
    [self.navigationController.navigationBar setHidden:NO];
    //[self  loadRandomProducts];
    self.logindefaults = [NSUserDefaults standardUserDefaults];
    isLoggedin = [self.logindefaults boolForKey:@"hasUserLoggedIn"];
    algoDidRun = [self.logindefaults boolForKey:@"algorithmHasRun"];
    self.username = [self.logindefaults valueForKey:@"username"];
    bool locationAccessAsked = [self.logindefaults boolForKey:@"LocationAccessAsked"];
    if(locationAccessAsked==false ){
        [self askUserForLocationUse];
    
    }
    
    NSLog(@"Is logged in %d", isLoggedin);
    NSLog(@"Algo ran in %d", algoDidRun);
    if (!algoDidRun) {
        self.loadRandomDataBool = TRUE;
    }
    [self checkIfUserLoggedIn];
    if(!isLoggedin){
        self.barButtonLogout.tintColor = [UIColor clearColor];
        self.barButtonLogout.enabled = NO;
        //[self LoadLoggedOutView ];
    }else{
        self.barButtonLogout.tintColor = [UIColor blackColor];
        self.barButtonLogout.enabled = YES;
        //also load the bottom view
        [self loadtheBottomView];
    }
    //[self getProductsModel];
    //[self initializeFetch ];
    //[self launchOtherCOntroller];
    
}
-(void)launchOtherCOntroller{
    NewUserLaunchViewController *nUser  = [[NewUserLaunchViewController alloc]init];
    //nUser.modalPresentationStyle = UIModalPresentationPopover;
    [self.navigationController presentViewController:nUser animated:YES completion:nil];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    //[self requestLocation];
    //[self getcurrentSeason];
}
-(void)viewDidDisappear:(BOOL)animated{
    //[self askUserForLocationUse]; //just in case we ran the first time and user gave us access.
}
-(void)initializeFetch{
    // Initialize Fetch Request
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Products"];
    
    // Add Sort Descriptors
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"brandedName" ascending:YES]]];
    // Initialize Fetched Results Controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    // Configure Fetched Results Controller
    self.fetchedResultsController.delegate = self;
    //[self.fetchedResultsController setDelegate:self];
    
    // Perform Fetch
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Products" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"brandedName" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}
-(void)getModel{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = app.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Pins" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *info in fetchedObjects) {
        NSLog(@"Get Model Name: %@", [info valueForKey:@"pindesc"]);
        //NSManagedObject *details = [info valueForKey:@"details"];
        //NSLog(@"Zip: %@", [details valueForKey:@"zip"]);
    }


}
-(void)getProductsModel{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = app.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Products" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *info in fetchedObjects) {
        NSLog(@"Get Model URL: %@", [info valueForKey:@"imageurl"]);
        //NSManagedObject *details = [info valueForKey:@"details"];
        //NSLog(@"Zip: %@", [details valueForKey:@"zip"]);
    }
    
    
}

-(void)setUpShopStyleProducts{

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
    
//    [queryForMaleProducts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            for(PFObject *object in objects){
//                [ _array addObject:object];
//            }
//            for(NSMutableArray *arr in _array){
//                PFImageView *tempImage = [[PFImageView alloc]init];
//                PFFile *imageFile = [arr valueForKey:@"productImage"];
//                tempImage.file = imageFile;
//                [tempImage loadInBackground];
//                
//                [_productImages addObject:tempImage];
//                
//            }
//            NSLog(@"Product Images: %@",_productImages);
//            NSLog(@"Product Images: %@",_array);
//            
//            // [self.tableView reloadData];
//        }
//        [self.tableView reloadData];
//    }];
    //setup images
    
    
    
}

#pragma mark - tableview Methods


#pragma mark - tableview Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (isLoggedin) {
        //return 2;
        return [[self.fetchedResultsController sections] count];
    
    }
    return 1;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isLoggedin) {
        NSArray *sections = [self.fetchedResultsController sections];
        id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        NSLog(@"section info %@",sectionInfo);
        return [sectionInfo numberOfObjects];
        
//            if (section ==0) {
//                NSArray *sections = [self.fetchedResultsController sections];
//                id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
//                NSLog(@"section info %@",sectionInfo);
//                return [sectionInfo numberOfObjects];
//                //return 1;
//            }else if(section==1){
//                NSArray *sections = [self.fetchedResultsController sections];
//                id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
//                NSLog(@"section info %@",sectionInfo);
//                return [sectionInfo numberOfObjects];
//                //return self.fetchedResultsController.fetchedObjects.count;
//                //return [self.sJsonModel.products count];
//            }
   
    }
    return 1;

    //return [_array count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    isLoggedin = [self.logindefaults boolForKey:@"hasUserLoggedIn"];
    if (isLoggedin){
//        if (indexPath.section ==0){
//            return 250; // header view
//        }
        return 350; //each product is sized 300
    
    }
    return 150;
}
-(void)loadRandomProducts{
    [ShopStyleAPIHelper searchforProductReturnJson:@"Nike shoes" limit:@"50" completionHandler:^(id responseObject, NSError *error) {
        
        
        
        
        
        NSLog(@"the response is %@",responseObject);
        //NSString *stringForResult = [NSString stringWithFormat:@"%@", responseObject];
               NSError *err;
        
        
        
        if (!err) {
            self.sJsonModel = [[ShopStyleJSONModel alloc] initWithDictionary:responseObject error:&err];
            
        }else{
            NSLog(@"Unable to initialize PublicPhotosModel, %@", err.localizedDescription);
        }
        
        
        
        
        ///
        
        
        
        
        [self.tableView reloadData];
        
    }];
    

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (isLoggedin) {
        
        self.tableView.scrollEnabled = YES;
        if (indexPath.section == 0) {
                static NSString *CellIdentifier = @"SearchResultsTableViewCell";
                
                SearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if(cell ==nil){
                                                    [self.tableView registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                                                    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    }
                
                [self configureCell:cell atIndexPath:indexPath];
                return cell;
//                    //show user profile image
//                        static NSString *CellIdentifier = @"pinterestImagetableViewcell";
//                        PinterestImageTableViewCell *cellDetails = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//                        if(cellDetails ==nil){
//                            [self.tableView registerNib:[UINib nibWithNibName:@"PinterestImageTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
//                            cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//                        }
//                        cellDetails.imageView.backgroundColor = [UIColor redColor];
//                        PDKImageInfo *forImage = self.user;
//                cellDetails.imageView.layer.cornerRadius = cellDetails.imageView.frame.size.width/2;
//                [cellDetails setUserInteractionEnabled:NO];
//                //cellDetails.nameLabel.hidden = FALSE;
//                //cellDetails.nameLabel.text = [NSString stringWithFormat:@"@%@",self.user.username];
//                if (_user != nil) {
//                    cellDetails.hiThereLbl.hidden = FALSE;
//                    cellDetails.weFoundLabels.hidden = FALSE;
//                    
//                    cellDetails.nameLabel.text = [NSString stringWithFormat:@"@%@",self.user.username];
//                }else if(![_user.username  isEqual:@"(null)"]){
//                    cellDetails.nameLabel.hidden = FALSE;
//                }
//                NSLog(@"%@", self.user.username);
//                        cellDetails.containerView.layer.cornerRadius = cellDetails.containerView.frame.size.width/2;
//                //        dispatch_async(kfetchQueue, ^{
//                //            //P1
//                //            
//                //            NSURL *urlforimage = [NSURL URLWithString:nURL];
//                //            NSData *imageData = [NSData dataWithContentsOfURL:urlforimage];
//                //            //P2- set the image
//                //            dispatch_async(dispatch_get_main_queue(), ^{
//                //                //P1
//                //                cellDetails.imageViewTemp.image = [UIImage imageWithData:imageData];
//                //                //P2
//                //                //[self setImage:cell.imageView.image forKey:cell.textLabel.text];
//                //                [cellDetails setNeedsLayout];
//                //            });
//                //        });
//                
//                
//                return cellDetails;

                
            }else{ //ndexpath not zero
                 static NSString *CellIdentifier = @"SearchResultsTableViewCell";
                
               // SearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                SearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                if(cell ==nil){
                    [self.tableView registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                }
                
                [self configureCell:cell atIndexPath:indexPath];
                return cell;
                
//                
//                            static NSString *CellIdentifier = @"SearchResultsTableViewCell";
//                            SearchResultsTableViewCell *cellDetails = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//                            if(cellDetails ==nil){
//                                [self.tableView registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
//                                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//                            }
//                            [self configureCell:cellDetails atIndexPath:indexPath];
//                            NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
//                            
//                            //cellDetails.productLabel.text = [[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"brandedName"]; //[_array objectAtIndex:indexPath.row];
//                            [cellDetails setSeparatorInset:UIEdgeInsetsZero];
//                            [cellDetails setLayoutMargins:UIEdgeInsetsZero];
//                            ///
//                                ShopStyleProductsModel *photo = self.sJsonModel.products[indexPath.row];//self.sJsonModel.products[indexPath.row];
//                            //        NSString *productUrl= photo.clickUrl;
//                
//                cellDetails.productLabel.text =photo.brandedName;
//                cellDetails.retailLabel.text =[photo valueForKeyPath:@"retailer.name"];
//                cellDetails.productPrice.text = photo.priceLabel;
//                [cellDetails.btnView addTarget:self action:@selector(malebuttonViewForPinterestPressedAction:) forControlEvents:UIControlEventTouchUpInside];
//                [cellDetails.btnShare addTarget:self action:@selector(malebuttonSharePressedAction:) forControlEvents:UIControlEventTouchUpInside];
//                        
//
////                                      dispatch_async(kfetchQueue, ^{
////                                        //P1
////                            
////                                        NSURL *urlforimage = [NSURL URLWithString:nURL];
////                                        NSData *imageData = [NSData dataWithContentsOfURL:urlforimage];
////                                        //P2- set the image
////                                        dispatch_async(dispatch_get_main_queue(), ^{
////                                            //P1
////                                            cellDetails.imageViewTemp.image = [UIImage imageWithData:imageData];
////                                            //P2
////                                            //[self setImage:cell.imageView.image forKey:cell.textLabel.text];
////                                            [cellDetails setNeedsLayout];
////                                        });
////                                    });
//                //http://stackoverflow.com/questions/16663618/async-image-loading-from-url-inside-a-uitableview-cell-image-changes-to-wrong
//                NSString *nURL = [photo valueForKeyPath:@"image.sizes.Best.url"];
//                cellDetails.imageViewTemp.image = nil; // or cell.poster.image = [UIImage imageNamed:@"placeholder.png"];
//                NSURL *urlforimage = [NSURL URLWithString:nURL];
//                //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://myurl.com/%@.jpg", self.myJson[indexPath.row][@"movieId"]]];
//                
//                NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:urlforimage completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//                    if (data) {
//                        UIImage *image = [UIImage imageWithData:data];
//                        if (image) {
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                SearchResultsTableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
//                                if (updateCell)
//                                    updateCell.imageViewTemp.image = image;
//                            });
//                        }
//                    }
//                }];
//                [task resume];
//                
//                        
//            return cellDetails;
            }//end of next section
                 
        
    }else{
        //user is not logged in
        self.tableView.scrollEnabled = NO;
        if (indexPath.section == 0) {
            
            static NSString *CellIdentifier = @"PinterestLoggedOutTableViewCell";
            PinterestLoggedOutTableViewCell *cellDetails = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"PinterestLoggedOutTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                cellDetails.backgroundColor = [UIColor clearColor];
            }
            cellDetails.backgroundColor = [UIColor clearColor];
            
            [cellDetails setUserInteractionEnabled:NO];
            
            
            
            
            //        dispatch_async(kfetchQueue, ^{
            //            //P1
            //
            //            NSURL *urlforimage = [NSURL URLWithString:nURL];
            //            NSData *imageData = [NSData dataWithContentsOfURL:urlforimage];
            //            //P2- set the image
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                //P1
            //                cellDetails.imageViewTemp.image = [UIImage imageWithData:imageData];
            //                //P2
            //                //[self setImage:cell.imageView.image forKey:cell.textLabel.text];
            //                [cellDetails setNeedsLayout];
            //            });
            //        });
            
            
            return cellDetails;
            
            
        }else{
            
            static NSString *CellIdentifier = @"SearchResultsTableViewCell";
            SearchResultsTableViewCell *cellDetails = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            
             NSString *nS = [[self.giantArayResponseObjectForJsonModel objectAtIndex:indexPath.row] valueForKey:@"brandedName"];
            cellDetails.productLabel.text =nS; //[_array objectAtIndex:indexPath.row];
            [cellDetails setSeparatorInset:UIEdgeInsetsZero];
            [cellDetails setLayoutMargins:UIEdgeInsetsZero];
            ///
            //ShopStyleProductsModel *photo = self.sJsonModel.products[indexPath.row];
            //        NSString *productUrl= photo.clickUrl;
           // NSString *nURL = [photo valueForKeyPath:@"image.sizes.Best.url"];
            
            
            return cellDetails;
        }

    
    }
    return nil;
}
- (void)configureCell:(SearchResultsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Fetch Record
   NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Update Cell
    [cell.productLabel setText:[record valueForKey:@"brandedName"]];
    [cell.productPrice setText:[record valueForKey:@"priceLabel"]];
    [cell.retailLabel setText:[record valueForKey:@"retailername"]];
    NSString *nURL = [record valueForKey:@"imageurl"];
                    cell.imageViewTemp.image = nil; // or cell.poster.image = [UIImage imageNamed:@"placeholder.png"];
                    NSURL *urlforimage = [NSURL URLWithString:nURL];
                    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://myurl.com/%@.jpg", self.myJson[indexPath.row][@"movieId"]]];
    
                    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:urlforimage completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        if (data) {
                            UIImage *image = [UIImage imageWithData:data];
                            if (image) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    SearchResultsTableViewCell *updateCell = (id)[self.tableView cellForRowAtIndexPath:indexPath];
                                    if (updateCell)
                                        updateCell.imageViewTemp.image = image;
                                });
                            }
                        }
                    }];
                    [task resume];
    [cell.btnView addTarget:self action:@selector(malebuttonViewForPinterestPressedAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnShare addTarget:self action:@selector(malebuttonSharePressedAction:) forControlEvents:UIControlEventTouchUpInside];
}


//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    
//    // height of the footer
//    // this needs to be set, otherwise the height is zero and no footer will show
//    if(isLoggedin){
//        return 250;
//    }
//    return 0.01f;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    //if (section ==1) {
//    if(isLoggedin){
//        if (section==0){
//
//            NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"ProfileHeader" owner:nil options:nil];
//            
//            // Find the view among nib contents (not too hard assuming there is only one view in it).
//            ProfileHeaderView *plainView = [nibContents lastObject]; //[[ProfileHeaderView alloc]initWithFrame:self.view.frame];//
//            plainView.usernameLabel.hidden = FALSE;
//            
//            
//            plainView.usernameLabel.text = [NSString stringWithFormat:@"@%@", self.username];//[self.logindefaults valueForKey:@"username"];;//self.user.username;//@"Frantz";
//            // Some hardcoded layout.
//            //CGSize padding = (CGSize){ 22.0, 22.0 };
//            //plainView.frame = (CGRect){padding.width, padding.height, plainView.frame.size};
//            
//            // Add to the view hierarchy (thus retain).
//            return plainView;
//            
//            // creates a custom view inside the footer
//    //        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 80)];
//    //        footerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    //        // create a button with image and add it to the view
//    //        //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
//    //        //[button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
//    //        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 400, 30)];
//    //        label.text = @"Your Recommendations";
//    //        label.textColor    = [UIColor darkGrayColor];
//    //        label.font = [UIFont fontWithName:@"Avenir-Book" size:20];
//    //        label.textAlignment = NSTextAlignmentLeft;
//    //        [footerView addSubview:label];
//    //        
//    //        return footerView;
//        }
//    }
//    return nil;
//    
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    
//    // height of the footer
//    // this needs to be set, otherwise the height is zero and no footer will show
//    if (section ==0){
//        return 250;
//    }
//    return 80;
//    
//    
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    
//    
//    
//    // creates a custom view inside the footer
//    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
//    footerView.backgroundColor = [UIColor colorWithRed:255/255.0f green:103/255.0f blue:120/255.0f alpha:1];
//    // create a button with image and add it to the view
//    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 400, 80)];
//    [button setImage:[UIImage imageNamed:@"pinterestlogin"] forState:UIControlStateNormal];
//    //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
//    
//    [footerView addSubview:button];
//    
//    return footerView;
//    
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    //only show footer if user is not logged in
    // height of the footer
    // this needs to be set, otherwise the height is zero and no footer will show
    if (!isLoggedin) {
        
        return 100;
    }
    return 0.001f;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (!isLoggedin) {
        
        
                    // creates a custom view inside the footer
//                    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
//                    footerView.backgroundColor = [UIColor colorWithRed:255/255.0f green:103/255.0f blue:120/255.0f alpha:1];
//                    // create a button with image and add it to the view
//                    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 400, 80)];
//                    [button setImage:[UIImage imageNamed:@"pinterestlogin"] forState:UIControlStateNormal];
//                    //[button setBackgroundImage:[UIImage imageNamed:@"giftideas"] forState:UIControlStateNormal];
//                    [button addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
//        
//                    
//                    [footerView addSubview:button];
//                    
//                    return footerView;
        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"LoginOrSearchView" owner:nil options:nil];
        
        // Find the view among nib contents (not too hard assuming there is only one view in it).
        self.logView = [nibContents lastObject];
        self.logView.backgroundColor = [UIColor colorWithRed:255/255.0f green:103/255.0f blue:120/255.0f alpha:1];
        [self.logView.noThanksButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.logView.noThanksButton addTarget:self action:@selector(noThanksTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.logView.logPinterestButton addTarget:self action:@selector(footerTapped) forControlEvents:UIControlEventTouchUpInside];
        return self.logView;
        
    }

    return nil;
   
}
- (void)noThanksTapped {
    self.tabBarController.selectedIndex = 1;

}
- (void)footerTapped {
    //[self showWithoutFooter];
    //log the user in.
    if(!debugMode){
    [[PDKClient sharedInstance]authenticateWithPermissions:@[PDKClientReadPublicPermissions,
                                                             PDKClientReadPrivatePermissions,
                                                             PDKClientWriteRelationshipsPermissions] withSuccess:^(PDKResponseObject *responseObject) {
                                                                 //
                                                                 self.user = [responseObject user];
                                                                 NSString *userName =  self.user.username;
                                                                 NSLog(@"%@",userName);
                                                                 //[self getUserlikes];
                                                                 [self.logindefaults setBool:YES forKey:@"hasUserLoggedIn"];
                                                                 id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                                                 [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                                                                       action:@"Pinterest_loggedin_success"  // Event action (required)
                                                                                                                        label:@"Pinterest Button clicked"          // Event label
                                                                                                                        value:nil] build]];    // Event value
                                                                 [self.logindefaults setValue:self.user.username forKey:@"username"];
                                                                 [self.logindefaults setValue:self.user.firstName forKey:@"firstname"];
                                                                 
                                                                 [self getUserpins];
                                                                 [self loadtheBottomView];
                                                             
                                                             } andFailure:^(NSError *error) {
                                                                 //error
                                                             
                                                             }];
    }else{
        
        NSString *stringForResult = @"This feature is coming soon.";
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Log in with Pinterest"
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

    
    //[self.tableView reloadData];
    NSLog(@"Footer tapped");
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //send user to productDetailsViewcontroller
    if (indexPath != nil)
    {
        //...
        NSLog(@"row % ldpped", (long)indexPath.row);
        NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
//       NSString *brand = [record valueForKey:@"brandedName"];
//        NSString *plabel = [record valueForKey:@"priceLabel"];
//       NSString *retaler = [record valueForKey:@"retailername"];
//        NSString *nurl = [record valueForKey:@"imageurl"];
        
        
        UIStoryboard *storyboard = self.storyboard;
        ProductDetailsViewController *pDetailsVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductDetailsViewController"];
        
        // UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pDetailsVC];
        
        //        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
        //                                                                       style:UIBarButtonItemStylePlain
        //                                                                      target:self
        //                                                                      action:@selector(backPressed:)];
        
        //navigationController.navigationItem.leftBarButtonItem = backButton;
        //pDetailsVC.productDetails = productDetails;
        //pDetailsVC.shopStyleModel = self.sJsonModel.products[indexPath.row];
        pDetailsVC.recordNSManagedObject = record;
        pDetailsVC.comingFromManagedObject = YES;
        [self.navigationController pushViewController:pDetailsVC animated:Nil];
        //[self p:navigationController  animated:NO completion:nil  ];
        
        
    }
    
    
    
    
    
    
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[[self tableView] cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
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

- (void)extraLeftItemDidPress {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)extraRightItemDidPress {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}



#pragma mark - UICollectionViewDataSource




//get user likes
-(void)getUserlikes{
    
//     if (debugMode) {
    PDKPin *pin ;//= self.pins[indexPath.row];
    //PDKPinCell *cell = (PDKPinCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PinCell" forIndexPath:indexPath];
    
    [[PDKClient sharedInstance] getAuthenticatedUserLikesWithFields:[NSSet setWithArray:@[@"id", @"image", @"note"]] success:^(PDKResponseObject *responseObject)
     {
         //
         NSArray *userPins = [responseObject pins];
         
         NSMutableArray *appendArray = [NSMutableArray new];
         for (PDKPin *p in userPins) {
             [appendArray addObject:[p.descriptionText lowercaseString]];
         }
         NSLog(@"things liked %@", userPins);
         //NSString *temp = pin.descriptionText;
     }
                                                         andFailure:^(NSError *error) {
                                                             // weakSelf.resultLabel.text = @"authentication failed";
                                                             
                                                         }];
//     }else{
//         
//         NSString *stringForResult = @"This feature is coming soon.";
//         UIAlertController *alertController = [UIAlertController
//                                               alertControllerWithTitle:@"Log in with Pinterest"
//                                               message:stringForResult
//                                               preferredStyle:UIAlertControllerStyleAlert];
//         UIAlertAction *cancelAction = [UIAlertAction
//                                        actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
//                                        style:UIAlertActionStyleCancel
//                                        handler:^(UIAlertAction *action)
//                                        {
//                                            NSLog(@"Cancel action");
//                                        }];
//         
//         UIAlertAction *okAction = [UIAlertAction
//                                    actionWithTitle:NSLocalizedString(@"OK", @"OK action")
//                                    style:UIAlertActionStyleDefault
//                                    handler:^(UIAlertAction *action)
//                                    {
//                                        NSLog(@"OK action");
//                                    }];
//         
//         [alertController addAction:cancelAction];
//         [alertController addAction:okAction];
//         [self presentViewController:alertController animated:YES completion:nil];
//     }

    
}
-(void)checkIfUserLoggedIn{
    //check if the user has already logged in
    if(isLoggedin){
        //if they already have clicke the footer to login
        //silenty log them in
        [[PDKClient sharedInstance] silentlyAuthenticateWithSuccess:^(PDKResponseObject *responseObject) {
            //
            self.user = [responseObject user];
            [self loadtheBottomView];
            [self.logindefaults setValue:self.user.username forKey:@"username"];
            NSString *userName =  self.user.username;
            NSLog(@"Silent log ine username: %@",userName);
            [self.tableView reloadData];
            [self getUserpins];
        } andFailure:^(NSError *error) {
            //
            NSLog(@"silent error: %@", error.description);
            
            //[self checkIfUserLoggedIn];
            if (!isLoggedin) {
                [self footerTapped];
            }
             
        }];
    
    }
    
//    [[PDKClient sharedInstance] getAuthorizedUserFields:[NSSet setWithArray:@[@"id", @"username", @"bio"]] withSuccess:^(PDKResponseObject *responseObject) {
//        //
//        PDKUser *user  = [responseObject user];
//        NSLog(@"Welcome %@",user.firstName);
//        //isLoggedin = TRUE;
//    } andFailure:^(NSError *error) {
//        //user not logged in
//        NSLog(@"No One is Logged in. Logging in silently");
//        //only if they have already authorized the app..check in userdefaults if they were already
//        //authorized and if so silently log them
//        [[PDKClient sharedInstance]authenticateWithPermissions:@[PDKClientReadPublicPermissions,
//                                                                 PDKClientReadPrivatePermissions,                                                             PDKClientReadRelationshipsPermissions,
//                                                                 PDKClientWriteRelationshipsPermissions] withSuccess:^(PDKResponseObject *responseObject) {
//                                                                     //
//                                                                     self.user = [responseObject user];
//                                                                     NSString *userName =  self.user.username;
//                                                                     
//                                                                                                                                          NSLog(@"Logged %@ in silenty lol",userName);
//                                                                     //[self getUserlikes];
//                                                                     //[self getUserpins];
//                                                                     
//                                                                     
//                                                                 } andFailure:^(NSError *error) {
//                                                                     //error
//                                                                 }];
//
//        //should log someone in
//    }];
}
-(void)getUserpins{
    
    //currently used for algo
    //get the user pins into an array. set user logged in bool to true. and reload the table
    PDKPin *pin ;//= self.pins[indexPath.row];
    //PDKPinCell *cell = (PDKPinCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PinCell" forIndexPath:indexPath];
//     if (debugMode) {
    [[PDKClient sharedInstance] getAuthenticatedUserPinsWithFields:[NSSet setWithArray:@[@"id",  @"note"]] success:^(PDKResponseObject *responseObject)
     {
         //
         NSArray *userPins = [responseObject pins];
         
         NSMutableArray *appendArray = [NSMutableArray new];
         for (PDKPin *p in userPins) {
             
             
             
             [appendArray addObject:p.descriptionText];
             [self.dataFromPinterest addObject:p.descriptionText];
         }
         NSDate *methodStart = [NSDate date];
         //user was successfully logged in
         
             self.barButtonLogout.tintColor = [UIColor grayColor];
             self.barButtonLogout.enabled = YES;
         
             
         
             [self runAlgorithmToMatchUserToProducts:^(BOOL finished) {
                 //
    //             if (finished) {

    //             }
             }];
         
         
         
         
        
     }andFailure:^(NSError *error) {
                                                             
    }];

    
    
}
//-(void)runAlgorithmToMatchUserToProducts:(pinCompletionBlock)completionHandler{
//    //algorithm setup
//    //this will
//    //start fist task with GCD. put this operation in the background
//   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
//       dispatch_group_t operationGroup = dispatch_group_create(); // create a group
//        
//        dispatch_group_enter(operationGroup); // enter the group of tasks to run
//            for (NSString *i in self.currentProductCategories) {
//                //do a lookup on each i. if i is found once send a request for one product. and break
//                //filter the pinteret array.
//                //the runtime complexity for this is O(n). man as categories increase shit will slow down fuck.
//                //improvement: Filter by the first ten objects in categories, then throw the algorithm in the background/or server.
//                //improvement: Load the results in background of app, and let user know we working..hmm ??
//                NSPredicate *predicateToLookFor = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", i];
//                
//                NSArray *tempcontainer = [self.dataFromPinterest filteredArrayUsingPredicate:predicateToLookFor];
//                if(tempcontainer.count >0){
//                    //make a request for that first category and store in the main container
//                    //then break and go to the next loop.
//                    NSLog(@"Sending request for %@", i);
//                    [self requestDataFromWS:i]; //store the reponse from request into object model.
//                    //continue;
//                }
//                
//
//                
//            }
//    isLoggedin = TRUE;
//    completionHandler(YES);
//    
//        dispatch_group_leave(operationGroup);//task done homie go ahead and go on now
//      dispatch_group_wait(operationGroup, DISPATCH_TIME_FOREVER); //wait until all group tasks are done...
//       dispatch_async(dispatch_get_main_queue(), ^{ // assume all work is done so get back in the main thread and reload table
////
//    
//               //[self.tableView reloadData]; //reload the table to show changes.
//        
//    
//        
//        
//       });
//   });
//        
//    }
-(void)runAlgorithmToMatchUserToProducts:(pinCompletionBlock)completionHandler{
    //algorithm setup
    //this will
    //start fist task with GCD. put this operation in the background
    //New idea: loop through categories and pick a random piece
    //TODO: remove break allow the requests to go in a queueu. Add a semaphore to not leave this loop until it is complete
    //then and only then reload the table
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t _myQueue = dispatch_queue_create("com.shopn.DispatchGroup",
                                                      0);
    
    if (!algoDidRun) {
    
    
        dispatch_group_async(group, _myQueue, ^{
            //  do some long running task.
        
                for (NSString *i in self.currentProductCategories) {
                    //do a lookup on each i. if i is found once send a request for one product. and break
                    //filter the pinteret array.
                    //the runtime complexity for this is O(n). man as categories increase shit will slow down fuck.
                    //improvement: Filter by the first ten objects in categories, then throw the algorithm in the background/or server.
                    //improvement: Load the results in background of app, and let user know we working..hmm ??
                    NSPredicate *predicateToLookFor = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", i]; //[i lowercaseString]
                    
                    NSArray *tempcontainer = [self.dataFromPinterest filteredArrayUsingPredicate:predicateToLookFor];
                    if(tempcontainer.count >0){
                        //make a request for that first category and store in the main container
                        //then break and go to the next loop.
                        NSLog(@"Sending request for %@", i);
                        [self requestDataFromWS:i limit:@"5"]; //store the reponse from request into object model.
                        //break;
                        self.loadRandomDataBool = FALSE;
                    }
                    
                    
                    
                }//end of for loop
            [self.logindefaults setBool:YES forKey:@"algorithmHasRun"];
 
             
             id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
             [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                   action:@"Pinterest_loggedin_success"  // Event action (required)
                                                                    label:@"Pinterest Login success"          // Event label
                                                                    value:nil] build]];    // Event value

            
            });
        //algo ran do a quicl lookup and see if we got data
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        if (self.loadRandomDataBool) {

            BOOL shouldWeGetRandomData = [self didWeGetStuffBack];
            NSLog(@"DID WE GET STUFF? %d", shouldWeGetRandomData);
            if (!shouldWeGetRandomData) {
                //run loadrandomproducts
                [self loadRandomProductsForUser];
                NSLog(@"LOADING RANDOMS %d", shouldWeGetRandomData);
            }else{
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                      action:@"Pinterest_algo_success"  // Event action (required)
                                                                       label:@"ALgorithm Ran"          // Event label
                                                                       value:nil] build]];    // Event value
            
            }
        }
        isLoggedin = YES;
        [self.tableView reloadData];
    }
    [self.tableView reloadData];
    //algorithm has run
    [self.logindefaults setBool:YES forKey:@"hasUserLoggedIn"];
    NSLog(@"");
     
    //now run some things after this block
   // NSLog(@"obj size %lu" ,(unsigned long)self.giantArayResponseObjectForJsonModel.count);
      isLoggedin = [self.logindefaults boolForKey:@"hasUserLoggedIn"];
     [self.tableView reloadData];
    
    
}
-(BOOL)didWeGetStuffBack{
    BOOL weGotStuff = FALSE;
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = app.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Products" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if ([fetchedObjects count]>0) {
        weGotStuff = TRUE;
        
    }
    return weGotStuff;

}
-(void)loadRandomProductsForUser{
    //since we havent ran the algo yet set it to default.
    [self.logindefaults setBool:NO forKey:@"algorithmHasRun"];
    for (NSString *i in self.currentProductCategories) {
        
        
        [self requestDataFromWS:i limit:@"2"];
        
    }
    [self.tableView reloadData];

}

-(void)loadtheBottomView{
                NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"ProfileHeader" owner:nil options:nil];
    
                // Find the view among nib contents (not too hard assuming there is only one view in it).
                _plainView = [nibContents lastObject]; //[[ProfileHeaderView alloc]initWithFrame:self.view.frame];//
                _plainView.usernameLabel.hidden = FALSE;
                _plainView.hiThereLbl.hidden = FALSE;
                //_plainView.loggedOutMessage.hidden = TRUE;
                _plainView.foundSomethings.hidden = FALSE;
    
                _plainView.frame = self.view.frame;
//                if (self.user.username) {
//                    plainView.usernameLabel.text = [NSString stringWithFormat:@"@%@", [self.logindefaults valueForKey:@"username"]];
//                }else
                if(self.user.firstName || self.username){
                    _plainView.usernameLabel.text = [NSString stringWithFormat:@"@%@", [self.logindefaults valueForKey:@"firstname"]];
                }else{
                _plainView.usernameLabel.hidden = TRUE;
                }
                //[self.logindefaults valueForKey:@"username"];;//self.user.username;//@"Frantz";
                // Some hardcoded layout.
                //CGSize padding = (CGSize){ 22.0, 22.0 };
                //plainView.frame = (CGRect){padding.width, padding.height, plainView.frame.size};
    
                // Add to the view hierarchy (thus retain).
            //self.headerView.hidden = FALSE;
            [self.headerTextView setHidden:YES];
            [self.headerView addSubview:_plainView];
            [self.logView removeFromSuperview];

}
-(void)LoadLoggedOutView{
    //NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"ProfileHeader" owner:nil options:nil];
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"PinterestLoggedOutTableViewCell" owner:nil options:nil];
    // Find the view among nib contents (not too hard assuming there is only one view in it).
    PinterestLoggedOutTableViewCell *pLoggedout = [nibContents lastObject];
    
    //_plainView.loggedOutMessage.hidden = FALSE;
    
    //[self.headerTextView setHidden:NO];
     [self.headerView addSubview:pLoggedout];


}

-(void)requestDataFromWS:(NSString *)searchText limit:(NSString * )limit{
  
    
        [ShopStyleAPIHelper searchforProductReturnJson:searchText limit:limit completionHandler:^(id responseObject, NSError *error) {
            
            
            
            
            
            //NSLog(@"the response is %@",responseObject);
            //[self.giantArayResponseObjectForJsonModel addObject:[responseObject objectForKey:@"products" ]];
            //self.giantArayResponseObjectForJsonModel= [responseObject objectForKey:@"products"];
            //[self.giantDicResponseObjectForJsonModel setValue:responseObject forKey:responseObject];
            
            
            NSError *err;
            
            
            self.sJsonModel = [[ShopStyleJSONModel alloc] initWithDictionary:responseObject error:&err];
            
            //[self.sJsonModel.products addObjectsFromArray:[responseObject objectForKey:@"products"]];
            if (err) {
                NSLog(@"Unable to initialize PublicPhotosModel, %@", err.localizedDescription);
            }
            //add some stff to coredata
            ShopStyleProductsModel *product;
            
            NSManagedObjectContext *context = [self managedObjectContext];
            for (int i=0; i<[limit intValue]; i++) {
                
                NSManagedObject *info = [NSEntityDescription
                                         insertNewObjectForEntityForName:@"Products"
                                         inManagedObjectContext:context];
                product=self.sJsonModel.products[i];
                
                 
                
                
                
                
                [info setValue:product.brandedName forKey:@"brandedName"];
                [info setValue:product.brandedName forKey:@"clickUrl"];
                [info setValue:[product valueForKeyPath:@"image.sizes.Best.url"] forKey:@"imageurl"];
                [info setValue:product.pageUrl forKey:@"pageUrl"];
                [info setValue:product.priceLabel forKey:@"priceLabel"];
                //[info setValue:product.salePriceLabel forKey:@"salePriceLabel"];
                [info setValue:product.description forKey:@"productdescription"];
                [info setValue:[product valueForKeyPath:@"retailer.name"] forKey:@"retailername"];
            
            }
            
                
            
            
            NSError *manageContextError;
            if (![context save:&manageContextError]) {
                NSLog(@"Whoops, couldn't save: %@", [manageContextError localizedDescription]);
            }

            
            
            //we can reload the table here if we wanted to
            NSLog(@"exiting req meth after kickoff: dic count now: %lu",self.giantArayResponseObjectForJsonModel.count);
            NSTimeInterval executionTime = [self.methodFinish timeIntervalSinceDate:self.methodStarted];
            NSLog(@"Sem: Algorithm executionTime = %f", executionTime);
            
            
            isLoggedin = true;
            //[self.tableView reloadData]; //comment this out and reload table after the algo ran.
            //NSLog(@"obj size %lu" ,(unsigned long)self.giantArayResponseObjectForJsonModel.count);
            //[self.tableView reloadData];
        }]; //
    
     //    isLoggedin = true;
    //NSLog(@"obj size %lu" ,(unsigned long)self.giantArayResponseObjectForJsonModel.count);
    [self.tableView reloadData];
    
}

//-(void)requestDataFromWS:(NSString *)searchText{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
//        dispatch_group_t operationGroup = dispatch_group_create(); // create a group
//        
//            dispatch_group_enter(operationGroup); // enter the group of tasks to run
//            [ShopStyleAPIHelper searchforProductReturnJson:searchText limit:@"1" completionHandler:^(id responseObject, NSError *error) {
//                
//                
//                
//                
//                
//                NSLog(@"the response is %@",responseObject);
//                [self.giantArayResponseObjectForJsonModel addObject:[responseObject objectForKey:@"products" ]];//self.giantArayResponseObjectForJsonModel= []//[responseObject objectForKey:@"products"];
//                [self.giantDicResponseObjectForJsonModel setValue:responseObject forKey:responseObject];
//                
//
//                NSError *err;
//                
//                
//                //self.sJsonModel = [[ShopStyleJSONModel alloc] initWithDictionary:responseObject error:&err];
//                [self.sJsonModel.products addObject:responseObject];
//                if (err) {
//                    NSLog(@"Unable to initialize PublicPhotosModel, %@", err.localizedDescription);
//                }
//                
//                
//         
//                //we can reload the table here if we wanted to
//                 NSLog(@"exiting req meth after kickoff: dic count now: %lu",self.giantArayResponseObjectForJsonModel.count);
//                NSTimeInterval executionTime = [self.methodFinish timeIntervalSinceDate:self.methodStarted];
//                NSLog(@"Algorithm executionTime = %f", executionTime);
//                
//            }]; //
//    
//        dispatch_group_leave(operationGroup);//task done homie go ahead and go on now
//        dispatch_group_wait(operationGroup, DISPATCH_TIME_FOREVER); //wait until all group tasks are done...
//        dispatch_async(dispatch_get_main_queue(), ^{ // assume all work is done so get back in the main thread and reload table
//            //
//           
//
//            isLoggedin = TRUE;
//            //[self.tableView reloadData]; //reload the table to show changes.
//            
//            
//        });
//    });
//    
//    
//}

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
    NSString *brandName;
    NSManagedObject *record;
    //ShopStyleProductsModel *product;
    if (indexPath != nil)
    {
        //...
        NSLog(@"row % ldpped", (long)indexPath.row);
        record = [self.fetchedResultsController objectAtIndexPath:indexPath];
        brandName = [record valueForKey:@"brandedName"];
        //product = self.sJsonModel.products[indexPath.row];
        productUrl = [record valueForKey:@"pageUrl"];//product.pageUrl;
    }
    NSString *textToShare = [NSString stringWithFormat:@"Check this %@ out!",brandName];//@"Check this out!";
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

- (void)malebuttonViewForPinterestPressedAction:(id)sender
{
    /*
     when tappped ask user if they are logged in to save to their Pinterest Board.
     */
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"pinproduct_button_press_loggedin"  // Event action (required)
                                                           label:@"Pin It Button - Logged In"          // Event label
                                                           value:nil] build]];    // Event value
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    NSString *brandName;
    NSManagedObject *record;
    NSString *productUrl;
    if (indexPath != nil)
    {
        //...
        NSLog(@"row % ldpped", (long)indexPath.row);
        //ShopStyleProductsModel *photo = self.sJsonModel.products[indexPath.row];
        record = [self.fetchedResultsController objectAtIndexPath:indexPath];
        brandName = [record valueForKey:@"brandedName"];
        
        productUrl = [record valueForKey:@"pageUrl"];//
        NSString *photoURL = [record valueForKey:@"imageurl"];//[photo valueForKeyPath:@"image.sizes.IPhone.url"];
        
        
        [PDKPin pinWithImageURL:[NSURL URLWithString:photoURL]
                           link:[NSURL URLWithString:productUrl]
             suggestedBoardName:@"Shopn"
                           note:brandName
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


- (IBAction)pinterestBTN1Tapped:(id)sender {
    
//    if (debugMode) {
    
    
    
    [[PDKClient sharedInstance]authenticateWithPermissions:@[PDKClientReadPublicPermissions,
                                                             PDKClientReadPrivatePermissions,                                                             PDKClientReadRelationshipsPermissions,
                                                             PDKClientWriteRelationshipsPermissions] withSuccess:^(PDKResponseObject *responseObject) {
                                                                 //
                                                                 self.user = [responseObject user];
                                                                 NSString *userName =  self.user.username;
                                                                 NSLog(@"%@",userName);
                                                                 //[self getUserlikes];
                                                                 [self getUserpins];
                                                             
                                                             
                                                             } andFailure:^(NSError *error) {
                                                                 //error
                                                             }];
//    }else{
//    
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
//    }
//
//    [[PDKClient sharedInstance] authenticateWithPermissions:@[PDKClientReadPublicPermissions,
//                                                              PDKClientWritePublicPermissions,
//                                                              PDKClientReadPrivatePermissions,
//                                                              PDKClientWritePrivatePermissions,
//                                                              PDKClientReadRelationshipsPermissions,
//                                                              PDKClientWriteRelationshipsPermissions]
//                                                withSuccess:^(PDKResponseObject *responseObject)
//     {
//         weakSelf.user = [responseObject user];
//         weakSelf.resultLabel.text = [NSString stringWithFormat:@"%@ authenticated!", weakSelf.user.firstName];
//         [weakSelf updateButtonEnabledState];
//     } andFailure:^(NSError *error) {
//         weakSelf.resultLabel.text = @"authentication failed";
//     }];

}
- (IBAction)barButtonLogoutClicked:(id)sender {
    [PDKClient clearAuthorizedUser];
    //delete core data stuff
    AppDelegate *app = [[AppDelegate alloc]init];
    
    [app dropEntityTable:@"Products"];
    [self.logindefaults setBool:NO forKey:@"hasUserLoggedIn"];
    isLoggedin = [self.logindefaults boolForKey:@"hasUserLoggedIn"];
    NSLog(@"user logged out. islogged = %d", isLoggedin);
    [self.tableView reloadData];
    _plainView.usernameLabel.hidden= TRUE;
    _plainView.hiThereLbl.hidden = TRUE;
    //_plainView.loggedOutMessage.hidden = FALSE;
    _plainView.foundSomethings.hidden = TRUE;
    [self.headerTextView setHidden:NO];
//    [_plainView removeFromSuperview];
//    _plainView = nil;
    //self.headerView = nil;
    [self.headerView addSubview:self.headerTextView];
        self.barButtonLogout.tintColor = [UIColor clearColor];
        self.barButtonLogout.enabled = YES;
   
}

#pragma - get current season
-(void)startLocationmanager{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    if ([ locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        //set the access to yes that location access was granted
        
        [ locationManager requestWhenInUseAuthorization];
    }
}
- (void)getcurrentSeason:(BOOL)startLocation
{
    NSCalendar* myCalendar = [NSCalendar currentCalendar];
//    NSDateComponents* components = [myCalendar components:NSYearCalendarUnit|NSCalendarUnitMonth|NSCalendarUnitDay
//                                                 fromDate:[NSDate date]];
    NSDateComponents* components = [myCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                                 fromDate:[NSDate date]];
    components.hour = 12;
    
    // Current year
    NSInteger currentYear = components.year;
    
    // Today
    NSDate *today = [NSDate date];
    
    // First Day of the year
    components.month = 1;
    components.day = 1;
    components.year = currentYear;
    NSDate *firstDayDate = [myCalendar dateFromComponents:components];
    
    // Spring Date
    components.month = 3;
    components.day = 21;
    components.year = currentYear;
    NSDate *springDate = [myCalendar dateFromComponents:components];
    
    // Summer Date
    components.month = 6;
    components.day = 21;
    components.year = currentYear;
    NSDate *summerDate = [myCalendar dateFromComponents:components];
    
    // Autumn Date
    components.month = 9;
    components.day = 23;
    components.year = currentYear;
    NSDate *autumnDate = [myCalendar dateFromComponents:components];
    
    // Winter Date
    components.month = 12;
    components.day = 22;
    components.year = currentYear;
    NSDate *winterDate = [myCalendar dateFromComponents:components];
    
    // Last Day of the year
    components.month = 12;
    components.day = 31;
    components.year = currentYear;
    NSDate *lastDayDate = [myCalendar dateFromComponents:components];
    
    // Current Location
    if (startLocation) {
         self.logindefaults = [NSUserDefaults standardUserDefaults];
        [self startLocationmanager];
    }
    //[self startLocationmanager];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    location = [locationManager location];
    coord = [location coordinate];
    NSLog(@"Coord: %f", coord.latitude);
    //[self.logindefaults setBool:YES forKey:@"LocationAccessGranted"];
    //get current location.
//    self.clGeocoder = [CLGeocoder new];
//    [self.clGeocoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        
//        CLPlacemark *placemark = [placemarks objectAtIndex:0];
//        [self.logindefaults setBool:YES forKey:@"LocationAccessGranted"];
//        NSString *city = placemark.locality;
//        NSString *state = placemark.administrativeArea;
//        [self.logindefaults setValue:city forKey:@"City"];
//        [self.logindefaults setValue:state forKey:@"State"];
//    
//        }
//    
//    ];
    // North Hemisphere
    if (coord.latitude > 0)
    {
        NSLog(@"North Pole");
        
        // Settings the background image
        if ([self isDate:today inRangeFirstDate:firstDayDate lastDate:springDate] || [self isDate:today inRangeFirstDate:winterDate lastDate:lastDayDate])
        {
            [self.logindefaults setValue:@"Winter" forKey:@"Season"];
            NSLog(@"Winter");
        }
        else if ([self isDate:today inRangeFirstDate:springDate lastDate:summerDate])
        {
            [self.logindefaults setValue:@"Spring" forKey:@"Season"];
            NSLog(@"Spring");
        }
        else if ([self isDate:today inRangeFirstDate:summerDate lastDate:autumnDate])
        {
            [self.logindefaults setValue:@"Summer" forKey:@"Season"];
            NSLog(@"Summer");
        }
        else if ([self isDate:today inRangeFirstDate:autumnDate lastDate:winterDate])
        {
            [self.logindefaults setValue:@"Autumn" forKey:@"Season"];
            NSLog(@"Autumn");
        }
    }
    else
    {
        NSLog(@"South Pole");
        
        // Settings the background image
        if ([self isDate:today inRangeFirstDate:firstDayDate lastDate:springDate] || [self isDate:today inRangeFirstDate:winterDate lastDate:lastDayDate])
        {
            [self.logindefaults setValue:@"Summer" forKey:@"Season"];
            NSLog(@"Summer");
        }
        else if ([self isDate:today inRangeFirstDate:springDate lastDate:summerDate])
        {
            [self.logindefaults setValue:@"Autumn" forKey:@"Season"];
            NSLog(@"Autumn");
        }
        else if ([self isDate:today inRangeFirstDate:summerDate lastDate:autumnDate])
        {
            [self.logindefaults setValue:@"Winter" forKey:@"Season"];
            NSLog(@"Winter");
        }
        else if ([self isDate:today inRangeFirstDate:autumnDate lastDate:winterDate])
        {
            [self.logindefaults setValue:@"Spring" forKey:@"Season"];
            NSLog(@"Spring");
        }
    }
}


- (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate
{
    return ([date compare:firstDate] == NSOrderedDescending) && ([date compare:lastDate] == NSOrderedAscending);
}
-(void)askUserForLocationUse{
//    bool locationAccessgranted = [self.logindefaults boolForKey:@"LocationAccessGranted"];
//    if (!locationAccessgranted) {
    
        //[self.logindefaults setBool:YES forKey:@"LocationAccessAsked"];
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Your Location"
                                              message:@"Can we use your location to show you products that would be more relevant to you?"
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self.logindefaults setBool:YES forKey:@"LocationAccessAsked"];
                                       //[self getcurrentSeason];
                                       [self requestLocation];
                                       NSLog(@"OK action");
                                   }];
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:@"No thanks"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self.logindefaults setBool:YES forKey:@"LocationAccessAsked"];
                                           [self.logindefaults setBool:YES forKey:@"LocationAccessDenied"];
                                           NSLog(@"cancel action");
                                       }];
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
//    }
//    else{
//        bool locationAccessdenied = [self.logindefaults boolForKey:@"LocationAccessDenied"];
//        if (!locationAccessdenied) {
//            [self getcurrentSeason];
//        }
//        
//    
//    }
}
#pragma locaition requestors
-(void)requestLocation{
    // Current Location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    [self startLocationmanager ];

    
    
}
-(void)getCityState{
    [self.locationManager startUpdatingLocation];
    self.clGeocoder = [CLGeocoder new];
    [self.clGeocoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        //[self.logindefaults setBool:YES forKey:@"LocationAccessGranted"];
        NSString *city = placemark.locality;
        NSString *state = placemark.administrativeArea;
        [self.logindefaults setValue:city forKey:@"City"];
        [self.logindefaults setValue:state forKey:@"State"];
        NSLog(@"city-state:%@,%@",[self.logindefaults valueForKey:@"City"],[self.logindefaults valueForKey:@"State"]);
        //[self.tableView reloadData];
        [self.locationManager stopUpdatingLocation];
    }];
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if(status==kCLAuthorizationStatusAuthorizedAlways||status==kCLAuthorizationStatusAuthorizedWhenInUse){
        [self.logindefaults setBool:YES forKey:@"LocationAccessGranted"];
        
        //[self requestLocation];
        [self getCityState];
        [self getcurrentSeason:false];
    }
}

@end
