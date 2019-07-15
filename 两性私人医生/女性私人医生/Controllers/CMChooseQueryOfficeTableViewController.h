//
//  CMChooseQueryOfficeTableViewController.h
//  私密健康医生
//
//  Created by Tim on 13-9-25.
//  Copyright (c) 2013年 Tim. All rights reserved.
//


#import "CustomBaseViewController.h"
#import "CMPickerViewController.h"
//20140519 jongs 增加无地域选择下立即查询需要选择地域


@interface CMChooseQueryOfficeTableViewController : CustomBaseViewController <UITableViewDelegate, UITableViewDataSource, CMPickerDelegate>

{
    NSMutableDictionary *officeIndexDict;
    
    //jongs add 20140519
    // 选择省份的VC
    CMPickerViewController *pickerViewController;
}

@property (strong, nonatomic) IBOutlet UITableView *officeTableView;

- (void)popPickerView;

@end
