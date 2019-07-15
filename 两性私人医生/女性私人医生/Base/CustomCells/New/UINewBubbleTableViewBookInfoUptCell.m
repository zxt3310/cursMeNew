//
//  UINewBubbleTableViewBookInfoUptCell.m
//  CureMe
//
//  Created by Tim on 12-11-7.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NSBubbleData.h"
#import "UINewBubbleTableViewBookInfoUptCell.h"

@implementation UINewBubbleTableViewBookInfoUptCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        self.userInteractionEnabled = YES;
        
        background = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].chatNotifyBubbleImage];
        [background setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:background];
        
        // 消息时间Label
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 20)];
        [headerLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [headerLabel setTextColor:[UIColor darkGrayColor]];
        [headerLabel setTextAlignment:UITextAlignmentCenter];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setHidden:YES];
        [self.contentView addSubview:headerLabel];

        dscpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [dscpLabel setFont:[UIFont systemFontOfSize:12]];
        [dscpLabel setBackgroundColor:[UIColor clearColor]];
        [dscpLabel setTextColor:[UIColor whiteColor]];
        [dscpLabel setShadowColor:[UIColor darkGrayColor]];
        [dscpLabel setShadowOffset:CGSizeMake(1, 1)];
        [dscpLabel setTextAlignment:UITextAlignmentCenter];
        [dscpLabel setNumberOfLines:2];
        [dscpLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.contentView addSubview:dscpLabel];
        
        updateBookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        updateBookBtn.userInteractionEnabled = NO;
        [updateBookBtn setImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
//        [updateBookBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
//        [updateBookBtn setBackgroundImage:[UIImage imageNamed:@"an_tongyong.png"] forState:UIControlStateNormal];
//        [updateBookBtn setBackgroundImage:[UIImage imageNamed:@"an_down_tongyong.png"] forState:UIControlStateHighlighted];
//        [updateBookBtn setBackgroundImage:[UIImage imageNamed:@"an_down_tongyong.png"] forState:UIControlStateSelected];
//        [updateBookBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateNormal];
//        [updateBookBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateNormal];
//        [updateBookBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateNormal];
//        [updateBookBtn setTitle:@"查看我的预约" forState:UIControlStateNormal];
//        [updateBookBtn setTitle:@"查看我的预约" forState:UIControlStateSelected];
//        [updateBookBtn setTitle:@"查看我的预约" forState:UIControlStateHighlighted];
//        [updateBookBtn addTarget:self action:@selector(viewMyBookInfo:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:updateBookBtn];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDataInternal:(NSBubbleDataInternal *)dataInternal
{
    _dataInternal = dataInternal;
}

- (void)setBubbleViewController:(CMNewQueryViewController *)bubbleViewController
{
    _bubbleViewController = bubbleViewController;
    
    [self generateLayout];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self showBookDetailPage];
}

- (void)generateLayout
{
    float inset = 4.0;
    
    float timeHeight = 0;
    
    if (_dataInternal.header) {
        headerLabel.text = _dataInternal.header;
        headerLabel.hidden = NO;
        timeHeight = 30;
    }
    else {
        headerLabel.hidden = YES;
    }
    
    background.frame = CGRectMake(80, timeHeight, 160, 40);
    
    dscpLabel.frame = CGRectMake(80 + inset * 2, timeHeight + 3, 120, 31);

    if (_dataInternal.data.talkerID != [CureMeUtils defaultCureMeUtil].userID) {
        [updateBookBtn setHidden:YES];
        dscpLabel.text = @"这是一条用户与医院的预约信息，由于隐私限制，您将不能查看详情。";
        return;
    }

    dscpLabel.text = @"您的预约单已经有了更新，请点击查看详情。";
    
    updateBookBtn.frame = CGRectMake(80 + 140, timeHeight + inset, 17, 30);
    [updateBookBtn setHidden:NO];
}

- (void)showBookDetailPage
{
    if (!_bubbleViewController) {
        return;
    }
    
    if (_dataInternal.data.talkerID != [CureMeUtils defaultCureMeUtil].userID) {
        return;
    }
    
    // 查看我的预约
    [_bubbleViewController showBookingPage];
}

@end
