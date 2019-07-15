//
//  UIComboBox.h
//  取样助手
//
//  Created by Zxt3310 on 2016/12/13.
//  Copyright © 2016年 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIComboBox : UIControl <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) NSArray *comboList;
@property (nonatomic) UIColor *layerColor;
@property (nonatomic) UIColor *comborColor;
@property (nonatomic) UIFont *textFont;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *placeColor;
@property (readonly) NSString *selectString;
@property (nonatomic) NSInteger selectId;
@property NSString *introductStr;

- (void)resetCombo;

- (void)dismissTable;

@end

@protocol UIComboBoxDelegate <NSObject>

@optional

- (void)UIComboBox:(UIComboBox *)comboBox didSelectRow:(NSIndexPath *) indexPath;

@end

@interface UIComboBox ()

@property id<UIComboBoxDelegate> delegate;

@end
