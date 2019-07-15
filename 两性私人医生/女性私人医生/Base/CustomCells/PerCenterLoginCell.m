//
//  PerCenterLoginCell.m
//  CureMe
//
//  Created by Tim on 12-9-12.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "PerCenterLoginCell.h"

@implementation PerCenterLoginCell

@synthesize viewController = _viewController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self generateLayout];
    }
    return self;
}

- (void)generateLayout
{
    loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 6, 70, 30)];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//    [loginBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:67.0/255 blue:87.0/255 alpha:1.0] forState:UIControlStateNormal];
//    [loginBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:67.0/255 blue:87.0/255 alpha:1.0] forState:UIControlStateSelected];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"登录_n.png"] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"登录_p.png"] forState:UIControlStateSelected];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"登录_p.png"] forState:UIControlStateHighlighted];
    [self.contentView addSubview:loginBtn];
    
    registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(210, 6, 70, 30)];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(registerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [registerBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//    [registerBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:67.0/255 blue:87.0/255 alpha:1.0] forState:UIControlStateNormal];
//    [registerBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:67.0/255 blue:87.0/255 alpha:1.0] forState:UIControlStateSelected];
    [registerBtn setBackgroundImage:[UIImage imageNamed:@"登录_n.png"] forState:UIControlStateNormal];
    [registerBtn setBackgroundImage:[UIImage imageNamed:@"登录_p.png"] forState:UIControlStateSelected];
    [registerBtn setBackgroundImage:[UIImage imageNamed:@"登录_p.png"] forState:UIControlStateHighlighted];
    [self.contentView addSubview:registerBtn];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setViewController:(PerCenterViewController *)viewController
{
    _viewController = viewController;
    
    [self generateLayout];
}

- (IBAction)loginBtnClick:(id)sender
{
    if (!_viewController)
        return;
    
    [_viewController login];
}

- (IBAction)registerBtnClick:(id)sender
{
    if (!_viewController)
        return;
    
    [_viewController regist];
}

@end
