//
//  ChangePasswordViewController.h
//  CureMe
//
//  Created by Tim on 12-9-21.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "CustomBaseViewController.h"
#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : CustomBaseViewController

@property (strong, nonatomic) IBOutlet UITextField *firstNewPWField;
@property (strong, nonatomic) IBOutlet UITextField *secondNewPWField;

- (IBAction)confirmBtnClick:(id)sender;

- (void)ntfUnreadMsgCountUpdated:(NSNotification *)note;

@end
