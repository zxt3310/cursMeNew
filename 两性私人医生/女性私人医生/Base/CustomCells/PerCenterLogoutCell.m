//
//  PerCenterLogoutCell.m
//  CureMe
//
//  Created by Tim on 12-9-21.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "PerCenterLogoutCell.h"

@implementation PerCenterLogoutCell

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)generateLayout
{
    phoneNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 150, 36)];
    [phoneNoLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:USER_REGISTERNAME]];
    [phoneNoLabel setBackgroundColor:[UIColor clearColor]];
    [phoneNoLabel setFont:[UIFont systemFontOfSize:14]];
    [self.contentView addSubview:phoneNoLabel];
    
    logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(195, 6, 90, 28)];
    [logoutBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [logoutBtn addTarget:self action:@selector(logoutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    if ([CureMeUtils defaultCureMeUtil].isUnRegLoginUser) {
        [logoutBtn setTitle:@"注册正式用户" forState:UIControlStateNormal];
    }
    else {
        [logoutBtn setTitle:@"注销" forState:UIControlStateNormal];
    }
    [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [logoutBtn setBackgroundImage:[UIImage imageNamed:@"登录_n.png"] forState:UIControlStateNormal];
    [logoutBtn setBackgroundImage:[UIImage imageNamed:@"登录_p.png"] forState:UIControlStateSelected];
    [logoutBtn setBackgroundImage:[UIImage imageNamed:@"登录_p.png"] forState:UIControlStateHighlighted];
    [self.contentView addSubview:logoutBtn];
}

- (void)clearDisplay
{
    phoneNoLabel.text = @"";
}

- (void)setViewController:(PerCenterViewController *)viewController
{
    _viewController = viewController;
    
    [self generateLayout];
}

- (IBAction)logoutBtnClick:(id)sender
{
    if (!_viewController)
        return;
    
    if ([CureMeUtils defaultCureMeUtil].isUnRegLoginUser) {
        [_viewController regist];
    }
    else {
        [_viewController logOff];
    }
}

@end
