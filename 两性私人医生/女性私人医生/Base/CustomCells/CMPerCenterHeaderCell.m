//
//  CMPerCenterHeaderCell.m
//  我的私人医生
//
//  Created by Tim on 13-8-21.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CMPerCenterHeaderCell.h"
#import "LoginViewController.h"
#import "CMMyChatListViewController.h"
#import "MyBookListViewController.h"
#import "WebViewController.h"


@interface CMPerCenterHeaderCell(private)

- (void)initialization;

@end



@implementation CMPerCenterHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    self.contentView.frame = CGRectMake(0, 0, 320, 80);
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:self.frame];
    backImageView.image = [UIImage imageNamed:@"personalHeaderBackimage_both"];
    self.backgroundView = backImageView;
    
    UIImageView *headImgVew = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-34.5*SCREEN_WIDTH/375, 29*SCREEN_HEIGHT/667, 69*SCREEN_WIDTH/375, 69*SCREEN_WIDTH/375)];
    headImgVew.layer.cornerRadius = 34.5*SCREEN_WIDTH/375;
    headImgVew.clipsToBounds = YES;
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"weixinHeadImg"];
    if (imageData) {
        headImgVew.image = [UIImage imageWithData:imageData];
    }
    else{
        headImgVew.image = [UIImage imageNamed:@"personalHeaderimage_both"];
    }
    [self.contentView addSubview:headImgVew];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(SCREEN_WIDTH/2-56*SCREEN_WIDTH/375, 113*SCREEN_HEIGHT/667, 112*SCREEN_WIDTH/375, 24);
    loginBtn.backgroundColor = [UIColor colorWithWhite:255.0 alpha:0.49];
    loginBtn.layer.cornerRadius = 13;
    [loginBtn setTitle:[CureMeUtils defaultCureMeUtil].userName forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14];
    [loginBtn addTarget:self action:@selector(loginBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:loginBtn];
    
    UIButton *editPersonalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editPersonalBtn.frame = CGRectMake(271*SCREEN_WIDTH/375, 14, 84*SCREEN_WIDTH/375, 20);
    editPersonalBtn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14];
    [editPersonalBtn addTarget:self action:@selector(editPersonalBtnClick) forControlEvents:UIControlEventTouchUpInside];
    if ([CureMeUtils defaultCureMeUtil].hasLogin) {
        if ([CureMeUtils defaultCureMeUtil].isUnRegLoginUser) {
            [editPersonalBtn setTitle:@"补充个人信息" forState:UIControlStateNormal];
        }
        else{
            [editPersonalBtn setTitle:@"编辑个人信息" forState:UIControlStateNormal];
        }
    }
    else {
        [loginBtn setTitle:@"登录/注册" forState:UIControlStateNormal];
        editPersonalBtn.hidden = YES;
    }
    [self.contentView addSubview:editPersonalBtn];
    
}

- (void)loginBtnClick{
    if (_personalDelegate) {
        [_personalDelegate loginBtnClick];
    }
}

- (void)editPersonalBtnClick{
    if (_personalDelegate) {
        [_personalDelegate editPersonalBtnClick];
    }
}

- (void)setPerCenterViewController:(PerCenterViewController *)perCenterViewController
{
    _perCenterViewController = perCenterViewController;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

