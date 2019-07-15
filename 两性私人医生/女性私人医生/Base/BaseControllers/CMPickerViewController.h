//
//  CMPickerViewController.h
//  私密健康医生
//
//  Created by Tim on 13-1-21.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBaseViewController.h"


enum {
    PICKER_COLUMN_ONE = 1,
    PICKER_COLUMN_TWO = 2,
    PICKER_COLUMN_THREE = 3
};

@interface DataPickUnit : NSObject

+ (id)UnitWithID:(NSInteger)ID andTitle:(NSString *)t andObject:(NSObject *)object;

- (id)initWithID:(NSInteger)ID andTitle:(NSString *)t andObject:(NSObject *)object;

@property NSInteger identifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSObject *unit;

@end



@protocol CMPickerDelegate <NSObject>

@required
- (void)didSelectOK:(NSDictionary *)firstUnit andSecondColumn:(NSDictionary *)secondUnit andThirdColumn:(NSDictionary *)thirdUnit;

@end



@interface CMPickerViewController : CustomBaseViewController <UIPickerViewDataSource, UIPickerViewDelegate>

{
    NSInteger selectedRow;
    
    NSDictionary *firstClmnSelectedData;
    NSInteger firstClmnSelectedIndex;
    NSDictionary *secondClmnSelectedData;
    NSInteger secondClmnSelectedIndex;
    NSDictionary *thirdClmnSelectedData;
    NSInteger thirdClmnSelectedIndex;
}

@property (nonatomic) NSInteger pickerColumnCount;

@property (nonatomic, readonly, strong) NSMutableArray *firstColumn;
@property (nonatomic, readonly, strong) NSMutableArray *secondColumn;
@property (nonatomic, readonly, strong) NSMutableArray *thirdColumn;

@property (nonatomic, strong) NSString *pickerTitle;
@property (nonatomic, retain) id<CMPickerDelegate> pickerDelegate;
@property (strong, nonatomic) IBOutlet UIPickerView *dataPicker;
@property (strong, nonatomic) IBOutlet UILabel *dataPickerTitle;
@property (strong, nonatomic) IBOutlet UIButton *okBtnClick;
@property (strong, nonatomic) IBOutlet UIImageView *background;


- (IBAction)onOkBtnClicked:(id)sender;

- (void)setFirstColumnData:(NSArray *)firstColumn;
- (void)setSecondColumnData:(NSArray *)secondColumn;
- (void)setSelectedIDAtFirstColumn:(NSInteger)firstID andSecondColumn:(NSInteger)secondID andThirdColumn:(NSInteger)thirdID;

@end
