//
//  CMMyBookListCell.m
//  私密健康医生
//
//  Created by Tim on 13-1-19.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CMMyBookListCell.h"
#import "MyBookListViewController.h"
#import "BubbleViewController.h"


#pragma mark 预约列表Cell，标题子View
@implementation BookCellTitleView

- (id)init
{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self initializatoin];
    }
    
    return self;
}

- (void)initializatoin
{
    float inset= 5.0;
    
    background = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].qaCellQuestionBgImage];
    background.frame = CGRectMake(0, 3, 320, BOOKLISTCELL_TITLEHEIGHT - 3);
    [background setBackgroundColor:[UIColor clearColor]];
    [self addSubview:background];
    
    bookIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"我的预约.png"]];
    bookIcon.frame = CGRectMake(16, inset + 3, 35, 30);
    [bookIcon setBackgroundColor:[UIColor clearColor]];
    [self addSubview:bookIcon];
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(75, inset + 3, 100, 18)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setFont:[UIFont systemFontOfSize:15]];
    [self addSubview:title];
    
    status = [[UILabel alloc] initWithFrame:CGRectMake(190, inset + 3, 120, 15)];
    [status setTextColor:[UIColor lightGrayColor]];
    [status setFont:[UIFont systemFontOfSize:12]];
    [status setTextAlignment:NSTextAlignmentCenter];
    [status setBackgroundColor:[UIColor clearColor]];
    [self addSubview:status];
    
    info = [[UILabel alloc] initWithFrame:CGRectMake(75, 30, 225, 15)];
    [info setTextColor:[UIColor lightGrayColor]];
    [info setFont:[UIFont systemFontOfSize:12]];
    [info setBackgroundColor:[UIColor clearColor]];
    [self addSubview:info];
}

- (void)setBookInfo:(BookInfoUnit *)bookInfo
{
    _bookInfo = bookInfo;
    
    if (!_bookInfo) {
        return;
    }
    
    title.text = [NSString stringWithFormat:@"%@的预约", _bookInfo.userName];
    info.text = [NSString stringWithFormat:@"预约时间：%@", [[CureMeUtils defaultCureMeUtil].shortDateFormatter stringFromDate:_bookInfo.bookDate]];
    
    // 更新预约状态Label
    bool hasExceed = dateHasExcedded(_bookInfo.bookDate, [NSDate date]);
    if (hasExceed) {
        status.text = @"预约已过期";
        [status setTextColor:[UIColor grayColor]];
    }
    else if (_bookInfo.bookNumber && _bookInfo.bookNumber.length > 0) {
        status.text = [NSString stringWithFormat:@"预约号：%@", _bookInfo.bookNumber];
        [status setTextColor:[UIColor greenColor]];
    }
    else {
        status.text = @"预约中";
        [status setTextColor:[UIColor grayColor]];
    }
}

@end


#pragma mark 预约列表Cell，信息子View
@implementation BookCellInfoView

- (id)init
{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self initialization];
    }
    
    return self;
}

- (void)initialization
{
    float inset = 5.0;
    
    background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, BOOKLISTCELL_INFOHEIGHT - 1)];
    [background setBackgroundColor:[UIColor clearColor]];
    [self addSubview:background];
    
    hospitalLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, inset, 60, 15)];
    [hospitalLabel setFont:[UIFont systemFontOfSize:13]];
    hospitalLabel.text = @"预约医院";
    [hospitalLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:hospitalLabel];
    
    hospitalName = [[UILabel alloc] initWithFrame:CGRectMake(75, inset, 205, 15)];
    [hospitalName setBackgroundColor:[UIColor clearColor]];
    [hospitalName setFont:[UIFont systemFontOfSize:13]];
    [hospitalName setTextColor:[UIColor lightGrayColor]];
    [self addSubview:hospitalName];
    
    officeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 60, 15)];
    [officeLabel setBackgroundColor:[UIColor clearColor]];
    officeLabel.text = @"预约科室";
    [officeLabel setFont:[UIFont systemFontOfSize:13]];
    [self addSubview:officeLabel];
    
    officeName = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, 205, 15)];
    [officeName setBackgroundColor:[UIColor clearColor]];
    [officeName setFont:[UIFont systemFontOfSize:13]];
    [officeName setTextColor:[UIColor lightGrayColor]];
    [self addSubview:officeName];
}

- (void)setHasDoctorReply:(bool)hasDoctorReply
{
    _hasDoctorReply = hasDoctorReply;
    
    if (_hasDoctorReply) {
        background.image = [CMImageUtils defaultImageUtil].qaCellAnswerMidImage;
        background.frame = CGRectMake(0, 0, 320, BOOKLISTCELL_INFOHEIGHT);
    }
    else {
        background.image = [CMImageUtils defaultImageUtil].qaCellAnswerTailImage;
        background.frame = CGRectMake(0, 0, 320, BOOKLISTCELL_INFOHEIGHT - 3);
    }
}

- (void)setBookInfo:(BookInfoUnit *)bookInfo
{
    _bookInfo = bookInfo;
    
    if (!_bookInfo) {
        return;
    }
    
    hospitalName.text = _bookInfo.hospitalName;
    officeName.text = _bookInfo.officeName;
    
    background.image = [CMImageUtils defaultImageUtil].qaCellAnswerMidImage;
//    if (_bookInfo.bookNumber && _bookInfo.bookNumber.length > 0) {
//        background.image = [CMImageUtils defaultImageUtil].qaCellAnswerMidImage;
//    }
//    else {
//        background.image = [CMImageUtils defaultImageUtil].qaCellAnswerTailImage;
//    }
}

- (void)initAdditionalLabels
{
//    if (!dateLabel) {
//        dateLabel = [UILabel alloc] initWithFrame:CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
//    }
}

@end


#pragma mark 预约列表Cell，回复子View
@implementation BookCellReplyView

- (id)init
{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self initialization];
    }
    
    return self;
}

- (void)initialization
{
    float inset = 5.0;
    
    background = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].qaCellAnswerTailImage];
    background.frame = CGRectMake(0, 0, 320, BOOKLISTCELL_REPLYHEIGHT - 3);
    [background setBackgroundColor:[UIColor clearColor]];
    [self addSubview:background];
    
    doctorHead = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].doctorDefaultHeadMImage];
    doctorHead.frame = CGRectMake(5, 4.5, 35, 35);
    [doctorHead.layer setCornerRadius:3.0];
    [doctorHead setClipsToBounds:YES];
    [doctorHead setBackgroundColor:[UIColor clearColor]];
    
    doctorHeadFrame = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].doctorDefaultBGMImage];
    doctorHeadFrame.frame = CGRectMake(13, inset, 45, 48);
    [doctorHeadFrame setBackgroundColor:[UIColor clearColor]];
    [doctorHeadFrame addSubview:doctorHead];
    doctorHeadFrame.autoresizesSubviews = YES;
    [self addSubview:doctorHeadFrame];
    
//    doctorName = [[UILabel alloc] initWithFrame:CGRectMake(65, inset, 60, 15)];
//    [doctorName setFont:[UIFont systemFontOfSize:15]];
//    [doctorName setBackgroundColor:[UIColor clearColor]];
//    [doctorName setTextColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0]];
//    [self addSubview:doctorName];
//    
//    doctorInfo = [[UILabel alloc] initWithFrame:CGRectMake(130, inset, 180, 15)];
//    [doctorInfo setBackgroundColor:[UIColor clearColor]];
//    [doctorInfo setFont:[UIFont systemFontOfSize:12]];
//    [self addSubview:doctorInfo];
    
    doctorReply = [[UILabel alloc] initWithFrame:CGRectMake(75, inset, 225, 40)];
    [doctorReply setFont:[UIFont systemFontOfSize:14]];
    [doctorReply setBackgroundColor:[UIColor clearColor]];
    [doctorReply setNumberOfLines:2];
    [doctorReply setLineBreakMode:NSLineBreakByTruncatingTail];
    [self addSubview:doctorReply];
}

- (void)setBookInfo:(BookInfoUnit *)bookInfo
{
    _bookInfo = bookInfo;
    
    if (!_bookInfo) {
        return;
    }
    
//    doctorName.text = _bookInfo.doctorName;
//    doctorInfo.text = _bookInfo.doctorInfo;
    doctorReply.text = _bookInfo.doctorReply;
    if (!doctorReply.text || doctorReply.text.length <= 0) {
        doctorReply.text = @"您的预约暂时没有医生回复，请留意我们的新消息通知，谢谢。";
    }

    // 获得医生头像图片
    UIImage *image = [_myBookListViewController hospitalImageWithKey:_bookInfo.doctorImageKey andSize:@"90"];
    if (image) {
        doctorHead.image = image;
    }
    
//    CGRect frame = doctorHeadFrame.frame;
//    frame.size.width -= 5;
//    frame.size.height -= 5;
//    doctorHeadFrame.frame = frame;
}

@end


#pragma mark CMMyBookListCell
@implementation CMMyBookListCell

@synthesize titleSubView = _titleSubView;
@synthesize infoSubView = _infoSubView;
@synthesize replySubView = _replySubView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        _bookCellType = MYBOOKCELL_TYPE_LIST;
        
        // Initialization code
        _titleSubView = [[BookCellTitleView alloc] initWithFrame:CGRectMake(0, 0, 320, BOOKLISTCELL_TITLEHEIGHT)];
        [self.contentView addSubview:_titleSubView];
        
        _infoSubView = [[BookCellInfoView alloc] initWithFrame:CGRectMake(0, BOOKLISTCELL_TITLEHEIGHT, 320, BOOKLISTCELL_INFOHEIGHT)];
        [self.contentView addSubview:_infoSubView];
        
        _replySubView = [[BookCellReplyView alloc] initWithFrame:CGRectMake(0, BOOKLISTCELL_TITLEHEIGHT + BOOKLISTCELL_INFOHEIGHT, 320, BOOKLISTCELL_REPLYHEIGHT)];
        [self.contentView addSubview:_replySubView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMyBookListViewController:(MyBookListViewController *)myBookListViewController
{
    _myBookListViewController = myBookListViewController;
    
    [_replySubView setMyBookListViewController:_myBookListViewController];
}

- (void)setChatViewController:(BubbleViewController *)chatViewController
{
    _chatViewController = chatViewController;
    self.userInteractionEnabled = YES;
}

- (void)setBookInfoUnit:(BookInfoUnit *)bookInfoUnit
{
    _bookInfoUnit = bookInfoUnit;

    [_titleSubView setBookInfo:_bookInfoUnit];
    [_infoSubView setBookInfo:_bookInfoUnit];
    [_replySubView setBookInfo:_bookInfoUnit];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_chatViewController || ![_chatViewController respondsToSelector:@selector(showBookingPage)]) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    
    [_chatViewController showBookingPage];
}

@end
