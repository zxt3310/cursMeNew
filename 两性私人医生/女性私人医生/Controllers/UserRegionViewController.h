//
//  UserRegionViewController.h
//  CureMe
//
//  Created by Tim on 12-9-20.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "CustomBaseViewController.h"
#import <UIKit/UIKit.h>

@interface UserRegionViewController : CustomBaseViewController <UIPickerViewDataSource, UIPickerViewDelegate>

{
    NSMutableArray *regionArray;
    NSInteger pickedIndex;
}

@property (strong, nonatomic) IBOutlet UIPickerView *userRegionPicker;

- (void)threadInitCityList;

- (IBAction)pickRegionOK:(id)sender;

@end
