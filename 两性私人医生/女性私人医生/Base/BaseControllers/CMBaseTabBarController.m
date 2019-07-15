//
//  CMBaseTabBarController.m
//  私密健康医生
//
//  Created by Tim on 13-1-11.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CMBaseTabBarController.h"
#import "LoginViewController.h"
#import "CMMyChatListViewController.h"

@interface CMBaseTabBarController ()

@end

@implementation CMBaseTabBarController

@synthesize unreadMsgBtn = _unreadMsgBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // 设置背景图片
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    // 设置NavigationBar的背景图片
    if (!navBarBgImage) {
        navBarBgImage = [UIImage imageNamed:@"top.png"];
    }
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 9, 18);
    [button setImage:[CMImageUtils defaultImageUtil].navBackBtnNormal forState:UIControlStateNormal];
    [button setImage:[CMImageUtils defaultImageUtil].navBackBtnSelected forState:UIControlStateHighlighted];
    [button setImage:[CMImageUtils defaultImageUtil].navBackBtnSelected forState:UIControlStateSelected];
    
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, barBtnItem];
    }else{
        self.navigationItem.leftBarButtonItem = barBtnItem;
    }
    
    //self.navigationItem.leftBarButtonItem = barBtnItem;

    // 初始化Activity Indicator
    if (!activityIndicator) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [activityIndicator setCenter:CGPointMake(155, 150)];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:activityIndicator];
    }
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 41, 41);
    [rightBtn setImage:[UIImage imageNamed:@"消息_n.png"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"消息_p.png"] forState:UIControlStateHighlighted];
    [rightBtn setImage:[UIImage imageNamed:@"消息_p.png"] forState:UIControlStateSelected];
    [rightBtn setBackgroundColor:[UIColor clearColor]];
    [rightBtn addTarget:self action:@selector(openUnreadMsg:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;
        self.navigationItem.rightBarButtonItems = @[negativeSpacer, rightBarItem];
    }else{
        self.navigationItem.rightBarButtonItem = rightBarItem;
    }
    //self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        // iOS 5 code
        [self.navigationController.navigationBar setBackgroundImage:buttonImageFromColor([UIColor whiteColor]) forBarMetrics:UIBarMetricsDefault];
//        self.navigationController.navigationBar.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 2);
//        self.navigationController.navigationBar.layer.shadowOpacity = 0.3;
    }
    else {
        // iOS 4.x code
        //[self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithPatternImage:navBarBgImage]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)openUnreadMsg:(id)sender
{
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    
    CMMyChatListViewController *myChatListVC = [[CMMyChatListViewController alloc] initWithNibName:@"CMMyChatListViewController" bundle:nil]; //[[CMMyChatListViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:myChatListVC animated:YES];
}

@end
