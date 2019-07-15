//
//  UserDetailInfoViewController.h
//  CureMe
//
//  Created by Tim on 12-9-20.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "CustomBaseViewController.h"
#import <UIKit/UIKit.h>
#import "LocateUtils.h"

@interface UserDetailInfoViewController : CustomBaseViewController

{
}

- (IBAction)selectUserRegion:(id)sender;
- (IBAction)submitUserInfo:(id)sender;

- (void)ntfUserRegionSelected:(NSNotification *)note;

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *ageField;
@property (strong, nonatomic) IBOutlet UITextField *telephoneField;
@property (strong, nonatomic) IBOutlet UILabel *regionLabel;

@end
