//
//  CMMainPageViewController.h
//  私密健康医生
//
//  Created by Tim on 13-1-9.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPickerViewController.h"
#import "CustomBaseViewController.h"
#import "CMAlertViewController.h"
#import <WebKit/WebKit.h>
#import "CMH5NewsWebViewController.h"
#import "CMMainTabViewController.h"
/**
 *  @author Zxt, 17-04-11 14:04:21
 *
 *  医爱淘 新增快速问诊
 */
#import "CMQuickAskChoosenViewController.h"


@interface CMMainPageViewController : CustomBaseViewController <CMPickerDelegate,UIScrollViewDelegate,UIWebViewDelegate,UITextFieldDelegate,chooseLocationDelegate,WKUIDelegate,WKNavigationDelegate,CMQuickAskLocationDeletage>

{
    // 选择省份的VC
    CMPickerViewController *pickerViewController;
    // 选中的区域与城市信息
    NSString *regionTitle;
    NSNumber *regionID;
    NSString *cityTitle;
    NSNumber *cityID;
    
    CMAlertViewController *alertViewController;
}

@property (strong, nonatomic) IBOutlet UIView *homeTopView;
@property (strong, nonatomic) IBOutlet UILabel *regionLabel;
@property (strong, nonatomic) IBOutlet UIButton *changeLocationBtn;
@property (strong, nonatomic) IBOutlet UIButton *locateBtn;
@property (strong, nonatomic) IBOutlet UIImageView *readdImg;

@property (strong, nonatomic) IBOutlet UIScrollView *entranceScrollView;

- (IBAction)meirongBtnClick:(id)sender;
- (IBAction)fukeBtnClick:(id)sender;
- (IBAction)chankeBtnClick:(id)sender;
- (IBAction)pifukeBtnCick:(id)sender;
- (IBAction)zhongyiBtnClick:(id)sender;
- (IBAction)yankeBtnClick:(id)sender;
- (IBAction)corpHospBtnClick:(id)sender;
- (IBAction)activityBtnClick:(id)sender;
- (IBAction)jiakangBtnClick:(id)sender;
- (IBAction)ganbingBtnClick:(id)sender;
- (IBAction)naotanBtnBlick:(id)sender;
- (IBAction)gukeBtnClick:(id)sender;
- (IBAction)dianxianBtnBlick:(id)sender;
- (IBAction)gangchangBtnClick:(id)sender;
// 2014-10-13新增七科室
- (IBAction)bybyBtnClick:(id)sender;
- (IBAction)xinzangBtnClick:(id)sender;
- (IBAction)shenjingBtnClick:(id)sender;
- (IBAction)erbihouBtnClick:(id)sender;
- (IBAction)weichangBtnClick:(id)sender;
- (IBAction)tangniaobingBtnClick:(id)sender;
- (IBAction)zhongliuBtnClick:(id)sender;

- (IBAction)locateBtnClick:(id)sender;
- (IBAction)changeLocationBtnClick:(id)sender;

- (void)ntfNetworkNotReachable:(NSNotification *)note;
- (void)ntfLocationSucceess:(NSNotification *)note;
- (void)ntfLocationFailed:(NSNotification *)note;
- (void)ntfUnreadMsgCountUpdated:(NSNotification *)note;

- (void)threadFirstUseOperation;

- (void)updateRegionDisplay;

@end
