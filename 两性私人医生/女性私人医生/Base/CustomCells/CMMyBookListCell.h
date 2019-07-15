//
//  CMMyBookListCell.h
//  私密健康医生
//
//  Created by Tim on 13-1-19.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>


#define BOOKLISTCELL_TITLEHEIGHT 50
#define BOOKLISTCELL_INFOHEIGHT 40
#define BOOKLISTCELL_REPLYHEIGHT 60


@class MyBookListViewController;
@class BubbleViewController;

#pragma mark 预约列表Cell，标题子View
@interface BookCellTitleView : UIView

{
    UIImageView *background;
    UIImageView *bookIcon;
    UILabel *title;
    UILabel *info;
    UILabel *status;
}

@property (nonatomic, strong) BookInfoUnit *bookInfo;

@end

#pragma mark 预约列表Cell，信息子View
@interface BookCellInfoView : UIView

{
    UIImageView *background;
    
    UILabel *hospitalLabel;
    UILabel *hospitalName;

    UILabel *officeLabel;
    UILabel *officeName;
    
    UILabel *dateLabel;
    UILabel *date;
    
    UILabel *memoLabel;
    UILabel *memory;
}

@property (nonatomic, strong) BookInfoUnit *bookInfo;
@property (nonatomic) bool hasDoctorReply;

- (void)initAdditionalLabels;

@end

#pragma mark 预约列表Cell，回复子View
@interface BookCellReplyView : UIView

{
    UIImageView *background;

    UIImageView *doctorHead;
    UIImageView *doctorHeadFrame;

//    UILabel *doctorName;
//    UILabel *doctorInfo;
    
    UILabel *doctorReply;
}

@property (nonatomic, strong) MyBookListViewController *myBookListViewController;
@property (nonatomic, strong) BookInfoUnit *bookInfo;

@end


#pragma mark MyBookListCell

enum {
    MYBOOKCELL_TYPE_LIST = 0,
    MYBOOKCELL_TYPE_CHAT
};

@interface CMMyBookListCell : UITableViewCell

{
    
}

@property NSInteger bookCellType;
@property (nonatomic, strong) MyBookListViewController *myBookListViewController;
@property (nonatomic, strong) BubbleViewController *chatViewController;
@property (nonatomic, strong) BookInfoUnit *bookInfoUnit;

@property (nonatomic, readonly, strong) BookCellTitleView *titleSubView;
@property (nonatomic, readonly, strong) BookCellInfoView *infoSubView;
@property (nonatomic, readonly, strong) BookCellReplyView *replySubView;

@end
