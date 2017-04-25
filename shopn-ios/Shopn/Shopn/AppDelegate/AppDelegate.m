

#import "AppDelegate.h"
#import "EasyPost.h"

//model
#import "YALTabBarItem.h"

//controller
#import "YALFoldingTabBarController.h"

//helpers
#import "YALAnimatingTabBarConstants.h"
//products. Download new products from Parse Backend and store in this product
 
#import "PFOrderDetailsHelper.h"
#import "PDKClient.h"
#import "ProductsViewController.h"
#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]

//@import WildcardSDK;
static NSString * const kPinAppId = @"4794675302554935362";
static NSString* const wildCardAPIKey = @"4f47674d-1b06-4b90-a059-9aa7ee000029";
@interface AppDelegate ()


@end

@implementation AppDelegate

@class Reachability;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize iscapStoneMode;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    self.logindefaults = [NSUserDefaults standardUserDefaults];
    iscapStoneMode = NO;
    [self testModel];
    [self setupYALTabBarController];
    [self configureGoogleAnalytics];
    [self getCurrentDaylight];
    
 //   [WildcardSDK initializeWithApiKey:wildCardAPIKey];
    
    //parse options
    [Parse enableLocalDatastore];
    //init keys
    [Parse setApplicationId:@"EeCrEzBGpDvsnGs8NYGnV9eYZHZhK1NYlIxvSyiH"
                  clientKey:@"7aQkYDHAyX2rBEOj18KJcewnlVqxz6FMuFGtiSfQ"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //pinterest setup
    [PDKClient configureSharedInstanceWithAppId:kPinAppId];
    
    [PDKClient configureSharedInstanceWithAppId:kPinAppId];
    
    ProductsViewController *pv = [[ProductsViewController alloc]init];
    pv.managedObjectContext = self.managedObjectContext;
    
    [self testInternetConnectionOnLoad];
    
    //create test classes
   // PFProduct *p = [PFProduct objectWithClassName:@"Products"];
//    PFObject *testObject = [PFObject objectWithClassName:@"Products"];
//    UIImage *image = [UIImage imageNamed:@"settings_icon"];
//    PFFile *file = [PFFile fileWithData:UIImageJPEGRepresentation(image,0.9)];
//    
//    [testObject setObject:file forKey:@"productImage"];
//    [testObject setObject:@"" forKey:@"name"];
//    [testObject setObject:@"" forKey:@"price"];
//    [testObject setObject:@"" forKey:@"quantity"];
//    [testObject setObject:@"" forKey:@"UPC"]; //unique product code
//    [testObject saveInBackground];
//    
//    PFObject *testOrderObject = [PFObject objectWithClassName:@"Orders"];
//    
//    [testOrderObject setObject:@"" forKey:@"name"];
//    [testOrderObject setObject:@"" forKey:@"address"];
//    [testOrderObject setObject:@"" forKey:@"city"];
//    [testOrderObject setObject:@"" forKey:@"state"];
//    [testOrderObject setObject:@"" forKey:@"zipcode"];
//    [testOrderObject setObject:@"" forKey:@"phone"];
//    [testOrderObject setObject:@"" forKey:@"quantity"];
//    [testOrderObject setObject:@"" forKey:@"UPC"]; //unique product code
//    [testOrderObject saveInBackground];
    return YES;
}
-(void)configureGoogleAnalytics{
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
#warning comment out before release
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release

}
-(void)getCurrentDaylight{
  //is it day time or night time.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH.mm"];
    NSString *strCurrentTime = [dateFormatter stringFromDate:[NSDate date]];
    
    NSLog(@"Check float value: %.2f",[strCurrentTime floatValue]);
    if ([strCurrentTime floatValue] >= 18.00 || [strCurrentTime floatValue]  <= 6.00){
        NSLog(@"It's night time");
#warning change this lol
        [self.logindefaults setBool:NO forKey:@"IsDayTime"];
    }else{
        NSLog(@"It's day time");
        [self.logindefaults setBool:YES forKey:@"IsDayTime"];
    }

}
-(void)testModel{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    
    for (int i =0; i <10; i++) {
        NSManagedObject *info = [NSEntityDescription
                                 insertNewObjectForEntityForName:@"Pins"
                                 inManagedObjectContext:context];
        NSString *stringtoAdd = [NSString stringWithFormat:@"Test bank %d", i];
        [info setValue:stringtoAdd forKey:@"pindesc"];
        
    }
    
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
}

- (void)setupYALTabBarController {
    
    if (!iscapStoneMode) {
        
     
        YALFoldingTabBarController *tabBarController = (YALFoldingTabBarController *) self.window.rootViewController;

        //prepare leftBarItems
        //help icon
        YALTabBarItem *item1 = [[YALTabBarItem alloc] initWithItemImage:[UIImage imageNamed:@"search_icon"]
                                                          leftItemImage:[UIImage imageNamed:@"logo"]
                                                         rightItemImage:nil];
        
        
        //male icon
        YALTabBarItem *item2 = [[YALTabBarItem alloc] initWithItemImage:[UIImage imageNamed:@"categories"]
                                                          leftItemImage:nil
                                                         rightItemImage:nil];
        
        
        tabBarController.leftBarItems = @[item1, item2]; // 0 1

        //female products
        YALTabBarItem *item3 = [[YALTabBarItem alloc] initWithItemImage:[UIImage imageNamed:@"useraccount"]
                                                          leftItemImage:nil
                                                         rightItemImage:nil];
        
        //settings
        YALTabBarItem *item4 = [[YALTabBarItem alloc] initWithItemImage:[UIImage imageNamed:@"settings_icon"]
                                                          leftItemImage:nil
                                                         rightItemImage:[UIImage imageNamed:@"logo"]];
        
        tabBarController.rightBarItems = @[item3, item4]; //2 2
        
        tabBarController.centerButtonImage = [UIImage imageNamed:@"logo"];
        tabBarController.selectedIndex = 2;
        
        //customize tabBarView
        tabBarController.tabBarView.extraTabBarItemHeight = YALExtraTabBarItemsDefaultHeight;
        tabBarController.tabBarView.offsetForExtraTabBarItems = YALForExtraTabBarItemsDefaultOffset;
    //    tabBarController.tabBarView.backgroundColor = [UIColor colorWithRed:204/255.0 green:52/255.0 blue:75/255.0 alpha:1];
    //    tabBarController.tabBarView.backgroundColor = [UIColor colorWithRed:204/255.0 green:52/255.0 blue:75/255.0 alpha:1];
    //    tabBarController.tabBarView.tabBarColor = [UIColor colorWithRed:255/255.0 green:164/255.0 blue:154/255.0 alpha:1];
        tabBarController.tabBarView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        //5AE1FF
        tabBarController.tabBarView.tabBarColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        tabBarController.tabBarView.layer.cornerRadius = 0;
        tabBarController.tabBarViewHeight = 59.0f;//YALTabBarViewDefaultHeight;
        tabBarController.tabBarView.clipsToBounds = NO;
        //tabBarController.tabBarView.layer.borderWidth = 1;
        //tabBarController.tabBarView.layer.borderColor =  (__bridge CGColorRef _Nullable)([UIColor colorWithRed:204/255.0 green:52/255.0 blue:75/255.0 alpha:1]);
        tabBarController.tabBarView.tabBarViewEdgeInsets = YALTabBarViewHDefaultEdgeInsets;
        tabBarController.tabBarView.tabBarItemsEdgeInsets = YALTabBarViewItemsDefaultEdgeInsets;
    }else{
        YALFoldingTabBarController *tabBarController = (YALFoldingTabBarController *) self.window.rootViewController;
        
        //prepare leftBarItems
        //help icon
        YALTabBarItem *item1 = [[YALTabBarItem alloc] initWithItemImage:[UIImage imageNamed:@"search_icon"]
                                                          leftItemImage:nil
                                                         rightItemImage:nil];
        
        
        //male icon
        YALTabBarItem *item2 = [[YALTabBarItem alloc] initWithItemImage:[UIImage imageNamed:@"categories"]
                                                          leftItemImage:nil
                                                         rightItemImage:nil];
        
        
//        tabBarController.leftBarItems = @[item1, item2]; // 0 1
            tabBarController.leftBarItems = @[item1];
        //female products
        YALTabBarItem *item3 = [[YALTabBarItem alloc] initWithItemImage:[UIImage imageNamed:@"useraccount"]
                                                          leftItemImage:nil
                                                         rightItemImage:nil];
        
        //settings
        YALTabBarItem *item4 = [[YALTabBarItem alloc] initWithItemImage:[UIImage imageNamed:@"settings_icon"]
                                                          leftItemImage:nil
                                                         rightItemImage:nil];
        
//        tabBarController.rightBarItems = @[item3, item4]; //2 2
        tabBarController.rightBarItems = @[item2];
        tabBarController.centerButtonImage = [UIImage imageNamed:@"logo"];
        tabBarController.
        tabBarController.selectedIndex = 1;
        
        //customize tabBarView
        tabBarController.tabBarView.extraTabBarItemHeight = YALExtraTabBarItemsDefaultHeight;
        tabBarController.tabBarView.offsetForExtraTabBarItems = YALForExtraTabBarItemsDefaultOffset;
        //    tabBarController.tabBarView.backgroundColor = [UIColor colorWithRed:204/255.0 green:52/255.0 blue:75/255.0 alpha:1];
        //    tabBarController.tabBarView.backgroundColor = [UIColor colorWithRed:204/255.0 green:52/255.0 blue:75/255.0 alpha:1];
        //    tabBarController.tabBarView.tabBarColor = [UIColor colorWithRed:255/255.0 green:164/255.0 blue:154/255.0 alpha:1];
        tabBarController.tabBarView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        //5AE1FF
        tabBarController.tabBarView.tabBarColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        tabBarController.tabBarView.layer.cornerRadius = 0;
        tabBarController.tabBarViewHeight = 59.0f;//YALTabBarViewDefaultHeight;
        tabBarController.tabBarView.clipsToBounds = NO;
        //tabBarController.tabBarView.layer.borderWidth = 1;
        //tabBarController.tabBarView.layer.borderColor =  (__bridge CGColorRef _Nullable)([UIColor colorWithRed:204/255.0 green:52/255.0 blue:75/255.0 alpha:1]);
        tabBarController.tabBarView.tabBarViewEdgeInsets = YALTabBarViewHDefaultEdgeInsets;
        tabBarController.tabBarView.tabBarItemsEdgeInsets = YALTabBarViewItemsDefaultEdgeInsets;
    
    
    
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [[PDKClient sharedInstance] handleCallbackURL:url];
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    return [[PDKClient sharedInstance] handleCallbackURL:url];
}


+ (void)testInternetConnection
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        /// Create an alert if connection doesn't work
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"No Internet Connection"   message:@"Looks like your internet is off. Please check your settings." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [myAlert show];
        //[myAlert release];
    }
    else
    {
        NSLog(@"INTERNET IS CONNECT");
    }
}
-(void)testInternetConnectionOnLoad
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        /// Create an alert if connection doesn't work
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"No Internet Connection"   message:@"Looks like your internet is off. Please check your settings." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [myAlert show];
        //[myAlert release];
    }
    else
    {
        NSLog(@"INTERNET IS CONNECT");
    }
}
-(BOOL)getCapstoneMode{
    
    return iscapStoneMode;

}

#pragma coredata
- (void)saveContext{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Shopn" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Shopn.sqlite"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

-(void)dropEntityTable:(NSString *)name{
    //TODO: Might not be optimal.
//    NSString *entityName = name;
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
//    
//    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
//    
//    NSError *deleteError = nil;
//    NSManagedObjectContext *context = [self managedObjectContext];
//    [_persistentStoreCoordinator executeRequest:delete withContext:context error:&deleteError];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:name];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error;
    NSManagedObjectContext *theContext=[self managedObjectContext];
    NSArray *fetchedObjects = [theContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *object in fetchedObjects)
    {
        [theContext deleteObject:object];
    }
    
    error = nil;
    [theContext save:&error];
}

-(void)flushCoreData{
    [_managedObjectContext performBlock:^{
        //delete objects and not block UI
        NSArray *objs = [_persistentStoreCoordinator persistentStores];
        for (NSPersistentStore *store in objs){
            [_persistentStoreCoordinator removePersistentStore:store error:nil];
            [[NSFileManager defaultManager]removeItemAtPath:store.URL.path error:nil];
        }
        _managedObjectModel    = nil;
        _managedObjectContext  = nil;
        _persistentStoreCoordinator = nil;
    }];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Uialertdelegate delegates






@end
