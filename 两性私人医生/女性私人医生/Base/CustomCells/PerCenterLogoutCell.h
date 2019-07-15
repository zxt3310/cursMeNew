//
//  PerCenterLogoutCell.h
//  CureMe
//
//  Created by Tim on 12-9-21.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "PerCenterViewController.h"
#import <UIKit/UIKit.h>

@interface PerCenterLogoutCell : UITableViewCell

{
    UILabel *phoneNoLabel;
    UIButton *logoutBtn;
}

@property (nonatomic, strong) PerCenterViewController *viewController;

- (void)generateLayout;

- (void)clearDisplay;

- (IBAction)logoutBtnClick:(id)sender;

@end
