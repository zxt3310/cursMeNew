//
//  CMQAViewController.h
//  私密健康医生
//
//  Created by Tim on 13-1-10.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMQATableView.h"
#import "LeveyPopListView.h"
#import "EGORefreshTableHeaderView.h"
#import "CustomBaseViewController.h"
#import "CMQAOfficeSubTypeView.h"
#import "CMAlertViewController.h"
#import "CMPickerViewController.h"
#import "CMQAProtocolView.h"

// 咨询列表页面，标题View
@class CMQAViewControllerTitleView;
@class CMQAOfficeSubTypeView;
// 发起咨询时显示的子分类View
@class CMQAQueryOfficeSubTypeView;

@interface CMQAViewController : CustomBaseViewController<ImageDownloadHelperDelegate, CMPickerDelegate, LeveyPopListViewDelegate, CMAlertViewControllerDelegate, CMQAOfficeSubTypeViewDelegate,CMQuickAskLocationDeletage>

{
    ImageDownloadHelper *imageDownloadHelper;
    NSMutableDictionary *headImageDict;        // 咨询列表，医生头像图片
    CMQAViewControllerTitleView *titleView;
    
    bool hasShownLoginPage;     // 标记是否已经显示过登录页面
    
    NSInteger lastOfficeType;   // 记录页面上一次显示的主科室ID，用于和当前这一次的进行比较
    NSString *lastQueryString;  // 记录上一次咨询内容
    NSDate *lastQuestionTime;   // 列表中最早一条咨询的
    
    CMQAOfficeSubTypeView *querySubTypeView;
    
    CMAlertViewController *alertViewController;
    
    // 显示咨询View时，保存Nav元素
    UIBarButtonItem *rightBarItem;
    // 显示咨询View时，显示“确定咨询”按钮
    UIBarButtonItem *confirmRightBarItem;

    //jongs add 20140519
    // 选择省份的VC
    CMPickerViewController *pickerViewController;
}

// 本次获取页的咨询总数
@property NSInteger curPageQueryCount;

@property bool isMainTabQAPage;
// 咨询列表
@property (strong, nonatomic) IBOutlet CMQATableView *qaTable;
// “立即咨询”按钮View
@property (strong, nonatomic) IBOutlet UIView *startQueryView;


@property (nonatomic, strong) LeveyPopListView *leveyPopListView;
@property NSInteger officeType;         // 当前列表里的主分类
@property NSInteger officeSubType;      // 当前列表显示内容的子分类
@property NSInteger queryOfficeSubType; // 咨询时选择的子分类
@property NSInteger userID;
//@property NSInteger pageNo;             // 当前咨询列表内容的页数

- (IBAction)sendQueryBtnClicked:(id)sender;
- (IBAction)startQueryBtnClicked:(id)sender;

// 初始化咨询时Bar右侧确认按钮
- (void)initQueryRightBarItem;

- (void)ntfUnreadMsgCountUpdated:(NSNotification *)note;

// 显示医生信息页面
- (void)showDoctorInfoPage:(NSInteger)doctorID;
// 显示对话页面
- (void)showDialogPage:(NSInteger)talkerID andReply:(Answer *)answer andSourceType:(NSString *)sourceType;
- (void)showAllOfficeTypeView;
// 移除主分类TableLise
- (void)dismissLeveyPopListView;
// 键盘显示、隐藏时，要做的事情
- (void)moveInputBarWithKeyboardHeight:(float)height withDuration:(NSTimeInterval)duration;

- (void)threadInitQAData;

- (void)startImageDownloader;
// CMQAViewController只保存中等尺寸头像图片
- (UIImage *)getHeadImage:(NSString *)imageKey;

- (void)refreshData;
- (void)appendData;

- (void)mainThreadRefreshData:(NSDictionary *)data;
- (void)mainThreadRefreshTableView;

- (void)popPickerView;

@end
