//
//  CMQueryViewController.h
//  私密健康医生
//
//  Created by Tim on 13-9-25.
//  Copyright (c) 2013年 Tim. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "CustomBaseViewController.h"
#import "CMQAOfficeSubTypeView.h"
#import "CMAlertViewController.h"


@interface CMQueryViewController : CustomBaseViewController<CMQAOfficeSubTypeViewDelegate, CMAlertViewControllerDelegate>

{
    CMQAOfficeSubTypeView *officeSubTypeView;
    CMAlertViewController *alertViewController;
}

@property (nonatomic) NSInteger officeType;
@property (nonatomic) NSInteger subOfficeType;
@property (strong, nonatomic) IBOutlet UIView *sendAreaView;
@property (strong, nonatomic) IBOutlet UITextField *inputField;
@property (strong, nonatomic) IBOutlet UIButton *sendAreaSendBtn;
@property (strong, nonatomic) IBOutlet UIButton *chooseBtn;
@property (strong, nonatomic) IBOutlet UILabel *protocolLabel;
@property (strong, nonatomic) IBOutlet UIButton *protocolBtn;
- (IBAction)sendBtnClicked:(id)sender;
- (IBAction)chooseBtnClicked:(id)sender;
- (IBAction)protocolBtnClicked:(id)sender;

- (void)initialization;

@end
