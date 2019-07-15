//
//  CMNewMyBookListCell.h
//  私密健康医生
//
//  Created by Tim on 13-1-19.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>


#define NBOOKLISTCELL_TITLEHEIGHT 50
#define NBOOKLISTCELL_INFOHEIGHT 40
#define NBOOKLISTCELL_REPLYHEIGHT 60


@class MyBookListViewController;
@class CMNewQueryViewController;

#pragma mark 预约列表Cell，标题子View
@interface NewBookCellTitleView : UIView

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
@interface NewBookCellInfoView : UIView

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
@interface NewBookCellReplyView : UIView

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


#pragma mark NewMyBookListCell

enum {
    NMYBOOKCELL_TYPE_LIST = 0,
    NMYBOOKCELL_TYPE_CHAT
};

@interface CMNewMyBookListCell : UITableViewCell

{
    
}

@property NSInteger bookCellType;
@property (nonatomic, strong) MyBookListViewController *myBookListViewController;
@property (nonatomic, strong) CMNewQueryViewController *chatViewController;
@property (nonatomic, strong) BookInfoUnit *bookInfoUnit;

@property (nonatomic, readonly, strong) NewBookCellTitleView *titleSubView;
@property (nonatomic, readonly, strong) NewBookCellInfoView *infoSubView;
@property (nonatomic, readonly, strong) NewBookCellReplyView *replySubView;

@end
