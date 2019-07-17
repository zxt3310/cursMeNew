//
//  CustomTableBaseViewController.m
//  CureMe
//
//  Created by Tim on 12-8-27.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "CustomTableBaseViewController.h"
#import "LoginViewController.h"
#import "CMMyChatListViewController.h"



@interface CustomTableBaseViewController ()

@end

@implementation CustomTableBaseViewController

@synthesize unreadMsgBtn = _unreadMsgBtn;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // 设置背景图片

//    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
//    bgImage.frame = self.view.frame;
//    [self.view addSubview:bgImage];
//    [self.view sendSubviewToBack:bgImage];

//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    // 设置NavigationBar的背景图片
    if (!navBarBgImage) {
        navBarBgImage = [UIImage imageNamed:@"top.png"];
    }
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 5, 25, 25);
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

    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:newMsgView];
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;
        self.navigationItem.rightBarButtonItems = @[negativeSpacer, rightBarItem];
    }else{
        self.navigationItem.rightBarButtonItem = rightBarItem;
    }
    //self.navigationItem.rightBarButtonItem = rightBarItem;
    
    
    // 初始化Activity Indicator
    if (!activityIndicator) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [activityIndicator setCenter:CGPointMake(155, 150)];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:activityIndicator];
    }
        
    // TableView无数据的View
    _noDataBgView = [[NoDataBackgroundView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 35, 140, 80, 70)];
    _noDataBgView.hidden = YES;
    [self.view addSubview:_noDataBgView];
    [self.view sendSubviewToBack:_noDataBgView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (void)didReceiveMemoryWarning
{
    NSLog(@"CustomTableBaseViewController didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
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
    
    CMMyChatListViewController *myChatListVC = [[CMMyChatListViewController alloc] initWithNibName:@"CMMyChatListViewController" bundle:nil];//[[CMMyChatListViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:myChatListVC animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


#pragma mark EGO refresh table header view
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource{
    NSLog(@"==开始加载数据");
    _reloading = YES;
}

- (void)doneLoadingTableViewData{
    NSLog(@"===加载完数据");
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

//#pragma mark –
//#pragma mark UIScrollViewDelegate Methods
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
//}


#pragma mark –
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:2.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [[NSDate alloc] init];
}

#pragma mark Keyboard delegate begin
- (void)keyboardWillShow:(NSNotification *)noti
{
    //键盘输入的界面调整
    //键盘的高度
    float height = 216.0;
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
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);//键盘高度216
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
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    [textField resignFirstResponder];
}
#pragma mark Keyboard delegate end

@end





