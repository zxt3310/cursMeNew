//
//  LoginViewController.h
//  CureMe
//
//  Created by Tim on 12-8-13.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CustomBaseViewController.h"

@class RegisterViewController;

@interface LoginViewController : CustomBaseViewController <UIAlertViewDelegate>

{
    RegisterViewController *registerViewController;
    NSString *phoneNo;
    NSString *password;
}

// Properties:
@property (strong, nonatomic) IBOutlet UITextField *phoneNoField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

// Button actions:
- (IBAction)login:(id)sender;
- (IBAction)registry:(id)sender;
- (IBAction)back:(id)sender;

@end
