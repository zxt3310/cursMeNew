//
//  CMDataPickEditCell.h
//  私密健康医生
//
//  Created by Tim on 13-1-18.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMDataPickEditCell : UITableViewCell <UIKeyInput, UIPopoverControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

{
    // 省份、直辖市
    NSMutableArray *regionArray;
    // 城市、区
    NSMutableArray *cityArray;
    // 选中的省份、直辖市
    NSDictionary *selectedRegion;
    // 选中的城市、区
    NSDictionary *selectedCity;
    
    UILabel *variableLabel;
    UILabel *valueLabel;
    
	// For iPad
	UIPopoverController *popoverController;
	UIToolbar *inputAccessoryView;
    
    NSInteger lastRegionID;
    NSInteger lastRegionIndex;
    NSInteger lastCityID;
    NSInteger lastCityIndex;
    NSString *lastCityName;
}

@property (nonatomic, strong) UIPickerView *picker;

- (void)setSecondColumn:(NSArray *)secondColumn;

@end
