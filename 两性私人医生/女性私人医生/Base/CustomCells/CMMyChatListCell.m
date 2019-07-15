//
//  CMMyChatListCell.m
//  私密健康医生
//
//  Created by Tim on 13-1-20.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CMMyChatListCell.h"
#import "CMMyChatListViewController.h"



#pragma mark CMMyChatLastWordView
@implementation CMMyChatLastWordView

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
    
    background = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].qaCellQuestionBgImage];
    background.frame = CGRectMake(0, 3, SCREEN_WIDTH, MYCHATLIST_CELL_WORDHEIGHT - 3);
    [background setBackgroundColor:[UIColor clearColor]];
    [self addSubview:background];
    
    headImage = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].doctorDefaultHeadMImage];
    headImage.frame = CGRectMake(5, 4.5, 41, 41);
    [headImage.layer setCornerRadius:20.0];
    [headImage setClipsToBounds:YES];
    [headImage setBackgroundColor:[UIColor clearColor]];
    
    headImageFrame = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].doctorDefaultBGMImage];
    headImageFrame.frame = CGRectMake(12, inset * 2, 51, 54);
    headImageFrame.image = nil;
    [headImageFrame setBackgroundColor:[UIColor clearColor]];
    [headImageFrame addSubview:headImage];
    [self addSubview:headImageFrame];

    // 无医生回复时的默认图片
    myHeadImage = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].qaListQuestionImage];
    myHeadImage.frame = CGRectMake(19, inset * 3, 38, 38);
    [myHeadImage setBackgroundColor:[UIColor clearColor]];
    myHeadImage.hidden = YES;
    [self addSubview:myHeadImage];
    
    doctorName = [[UILabel alloc] initWithFrame:CGRectMake(70, inset * 2 + 2, 80, 17)];
    [doctorName setFont:[UIFont systemFontOfSize:15]];
    [doctorName setBackgroundColor:[UIColor clearColor]];
    [doctorName setBackgroundColor:[UIColor clearColor]];
    [doctorName setTextColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0]];
    [self addSubview:doctorName];
    
    doctorInfo = [[UILabel alloc] initWithFrame:CGRectMake(164 *SCREEN_WIDTH / 320, inset * 2 + 4, 185 *SCREEN_WIDTH/320, 15)];
    [doctorInfo setBackgroundColor:[UIColor clearColor]];
    [doctorInfo setTextColor:[UIColor lightGrayColor]];
    [doctorInfo setFont:[UIFont systemFontOfSize:13]];
    [self addSubview:doctorInfo];
    
    lastWord = [[UILabel alloc] initWithFrame:CGRectMake(70, 30, 240 * SCREEN_WIDTH/320, 40)];
    [lastWord setNumberOfLines:2];
    [lastWord setFont:[UIFont systemFontOfSize:14]];
    [lastWord setLineBreakMode:NSLineBreakByTruncatingTail];
//    lastWord.contentVerticalAlignment = UIControlContentVerticalAlignmentTop:
    [lastWord setBackgroundColor:[UIColor clearColor]];
    [self addSubview:lastWord];
}

- (void)setChatInfoUnit:(MyChatInfoUnit *)chatInfoUnit
{
    _chatInfoUnit = chatInfoUnit;
    if (!_chatInfoUnit) {
        return;
    }
    
    // 如果最后一句话是自己，并且只有一行，调小背景高度
    if ([_chatInfoUnit.lastMsgUserType isEqualToString:@"user"] && _chatInfoUnit.lastMsg.length < 16) {
        background.frame = CGRectMake(0, 3, 320, MYCHATLIST_CELL_MYWORDHEIGHT - 3);
    }
    else {
        background.frame = CGRectMake(0, 3, 320, MYCHATLIST_CELL_WORDHEIGHT - 3);
    }

    if (!_chatInfoUnit.doctorName || _chatInfoUnit.doctorName.length <= 0) {
        doctorName.hidden = YES;
        //doctorInfo.hidden = YES;
        //lastWord.frame = CGRectMake(70, 5 * 2 + 2, 240, 40);
    }
    else {
        doctorName.text = _chatInfoUnit.doctorName;
        doctorName.hidden = NO;
        doctorInfo.hidden = NO;
        lastWord.frame = CGRectMake(70, 30, 240 * SCREEN_WIDTH/320, 40);
    }

    if (_chatInfoUnit.doctorTitle || _chatInfoUnit.hospitalName) {
        if (!_chatInfoUnit.doctorName) {
            CGRect temp2 = doctorInfo.frame;
            temp2.origin.x = doctorName.frame.origin.x;
            temp2.origin.y = doctorName.frame.origin.y-2;
            doctorInfo.frame = temp2;
            doctorInfo.textColor = [UIColor blackColor];
            doctorInfo.font = [UIFont systemFontOfSize:15];
        }
        else{
            doctorInfo.frame = CGRectMake(124 *SCREEN_WIDTH/320, 14, 185, 15);
            doctorInfo.textColor = [UIColor lightGrayColor];
            doctorInfo.font = [UIFont systemFontOfSize:13];
        }
        doctorInfo.text = [NSString stringWithFormat:@"%@", /*_chatInfoUnit.doctorTitle,*/ _chatInfoUnit.hospitalName];
    }
    
    // 最后一句对话内容
    lastWord.text = _chatInfoUnit.lastMsg;
    CGSize wordSize = [lastWord.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(240, 40) lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect frame = lastWord.frame;
    frame.size.height = wordSize.height;
    lastWord.frame = frame;
    
    // 未读消息按钮的处理
    if (_chatInfoUnit.unreadCount <= 0) {
        if (unreadMsgCount) {
            [unreadMsgCount removeFromSuperview];
            unreadMsgCount = nil;
        }
    }
    else if (_chatInfoUnit.unreadCount > 0) {
        if (!unreadMsgCount) {
            unreadMsgCount = [UIButton buttonWithType:UIButtonTypeCustom];
            [unreadMsgCount setBackgroundImage:[UIImage imageNamed:@"no.png"] forState:UIControlStateNormal];
            [unreadMsgCount.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [unreadMsgCount setUserInteractionEnabled:NO];
            [unreadMsgCount setTitle:[NSString stringWithFormat:@"%ld", (long)_chatInfoUnit.unreadCount] forState:UIControlStateNormal];
            unreadMsgCount.frame = CGRectMake(50, 5.0, 23, 23);
            [self addSubview:unreadMsgCount];
        }
    }
}

- (void)setMyChatListViewController:(CMMyChatListViewController *)myChatListViewController
{
    _myChatListViewController = myChatListViewController;
    if (!_myChatListViewController) {
        return;
    }

    // 如果最后一句话是自己说的
    if ([_chatInfoUnit.lastMsgUserType isEqualToString:@"user"]) {
        myHeadImage.hidden = NO;
        headImageFrame.hidden = YES;
    }
    else if ([_chatInfoUnit.lastMsgUserType isEqualToString:@"doctor"]) {
        myHeadImage.hidden = YES;
        headImageFrame.hidden = NO;
        if (_chatInfoUnit.chatID > 0) {
            UIImage *image = [_myChatListViewController getDoctorHeadImage:_chatInfoUnit.doctorImageKey];
            if (image) {
                headImage.image = image;
            }
            else {
                headImage.image = [CMImageUtils defaultImageUtil].doctorDefaultHeadMImage;
            }
        }
    }
}

@end



#pragma mark CMMyChatInfoView
@implementation CMMyChatInfoView

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
    background = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].qaCellAnswerTailImage];
    background.frame = CGRectMake(0, 0, SCREEN_WIDTH, MYCHATLIST_CELL_INFOHEIGHT - 3);
    [self addSubview:background];
    
    lastMsgTime = [[UILabel alloc] initWithFrame:CGRectMake(70, 6, 150, 20)];
    [lastMsgTime setFont:[UIFont systemFontOfSize:13]];
    [lastMsgTime setBackgroundColor:[UIColor clearColor]];
    [lastMsgTime setTextColor:[UIColor lightGrayColor]];
    [self addSubview:lastMsgTime];
    
    msgCount = [[UILabel alloc] initWithFrame:CGRectMake(230 *SCREEN_WIDTH/320, 6, 80, 20)];
    [msgCount setTextAlignment:NSTextAlignmentCenter];
    [msgCount setFont:[UIFont systemFontOfSize:13]];
    [msgCount setTextColor:[UIColor grayColor]];
    [msgCount setBackgroundColor:[UIColor clearColor]];
    [self addSubview:msgCount];
    
//    _markBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _markBtn.frame = CGRectMake(16, 5, 44, 23);
//    [_markBtn setTitle:@"    评价" forState:UIControlStateNormal];
//    [_markBtn setTitle:@"    评价" forState:UIControlStateHighlighted];
//    [_markBtn setTitle:@"    评价" forState:UIControlStateSelected];
//    [_markBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
//    [_markBtn addTarget:self action:@selector(markBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_markBtn];
}

- (NSString *)stringWithMarkPoint:(NSInteger)point
{
    if (point == 1) {
        return [NSString stringWithFormat:@"    差评"];
    }
    else if (point == 6) {
        return [NSString stringWithFormat:@"    中评"];
    }
    else if (point == 10) {
        return [NSString stringWithFormat:@"    好评"];
    }
    
    return [NSString stringWithFormat:@"    评价"];
}

- (void)setChatInfoUnit:(MyChatInfoUnit *)chatInfoUnit
{
    _chatInfoUnit = chatInfoUnit;
    if (!_chatInfoUnit) {
        return;
    }
    
    lastMsgTime.text = [[CureMeUtils defaultCureMeUtil].dateFormatter stringFromDate:_chatInfoUnit.lastMsgTime];

    // 评价按钮背景
    // 还未创建对话时，不可评价。按钮背景白色，文字白色
    if (_chatInfoUnit.chatID == 0 || _chatInfoUnit.isSWT) {
        [_markBtn setTitle:@"    评价" forState:UIControlStateNormal];
        [_markBtn setTitle:@"    评价" forState:UIControlStateSelected];
        [_markBtn setTitle:@"    评价" forState:UIControlStateHighlighted];
        [_markBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_markBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_markBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateNormal];
        [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateHighlighted];
        [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateSelected];
        if (_chatInfoUnit.isSWT){
            [_markBtn setEnabled:NO];
        }
    }
    else {
        // 有对话，未评价时，背景绿色，文字白色
        if (_chatInfoUnit.markPoint <= 0) {
            [_markBtn setTitle:@"    评价" forState:UIControlStateNormal];
            [_markBtn setTitle:@"    评价" forState:UIControlStateSelected];
            [_markBtn setTitle:@"    评价" forState:UIControlStateHighlighted];
            [_markBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_markBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [_markBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasMarkedBtnImage forState:UIControlStateNormal];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasMarkedBtnImage forState:UIControlStateHighlighted];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasMarkedBtnImage forState:UIControlStateSelected];
        }
        // 已评价，背景白色，文字红色
        else {
            NSString *markTitle = [self stringWithMarkPoint:_chatInfoUnit.markPoint];
            [_markBtn setTitle:markTitle forState:UIControlStateNormal];
            [_markBtn setTitle:markTitle forState:UIControlStateHighlighted];
            [_markBtn setTitle:markTitle forState:UIControlStateSelected];
            
            [_markBtn setTitleColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_markBtn setTitleColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0] forState:UIControlStateHighlighted];
            [_markBtn setTitleColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0] forState:UIControlStateSelected];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateNormal];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateHighlighted];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateSelected];
        }
    }

    // 对话总数
    if (_chatInfoUnit.chatID <= 0 && !_chatInfoUnit.isSWT) {
        msgCount.text = @"暂无医生回复";
    }
    else {
        msgCount.text = [NSString stringWithFormat:@"共%ld条对话", (long)_chatInfoUnit.totalCount];
    }
}

- (IBAction)markBtnClicked:(id)sender
{
    if (_myChatListViewController) {
        [_myChatListViewController showMarkDialog:_chatInfoUnit andInfoView:self];
    }
}

- (void)updatePointDisplay
{
    switch (_chatInfoUnit.markPoint) {
        case 1:
            [_markBtn setTitle:@"    差评" forState:UIControlStateNormal];
            [_markBtn setTitleColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_markBtn setTitleColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0] forState:UIControlStateHighlighted];
            [_markBtn setTitleColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0] forState:UIControlStateSelected];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateNormal];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateHighlighted];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateSelected];
            break;
        case 6:
            [_markBtn setTitle:@"    中评" forState:UIControlStateNormal];
            [_markBtn setTitleColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_markBtn setTitleColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0] forState:UIControlStateHighlighted];
            [_markBtn setTitleColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0] forState:UIControlStateSelected];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateNormal];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateHighlighted];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateSelected];
            break;
        case 10:
            [_markBtn setTitle:@"    好评" forState:UIControlStateNormal];
            [_markBtn setTitleColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_markBtn setTitleColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0] forState:UIControlStateHighlighted];
            [_markBtn setTitleColor:[UIColor colorWithRed:200.0/255 green:62.0/255 blue:101.0/255 alpha:1.0] forState:UIControlStateSelected];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateNormal];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateHighlighted];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasNotMarkedBtnImage forState:UIControlStateSelected];
            break;
        default:
            [_markBtn setTitle:@"    评价" forState:UIControlStateNormal];
            [_markBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_markBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [_markBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasMarkedBtnImage forState:UIControlStateNormal];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasMarkedBtnImage forState:UIControlStateHighlighted];
            [_markBtn setBackgroundImage:[CMImageUtils defaultImageUtil].hasMarkedBtnImage forState:UIControlStateSelected];
            break;
    }
}

@end


#pragma mark MyChatList Cell
@implementation CMMyChatListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        lastWordView = [[CMMyChatLastWordView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, MYCHATLIST_CELL_WORDHEIGHT)];
        [self.contentView addSubview:lastWordView];
        
        infoView = [[CMMyChatInfoView alloc] initWithFrame:CGRectMake(0, MYCHATLIST_CELL_WORDHEIGHT, SCREEN_WIDTH, MYCHATLIST_CELL_INFOHEIGHT)];
        [self.contentView addSubview:infoView];
        
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[CMImageUtils defaultImageUtil].deleteChatBtnImage forState:UIControlStateNormal];
        _deleteBtn.frame = CGRectMake(SCREEN_WIDTH - 35, MYCHATLIST_CELL_WORDHEIGHT + MYCHATLIST_CELL_INFOHEIGHT + 1, 16, 16);
        [_deleteBtn addTarget:self action:@selector(deleteBtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteBtn];
        
        _lineLb = [[UILabel alloc] initWithFrame:CGRectMake(0, MYCHATLIST_CELL_WORDHEIGHT + MYCHATLIST_CELL_INFOHEIGHT + 18, SCREEN_WIDTH, 5)];
        _lineLb.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
        [self.contentView addSubview:_lineLb];
    }
    return self;
}

- (void)deleteBtonClick{
    CMMyChatListViewController *tempclvc = (CMMyChatListViewController *)self.chatListView;
    [tempclvc deleteChatCell:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setChatInfoUnit:(MyChatInfoUnit *)chatInfoUnit
{
    _chatInfoUnit = chatInfoUnit;
    
    CGRect wordViewFrame = lastWordView.frame;
    CGRect infoViewFrame = infoView.frame;
    // 如果最后一句话是自己，并且只有一行，调小高度
    if ([_chatInfoUnit.lastMsgUserType isEqualToString:@"user"] && _chatInfoUnit.lastMsg.length < 16) {
        wordViewFrame.size.height = MYCHATLIST_CELL_MYWORDHEIGHT;
        lastWordView.frame = wordViewFrame;
        
        infoViewFrame.origin.y = MYCHATLIST_CELL_MYWORDHEIGHT;
        infoView.frame = infoViewFrame;
    }
    else {
        wordViewFrame.size.height = MYCHATLIST_CELL_WORDHEIGHT;
        lastWordView.frame = wordViewFrame;
        
        infoViewFrame.origin.y = MYCHATLIST_CELL_WORDHEIGHT;
        infoView.frame = infoViewFrame;
    }

    [lastWordView setChatInfoUnit:_chatInfoUnit];
    [infoView setChatInfoUnit:_chatInfoUnit];
}

- (void)setMyChatListViewController:(CMMyChatListViewController *)myChatListViewController
{
    _myChatListViewController = myChatListViewController;
    
    [lastWordView setMyChatListViewController:_myChatListViewController];
    [infoView setMyChatListViewController:_myChatListViewController];
}

@end
