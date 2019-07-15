//
//  CMLoginViewController.m
//  女性私人医生
//
//  Created by Zxt3310 on 2017/10/20.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import "CMLoginViewController.h"
#import "CMCustomViews.h"
#import "HiChat.h"

@interface CMLoginViewController ()
{
    UIButton *loginWithAccount;
    UIButton *loginWithTel;
    UILabel *underLine;
    
    UITextField *telField;
    UITextField *codeField;
    UITextField *passwordField;
    UILabel *passwordLb;
    UIButton *codeBtn;
    UILabel *codeLb;
    
    UIView *otherPlaceLoginView;
    UIButton *switchBtn;
    
    BOOL switchLoginWithTel;
    BOOL switchOn;
    
    NSString *phoneNo;
    NSString *password;
    NSInteger *getCode;
    NSString *code;
    
    LoadingView *loading;
}
@end

@implementation CMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    switchLoginWithTel = YES;
    switchOn = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    loading = [[LoadingView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 40, SCREEN_HEIGHT/3, 80, 70)];
    loading.hidden = YES;
    [self.view addSubview:loading];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-70*SCREEN_WIDTH/375)/2 ,
                                                                               30*SCREEN_HEIGHT/667,
                                                                               70*SCREEN_WIDTH/375,
                                                                               70*SCREEN_WIDTH/375)];
    logoImageView.image = [UIImage imageNamed:@"man"];
    [self.view addSubview:logoImageView];
    
    
    UILabel *titleLb = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                120*SCREEN_HEIGHT/667,
                                                                SCREEN_WIDTH,
                                                                 20)];
    titleLb.textAlignment = NSTextAlignmentCenter;
    titleLb.font = [UIFont fontWithName:@"STHeitiSC-Light" size:16];
    titleLb.textColor = UIColorFromHex(0xd0ccd1, 1);
    titleLb.text = @"私密健康医生";
    [self.view addSubview:titleLb];
    
    loginWithAccount = [UIButton buttonWithType:UIButtonTypeCustom];
    loginWithAccount.frame = CGRectMake(66 *SCREEN_WIDTH/375, 176*SCREEN_HEIGHT/667, 90*SCREEN_WIDTH/375, 15);
    loginWithTel = [UIButton buttonWithType:UIButtonTypeCustom];
    loginWithTel.frame = CGRectMake(221*SCREEN_WIDTH/375, 176*SCREEN_HEIGHT/667, 90*SCREEN_WIDTH/375, 15);
    //隐藏手机验证登录
    loginWithTel.hidden = YES;
    
    [loginWithAccount setTitle:@"账号密码登录" forState:UIControlStateNormal];
    [loginWithTel setTitle:@"手机验证登录" forState:UIControlStateNormal];
    [loginWithAccount setTitleColor:UIColorFromHex(0x9d9d9d, 1) forState:UIControlStateNormal];
    [loginWithTel setTitleColor:UIColorFromHex(0xd0021b, 1) forState:UIControlStateNormal];
    loginWithTel.titleLabel.font = loginWithAccount.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15];
    
    [loginWithAccount addTarget:self action:@selector(loginWithAccountBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [loginWithTel addTarget:self action:@selector(loginWithTelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    underLine = [[UILabel alloc] initWithFrame:CGRectMake(188*SCREEN_WIDTH/375, 199*SCREEN_HEIGHT/667, 145*SCREEN_WIDTH/375, 3)];
    [underLine setBackgroundColor:UIColorFromHex(0xd0021b, 1)];
    [self.view addSubview:loginWithAccount];
    [self.view addSubview:loginWithTel];
    [self.view addSubview:underLine];
    
    UILabel *telLb = [[UILabel alloc] initWithFrame:CGRectMake(42 *SCREEN_WIDTH/375, 252*SCREEN_HEIGHT/667, 45, 15)];
    telLb.text = @"账号";
    telLb.font = [UIFont fontWithName:@"STHeitiSC-Light" size:15];
    [self.view addSubview:telLb];
    
    telField = [[UITextField alloc] initWithFrame:CGRectMake(107*SCREEN_WIDTH/375, 252*SCREEN_HEIGHT/667, 150*SCREEN_WIDTH/375, 15)];
    telField.font = [UIFont fontWithName:@"STHeitiSC-Light" size:15];
    telField.placeholder = @"请输入账号/手机号";
    telField.keyboardType = UIKeyboardTypeDefault;
    [self.view addSubview:telField];
    
    codeLb = [[UILabel alloc] initWithFrame:CGRectMake(42*SCREEN_WIDTH/375, 330*SCREEN_HEIGHT/667, 45, 15)];
    codeLb.font = telLb.font;
    codeLb.text = @"验证码";
    [self.view addSubview:codeLb];
    
    codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    codeBtn.frame = CGRectMake(240*SCREEN_WIDTH/375, 320*SCREEN_HEIGHT/667, 87*SCREEN_WIDTH/375, 32);
    [codeBtn setTitleColor:UIColorFromHex(0x393939, 1) forState:UIControlStateNormal];
    [codeBtn setBackgroundColor:[UIColor whiteColor]];
    [codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    codeBtn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:14];
    codeBtn.layer.borderWidth = 1;
    codeBtn.layer.borderColor = UIColorFromHex(0xadadad, 1).CGColor;
    [codeBtn addTarget:self action:@selector(getVcode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:codeBtn];
    
    codeField = [[UITextField alloc] initWithFrame:CGRectMake(107*SCREEN_WIDTH/375, 330*SCREEN_HEIGHT/667, 150*SCREEN_WIDTH/375, 15)];
    codeField.font = telField.font;
    codeField.placeholder = @"请输入验证码";
    [self.view addSubview:codeField];
    
    passwordLb = [[UILabel alloc] init];
    passwordLb.frame = codeLb.frame;
    passwordLb.text = @"密码";
    passwordLb.font = codeLb.font;
    passwordLb.hidden = YES;
    [self.view addSubview:passwordLb];
    
    passwordField = [[UITextField alloc] initWithFrame:codeField.frame];
    passwordField.placeholder = @"请输入密码";
    passwordField.font = codeField.font;
    passwordField.hidden = YES;
    passwordField.secureTextEntry = YES;
    [self.view addSubview:passwordField];
    
    for (int i=0; i<3; i++) {
        UILabel *lineLB = [[UILabel alloc] initWithFrame:CGRectMake(43*SCREEN_WIDTH/375, 202*SCREEN_HEIGHT/667 + i*76*SCREEN_HEIGHT/667, 290*SCREEN_WIDTH/375, 2)];
        lineLB.layer.borderWidth = 1;
        lineLB.layer.borderColor = UIColorFromHex(0xdbdbdb, 1).CGColor;
        //隐藏第一条分割线
        if (i==0) {
            lineLB.hidden = YES;
        }
        [self.view addSubview:lineLB];
    }
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(43*SCREEN_WIDTH/375, 410*SCREEN_HEIGHT/667, 290*SCREEN_WIDTH/375, 40);
    [loginBtn setBackgroundColor:UIColorFromHex(0xd0021b, 1)];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnClickEventAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    otherPlaceLoginView = [[UIView alloc] initWithFrame:CGRectMake(0, 473*SCREEN_HEIGHT/667, SCREEN_WIDTH, 100*SCREEN_HEIGHT/667)];
    switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [switchBtn setBackgroundImage:[UIImage imageNamed:@"otherSwitchOff"] forState:UIControlStateNormal];
    switchBtn.frame = CGRectMake(178*SCREEN_WIDTH/375, 0, 19, 19);
    [switchBtn addTarget:self action:@selector(oherSwitchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [otherPlaceLoginView addSubview:switchBtn];
    
    UILabel *otherPlaceLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, SCREEN_WIDTH, 13)];
    otherPlaceLb.text = @"第三方登录";
    otherPlaceLb.font = [UIFont fontWithName:@"STHeitiSC-Light" size:13];
    otherPlaceLb.textColor = UIColorFromHex(0x4a4a4a, 1);
    otherPlaceLb.textAlignment = NSTextAlignmentCenter;
    [otherPlaceLoginView addSubview:otherPlaceLb];
    
    NSArray *nameArray = @[@"qq",@"weixin",@"weibo"];
    for (int i=0; i<3; i++) {
        UIButton *otherPlaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        otherPlaceBtn.frame = CGRectMake(42*SCREEN_WIDTH/375 + i%3*124*SCREEN_WIDTH/375, 53, 43*SCREEN_WIDTH/375, 43*SCREEN_WIDTH/375);
        [otherPlaceBtn setBackgroundImage:[UIImage imageNamed:nameArray[i]] forState:UIControlStateNormal];
        [otherPlaceLoginView addSubview:otherPlaceBtn];
        otherPlaceBtn.hidden = YES;
        if (i==1) {
            otherPlaceBtn.hidden = NO;
            [otherPlaceBtn addTarget:self action:@selector(weixinLogin) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    [self.view addSubview:otherPlaceLoginView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 30, 15);
    [button setTitle:@"注册" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:15];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(registBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    if (![WXApi isWXAppInstalled]) {
        otherPlaceLoginView.hidden = YES;
    }
    else{
        otherPlaceLoginView.hidden = YES;
    }
    
    //切换到账号密码登录
    [self loginWithAccountBtnClick];
}

- (void)oherSwitchBtnClick{
    if (switchOn){
        [UIView animateWithDuration:0.3 animations:^{
            CGRect temp = otherPlaceLoginView.frame;
            temp.origin.y = 550*SCREEN_HEIGHT/667;
            otherPlaceLoginView.frame = temp;
        }];
        [switchBtn setBackgroundImage:[UIImage imageNamed:@"otherSwitchOn"] forState:UIControlStateNormal];
        switchOn = NO;
    }
    else{
        [UIView animateWithDuration:0.3 animations:^{
            CGRect temp = otherPlaceLoginView.frame;
            temp.origin.y = 473*SCREEN_HEIGHT/667;
            otherPlaceLoginView.frame = temp;
        }];
        [switchBtn setBackgroundImage:[UIImage imageNamed:@"otherSwitchOff"] forState:UIControlStateNormal];
        switchOn = YES;
    }
}

- (void)loginWithAccountBtnClick{
    if (!switchLoginWithTel) {
        return;
    }
    [loginWithAccount setTitleColor:UIColorFromHex(0xd0021b, 1) forState:UIControlStateNormal];
    [loginWithTel setTitleColor:UIColorFromHex(0x9d9d9d, 1) forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect temp = underLine.frame;
        temp.origin.x = 43*SCREEN_WIDTH/375;
        underLine.frame = temp;
    }];
    codeBtn.hidden = YES;
    codeField.hidden = YES;
    codeLb.hidden = YES;
    passwordField.hidden = NO;
    passwordLb.hidden = NO;
    
    switchLoginWithTel = NO;
}

- (void)loginWithTelBtnClick{
    if (switchLoginWithTel) {
        return;
    }
    [loginWithAccount setTitleColor:UIColorFromHex(0x9d9d9d, 1) forState:UIControlStateNormal];
    [loginWithTel setTitleColor:UIColorFromHex(0xd0021b, 1) forState:UIControlStateNormal];

    [UIView animateWithDuration:0.3 animations:^{
        CGRect temp = underLine.frame;
        temp.origin.x = 188*SCREEN_WIDTH/375;
        underLine.frame = temp;
    }];
    codeBtn.hidden = NO;
    codeField.hidden = NO;
    codeLb.hidden = NO;
    passwordField.hidden = YES;
    passwordLb.hidden = YES;
    
    switchLoginWithTel = YES;
}

- (void)registBtnClick{
    CMregisterViewController *regist = [[CMregisterViewController alloc] init];
    if (_cmDelegate) {
        regist.cmDelegate = _cmDelegate;
    }
    [self.navigationController pushViewController:regist animated:YES];
}

- (void)loginBtnClickEventAction{
//    dispatch_async(dispatch_get_main_queue(), ^{
        loading.hidden = NO;
        
        phoneNo = [telField text];
        password = [passwordField text];
        code = [codeField text];
        
        if (!switchLoginWithTel) {
            if (!phoneNo || !password || phoneNo.length <= 0 || password.length <= 0) {
                loading.hidden = YES;
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"登录账号"
                                      message:@"您输入的手机号或密码错误"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
        else{
            if (!phoneNo || !code || phoneNo.length <=0 || code.length <=0) {
                loading.hidden = YES;
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"登录账号"
                                      message:@"您输入的手机号或验证码错误"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
  //  });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0), ^{
        
        // 发送注册请求，获取验证码
        // 发送注册请求，如果失败则提示错误（回到根页面）；如果成功则回到登陆页面
        NSString *post = nil;
        NSString *responseString = nil;
        NSData *returnData = nil;
        // 获取注册验证码请求
        if (switchLoginWithTel) {
            post = [[NSString alloc] initWithFormat:@"action=login&mobileTel=%@&username=%@&vocde=%@&password=", [phoneNo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[phoneNo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [code stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        else{
            post = [[NSString alloc] initWithFormat:@"action=login&username=%@&password=%@&mobileTel=&vcode=", [phoneNo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
        returnData = sendRequest(@"m.php", post);
        responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", responseString);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!returnData) {
                loading.hidden = YES;
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"登录账号"
                                      message:@"无法连接服务器，请检查网络"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                NSLog(@"login fail");
                return;
            }
            
            NSDictionary *jsonDict = parseJsonResponse(returnData);
            NSNumber *result = [jsonDict objectForKey:@"result"];
            NSNumber *userID = nil;
            NSString *strUserID = nil;
            if ([result intValue] == 1) {
                strUserID = [jsonDict objectForKey:@"msg"];
                userID = [jsonDict objectForKey:@"msg"];
                NSLog(@"login ok");
                loading.hidden = YES;
            }
            else {
                loading.hidden = YES;
                NSString *msg = [jsonDict objectForKey:@"msg"];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"登录异常"
                                      message:msg
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                NSLog(@"login fail %@", msg);
            }
            
            // 登录OK
            if (userID) {
                // 如果登录账号切换，清除上次登录账号保存的信息
                NSNumber *lastUserID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_LASTUSERID];
                if (!lastUserID || userID.integerValue != lastUserID.integerValue) {
                    // 清理用户账户信息，但不清理lastuserID
                    [[CureMeUtils defaultCureMeUtil] clearUserInfoStore];
                    // 内存和本地数据库中都保存lastuserID
                    [CureMeUtils defaultCureMeUtil].lastUserID = userID.integerValue;
                    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:USER_LASTUSERID];
                    // 请求一次获取当前用户信息，并保存到数据库
                    [[CureMeUtils defaultCureMeUtil] updateUserInfo:userID.integerValue];
                }
                
                NSString *modifyTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"ModifyTime"];
                if (!modifyTime || modifyTime.length <= 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"ModifyTime"];
                }
                [[NSUserDefaults standardUserDefaults] setObject:phoneNo forKey:USER_REGISTERNAME];
                NSNumber *ID = [[NSNumber alloc] initWithInteger:strUserID.integerValue];
                [[NSUserDefaults standardUserDefaults] setObject:ID forKey:USER_ID];
                NSNumber *SWTID = [[NSNumber alloc] initWithInteger:0];
                [[NSUserDefaults standardUserDefaults] setObject:SWTID forKey:USER_SWT_ID];
                [[NSUserDefaults standardUserDefaults] setObject:password forKey:USER_PASSWORD];
                if (![[NSUserDefaults standardUserDefaults] synchronize]) {
                    NSLog(@"LoginViewController login NSUserDefaults synchronize failed");
                }
                
                NSLog(@"Password %@", [[NSUserDefaults standardUserDefaults] objectForKey:USER_PASSWORD]);
                
                [HiChat login:[NSString stringWithFormat:@"%ld",[CureMeUtils defaultCureMeUtil].userID] withPassword:@"" completion:^(NSError *error){
                    if (error) {
                        NSLog(@"%@",error);
                    }
                    
                    NSData *deviceToken = [NSData dataWithData:[[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TOKEN_NSDATA]];
                    if (!deviceToken) {
                        NSLog(@"push token is nil fail to submit");
                    }
                    else{
                        [HiChat submitDeviceToken:deviceToken];
                    }
                }];
                
                [[CureMeUtils defaultCureMeUtil] initUserLoginInfo];
                [[CureMeUtils defaultCureMeUtil] initUserPersonalInfo];
                
                // 登录成功，此时发送设备token以及GUID
                updateIOSPushInfo();
                [[self navigationController] popToRootViewControllerAnimated:YES];
                if (_cmDelegate) {
                    [_cmDelegate moreActionAfterLogin];
                }
            }
        });
    });
}

- (void)getVcode{
    NSString *post = [NSString stringWithFormat:@"action=getcode_mobilelogin&username=%@&mobileTel=%@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID],[telField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *response = sendRequest(@"m.php", post);
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
            getCode = [JsonValue([codeDic objectForKey:@"vcode"],CLASS_NUMBER) integerValue];
            [self sendMsgButtonChange];
        });
    });
}


- (void)weixinLogin{
    [[WeixinBackTools sharedInstance] sendAuthRequest];
    [WeixinBackTools sharedInstance].wxBackDelegate = self;
}

- (void)recieveAuthResponse:(BOOL)isSucced code:(NSString *)code{
    NSString *backCode = code;
    NSString *urlStr = [NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/api/m.php?action=createuserdata&version=3.0&source=apple&deviceid=%@&addretail=%@&openid=%@",[CureMeUtils defaultCureMeUtil].uniID,[CureMeUtils defaultCureMeUtil].encodedLocateInfo,backCode];
    NSString *post = [NSString stringWithFormat:@"source=apple&imei=%@&addrdetail=%@&ersion=%@&appid=7&deviceid=%@&os=ios",[CureMeUtils defaultCureMeUtil].UDID,[CureMeUtils defaultCureMeUtil].encodedLocateInfo,[CureMeUtils defaultCureMeUtil].appVersion,[CureMeUtils defaultCureMeUtil].uniID];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *response = sendRequestWithFullURL(urlStr, post);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"%@", responseString);
            
            if (!response) {
                loading.hidden = YES;
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"登录账号"
                                      message:@"无法连接服务器，请检查网络"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                NSLog(@"login fail");
                return;
            }
            
            NSDictionary *jsonDict = parseJsonResponse(response);
            NSNumber *result = [jsonDict objectForKey:@"result"];
            NSNumber *userID = nil;
            NSString *strUserID = nil;
            if ([result intValue] == 1) {
                strUserID = [jsonDict objectForKey:@"msg"];
                userID = [jsonDict objectForKey:@"msg"];
                NSLog(@"login ok");
                loading.hidden = YES;
            }
            else {
                loading.hidden = YES;
                NSString *msg = [jsonDict objectForKey:@"msg"];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"登录异常"
                                      message:msg
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                NSLog(@"login fail %@", msg);
            }
            
            // 登录OK
            if (userID) {
                // 如果登录账号切换，清除上次登录账号保存的信息
                NSNumber *lastUserID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_LASTUSERID];
                if (!lastUserID || userID.integerValue != lastUserID.integerValue) {
                    // 清理用户账户信息，但不清理lastuserID
                    [[CureMeUtils defaultCureMeUtil] clearUserInfoStore];
                    // 内存和本地数据库中都保存lastuserID
                    [CureMeUtils defaultCureMeUtil].lastUserID = userID.integerValue;
                    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:USER_LASTUSERID];
                    // 请求一次获取当前用户信息，并保存到数据库
                    [[CureMeUtils defaultCureMeUtil] updateUserInfo:userID.integerValue];
                }
                
                NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WX_BOTH_ID,WX_BOTH_SECRET,backCode];
                NSData *returnData = sendGETRequest(urlStr);
                
                NSString *strResp = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                NSLog(@"updateUserInfo resp: %@", strResp);
                
                NSDictionary *jsonDic = parseJsonResponse(returnData);
                NSString *access_token = [jsonDic objectForKey:@"access_token"];
                if (access_token) {
                    urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",access_token,backCode];
                    returnData = sendGETRequest(urlStr);
                    strResp = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                    NSLog(@"updateUserInfo resp: %@", strResp);
                    
                    jsonDic = parseJsonResponse(returnData);
                    NSString *nameStr = [jsonDic objectForKey:@"nickname"];
                    [[NSUserDefaults standardUserDefaults] setObject:nameStr forKey:USER_REGISTERNAME];
                    //获取微信头像存本地
                    NSString *imageUrlStr = [jsonDic objectForKey:@"headimgurl"];
                    NSData *headImgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlStr]];
                    [[NSUserDefaults standardUserDefaults] setObject:headImgData forKey:WX_HEAD];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                NSString *modifyTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"ModifyTime"];
                if (!modifyTime || modifyTime.length <= 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"ModifyTime"];
                }
                //[[NSUserDefaults standardUserDefaults] setObject:phoneNo forKey:USER_REGISTERNAME];
                NSNumber *ID = [[NSNumber alloc] initWithInteger:strUserID.integerValue];
                [[NSUserDefaults standardUserDefaults] setObject:ID forKey:USER_ID];
                NSNumber *SWTID = [[NSNumber alloc] initWithInteger:0];
                [[NSUserDefaults standardUserDefaults] setObject:SWTID forKey:USER_SWT_ID];
                [[NSUserDefaults standardUserDefaults] setObject:password forKey:USER_PASSWORD];
                //微信标识
                [[NSUserDefaults standardUserDefaults] setObject:@"weixin" forKey:@"userType"];
                if (![[NSUserDefaults standardUserDefaults] synchronize]) {
                    NSLog(@"LoginViewController login NSUserDefaults synchronize failed");
                }
                
                NSLog(@"Password %@", [[NSUserDefaults standardUserDefaults] objectForKey:USER_PASSWORD]);
                
                [HiChat login:[NSString stringWithFormat:@"%ld",[CureMeUtils defaultCureMeUtil].userID] withPassword:@"" completion:^(NSError *error){
                    if (error) {
                        NSLog(@"%@",error);
                    }
                    
                    NSData *deviceToken = [NSData dataWithData:[[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TOKEN_NSDATA]];
                    if (!deviceToken) {
                        NSLog(@"push token is nil fail to submit");
                    }
                    else{
                        [HiChat submitDeviceToken:deviceToken];
                    }
                }];
                
                [[CureMeUtils defaultCureMeUtil] initUserLoginInfo];
                [[CureMeUtils defaultCureMeUtil] initUserPersonalInfo];
                
                // 登录成功，此时发送设备token以及GUID
                updateIOSPushInfo();
                
                [[self navigationController] popToRootViewControllerAnimated:YES];
                if (_cmDelegate) {
                    [_cmDelegate moreActionAfterLogin];
                }
            }
        });
    });
}

- (void)sendMsgButtonChange
{
    __block int time = 60;
    __block UIButton *verifybutton = codeBtn;
    CGRect temp = verifybutton.frame;
    verifybutton.enabled = NO;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                // verifybutton.backgroundColor = [UIColor colorWithHexString:@"FC740A"];
                verifybutton.frame = temp;
                [verifybutton setTitleColor:UIColorFromHex(0x393939, 1) forState:UIControlStateNormal];
                [verifybutton setTitle:@"获取验证码" forState:UIControlStateNormal];
                verifybutton.enabled = YES;
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //verifybutton.backgroundColor = [UIColor grayColor];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)presentAlert:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"消息" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
