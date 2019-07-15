//
//  CMMainTabViewController.m
//  私密健康医生
//
//  Created by Tim on 13-1-9.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "LoginViewController.h"
#import "CMMainTabViewController.h"

@interface CMMainTabViewController (privateMethod)

- (void)hideExistingTabBar;

@end

@implementation CMMainTabViewController

@synthesize customTabBarView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        CGRect frame = CGRectMake(0, 0, 100, 44);
//        UIView *v = [[UIView alloc] initWithFrame:frame];
//        UIColor *c = [[UIColor alloc] initWithRed:0.4 green:0.7 blue:0.3 alpha:1.0];
//        v.backgroundColor = c;
//        [self.tabBar insertSubview:v aboveSubview:0];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self hideExistingTabBar];
//    [self.navigationController setNavigationBarHidden:YES];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!customTabBarView) {
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"TabBarView" owner:self options:nil];
        customTabBarView = [nibObjects objectAtIndex:0];
        customTabBarView.delegate = self;
        CGRect viewFrame = customTabBarView.frame;
        viewFrame.size.width = SCREEN_WIDTH;
        viewFrame.origin.y = [self view].frame.size.height - (FitIpX(49));
        viewFrame.size.height = FitIpX(49);
        customTabBarView.frame = viewFrame;
        for (UIButton *button in customTabBarView.subviews) {
            if ([button isKindOfClass:[UIButton class]] && button.tag == 0) {
                [button setSelected:YES];
                break;
            }
        }
        
        [self.view setBackgroundColor:[UIColor grayColor]];
        [self.view addSubview:customTabBarView];
    }
        
    [super viewDidAppear:animated];

    // 更新未读消息数
    [[CureMeUtils defaultCureMeUtil] updateUnreadMsgCount];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfUnreadMsgCountUpdated:) name:NTF_UNREADMSGCOUNT_UPDATED object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NTF_UNREADMSGCOUNT_UPDATED object:nil];    
}

- (void)ntfUnreadMsgCountUpdated:(NSNotification *)note
{
    unreadChatCount = [CureMeUtils defaultCureMeUtil].unreadMessageCount;

    // 通知更新界面
    [self performSelectorOnMainThread:@selector(mainthreadUpdateUnreadCount) withObject:nil waitUntilDone:NO];
}

- (void)hideExistingTabBar
{
    [self.tabBar setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ALTabBarViewDelegate
-(void)tabWasSelected:(NSInteger)index {
    NSLog(@"tabWasSelected: %ld", (long)index);
    switch (index) {
        case 0:
            break;
        case 1:
        case 2:
        case 3:
            break;
        case 4:
            break;
        default:
            break;
    }
    self.selectedIndex = index;
    [customTabBarView selectButtonAtIndex:index];
}

#pragma mark UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSLog(@"CMMainTabViewController didSelectItem");
}

- (void)tabBar:(UITabBar *)tabBar willBeginCustomizingItems:(NSArray *)items
{
    NSLog(@"CMMainTabViewController willBeginCustomizingItems");
}

- (void)tabBar:(UITabBar *)tabBar didBeginCustomizingItems:(NSArray *)items
{
    NSLog(@"CMMainTabViewController didBeginCustomizingItems");
}

- (void)tabBar:(UITabBar *)tabBar willEndCustomizingItems:(NSArray *)items changed:(BOOL)changed
{
    NSLog(@"CMMainTabViewController willEndCustomizingItems");
}

- (void)tabBar:(UITabBar *)tabBar didEndCustomizingItems:(NSArray *)items changed:(BOOL)changed
{
    NSLog(@"CMMainTabViewController didEndCustomizingItems");
}

#pragma mark Thread Methods
- (void)mainthreadUpdateUnreadCount
{
    if (!customTabBarView) {
        return;
    }
    
    [customTabBarView setUnreadMsgCount:unreadChatCount];
}

@end
