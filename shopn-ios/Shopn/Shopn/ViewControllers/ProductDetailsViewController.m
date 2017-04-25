//
//  ProductDetailsViewController.m
//  Surprise
//
//  Created by Frantzdy romain on 8/5/15.
//  Copyright (c) 2015 Frantz. All rights reserved.
// todo add buttonSharePressedAction to celldetails

#import "ProductDetailsViewController.h"
#import "ProductHeaderViewCell.h"
#import "ProductPriceCell.h"
#import "ProductDetailsInfoCell.h"

#import "ProductTitleCell.h"
#import "ProductOrderButtonCell.h"
#import "BuyOrAddTableViewCell.h"
#import "QuantityTableViewCell.h"
#import "ShopnWebViewController.h"

#define kfetchQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface ProductDetailsViewController ()<UIPickerViewDelegate, UITextFieldDelegate,UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@end

@implementation ProductDetailsViewController

@synthesize shopStyleModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //if activity view remove it
    if(_activityIndicatorView){
        [_activityIndicatorView stopAnimating];
        [_activityIndicatorView removeFromSuperview];
    
    }
    
    self.navigationController.delegate = self;
    //remove unused cells
    self.detailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(buttonBackPressed:)];
    
    
    //UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:nil action:@selector(closeSelf)];
    [[self navigationItem] setLeftBarButtonItem:backButton];
    
    backButton.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = backButton;
    
    _quantity = [_productDetails objectForKey:@"quantity"];
    //NSString *productUrl= shopStyleModel.brandedName;
    //set a default quality in case user doesnt care
    // _quantitySelected =[NSNumber numberWithInt:1];
    
    NSInteger integer = [_quantity integerValue];
    _arrQuantity = [[NSMutableArray alloc]init];
    for (NSInteger i =1; i<=integer; i++) {
        [_arrQuantity addObject:[NSNumber numberWithInteger:i]];
    }
//    _pickerForQuantity = [[UIPickerView alloc]init];
//    _pickerForQuantity.tag = 0;
//    [_pickerForQuantity setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    ///add gesture recognizer to the picker row
//    UITapGestureRecognizer *gestureRecognizer =  [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapPicker)];
//    [_pickerForQuantity addGestureRecognizer:gestureRecognizer];
//    gestureRecognizer.delegate = self;
}
-(void)viewWillAppear:(BOOL)animated{
    if(self.comingFromManagedObject){
        self.navigationItem.title = [self.recordNSManagedObject valueForKey:@"retailername"];
    }else{
    
        self.navigationItem.title = [self.shopStyleModel.retailer objectForKey:@"name"];
    }
}
-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
    }
    [super viewWillDisappear:animated];
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
    return 4;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0){
    return 380;
    
    }else if(indexPath.row==2){
        return 130;
    }else if(indexPath.row==3){
        return 70;
    }
    else if(indexPath.row==4){
        return 350;
    }
    return  44;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!self.comingFromManagedObject){
        if(indexPath.row==0){
                static NSString *CellIdentifier = @"ProductHeaderViewCell";
                ProductHeaderViewCell *cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if(cellDetails ==nil){
                    [_detailsTableView registerNib:[UINib nibWithNibName:@"ProductHeaderViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                    cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
                }
                cellDetails.separatorInset = UIEdgeInsetsMake(0.f, cellDetails.bounds.size.width+1000, 0.f, 0.f);
        //        PFFile *imageFile = (PFFile*)[_productDetails objectForKey:@"productImage"];//[_productDetails objectForKey:@"productImage"];
        //        
        //        cellDetails.headerImageView.file = imageFile;
        //        [cellDetails.headerImageView loadInBackground];
        //        NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
                
                //NSString *brand = [self.recordNSManagedObject valueForKey:@"brandedName"];
                NSString *nURL = [shopStyleModel valueForKeyPath:@"image.sizes.XLarge.url"];
//                dispatch_async(kfetchQueue, ^{
//                    //P1
//                    
//                    NSURL *urlforimage = [NSURL URLWithString:nURL];
//                    NSData *imageData = [NSData dataWithContentsOfURL:urlforimage];
//                    //P2- set the image
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        //P1
//                        cellDetails.headerImageView.image = [UIImage imageWithData:imageData];
//                        //P2
//                        //[self setImage:cell.imageView.image forKey:cell.textLabel.text];
//                        [cellDetails setNeedsLayout];
//                    });
//                });
            //NSString *nURL = [photo valueForKeyPath:@"image.sizes.XLarge.url"]; // //@"image.sizes.Large.url" //loads faster?
            cellDetails.headerImageView.image = nil; // or cell.poster.image = [UIImage imageNamed:@"placeholder.png"];
            NSURL *urlforimage = [NSURL URLWithString:nURL];
            //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://myurl.com/%@.jpg", self.myJson[indexPath.row][@"movieId"]]];
            
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:urlforimage completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ProductHeaderViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell)
                                updateCell.headerImageView.image = image;
                        });
                    }
                }
            }];
            [task resume];
               

                return cellDetails;
            }else if(indexPath.row==1){
                static NSString *CellIdentifier = @"ProductTitleCell";
                ProductTitleCell *cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if(cellDetails ==nil){
                    [_detailsTableView registerNib:[UINib nibWithNibName:@"ProductTitleCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                    cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
                }
        //        NSString *stringForPrice = [NSString stringWithFormat:@"$%@",[_productDetails objectForKey:@"price"]];
                NSString *stringForPrice = [NSString stringWithFormat:@"%@",shopStyleModel.priceLabel];
                //cellDetails.productTitle.text = [_productDetails objectForKey:@"name"];
                cellDetails.productTitle.text = shopStyleModel.brandedName;
                [cellDetails setSeparatorInset:UIEdgeInsetsZero];
                [cellDetails setLayoutMargins:UIEdgeInsetsZero]; //set the the line edge to edge
                
                return cellDetails;
            }
        //    else if(indexPath.row==2){
        //    
        //        static NSString *CellIdentifier = @"ProductPriceCell";
        //        ProductPriceCell *cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //        if(cellDetails ==nil){
        //            [_detailsTableView registerNib:[UINib nibWithNibName:@"ProductPriceCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        //            cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //        }
        //        NSString *stringForPrice = [NSString stringWithFormat:@"$%@",[_productDetails objectForKey:@"price"]];
        //        cellDetails.priceLabel.text = stringForPrice;
        //        //cellDetails.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
        //        return cellDetails;
        //        
        //    }
            else if(indexPath.row==2){
                
                
                static NSString *CellIdentifier = @"ProductDetailsInfoCell";
                ProductDetailsInfoCell *cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if(cellDetails ==nil){
                    [_detailsTableView registerNib:[UINib nibWithNibName:@"ProductDetailsInfoCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                    cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
                }
                //remove cell seperator
                cellDetails.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
               // cellDetails.textViewDetails.text = shopStyleModel.description;
                 [cellDetails.webviewForDetails loadHTMLString:[NSString stringWithFormat:@"<div style='text-align:justify; font-size:12px;font-family:HelveticaNeue-light;color:#757575;'>%@",shopStyleModel.description] baseURL:nil];
                
                
        //        static NSString *CellIdentifier = @"QuantityTableViewCell";
        //        QuantityTableViewCell *cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //        if(cellDetails ==nil){
        //            [_detailsTableView registerNib:[UINib nibWithNibName:@"QuantityTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        //            cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //        }
                //NSString *quantity = [NSString stringWithFormat:@"%@",[_productDetails objectForKey:@"quantity"]];
                //NSString *quantity = [NSString stringWithFormat:@"%@",_quantitySelected];
                //cellDetails.textLabel.text = [shopStyleModel valueForKeyPath:@"brand.name"];
                
        //        cellDetails.textFieldForQuantity.inputView = _pickerForQuantity;
        //        cellDetails.textFieldForQuantity.text = quantity;
        //        cellDetails.textFieldForQuantity.delegate = self;
        //        cellDetails.textFieldForQuantity.tag = 0;
                 cellDetails.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0); //remove te line
        //        [cellDetails setSeparatorInset:UIEdgeInsetsZero];
        //        [cellDetails setLayoutMargins:UIEdgeInsetsZero]; //set the the line edge to edge
                return cellDetails;
                
            }
            else if(indexPath.row==3){
                //BuyOrAddTableViewCell.h
            
        //        static NSString *CellIdentifier = @"ProductOrderButtonCell";
        //        ProductOrderButtonCell *cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //        if(cellDetails ==nil){
        //            [_detailsTableView registerNib:[UINib nibWithNibName:@"ProductOrderButtonCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        //            cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //        }
        //        //remove cell seperator
        //        cellDetails.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
                static NSString *CellIdentifier = @"BuyOrAddTableViewCell";
                BuyOrAddTableViewCell *cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if(cellDetails ==nil){
                    [_detailsTableView registerNib:[UINib nibWithNibName:@"BuyOrAddTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                    cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
                }
                
                NSString *buyTitle = [NSString stringWithFormat:@"Buy %@ ", shopStyleModel.priceLabel];
                [cellDetails.btnBuy setTitle:buyTitle forState:UIControlStateNormal];
                //remove cell seperator
                [cellDetails.btnBuy addTarget:self action:@selector(buttonBuyPressedAction) forControlEvents:UIControlEventTouchUpInside];
                cellDetails.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
                
                return cellDetails;
            }
            else if(indexPath.row==4){
                
                static NSString *CellIdentifier = @"ProductDetailsInfoCell";
                ProductDetailsInfoCell *cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if(cellDetails ==nil){
                    [_detailsTableView registerNib:[UINib nibWithNibName:@"ProductDetailsInfoCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                    cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
                }
                //remove cell seperator
                cellDetails.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
                cellDetails.textViewDetails.text = shopStyleModel.description;
                return cellDetails;
            }
    }else{
    //coming from managed object
    if(indexPath.row==0){
            static NSString *CellIdentifier = @"ProductHeaderViewCell";
            ProductHeaderViewCell *cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [_detailsTableView registerNib:[UINib nibWithNibName:@"ProductHeaderViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            cellDetails.separatorInset = UIEdgeInsetsMake(0.f, cellDetails.bounds.size.width+1000, 0.f, 0.f);
            //        PFFile *imageFile = (PFFile*)[_productDetails objectForKey:@"productImage"];//[_productDetails objectForKey:@"productImage"];
            //
            //        cellDetails.headerImageView.file = imageFile;
            //        [cellDetails.headerImageView loadInBackground];
            //        NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
        
            NSString *nURL = [self.recordNSManagedObject valueForKey:@"imageurl"];;
            dispatch_async(kfetchQueue, ^{
                //P1
                
                NSURL *urlforimage = [NSURL URLWithString:nURL];
                NSData *imageData = [NSData dataWithContentsOfURL:urlforimage];
                //P2- set the image
                dispatch_async(dispatch_get_main_queue(), ^{
                    //P1
                    cellDetails.headerImageView.image = [UIImage imageWithData:imageData];
                    //P2
                    //[self setImage:cell.imageView.image forKey:cell.textLabel.text];
                    [cellDetails setNeedsLayout];
                });
            });
            
            
            
            return cellDetails;
        }else if(indexPath.row==1){
            static NSString *CellIdentifier = @"ProductTitleCell";
            ProductTitleCell *cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [_detailsTableView registerNib:[UINib nibWithNibName:@"ProductTitleCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            //        NSString *stringForPrice = [NSString stringWithFormat:@"$%@",[_productDetails objectForKey:@"price"]];
            
            NSString *brandedName = [self.recordNSManagedObject valueForKey:@"brandedName"];
            //cellDetails.productTitle.text = [_productDetails objectForKey:@"name"];
            cellDetails.productTitle.text = brandedName;//shopStyleModel.brandedName;
            [cellDetails setSeparatorInset:UIEdgeInsetsZero];
            [cellDetails setLayoutMargins:UIEdgeInsetsZero]; //set the the line edge to edge
            
            return cellDetails;
            
        }else if(indexPath.row==2){
            
            
            static NSString *CellIdentifier = @"ProductDetailsInfoCell";
            ProductDetailsInfoCell *cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [_detailsTableView registerNib:[UINib nibWithNibName:@"ProductDetailsInfoCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            //remove cell seperator
            cellDetails.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
            // cellDetails.textViewDetails.text = shopStyleModel.description;
            NSString *description = [self.recordNSManagedObject valueForKey:@"productdescription"];
            [cellDetails.webviewForDetails loadHTMLString:[NSString stringWithFormat:@"<div style='text-align:justify; font-size:12px;font-family:HelveticaNeue-light;color:#757575;'>%@",description] baseURL:nil];
            

            cellDetails.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0); //remove te line

            return cellDetails;
            
        }
        else if(indexPath.row==3){
  
            static NSString *CellIdentifier = @"BuyOrAddTableViewCell";
            BuyOrAddTableViewCell *cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [_detailsTableView registerNib:[UINib nibWithNibName:@"BuyOrAddTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            NSString *price = [self.recordNSManagedObject valueForKey:@"priceLabel"];
            NSString *buyTitle = [NSString stringWithFormat:@"Buy %@ ", price];
            [cellDetails.btnBuy setTitle:buyTitle forState:UIControlStateNormal];
            //remove cell seperator
            [cellDetails.btnBuy addTarget:self action:@selector(buttonBuyPressedAction) forControlEvents:UIControlEventTouchUpInside];
            cellDetails.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
            
            return cellDetails;
        }
        else if(indexPath.row==4){
            
            static NSString *CellIdentifier = @"ProductDetailsInfoCell";
            ProductDetailsInfoCell *cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [_detailsTableView registerNib:[UINib nibWithNibName:@"ProductDetailsInfoCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [_detailsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            //remove cell seperator
            cellDetails.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
            cellDetails.textViewDetails.text = shopStyleModel.description;
            return cellDetails;
        }
    
    
    
    }
    
     return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //send user to productDetailsViewcontroller
    if(indexPath.row==3){
        OrderDetailsModel *sharedDetails = [OrderDetailsModel sharedManager];
        UIStoryboard *storyboard = self.storyboard;
        NSString *stringForQuant = [NSString stringWithFormat:@"%lD",(long)_quantitySelected];
        CheckoutOrderViewController *checkoutOrderDetails = [storyboard instantiateViewControllerWithIdentifier:@"CheckoutOrderViewController"];
        checkoutOrderDetails.orderDetailsModel.productDetails = _productDetails;
        sharedDetails.productDetails = _productDetails;
        checkoutOrderDetails.orderDetailsModel.quantity = _quantitySelected;
        sharedDetails.quantity = _quantitySelected;
        checkoutOrderDetails.quantitySelected = _quantitySelected;
        
        [self.navigationController pushViewController:checkoutOrderDetails animated:YES];
    }
    
    
    
}
#pragma mark - TextField delegeates
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 0){
        NSString *mystr = textField.text;
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        
        _quantitySelected = [f numberFromString:mystr];
    }
    [textField resignFirstResponder];
    
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return true;
}
#pragma mark - Picker delegeates

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    //NSArray *a= [_arrQuantity mutableCopy];
    if(thePickerView.tag==0){
        
        return [_arrQuantity count];
    }
    return 0;
    
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(thePickerView.tag==0){
        int quant = [[_arrQuantity objectAtIndex:row] intValue];
        NSString *str = [NSString stringWithFormat:@"%d", quant];
        return str;
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(thePickerView.tag ==0){
        NSLog(@"Selected state: %@. Index of : %li", [_arrQuantity objectAtIndex:row], (long)row);
        QuantityTableViewCell *cellForState = (QuantityTableViewCell*)[self.detailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        int quant = [[_arrQuantity objectAtIndex:row] intValue];
        NSString *str = [NSString stringWithFormat:@"%d", quant];
        cellForState.textFieldForQuantity.text = str;
        
        NSNumber *myNum = [NSNumber numberWithInteger:[[_arrQuantity objectAtIndex:row] integerValue]];
        
        _quantitySelected =myNum;
        
    }
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    } else {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
    }
    
    self.detailsTableView.contentInset = contentInsets;
    self.detailsTableView.scrollIndicatorInsets = contentInsets;
    [self.detailsTableView scrollToRowAtIndexPath:self.editingIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    self.detailsTableView.contentInset = UIEdgeInsetsZero;
    self.detailsTableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return true;
    
}
-(void)didTapPicker{
    NSLog(@"picker view called");
    [self.view endEditing:YES];
}
-(void)buttonBuyPressedAction{

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShopnWebViewController *shopnWVC = [storyboard instantiateViewControllerWithIdentifier:@"ShopnWebViewController"];
    shopnWVC.urlString = shopStyleModel.clickUrl;
    
    //[self presentModalViewController:vc animated:YES];
    
    
    
    [self.navigationController pushViewController:shopnWVC animated:YES];
    

}

-(void)buttonBackPressed:(id)sender{
    if(_activityIndicatorView){
        [_activityIndicatorView stopAnimating];
        [_activityIndicatorView removeFromSuperview];
    }
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
    [[self navigationController] popViewControllerAnimated:nil];
}

- (void)backPressed:(id)sender
{
    if(_activityIndicatorView){
        [_activityIndicatorView stopAnimating];
        [_activityIndicatorView removeFromSuperview];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
 

@end
