//
//  PerCenterViewController.m
//  CureMe
//
//  Created by Tim on 12-8-16.
//  Copyright (c) 2012年 Tim. All rights reserved.
//


// 1. 账户Cell：已登录（姓名+“退出登录”）；未登录（登录、注册）
// 2. 个人信息Cell：
//  1）姓名Cell - 可编辑
//  2）年龄Cell - 可编辑
//  3）手机Cell - 可编辑
//  4）地区Cell - 可编辑
// 3. 修改密码Cell

#import "PerCenterViewController.h"
#import "PerCenterViewController.h"
#import "LoginViewController.h"
#import "PerCenterLoginCell.h"
#import "PerCenterLogoutCell.h"
#import "CMDataPickEditCell.h"
#import "RegisterViewController.h"
#import "ChangePasswordViewController.h"
#import "CMChooseQueryOfficeTableViewController.h"
#import "CMMainTabViewController.h"
#import "CMPerCenterHeaderCell.h"
#import "MyBookListViewController.h"
#import "personalDetailTableViewController.h"
#import "CMPersonSetingViewController.h"
#import "RegisteOfficeMemberViewController.h"
#import "WebViewController.h"

@interface PerCenterViewController ()
{
    UIButton *registVipBtn;
}
@end

@implementation PerCenterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        hasShownLoginViewController = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    if (@available(iOS 11.0,*)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.tableView.estimatedSectionFooterHeight = self.tableView.estimatedSectionHeaderHeight = self.tableView.estimatedRowHeight = 0;
    }
    else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.backgroundView = nil;
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    self.tableView.userInteractionEnabled = YES;
    
    self.tableView.scrollEnabled = NO;
    
    [self.tableView reloadData];
    
    [self.navigationItem setTitle:@"个人中心"];
    
    registVipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registVipBtn.frame = CGRectMake(SCREEN_WIDTH/2 - 115,
                                    452 * SCREEN_HEIGHT/667,
                                    230,
                                    40);
    [registVipBtn setTitle:@"填写个人信息成为正式用户" forState:UIControlStateNormal];
    registVipBtn.titleLabel.textColor = [UIColor whiteColor];
    registVipBtn.backgroundColor = UIColorFromHex(0xd0021b, 1);
    registVipBtn.hidden = YES;
    [registVipBtn addTarget:self action:@selector(registOfficeMember) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registVipBtn];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    //    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.navigationItem.leftBarButtonItems = nil;
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
    self.tabBarController.navigationItem.titleView = nil;
    self.tabBarController.navigationItem.title = @"个人中心";
    
    [super viewWillAppear:animated];
    
    if (IOS_VERSION >= 7.0) {
        CGRect tableFrame = self.tableView.frame;
        //tableFrame.origin.y = 20 + NAVIGATIONBAR_HEIGHT;
        //tableFrame.size.height = SCREEN_HEIGHT - 20 - NAVIGATIONBAR_HEIGHT - 50;
        tableFrame.size.height = SCREEN_HEIGHT - 49 - 64;
        self.tableView.frame = tableFrame;
        //[self.tableView setContentOffset:CGPointMake(0.0, 20.0) animated:NO];
    }
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([CureMeUtils defaultCureMeUtil].hasLogin && [CureMeUtils defaultCureMeUtil].isUnRegLoginUser){
        registVipBtn.hidden = NO;
    }
    else{
        registVipBtn.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"PerCenterViewController didReceiveMemoryWarning");
    
    [super didReceiveMemoryWarning];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section != 2) {
        return 0.1;
    }
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return nil;
//    }
//    if (section == 1) {
//        return @"账户";
//    }
//    else if (section == 2) {
//        return @"个人信息";
//    }
//
//    return @"账户管理";
//}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    
    else if (section == 1) {
        return 1;
    }
    else if (section == 2) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DefaultCell = @"DefaultCell";
    static NSString *HeaderCell = @"HeaderCell";
    //    static NSString *loginCell = @"LoginCell";
    //    static NSString *logoutCell = @"LogoutCell";
    static NSString *StringEditCell = @"StringEditCell";
    
    if (indexPath.section == 0) {
        CMPerCenterHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:HeaderCell];
        cell = nil;
        cell = [[CMPerCenterHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HeaderCell];
        cell.personalDelegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setPerCenterViewController:self];
        
        return cell;
    }
    
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:StringEditCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StringEditCell];
            UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 17, 18, 18)];
            leftView.contentMode = UIViewContentModeScaleAspectFit;
            [cell.contentView addSubview:leftView];
            
            UILabel *titleLb = [[UILabel alloc] initWithFrame:CGRectMake(50, 17, 100, 16)];
            [cell.contentView addSubview:titleLb];
            
//            if (indexPath.row == 0) {
//                leftView.image = [UIImage imageNamed:@"ico_both_wdyy.png"];
//                titleLb.text = @"我的预约";
//            }
            //else
            if (indexPath.row == 0){
                leftView.image = [UIImage imageNamed:@"ico_msg_wdzx"];
                titleLb.text = @"我的咨询";
            }
//            else{
//                leftView.image = [UIImage imageNamed:@"serviceorder_both.png"];
//                titleLb.text = @"服务订单";
//            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        return cell;
    }
    else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DefaultCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCell];
            UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 17, 18, 18)];
            leftView.contentMode = UIViewContentModeScaleAspectFit;
            leftView.image = [UIImage imageNamed:@"ico_set"];
            [cell.contentView addSubview:leftView];
            
            UILabel *titleLb = [[UILabel alloc] initWithFrame:CGRectMake(50, 17, 100, 16)];
            [cell.contentView addSubview:titleLb];
            titleLb.text = @"设置";
        }
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCell];
    return cell;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 171*SCREEN_HEIGHT/667;
    }
    return 50;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (indexPath.section == 0) {
    //
    //        if (![CureMeUtils defaultCureMeUtil].hasLogin) {
    //            CMLoginViewController *loginVC = [[CMLoginViewController alloc] init];
    //            [self.navigationController pushViewController:loginVC animated:YES];
    //            hasShownLoginViewController = true;
    //            return;
    //        }
    //        else{
    //            if ([CureMeUtils defaultCureMeUtil].isUnRegLoginUser) {
    //
    //                [self registOfficeMember];
    //                return;
    //            }
    //        }
    //
    //        personalDetailTableViewController *personDetialVc = [[personalDetailTableViewController alloc] init];
    //        [self.navigationController pushViewController:personDetialVc animated:YES];
    //    }
    //    else
    if (indexPath.section == 1){
//        if (indexPath.row == 0) {
//            MyBookListViewController *myBookListVC = [[MyBookListViewController alloc] initWithNibName:@"MyBookListViewController" bundle:nil];
//            myBookListVC.isMainTabPage = false;
//            myBookListVC.title = @"我的预约";
//            [self.navigationController pushViewController:myBookListVC animated:YES];
//        }
//        else
        if (indexPath.row == 0){
            
            CMMainTabViewController *mainTabVC = (CMMainTabViewController *)[[self.navigationController viewControllers] objectAtIndex:0];
            
            [mainTabVC tabWasSelected:1];
        }
//        else{
//            if ([CureMeUtils defaultCureMeUtil].hasLogin) {
//                WebViewController *webVc = [WebViewController new];
//                webVc.strURL = [NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/famous_doctors/service_order_list.php?userid=%ld",[CureMeUtils defaultCureMeUtil].userID];
//                [self.navigationController pushViewController:webVc animated:YES];
//            }
//            else{
//                CMLoginViewController *loginView = [[CMLoginViewController alloc] init];
//                loginView.cmDelegate = self;
//                [self.navigationController pushViewController:loginView animated:YES];
//            }
//        }
    }
    else if (indexPath.section == 2){
        CMPersonSetingViewController *setingVc = [[CMPersonSetingViewController alloc] init];
        [self.navigationController pushViewController:setingVc animated:YES];
    }
}

- (void)moreActionAfterLogin{
    WebViewController *webVc = [WebViewController new];
    webVc.strURL = [NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/famous_doctors/service_order_list.php?userid=%ld",[CureMeUtils defaultCureMeUtil].userID];
    [self.navigationController pushViewController:webVc animated:YES];
}

- (bool)logOff
{
    NSString *post = [NSString stringWithFormat:@"action=logout&userid=%ld&lastactivity=%.2f", (long)[CureMeUtils defaultCureMeUtil].userID, [[NSDate alloc] init].timeIntervalSince1970];
    NSLog(@"logoff %@", post);
    
    NSData *response = sendRequest(@"m.php", post);
    
    NSString *logoffStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"logOff: %@", logoffStr);
    
    NSDictionary *jsonData = parseJsonResponse(response);
    NSNumber *result = [jsonData objectForKey:@"result"];
    if (!result || result.integerValue != 1) {
        NSLog(@"logOff error: %@", [jsonData objectForKey:@"msg"]);
        //        return false;
    }
    
    [[CureMeUtils defaultCureMeUtil] resetUserInfo];
    [[CureMeUtils defaultCureMeUtil] clearUserInfoStore];
    
    [self.tableView reloadData];
    if (IOS_VERSION >= 7.0) {
        CGRect tableFrame = self.tableView.frame;
        //tableFrame.origin.y = 20 + NAVIGATIONBAR_HEIGHT;
        //tableFrame.size.height = SCREEN_HEIGHT - 20 - NAVIGATIONBAR_HEIGHT - 50;
        tableFrame.size.height = SCREEN_HEIGHT - 49 - 64;
        self.tableView.frame = tableFrame;
        //[self.tableView setContentOffset:CGPointMake(0.0, 20.0) animated:NO];
    }
    
    {
        // 跳转到“我的咨询”页面
        CMMainTabViewController *mainTabVC = (CMMainTabViewController *)[[self.navigationController viewControllers] objectAtIndex:0];
        
        NSMutableArray *VCs = [[NSMutableArray alloc] initWithArray:[mainTabVC viewControllers]];
        // “我的咨询”页面
        UIViewController *listViewController = [VCs objectAtIndex:1];
        if (![listViewController isKindOfClass:[CMChooseQueryOfficeTableViewController class]]) {
            CMChooseQueryOfficeTableViewController *chooseVC = [[CMChooseQueryOfficeTableViewController alloc] initWithNibName:@"CMChooseQueryOfficeTableViewController" bundle:nil]; //[[CMChooseQueryOfficeTableViewController alloc] initWithStyle:UITableViewStylePlain];
            [VCs setObject:chooseVC atIndexedSubscript:1];
        }
        
        // “我的预约”页面
        listViewController = [VCs objectAtIndex:3];
        if (![listViewController isKindOfClass:[CMChooseQueryOfficeTableViewController class]]) {
            CMChooseQueryOfficeTableViewController *chooseVC = [[CMChooseQueryOfficeTableViewController alloc] initWithNibName:@"CMChooseQueryOfficeTableViewController" bundle:nil]; //[[CMChooseQueryOfficeTableViewController alloc] initWithStyle:UITableViewStylePlain];
            [VCs setObject:chooseVC atIndexedSubscript:3];
        }
        [mainTabVC setViewControllers:[VCs copy]];
    }
    
    return true;
}

- (void)loginBtnClick{
    if ([CureMeUtils defaultCureMeUtil].hasLogin) {
        return;
    }
    
    CMLoginViewController *loginVc = [[CMLoginViewController alloc] init];
    [self.navigationController pushViewController:loginVc animated:YES];
}

- (void)editPersonalBtnClick{
    
    if ([CureMeUtils defaultCureMeUtil].isUnRegLoginUser) {
        
        [self registOfficeMember];
        return;
    }
    personalDetailTableViewController *personVc = [[personalDetailTableViewController alloc] init];
    [self.navigationController pushViewController:personVc animated:YES];
}

- (void)login
{
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    if (!loginVC)
        return;
    
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)regist
{
    RegisterViewController *registerVC = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    if (!registerVC)
        return;
    
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)registOfficeMember{
    RegisteOfficeMemberViewController *romvc = [[RegisteOfficeMemberViewController alloc] init];
    [self.navigationController pushViewController:romvc animated:YES];
}

@end

