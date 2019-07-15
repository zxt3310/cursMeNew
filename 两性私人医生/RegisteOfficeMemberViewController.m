//
//  RegisteOfficeMemberViewController.m
//  私密健康医生
//
//  Created by 张信涛 on 2017/4/21.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import "RegisteOfficeMemberViewController.h"

@interface RegisteOfficeMemberViewController ()
{
    NSInteger code;
    NSInteger provinceId;
    NSInteger cityOrDistId;
    NSString *cityName;
}
@end

@implementation RegisteOfficeMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册正式用户";
    self.view.backgroundColor = UIColorFromHex(0xf9f9f9, 0.9);
    self.tableView.tableFooterView = [[UITableView alloc] initWithFrame:CGRectZero];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:tap];
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(regist)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Default"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Default"];
        UILabel *lable = [[UILabel alloc ]initWithFrame:CGRectMake(40 *SCREEN_WIDTH/374, 15, 65 *SCREEN_WIDTH/375, 20)];
        lable.font = [UIFont systemFontOfSize:15];
        lable.tag = 1;
        [cell.contentView addSubview:lable];
        
        UITextField *textFile = [[UITextField alloc] initWithFrame:CGRectMake(lable.frame.origin.x + lable.frame.size.width + 5,
                                                                              10,
                                                                              200*SCREEN_WIDTH/375,
                                                                              30)];
        textFile.font = [UIFont systemFontOfSize:15];
        textFile.leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
        textFile.leftViewMode = UITextFieldViewModeAlways;
        textFile.clearButtonMode = UITextFieldViewModeWhileEditing;
        textFile.layer.borderColor = UIColorFromHex(0xdfdfdf, 1).CGColor;
        textFile.layer.borderWidth = 1;
        textFile.tag = 2;
        [cell.contentView addSubview:textFile];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(260 *SCREEN_WIDTH/375, 10, 80 *SCREEN_WIDTH/375, 30);
        [button setTitle:@"获取验证码" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.backgroundColor = UIColorFromHex(0xd0021b, 1);
        button.hidden = YES;
        button.tag = 3;
        button.titleLabel.textColor = [UIColor whiteColor];
        [button addTarget:self action:@selector(codeBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
        
    }
    
    UILabel *userName = (UILabel *)[cell.contentView viewWithTag:1];
    UITextField *contentTF = (UITextField *)[cell.contentView viewWithTag:2];
    UIButton *codeBtn = (UIButton *)[cell.contentView viewWithTag:3];
    
    switch (indexPath.row) {
        case 0:
            userName.text = @"用户名";
            break;
        case 1:
            userName.text = @"设置密码";
            break;
        case 2:
            userName.text = @"手机号";
            break;
        case 3:
        {
            userName.text = @"验证码";
            CGRect temp = contentTF.frame;
            temp.size.width -= 70;
            contentTF.frame = temp;
            codeBtn.hidden = NO;
        }
            break;
        case 4:
        {
            userName.text = @"地区";
            contentTF.placeholder = @"请选择所在地区";
            contentTF.delegate = self;
        }
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tap{
    [self.view endEditing:YES];
}

- (void)regist{

    NSArray *postArray = @[@"username",@"password",@"mobile",@"mobileverify"];
    NSMutableString *postStr = [[NSMutableString alloc] init];
    for (int i=0; i<postArray.count; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UITextField *textFT = (UITextField *)[cell.contentView viewWithTag:2];
        [postStr appendString:[NSString stringWithFormat:@"&%@=%@",postArray[i],textFT.text]];
    }
    
    NSString *contextPost = [postStr copy];
    
    NSString *post = [NSString stringWithFormat:@"action=upduserinfo%@&userid=%ld&age=0&gender=0&name=&cityid=%ld&city2id=%ld",contextPost,[CureMeUtils defaultCureMeUtil].userID,provinceId,cityOrDistId];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *response = sendRequest(@"m.php", post);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!response) {
                [self presentAlert:@"注册失败，请检查网络"];
                return ;
            }
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"%@",strResp);
            
            NSDictionary *returnDic = parseJsonResponse(response);
            if (!returnDic) {
                [self presentAlert:@"注册失败，返回错误数据"];
                return;
            }
            NSNumber *result = JsonValue([returnDic objectForKey:@"result"], CLASS_NUMBER);
            if ([result integerValue] !=1) {
                NSString *err = [returnDic objectForKey:@"msg"];
                [self presentAlert:err];
                return;
            }
            [self userLogin];
        });
    });

}

- (void)userLogin{
    
    UITableViewCell *userNameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITableViewCell *passwordCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *nameFT = (UITextField *)[userNameCell.contentView viewWithTag:2];
    UITextField *passwodFt = (UITextField *)[passwordCell.contentView viewWithTag:2];
    
    NSString *post = [NSString stringWithFormat:@"action=login&password=%@&username=%@",[passwodFt.text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                                                       ,[nameFT.text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *response = sendRequest(@"m.php", post);
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if (!response) {
                [self presentAlert:@"登录失败,检查网络"];
                return ;
            }
            
            NSString* responseString = [[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding];
            NSLog(@"action=register resp: %@", responseString);

            NSDictionary *jsonData = parseJsonResponse(response);
            
            if (!jsonData) {
                [self presentAlert:@"登录失败，返回错误数据"];
                return;
            }
            
            NSNumber *result = [jsonData objectForKey:@"result"];
            if (!result || result.integerValue != 1) {
                NSLog(@"registerBtn register user result invalid");
                NSString *errorMsg = [jsonData objectForKey:@"msg"];
                [self presentAlert:errorMsg];
                return;
            }
            
            NSNumber *userID = [jsonData objectForKey:@"msg"];
            
            [[NSUserDefaults standardUserDefaults] setObject:nameFT.text forKey:USER_REGISTERNAME];
            [[NSUserDefaults standardUserDefaults] setObject:passwodFt.text forKey:USER_PASSWORD];
            [[NSUserDefaults standardUserDefaults] setObject:userID forKey:USER_ID];
            NSNumber *SWTID = [[NSNumber alloc] initWithInteger:0];
            [[NSUserDefaults standardUserDefaults] setObject:SWTID forKey:USER_SWT_ID];
            // 保存上次用户登录ID
            [[NSUserDefaults standardUserDefaults] setObject:userID forKey:USER_LASTUSERID];
            
            [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc] initWithInteger:provinceId] forKey:USER_REGION];
            [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc] initWithInteger:cityOrDistId] forKey:USER_CITY];
            [[NSUserDefaults standardUserDefaults] setObject:cityName forKey:USER_CITY_NAME];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_PERSONALNAME];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_PHONENO];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_AGE];
            
            if (![[NSUserDefaults standardUserDefaults] synchronize]) {
                NSLog(@"RegisterViewController NSUserDefaults synchronize failed!");
            }
            
            [[CureMeUtils defaultCureMeUtil] initUserLoginInfo];
            [[CureMeUtils defaultCureMeUtil] initUserPersonalInfo];
            
            
            updateIOSPushInfo();
            
            
            [HiChat login:[NSString stringWithFormat:@"%ld",[CureMeUtils defaultCureMeUtil].userID] withPassword:@"" completion:^(NSError *error){
                if (error) {
                    NSLog(@"%@",error);
                }
            }];
            
            NSData *deviceToken = [NSData dataWithData:[[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TOKEN_NSDATA]];
            if (!deviceToken) {
                
                NSLog(@"push token is nil fail to submit");

            }
            else{
                [HiChat submitDeviceToken:deviceToken];
            }
            
            [[self navigationController] popToRootViewControllerAnimated:YES];
        });
    });
}

- (void)codeBtnClick{
    
    UITableViewCell *phoneCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    UITextField *PhoneTF = (UITextField *)[phoneCell viewWithTag:2];
    if (PhoneTF.text.length == 0 || PhoneTF.text.length !=11) {
        [self presentAlert:@"请正确输入手机号"];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *urlStr = @"http://new.medapp.ranknowcn.com/api/m.php?action=yanzheng_getvcode&version=3.0";
        NSString *post = [NSString stringWithFormat:@"source=apple&version=3.3&appid=7&switchType=1&os=ios&imei=%@&deviceid=%@&username=%@&mobileTel=%@&userid=%ld",[CureMeUtils defaultCureMeUtil].UDID,[CureMeUtils defaultCureMeUtil].uniID,[CureMeUtils defaultCureMeUtil].userName,PhoneTF.text,[CureMeUtils defaultCureMeUtil].userID];
        NSData *response = sendFullRequest(urlStr, post, nil, NO, NO);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!response) {
                [self presentAlert:@"验证码发送失败，请检查网络"];
                return ;
            }
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"%@",strResp);
            
            NSDictionary *returnDic = parseJsonResponse(response);
            if (!returnDic) {
                [self presentAlert:@"验证码发送失败，返回错误数据"];
                return;
            }
            NSNumber *result = JsonValue([returnDic objectForKey:@"result"], CLASS_NUMBER);
            if ([result integerValue] !=1) {
                NSString *err = [returnDic objectForKey:@"msg"];
                [self presentAlert:err];
                return;
            }
            NSDictionary *codeDic = JsonValue([returnDic objectForKey:@"msg"], CLASS_DICTIONARY);
            code = [JsonValue([codeDic objectForKey:@"vcode"],CLASS_NUMBER) integerValue];
            [self sendMsgButtonChange];
        });
    });
    

}

- (void)sendMsgButtonChange
{
    UITableViewCell *buttonCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    
    UIButton *codeBtn = (UIButton*)[buttonCell viewWithTag:3];

    __block int time = 60;
    __block UIButton *verifybutton = codeBtn;
    CGRect temp = verifybutton.frame;
    verifybutton.enabled = NO;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                verifybutton.frame = temp;
                [verifybutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [verifybutton setTitle:@"获取验证码" forState:UIControlStateNormal];
                verifybutton.enabled = YES;
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                NSString *strTime = [NSString stringWithFormat:@"(%d)秒",time];
                [verifybutton setTitle:strTime forState:UIControlStateNormal];
                // verifybutton.titleLabel.textColor = [UIColor darkGrayColor];
                [verifybutton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}


- (void)presentAlert:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"消息" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    CMQuickAskChoosenAndLocationViewController *choosView = [[CMQuickAskChoosenAndLocationViewController alloc] init];
    choosView.isQuickAskView = NO;
    choosView.chooseDelegate = self;
    [self.navigationController pushViewController:choosView animated:YES];
    return NO;
}

- (void)refreshChosedLocation:(NSString *)province City:(NSString *)city Province:(NSInteger)city1 userCity:(NSInteger)city2{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    UITextField *textFT = [cell viewWithTag:2];
    textFT.text = [NSString stringWithFormat:@"%@ %@",province,city];
    provinceId = city1;
    cityOrDistId = city2;
}
@end
