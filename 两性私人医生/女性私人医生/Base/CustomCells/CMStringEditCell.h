//
//  CMPerCenterEditCell.h
//  私密健康医生
//
//  Created by Tim on 13-1-16.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>


enum EditCellType {
    EDITCELL_NAME = 0,
    EDITCELL_AGE = 1,
    EDITCELL_PHONE = 2,
    EDITCELL_REGION = 3
};

@class CMStringEditCell;

@protocol CMStringEditCellDelegate <NSObject>
@optional
- (void)tableViewCell:(CMStringEditCell *)cell didEndEditingWithString:(NSString *)value;
@end


@interface CMStringEditCell : UITableViewCell <UITextFieldDelegate>

{
	UITextField *textField;
    UILabel *variableLabel;
//    UIImageView *moreImageView;
    NSString *lastValue;
}

@property NSInteger editType;
@property (nonatomic, strong) NSString *stringValue;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) IBOutlet id<CMStringEditCellDelegate> delegate;

- (id)initWithEditType:(NSInteger)editType reuseIdentifier:(NSString *)reuseIdentifier;

@end
