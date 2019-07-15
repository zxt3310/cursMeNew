//
//  UIBubbleTableView.h
//
//  Created by Alex Barinov
//  StexGroup, LLC
//  http://www.stexgroup.com
//
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <UIKit/UIKit.h>

#import "UIBubbleTableViewDataSource.h"
#import "UIBubbleTableViewCell.h"
#import "UIBubbleTableViewBookInfoCell.h"
#import "CMMyBookListCell.h"
#import "UIBubbleTableViewBookInfoUptCell.h"
#import "UIBubbleTableViewTelephoneCell.h"
#import "UIBubbleTableViewMapInfoCell.h"
#import "UIBubbleTableViewTextRemindCell.h"
#import "ChatHospitalInfoCell.h"
#import "CMChatHeaderBtnView.h"     // 聊天窗口顶部的信息缩略显示


#define CHATINFOCELL_MIN_HEIGHT 95

enum MoreHistoryLayoutType {
    MOREHISTORY_LAYOUT_DOCTOR = 0,
    MOREHISTORY_LAYOUT_QUERY
    };

@class BubbleViewController;

@interface UIBubbleTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

{
    IBOutlet UIBubbleTableViewCell *bubbleCell;
    CMChatHeaderBtnView *headBtnView;
    
    CGFloat lastYOffset;          // ScrollView上一次Offset
    CGFloat totalYOffset;         // 记录正向移动距离，大于CHATINFOCELL_MIN_HEIGHT时显示缩略信息，负向移动最小为0
}

// 更多历史消息按钮cell的展现位置，如果医生聊天则在最上。如果咨询聊天则在reply之后
@property (nonatomic) NSString *metaDataDoctorHeadImageKey;
@property bool hasLoadHistoryComplete;
@property NSInteger moreHistoryLayoutType;
@property (nonatomic, strong) BubbleViewController *chatViewController;
@property (nonatomic, assign) id<UIBubbleTableViewDataSource> bubbleDataSource;
@property (nonatomic) NSTimeInterval snapInterval;

// 通知缩略信息View更新头像
- (void)updateHeadBtnViewHeadImage;

@end
