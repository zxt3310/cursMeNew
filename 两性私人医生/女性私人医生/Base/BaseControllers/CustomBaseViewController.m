//
//  CustomBaseViewController.m
//  CureMe
//
//  Created by Tim on 12-8-15.
//  Copyright (c) 2012年 Tim. All rights reserved.
//



#import "CustomBaseViewController.h"
#import "LoginViewController.h"
#import "CMMyChatListViewController.h"



@interface CustomBaseViewController ()

@end


@implementation CustomBaseViewController


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
    
    // 设置NavigationBar的返回按钮效果
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 5, 9, 18);
    [button setImage:[CMImageUtils defaultImageUtil].navBackBtnNormal forState:UIControlStateNormal];
    [button setImage:[CMImageUtils defaultImageUtil].navBackBtnSelected forState:UIControlStateHighlighted];
    [button setImage:[CMImageUtils defaultImageUtil].navBackBtnSelected forState:UIControlStateSelected];

    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 36)];
    
    [contentView addSubview:button];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:contentView];
    
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
//    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7) {
//        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        negativeSpacer.width = -10;
//        self.navigationItem.leftBarButtonItems = @[negativeSpacer, barBtnItem];
//    }else{
//        self.navigationItem.leftBarButtonItem = barBtnItem;
//    }
    //self.navigationItem.leftBarButtonItem = barBtnItem;

    UIView *newMsgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 41, 41)];
    [newMsgView setClipsToBounds:NO];

    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 41, 41);
    [rightBtn setImage:[UIImage imageNamed:@"消息_n.png"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"消息_p.png"] forState:UIControlStateHighlighted];
    [rightBtn setImage:[UIImage imageNamed:@"消息_p.png"] forState:UIControlStateSelected];
    [rightBtn setBackgroundColor:[UIColor clearColor]];
    [rightBtn addTarget:self action:@selector(openUnreadMsg:) forControlEvents:UIControlEventTouchUpInside];
    [newMsgView addSubview:rightBtn];
    
    if (!_unreadMsgBtn) {
        // 初始化未读消息小圆圈按钮
        _unreadMsgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _unreadMsgBtn.frame = CGRectMake(22, -1, 23, 24);
        [_unreadMsgBtn setBackgroundImage:[UIImage imageNamed:@"no.png"] forState:UIControlStateNormal];
        _unreadMsgBtn.userInteractionEnabled = NO;
        [_unreadMsgBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        _unreadMsgBtn.hidden = YES;
    }
    [newMsgView addSubview:_unreadMsgBtn];
    
//    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:newMsgView];
//    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7) {
//        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        negativeSpacer.width = -10;
//        self.navigationItem.rightBarButtonItems = @[negativeSpacer, rightBarItem];
//    }else{
//        self.navigationItem.rightBarButtonItem = rightBarItem;
//    }
    //self.navigationItem.rightBarButtonItem = rightBarItem;

    // 初始化Activity Indicator
    if (!activityIndicator) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [activityIndicator setCenter:CGPointMake(155, 150)];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:activityIndicator];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        // iOS 5 code
        [self.navigationController.navigationBar setBackgroundImage:buttonImageFromColor([UIColor whiteColor]) forBarMetrics:UIBarMetricsDefault];
    }
    else {
        // iOS 4.x code
        //[self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithPatternImage:navBarBgImage]];
    }
}

- (void)dealloc
{
}

- (IBAction)openUnreadMsg:(id)sender
{
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    
    CMMyChatListViewController *myChatListVC = [[CMMyChatListViewController alloc] initWithNibName:@"CMMyChatListViewController" bundle:nil];//[[CMMyChatListViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:myChatListVC animated:YES];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"CustomBaseViewController didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

#pragma mark Keyboard delegate begin
- (void)keyboardWillShow:(NSNotification *)noti
{
    //键盘输入的界面调整
    //键盘的高度
//    float height = 216.0;
    float height = 250.0;
    CGRect frame = self.view.frame;
    frame.size = CGSizeMake(frame.size.width, frame.size.height - height);
    [UIView beginAnimations:@"Curl"context:nil];//动画开始
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationDelegate:self];
    [self.view setFrame:frame];
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
//    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);//键盘高度216
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 250.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 64.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    [textField resignFirstResponder];
}
#pragma mark Keyboard delegate end

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    NSSet *setTouches = [event allTouches];
    UITouch *touch = [setTouches anyObject];
    
    switch ([setTouches count]) {
        case 1:
            if (![[touch view] isKindOfClass:[UITextField class]]) {
                [[self view] becomeFirstResponder];
                [[[self view] superview] becomeFirstResponder];
//                [self becomeFirstResponder];
            }
            break;
            
        default:
            break;
    }
}

@end
