//
//  CMPersonSetingViewController.m
//  私密健康医生
//
//  Created by 张信涛 on 2017/4/19.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import "CMPersonSetingViewController.h"
#import "AboutUsViewController.h"
#import "WebViewController.h"
#import "FeedBackViewController.h"

@interface CMPersonSetingViewController ()

@end

@implementation CMPersonSetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = nil;
    self.title = @"设置";
    self.tableView.tableFooterView = [[UITableView alloc] initWithFrame:CGRectZero];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"关于我们";
        }
        else if (indexPath.row == 1){
            cell.textLabel.text = @"用户协议";
        }
        else if (indexPath.row == 2){
            cell.textLabel.text = @"意见反馈";
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            AboutUsViewController *AVC = [[AboutUsViewController alloc] init];
            [self.navigationController pushViewController:AVC animated:YES];
        }
        if (indexPath.row == 1) {
            WebViewController *wvc = [[WebViewController alloc] init];
            wvc.strURL = [[NSBundle mainBundle] pathForResource:@"protocol" ofType:@"html"];
            [self.navigationController pushViewController:wvc animated:YES];
        }
        if (indexPath.row == 2) {
            FeedBackViewController *FVC = [[FeedBackViewController alloc] init];
            [self.navigationController pushViewController:FVC animated:YES];
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
