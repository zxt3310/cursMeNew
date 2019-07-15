//
//  PerCenterLoginCell.h
//  CureMe
//
//  Created by Tim on 12-9-12.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "PerCenterViewController.h"
#import <UIKit/UIKit.h>

@interface PerCenterLoginCell : UITableViewCell

{
    UIButton *loginBtn;
    UIButton *registerBtn;
}

@property (nonatomic, strong) PerCenterViewController *viewController;
- (void)generateLayout;

- (IBAction)loginBtnClick:(id)sender;
- (IBAction)registerBtnClick:(id)sender;

@end
