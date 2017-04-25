

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "YALTabBarInteracting.h"
#import "ShopStyleJSONModel.h"
#import "PDKBoard.h"

#import "PDKClient.h"
#import "PDKPin.h"
#import "PDKResponseObject.h"
#import "PDKUser.h"
//#import "PinterestUser.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "ProfileHeaderView.h"
#import "LoginOrSearchView.h"
#import "NewUserLaunchViewController.h"

typedef void (^pinCompletionBlock)(BOOL);

@interface ProductsViewController : UIViewController <YALTabBarInteracting,UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property BOOL isLoggedin;
@property BOOL algoDidRun;

@property (nonatomic) NSMutableArray *array;
@property (nonatomic) NSMutableArray *products;
@property (nonatomic) NSMutableArray *productImages;
@property (nonatomic) NSDictionary *dictImages;

@property (strong, nonatomic) ShopStyleJSONModel *sJsonModel;

@property PFImageView *productImageView;
@property (strong, nonatomic) IBOutlet UIButton *pinterestBTN1;

- (IBAction)pinterestBTN1Tapped:(id)sender;
//pinterst
@property (nonatomic, strong) PDKUser *user;
@property (nonatomic, strong) PDKResponseObject *currentLikesResponseObject; //pinterest likes response

@property BOOL debugMode;

@property NSMutableArray *giantRecommendationContainer;
@property NSMutableArray *currentProductCategories;
@property NSMutableArray *dataFromPinterest;
@property id giantResponseObjectForJsonModel;
@property NSDictionary* giantDicResponseObjectForJsonModel;
@property NSMutableArray * giantArayResponseObjectForJsonModel;

-(void)runAlgorithmToMatchUserToProducts:(pinCompletionBlock)completionHandler;
@property NSDate *methodStarted;
@property NSDate *methodFinish;
//Coredata
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property AppDelegate *appdelegate;
@property NSUserDefaults *logindefaults;
@property NSString *username;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonLogout;
- (IBAction)barButtonLogoutClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UITextView *headerTextView;
@property (strong, nonatomic) ProfileHeaderView *plainView;
@property (strong, nonatomic) LoginOrSearchView *logView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property  CLLocationCoordinate2D coord;
@property BOOL loadRandomDataBool;

@property (strong, nonatomic)CLGeocoder* clGeocoder;

- (void)getcurrentSeason:(BOOL)startLocation;


@end
