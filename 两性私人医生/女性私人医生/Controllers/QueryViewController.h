//
//  QueryViewController.h
//  CureMe
//
//  Created by Tim on 12-8-27.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBaseViewController.h"
#import "CMDatePickerViewController.h"
#import "CMPickerViewController.h"

/*
@interface UIScrollView (my)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end*/


@interface QueryViewController : CustomBaseViewController<CMDatePickerViewControllerDelegate, CMPickerDelegate>

{
    NSDate *pickedDate;
    
    NSMutableArray *officeList;
    
    // 选择日期的Modal View
    CMDatePickerViewController *datePickerViewController;
    
    // 选择科室的Modal View
    CMPickerViewController *officePickerViewController;
    
    // 预约医院的所属地区
    NSNumber *bookHospRegion;
}

@property NSInteger bookID;
@property (nonatomic, strong) BookDetail *bookDetail;
@property (nonatomic, strong) NSString *hospitalName;
@property NSInteger hospitalID;
@property NSInteger officeID;
@property NSInteger chatID;     // 如果是自己的聊天并且是新建预约则要告知服务端关联

@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic) IBOutlet UILabel *hospitalNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *officeLabel;
@property (strong, nonatomic) IBOutlet UILabel *pickDateLabel;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *ageField;
@property (strong, nonatomic) IBOutlet UITextField *telField;
@property (strong, nonatomic) IBOutlet UITextField *remarksField;
@property (strong, nonatomic) IBOutlet UIButton *bookBtn;
@property (strong, nonatomic) IBOutlet UIImageView *submitStateBgImageView;
@property (strong, nonatomic) IBOutlet UIImageView *passStateBgImageView;
@property (strong, nonatomic) IBOutlet UIImageView *selectOfficeBgImageView;
@property (strong, nonatomic) IBOutlet UIImageView *selectDateBgImageView;

- (IBAction)pickDateBtn:(id)sender;
- (IBAction)pickOfficeBtn:(id)sender;
- (IBAction)bookBtnClick:(id)sender;

- (void)ntfDatePicked:(NSNotification *)note;
- (void)ntfOfficePicked:(NSNotification *)note;

- (void)threadGetBookInfo;
- (void)mainThreadRefreshDisplay;

@end
