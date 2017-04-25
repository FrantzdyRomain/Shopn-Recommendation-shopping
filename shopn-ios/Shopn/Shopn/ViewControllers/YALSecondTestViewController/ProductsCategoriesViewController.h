// For License please refer to LICENSE file in the root of YALAnimatingTabBarController project

#import <UIKit/UIKit.h>

#import "YALTabBarInteracting.h"
#import "AppDelegate.h"
#import "CZPicker.h"
#import "HTHorizontalSelectionList.h"
#import "ShopStyleJSONModel.h"

#import "PDKBoard.h"

#import "PDKClient.h"
#import "PDKPin.h"
#import "PDKResponseObject.h"
#import "PDKUser.h"
#import "DGActivityIndicatorView.h"



@interface ProductsCategoriesViewController : UIViewController <YALTabBarInteracting, UITableViewDataSource, UITableViewDelegate,CZPickerViewDataSource, CZPickerViewDelegate, HTHorizontalSelectionListDataSource, HTHorizontalSelectionListDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *array;
@property (nonatomic) NSMutableArray *products;
@property (nonatomic) NSMutableArray *productImages;
@property  NSArray *maleCatogeries;
@property (nonatomic) NSArray *femaleCatogeries;
@property PFImageView *productImageView;

@property NSArray *trendOptions;

@property (nonatomic, strong) HTHorizontalSelectionList *selectionList;
@property (nonatomic) NSMutableArray *optionsCategories;
@property (nonatomic, strong) NSArray *subMenCategories;
@property (nonatomic, strong) UILabel *selectedLabel;
@property (strong, nonatomic) IBOutlet UIView *topView;

@property (strong, nonatomic) ShopStyleJSONModel *sJsonModel;

@property (strong, nonatomic)DGActivityIndicatorView *activityIndicatorView;

@property BOOL isLoggedin;

@property BOOL maleCategorySelected;
@property BOOL femaleCategorySelected;
@property NSUserDefaults *logindefaults;
@property BOOL capStoneMode;
@property AppDelegate *appdelegate;

@end
