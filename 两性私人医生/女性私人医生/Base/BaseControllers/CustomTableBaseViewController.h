//
//  CustomTableBaseViewController.h
//  CureMe
//
//  Created by Tim on 12-8-27.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "CMCustomViews.h"


@interface CustomTableBaseViewController : UITableViewController <EGORefreshTableHeaderDelegate, UITextFieldDelegate>

{
    UIImage *navBarBgImage;

    // Drag refresh datas
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) NoDataBackgroundView *noDataBgView;
@property (nonatomic, strong) UIButton *unreadMsgBtn;

- (IBAction)back:(id)sender;
- (IBAction)openUnreadMsg:(id)sender;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
