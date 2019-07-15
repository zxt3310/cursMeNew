//
//  CMPerCenterHeaderCell.h
//  我的私人医生
//
//  Created by Tim on 13-8-21.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PerCenterViewController.h"


@interface CMPerCenterHeaderCell : UITableViewCell

@property id <personHeaderClickDelegate> personalDelegate;
- (IBAction)myBookBtnClick:(id)sender;
- (IBAction)myChatBtnClick:(id)sender;
- (IBAction)appBtnClick:(id)sender;

@property (nonatomic, strong) PerCenterViewController *perCenterViewController;

@end
