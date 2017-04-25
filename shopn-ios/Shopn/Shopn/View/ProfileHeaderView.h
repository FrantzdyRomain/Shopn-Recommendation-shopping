//
//  ProfileHeaderView.h
//  shopn
//
//  Created by Frantzdy romain on 11/22/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UITextView *loggedOutMessage;
@property (strong, nonatomic) IBOutlet UITextView *foundSomethings;
@property (strong, nonatomic) IBOutlet UITextView *hiThereLbl;

@end
