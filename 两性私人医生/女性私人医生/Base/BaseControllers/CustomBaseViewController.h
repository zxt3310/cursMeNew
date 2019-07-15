//
//  CustomBaseViewController.h
//  CureMe
//
//  Created by Tim on 12-8-15.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;

@interface CustomBaseViewController : UIViewController <UITextFieldDelegate>

{
    UIActivityIndicatorView *activityIndicator;
    UIImage *navBarBgImage;
}

@property (nonatomic, strong) UIButton *unreadMsgBtn;

- (IBAction)back:(id)sender;
- (IBAction)openUnreadMsg:(id)sender;

//- (void)mainthreadUpdateUnreadCount;

@end
