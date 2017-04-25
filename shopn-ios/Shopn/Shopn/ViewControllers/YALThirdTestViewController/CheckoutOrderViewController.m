//
//  CheckoutOrderViewController.m
//  Surprise
//
//  Created by Frantzdy romain on 8/13/15.
//  Copyright (c) 2015 Frantz. All rights reserved.
//TODO:
//After use rmakes a purchese subtract the number from what is stored in parse and save the object. Make query by objectID and update it.
//https://parse.com/questions/updating-values-in-a-pfobject
//https://www.parse.com/questions/query-pfobject-by-objectid

#import "CheckoutOrderViewController.h"
#import "EasyPost.h"
#import "PlaceOrderViewController.h"
#import "EasyPostHelper.h"

@interface CheckoutOrderViewController ()<UITableViewDataSource, UITableViewDelegate,UIPickerViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property __block NSArray *shippingresultsArray;


@end

@implementation CheckoutOrderViewController
@synthesize activityView, sharedDetails;
- (void)viewDidLoad {
    [super viewDidLoad];
    //remove unused cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(barButtonBackPressed:)];
    backButton.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = backButton;
        arr_state = [NSMutableArray arrayWithObjects:@"",@"Alabama", @"Alaska", @"Arizona", @"Arkansas", @"California", @"Colorado", @"Connecticut", @"Delaware", @"Florida", @"Georgia", @"Hawaii", @"Idaho", @"Illinois", @"Indiana", @"Iowa", @"Kansas", @"Kentucky", @"Louisiana", @"Maine", @"Maryland", @"Massachusetts", @"Michigan", @"Minnesota", @"Mississippi", @"Missouri", @"Montana", @"Nebraska", @"Nevada", @"New Hampshire", @"New Jersey", @"New Mexico", @"New York", @"North Carolina", @"North Dakota", @"Ohio", @"Oklahoma", @"Oregon", @"Pennsylvania", @"Rhode Island", @"South Carolina", @"South Dakota", @"Tennessee", @"Texas", @"Utah", @"Vermont", @"Virginia", @"Washington", @"West Virginia", @"Wisconsin", @"Wyoming", nil];
    
    
    sharedDetails = [OrderDetailsModel sharedManager];
    NSMutableDictionary *testDic = [[NSMutableDictionary alloc]init];
    testDic = [sharedDetails.productDetails valueForKey:@"objectId"];
    NSNumber *testQuantity=_quantitySelected; //After the user checks out. SUbtract this number from the model in parse.
    
    _pickerUserState = [[UIPickerView alloc]init];
    _pickerUserState.tag = 0;
    [_pickerUserState setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    ///add gesture recognizer to the picker row
    UITapGestureRecognizer *gestureRecognizer =  [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapPicker)];
    [_pickerUserState addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.delegate = self;
    activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setHidesWhenStopped:YES];
    activityView.center = self.view.center;
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [activityView stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
#pragma mark - tableview Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==1){
        return 5;
    }else if(section==2){
        return 3;
    }
    return 2;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==2){
        return 60;
    }
    return 54;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        if (indexPath.row==0) {
            static NSString *CellIdentifier = @"NameTableViewCell";
            NameTableViewCell *cellDetails = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"NameTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            cellDetails.cellLabel.text = @"First Name";
            cellDetails.cellTextField.tag = FIRSTNAME_TAG;
            cellDetails.cellTextField.delegate = self;
            return cellDetails;
        }
        else if (indexPath.row==1) {
            static NSString *CellIdentifier = @"NameTableViewCell";
            NameTableViewCell *cellDetails = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"NameTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            cellDetails.cellLabel.text = @"Last Name";
            cellDetails.cellTextField.delegate = self;
            cellDetails.cellTextField.tag = LASTNAME_TAG;
            return cellDetails;
        }

    }
    else if(indexPath.section == 1){
        if(indexPath.row==0){
            static NSString *CellIdentifier = @"AddressDetailsTableViewCell";
            AddressDetailsTableViewCell *cellDetails = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"AddressDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            cellDetails.cellTextField.delegate = self;
            cellDetails.cellLabel.text = @"Street Address";
            
            cellDetails.cellTextField.tag =ADDRESS_TAG;
            return cellDetails;
        }
        else if(indexPath.row==1){
            static NSString *CellIdentifier = @"AddressDetailsTableViewCell";
            AddressDetailsTableViewCell *cellDetails = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"AddressDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            cellDetails.cellTextField.delegate = self;
            cellDetails.cellTextField.tag = APT_TAG;
            cellDetails.cellLabel.text = @"Apt., Floor, Unit";
            return cellDetails;
        }
        else if(indexPath.row==2){
            static NSString *CellIdentifier = @"AddressDetailsTableViewCell";
            AddressDetailsTableViewCell *cellDetails = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"AddressDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            cellDetails.cellLabel.text = @"City";
            cellDetails.cellTextField.delegate = self;
            cellDetails.cellTextField.tag = CITY_TAG;
            return cellDetails;
        }
        else if(indexPath.row==3){
            static NSString *CellIdentifier = @"AddressDetailsTableViewCell";
            AddressDetailsTableViewCell *cellDetails = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"AddressDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            cellDetails.cellLabel.text = @"State";
            cellDetails.cellTextField.tag = STATE_TAG;
            cellDetails.cellTextField.inputView = _pickerUserState;
            cellDetails.cellTextField.delegate = self;
            
            return cellDetails;
            
        }else if(indexPath.row==4){
            static NSString *CellIdentifier = @"AddressDetailsTableViewCell";
            AddressDetailsTableViewCell *cellDetails = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"AddressDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            cellDetails.cellLabel.text = @"Zip Code";
            cellDetails.cellTextField.delegate = self;
            cellDetails.cellTextField.tag = ZIPCODE_TAG;
            return cellDetails;
        }
    
    }
    else if(indexPath.section==2){
    
        if (indexPath.row==0) {
            static NSString *CellIdentifier = @"NameTableViewCell";
            NameTableViewCell *cellDetails = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"NameTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            cellDetails.cellLabel.text = @"Phone Number";
            cellDetails.cellTextField.tag = PHONE_TAG;
            cellDetails.cellTextField.delegate = self;
            return cellDetails;
        }
        else if (indexPath.row==1) {
            static NSString *CellIdentifier = @"NameTableViewCell";
            NameTableViewCell *cellDetails = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"NameTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            cellDetails.cellLabel.text = @"Email";
            
            cellDetails.cellTextField.tag = EMAIL_TAG;
            cellDetails.cellTextField.delegate = self;
            return cellDetails;
        }
        else if(indexPath.section==2){
            static NSString *CellIdentifier = @"ProductOrderButtonCell";
            ProductOrderButtonCell *cellDetails = [self.tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cellDetails ==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"ProductOrderButtonCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cellDetails = [self.tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            //remove cell seperator
            cellDetails.labelBuy.text = @"Save Address & Contiue";
            
            cellDetails.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
            
            return cellDetails;
        }
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //send user to productDetailsViewcontroller
    if (indexPath.section==2){
        if(indexPath.row==2){
            //START a loading view
           //NSArray *result= [self getShippingrates];
            // NSLog(@"%@", result);
            OrderDetailsModel *orderDetails = [OrderDetailsModel sharedManager];
            [activityView startAnimating];
            [self.view addSubview:activityView];
            NSMutableDictionary *dictionaryForParcel = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                        @"8",@"parcel[length]",
                                                        @"6",@"parcel[width]",
                                                        @"5",@"parcel[height]",
                                                        @"10",@"parcel[weight]",
                                                        nil];
            NSMutableDictionary *shipFromDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 @"Frantz Romain",@"address[name]",
                                                 @"",@"address[company]",
                                                 @"2424 Morris Avenue",@"address[street1]",
                                                 @"",@"address[street2]",
                                                 @"Union",@"address[city]",
                                                 @"NJ",@"address[state]",
                                                 @"07083",@"address[zip]",
                                                 @"US",@"address[country]",
                                                 @"(201)974-5050",@"address[phone]",
                                                 @"frantz@apple.com",@"address[email]",
                                                 nil];
            NSMutableDictionary *shipToDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               @"Bill Gates",@"address[name]",
                                               @"",@"address[company]",
                                               @"1 Microsoft Way",@"address[street1]",
                                               @"",@"address[street2]",
                                               @"Redmond",@"address[city]",
                                               @"WA",@"address[state]",
                                               @"98052",@"address[zip]",
                                               @"US",@"address[country]",
                                               @"(425)882-8080",@"address[phone]",
                                               @"bill@microsoft.com",@"address[email]",
                                               nil];
            
            
            
//            [EasyPost getShipmentTo:shipToDict from:shipFromDict forParcel:dictionaryForParcel withCompletionHandler:^(NSError *error, NSDictionary *result) {
//                
//                
//                
//                if(!error){
//                _shippingresultsArray = [result valueForKey:@"rates"];
//                stringForResult = [NSString stringWithFormat:@"%@", _shippingresultsArray];
//                
////                UIAlertController *alertController = [UIAlertController
////                                                      alertControllerWithTitle:@"Rates"
////                                                      message:stringForResult
////                                                      preferredStyle:UIAlertControllerStyleAlert];
////                UIAlertAction *cancelAction = [UIAlertAction
////                                               actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
////                                               style:UIAlertActionStyleCancel
////                                               handler:^(UIAlertAction *action)
////                                               {
////                                                   NSLog(@"Cancel action");
////                                               }];
////                
////                UIAlertAction *okAction = [UIAlertAction
////                                           actionWithTitle:NSLocalizedString(@"OK", @"OK action")
////                                           style:UIAlertActionStyleDefault
////                                           handler:^(UIAlertAction *action)
////                                           {
////                                               NSLog(@"OK action");
////                                           }];
////                
////                [alertController addAction:cancelAction];
////                [alertController addAction:okAction];
////                    [self presentViewController:alertController animated:YES completion:nil];
////                }
//                }
//                }];
                __block NSArray *rates;
                //
                 [EasyPostHelper getShipmentrates:shipToDict from:shipFromDict forParcel:dictionaryForParcel completionHandler:^(id responseObject, NSError *error) {
                    //Do something after data is returned
                   
                    UIStoryboard *storyboard = self.storyboard;
                    PlaceOrderViewController *orderDetails = [storyboard instantiateViewControllerWithIdentifier:@"PlaceOrderViewController"];
                    
                    orderDetails.rates = responseObject;
                    //dismiss loading view and send user on if no errors were found and all forms copleted
                    [activityView stopAnimating];
                    [self.navigationController pushViewController:orderDetails animated:YES];
                }];
            NSLog(@"rates: %@", rates);
            

                }
                
            
            

            

            
        }
    }
    
 
    

-(NSArray *)getShippingrates{
    NSArray *results;
    NSMutableDictionary *dictionaryForParcel = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                @"8",@"parcel[length]",
                                                @"6",@"parcel[width]",
                                                @"5",@"parcel[height]",
                                                @"10",@"parcel[weight]",
                                                nil];
    NSMutableDictionary *shipFromDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         @"Steve Jobs",@"address[name]",
                                         @"",@"address[company]",
                                         @"1 Infinite Loop",@"address[street1]",
                                         @"",@"address[street2]",
                                         @"Cupertino",@"address[city]",
                                         @"CA",@"address[state]",
                                         @"95014",@"address[zip]",
                                         @"US",@"address[country]",
                                         @"(408)974-5050",@"address[phone]",
                                         @"steve@apple.com",@"address[email]",
                                         nil];
    NSMutableDictionary *shipToDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Bill Gates",@"address[name]",
                                       @"",@"address[company]",
                                       @"1 Microsoft Way",@"address[street1]",
                                       @"",@"address[street2]",
                                       @"Redmond",@"address[city]",
                                       @"WA",@"address[state]",
                                       @"98052",@"address[zip]",
                                       @"US",@"address[country]",
                                       @"(425)882-8080",@"address[phone]",
                                       @"bill@microsoft.com",@"address[email]",
                                       nil];
    
    
    
    __block NSString *stringForResult;
    [EasyPost getShipmentTo:shipToDict from:shipFromDict forParcel:dictionaryForParcel withCompletionHandler:^(NSError *error, NSDictionary *result) {
        
        
       
        _shippingresultsArray = [result valueForKey:@"rates"];
        stringForResult = [NSString stringWithFormat:@"%@", _shippingresultsArray];
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Rates"
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
    }];
    results=_shippingresultsArray;
    return results;
    
}
#pragma mark - TextField delegeates
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == FIRSTNAME_TAG){
        sharedDetails.firstname = textField.text;
    }else if(textField.tag==LASTNAME_TAG){
        sharedDetails.lastname = textField.text;
    }else if(textField.tag==ADDRESS_TAG){
        sharedDetails.streetaddr=textField.text;
    }
    else if(textField.tag==APT_TAG){
        sharedDetails.aptfloorunit = textField.text;
    }else if(textField.tag==CITY_TAG){
        sharedDetails.city = textField.text;
    }else if(textField.tag==STATE_TAG){
        sharedDetails.state = textField.text;
    }else if(textField.tag==ZIPCODE_TAG){
        sharedDetails.zipcode = textField.text;
    }else if(textField.tag==PHONE_TAG){
        sharedDetails.phonenumber = textField.text;
    }
    else if(textField.tag==EMAIL_TAG){
        sharedDetails.emailaddr = textField.text;
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
 if(thePickerView.tag==0){
        return [arr_state count];
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(thePickerView.tag==0){
        return [arr_state objectAtIndex:row];
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
 if(thePickerView.tag ==0){
        NSLog(@"Selected state: %@. Index of : %li", [arr_state objectAtIndex:row], (long)row);
     AddressDetailsTableViewCell *cellForState = (AddressDetailsTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]];
     cellForState.cellTextField.text = [arr_state objectAtIndex:row];
        _orderDetailsModel.state =[arr_state objectAtIndex:row];
     
    }
}

-(void)barButtonBackPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
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
    
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    [self.tableView scrollToRowAtIndexPath:self.editingIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return true;

}
-(void)didTapPicker{
    NSLog(@"picker view called");
    [self.view endEditing:YES];
}
@end
