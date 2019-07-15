//
//  CMMyChatListViewController.h
//  私密健康医生
//
//  Created by Tim on 13-1-20.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBaseViewController.h"
#import "CMMarkDoctorViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "CMMyChatListCell.h"
//#import <StoreKit/StoreKit.h>


@class CMAlertViewController;
@class CMMyChatInfoView;
@class LoadingView;
@class NoDataBackgroundView;

/**
 *  @author Zxt, 17-04-01 17:04:28
 *
 *  点击删除 cell刷新协议
 */
@protocol deleteChatCellDelegate <NSObject>

- (void)deleteChat:(UITableViewCell *)cell;
@end

@interface CMMyChatListViewController : CustomBaseViewController<UITableViewDelegate, UITableViewDataSource, ImageDownloadHelperDelegate, CMMarkDoctorViewControllerDelegate,UIAlertViewDelegate, EGORefreshTableHeaderDelegate>

{
    // Drag refresh datas
    EGORefreshTableHeaderView *_refreshHeaderView;

    NSMutableArray *chatInfoArray;
    NSMutableDictionary *doctorHeadImages;
    
    ImageDownloadHelper *imageDownloader;
    
    bool hasShownLoginViewController;
    NSInteger lastLoginUserID;       // 保存上次登录的用户ID

    // 消息提示Alert ViewController
    CMAlertViewController *alertViewController;
    // 为对话打分的Alert View Controller
    CMMarkDoctorViewController *markDoctorViewController;

    // 打开评分的Cell指针
    CMMyChatInfoView *markInfoView;
    // 打开评分的对话Data
    MyChatInfoUnit *markChatInfoUnit;
    
    // 正在载入中的提示View
    LoadingView *loadingView;
    
    // 标记我的对话列表页面是否正在加载数据中
    bool isLoadingDataInBackground;
    
    BOOL _reloading;
}

@property bool isMainTabController;
@property (strong, nonatomic) IBOutlet UITableView *listTableView;
@property (nonatomic, strong) NoDataBackgroundView *noDataBgView;
//@property (nonatomic, strong) id<deleteChatCellDelegate> deleteDelegate;
- (void)ntfUpdateUnreadMsgCount:(NSNotification *)note;

- (void)threadInitMyChatListData;
- (UIImage *)getDoctorHeadImage:(NSString *)imageKey;

- (void)showMarkDialog:(MyChatInfoUnit *)chatInfoUnit andInfoView:(CMMyChatInfoView *)infoView;

- (void)deleteChatCell:(CMMyChatListCell *)cell;
@end

UIImage* buttonImageFromColor(UIColor *color);
