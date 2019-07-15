//
//  CMMyChatListCell.h
//  私密健康医生
//
//  Created by Tim on 13-1-20.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "CMMyChatListViewController.h"
#define MYCHATLIST_CELL_MYWORDHEIGHT 52
#define MYCHATLIST_CELL_WORDHEIGHT 68
#define MYCHATLIST_CELL_INFOHEIGHT 35


@class CMMyChatListViewController;

#pragma mark 我的咨询，最后一句子View
@interface CMMyChatLastWordView : UIView

{
    UIImageView *background;

    // 医生头像
    UIImageView *headImage;
    UIImageView *headImageFrame;
    // 无医生回复时的默认头像
    UIImageView *myHeadImage;
    
    UIButton *unreadMsgCount;

    UILabel *doctorName;
    UILabel *doctorInfo;
    UILabel *lastWord;
}

@property (nonatomic, strong) CMMyChatListViewController *myChatListViewController;
@property (nonatomic, strong) MyChatInfoUnit *chatInfoUnit;
@end


#pragma mark 我的咨询，信息子View
@interface CMMyChatInfoView : UIView

{
    UIImageView *background;

    UILabel *lastMsgTime;
    UILabel *msgCount;
}

@property (nonatomic, strong) UIButton *markBtn;
@property (nonatomic, strong) CMMyChatListViewController *myChatListViewController;
@property (nonatomic, strong) MyChatInfoUnit *chatInfoUnit;

- (IBAction)markBtnClicked:(id)sender;

- (void)updatePointDisplay;

@end


#pragma mark 我的咨询Cell
@interface CMMyChatListCell : UITableViewCell

{
    CMMyChatLastWordView *lastWordView;
    CMMyChatInfoView *infoView;
}

@property (nonatomic, strong) CMMyChatListViewController *myChatListViewController;
@property (nonatomic, strong) MyChatInfoUnit *chatInfoUnit;
@property (nonatomic, strong) UILabel *lineLb;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) id chatListView;

@end
