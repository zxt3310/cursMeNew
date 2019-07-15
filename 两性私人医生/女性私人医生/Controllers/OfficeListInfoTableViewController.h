//
//  OfficeListInfoTableViewController.h
//  CureMe
//
//  Created by Tim on 12-9-6.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "CustomTableBaseViewController.h"
#import <UIKit/UIKit.h>

@interface OfficeListInfoTableViewController : CustomTableBaseViewController

{
    NSMutableArray *officeArray;
}

@property NSInteger hospitalID;

- (void)refreshTable;

- (void)threadInitOfficeInfo;

@end
