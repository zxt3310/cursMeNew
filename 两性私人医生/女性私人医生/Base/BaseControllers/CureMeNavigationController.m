//
//  CureMeNavigationController.m
//  CureMe
//
//  Created by Tim on 12-8-10.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CureMeNavigationController.h"

@interface CureMeNavigationController ()

@end

@implementation CureMeNavigationController


@synthesize unreadMsgBtn = _unreadMsgBtn;

- (id)init
{
    self = [super initWithNibName:@"" bundle:nil];
    
    if (self) {
        
    }
    
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rVC
{
    self = [super initWithRootViewController:rVC];
    
    if (self) {
        rootViewController = rVC;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (void) SetNavRootViewController:(UIViewController *)controller
{
    if (!controller) {
        rootViewController = nil;
        return;
    }

    rootViewController = controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[self navigationBar] setBackgroundColor:[UIColor clearColor]];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_unreadMsgBtn) {
        // 初始化未读消息小圆圈按钮
        _unreadMsgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _unreadMsgBtn.frame = CGRectMake(280, 10, 23, 24);
        [_unreadMsgBtn setBackgroundImage:[UIImage imageNamed:@"no.png"] forState:UIControlStateNormal];
        _unreadMsgBtn.userInteractionEnabled = NO;
        _unreadMsgBtn.hidden = YES;
        [self.view addSubview:_unreadMsgBtn];
    }
}

- (void)setUnreadMsgCount:(NSInteger)unreadCount
{
//    if (unreadCount > 0) {
//        [_unreadMsgBtn setTitle:[NSString stringWithFormat:@"%d", unreadCount] forState:UIControlStateNormal];
//        _unreadMsgBtn.hidden = NO;
//    }
//    else {
//        _unreadMsgBtn.hidden = YES;
//    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.7;
    transition.timingFunction = UIViewAnimationCurveEaseInOut;
    transition.type = @"rippleEffect";
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    [self.view.layer addAnimation:transition forKey:nil];

    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.7;
//    transition.timingFunction = UIViewAnimationCurveEaseInOut;
//    transition.type = @"rippleEffect";
//    //        transition.subtype = kCATransitionFromRight;
//    transition.delegate = self;
//    [self.view.layer addAnimation:transition forKey:nil];

    return [super popViewControllerAnimated:animated];
}

@end
