// For License please refer to LICENSE file in the root of YALAnimatingTabBarController project

#import <UIKit/UIKit.h>

#import "YALTabBarInteracting.h"
#import "ShopStyleJSONModel.h"
#import "SearchResultsTVCTableViewController.h"
#import "CZPicker.h"
#import "NewUserLaunchViewController.h"
#import "ForecastIOHandler.h"
#import "ForecastIOModel.h"
#import "DGActivityIndicatorView.h"
@interface SearchViewController : UIViewController <YALTabBarInteracting, CZPickerViewDataSource, CZPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *viewToAnimate;

- (IBAction)toggleSearch:(id)sender;
@property BOOL searchBarShown;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ShopStyleJSONModel *sJsonModel;
@property (strong, nonatomic) ForecastIOModel *forecastModel;


@property (strong, retain) IBOutlet UIBarButtonItem *rightBarBtn;
@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, strong) NSString *searchTerm;

@property(nonatomic, retain) UISearchBar *mySearchBar;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) SearchResultsTVCTableViewController *searchTVController;
@property NSUserDefaults *logindefaults;

@property BOOL userLocationEnabled;

@property BOOL isDayTime;
//
@property BOOL shouldGetWeatherData;

@property (strong, nonatomic) IBOutlet UIView *viewForSearch;
@property (strong, nonatomic) UIView *searchBarView;
@property (strong, nonatomic) IBOutlet UIButton *btnforViewForSearch;

@property (strong) ShopStyleProductsModel *photo;
@property (strong, nonatomic)DGActivityIndicatorView *activityIndicatorView;
@property BOOL isLoggedin;
@property (nonatomic, strong) PDKUser *user;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end
