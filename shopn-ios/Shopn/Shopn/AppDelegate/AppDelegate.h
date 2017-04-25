// For License please refer to LICENSE file in the root of YALAnimatingTabBarController project
//GOogle UA-71012941-1
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <CoreData/CoreData.h>
#import "Reachability.h"
#import <CoreData/CoreData.h>
#import <Google/Analytics.h>
#import "CZPicker.h"
//Wildcard sdk API key API Key: 4f47674d-1b06-4b90-a059-9aa7ee000029

//@class Reachability;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>{
    Reachability* internetReachableFoo;
    

}


@property (strong, nonatomic) UIWindow *window;


// Core Data properties
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property BOOL iscapStoneMode;
@property NSUserDefaults *logindefaults;

// Core Data public methods
//+(void) checkNetworkStatus:(NSNotification *)notice;
+ (void)testInternetConnection;
-(BOOL)getCapstoneMode;
-(void)flushCoreData;
-(void)dropEntityTable:(NSString *)name;


- (NSURL *)applicationDocumentsDirectory;


@end

