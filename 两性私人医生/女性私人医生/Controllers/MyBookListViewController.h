//
//  MyBookListViewController.h
//  CureMe
//
//  Created by Tim on 12-11-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

//#import "CustomTableBaseViewController.h"
#import "CustomBaseViewController.h"
#import "EGORefreshTableHeaderView.h"
#import <UIKit/UIKit.h>

@class LoadingView;
@class NoDataBackgroundView;

@interface MyBookListViewController : CustomBaseViewController<ImageDownloadHelperDelegate, UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate>

{
    // Drag refresh datas
    EGORefreshTableHeaderView *_refreshHeaderView;

    NSMutableArray *bookDataList;

    NSMutableDictionary *hospImages;
    ImageDownloadHelper *imageDownloadHelper;
    
    bool isLoadingDataInBackground; // 标记是否后台正在刷新数据
    bool hasShownLoginPage;         // 标记是否已经显示过登录页面
    NSInteger lastLoginUserID;      // 保存上次用户登录的userID
    
    // 正在载入中的提示View
    LoadingView *loadingView;
    BOOL _reloading;
}

@property NSInteger isMainTabPage;
@property (strong, nonatomic) IBOutlet UITableView *listTableView;
@property (nonatomic, strong) NoDataBackgroundView *noDataBgView;

- (UIImage *)hospitalImageWithKey:(NSString *)imageKey andSize:(NSString *)size;
- (void)threadInitBookListInfo;
- (void)mainThreadRefresh;

@end
