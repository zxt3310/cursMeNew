//
//  CMChatHeaderBtnView.m
//  私密健康医生
//
//  Created by Tim on 13-1-16.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "UIBubbleTableView.h"
#import "CMChatHeaderBtnView.h"

@implementation CMChatHeaderBtnView

@synthesize backgroundImage = _backgroundImage;
@synthesize headImage = _headImage;
@synthesize headImageFrame = _headImageFrame;
@synthesize name = _name;
@synthesize info = _info;
@synthesize bookBtn = _bookBtn;

- (id)initWithBubbleViewController:(BubbleViewController *)viewController andInView:(UIBubbleTableView *)tableView
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 52)];
    if (self) {
        _bubbleViewController = viewController;
        _tableView = tableView;
        [self setBackgroundColor:[UIColor clearColor]];

        // 背景
        _backgroundImage = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].qaCellAnswerTailImage];
        _backgroundImage.frame = CGRectMake(0, 0, SCREEN_WIDTH, 52);
        _backgroundImage.alpha = 0.9;
        [self addSubview:_backgroundImage];
        
        // 头像
        _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(5.5, 4, 38, 38)];
        [_headImage setBackgroundColor:[UIColor clearColor]];
        
        _headImageFrame = [[UIImageView alloc] initWithImage:[CMImageUtils defaultImageUtil].doctorDefaultHeadImage];
        _headImageFrame.frame = CGRectMake(10, 2, 48, 48);
        [_headImageFrame addSubview:_headImage];
        [self addSubview:_headImageFrame];
        
        _name = [[UILabel alloc] initWithFrame:CGRectMake(62, 5, 180 *SCREEN_WIDTH/320, 20)];
        [_name setFont:[UIFont systemFontOfSize:14]];
        [_name setLineBreakMode:NSLineBreakByTruncatingTail];
        [_name setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_name];
        
        _info = [[UILabel alloc] initWithFrame:CGRectMake(62, 25, 180* SCREEN_WIDTH/320, 20)];
        [_info setFont:[UIFont systemFontOfSize:14]];
        [_info setTextColor:[UIColor grayColor]];
        [_info setLineBreakMode:NSLineBreakByTruncatingTail];
        [_info setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_info];
        
        // 预约挂号按钮
        _bookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bookBtn setTitle:@"预约挂号" forState:UIControlStateNormal];
        [_bookBtn setBackgroundImage:[UIImage imageNamed:@"全_n.png"] forState:UIControlStateNormal];
        [_bookBtn setTitle:@"预约挂号" forState:UIControlStateSelected];
        [_bookBtn setBackgroundImage:[UIImage imageNamed:@"全_p.png"] forState:UIControlStateSelected];
        [_bookBtn setTitle:@"预约挂号" forState:UIControlStateHighlighted];
        [_bookBtn setBackgroundImage:[UIImage imageNamed:@"全_p.png"] forState:UIControlStateHighlighted];
        [_bookBtn setFrame:CGRectMake(245 *SCREEN_WIDTH/320, 5, 75, 40)];
        [_bookBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_bookBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_bookBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [_bookBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        //        [_bookBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateNormal];
        //        [_bookBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateHighlighted];
        //        [_bookBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:66.0/255 blue:86.0/255 alpha:1] forState:UIControlStateSelected];
        [_bookBtn setUserInteractionEnabled:YES];
        [_bookBtn setHidden:YES];
        [_bookBtn addTarget:self action:@selector(bookBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bookBtn];
        
        self.alpha = 0;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)bookBtnClick:(id)sender
{
    if (!_bubbleViewController) {
        return;
    }
    
    [_bubbleViewController showBookingPage];
}

- (void)updateData
{
    if (!_bubbleViewController.metaInfoData)
        return;
    
    _name.text = _bubbleViewController.metaInfoData.name;
    _info.text = _bubbleViewController.metaInfoData.info;
    
    // 更新图片
    UIImage *head = [_bubbleViewController metaDataImageWithImageKey:_headImageKey];
    if (head) {
        _headImage.image = head;
    }
    else {
        _headImage.image = [CMImageUtils defaultImageUtil].doctorDefaultHeadMImage;
    }
    
    // 按钮变可见
    _bookBtn.hidden = NO;
}

- (void)show:(BOOL)animated
{
    if (!_tableView)
        return;

    if (![[_bubbleViewController.view subviews] containsObject:self]) {
        [_bubbleViewController.view addSubview:self];
    }

    if (animated && self.alpha == 0) {
        [self fadeIn];
    }
}

- (void)fadeIn
{
    UIImage *image = nil;
    if (_bubbleViewController) {
        image = [_bubbleViewController metaDataImageWithImageKey:_headImageKey];
        if (image) {
            _headImage.image = image;
        }
    }
    
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)hide
{
    if (![[_bubbleViewController.view subviews] containsObject:self]) {
        return;
    }
    
    if (self.alpha == 1) {
        [self fadeOut];
    }
}

- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
