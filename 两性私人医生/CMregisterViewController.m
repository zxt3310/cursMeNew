//
//  CMregisterViewController.m
//  女性私人医生
//
//  Created by Zxt3310 on 2017/11/1.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import "CMregisterViewController.h"
#import <VaptchaSDK/VaptchaSDK.h>

@interface CMregisterViewController ()<VPEmbedManagerDelegate>
{
    UITextField *phoneTf;
    UITextField *codeTf;
    UITextField *passwrdTf;
    NSString *getcode;
    UIButton *codeBtn;
    VPEmbedManager *embedManager;
}
@end

@implementation CMregisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //添加视图到图层
    [self.view addSubview:[self getEmbedManager].embedView];
    
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
    titleLb.font = [UIFont fontWithName:@"STHeitiSC-Light" size:20];
    titleLb.textColor = UIColorFromHex(0xd0ccd1, 1);
    titleLb.text = @"私密健康医生";
    [self.view addSubview:titleLb];

    UILabel *phoneLb = [[UILabel alloc] initWithFrame:CGRectMake(42*SCREEN_WIDTH/375, 179*SCREEN_HEIGHT/667, 45, 15)];
    phoneLb.text = @"手机号";
    phoneLb.font = [UIFont fontWithName:@"STHeitiSC-Light" size:15];
    [self.view addSubview:phoneLb];
    
    UILabel *codeLb = [[UILabel alloc] initWithFrame:CGRectMake(42*SCREEN_WIDTH/375, 258*SCREEN_HEIGHT/667, 45, 15)];
    codeLb.text = @"验证码";
    codeLb.font = phoneLb.font;
    [self.view addSubview:codeLb];
    
    UILabel *pwdLb = [[UILabel alloc] initWithFrame:CGRectMake(42*SCREEN_WIDTH/375, 480*SCREEN_HEIGHT/667, 30, 15)];
    pwdLb.text = @"密码";
    pwdLb.font = phoneLb.font;
    [self.view addSubview:pwdLb];
    
    phoneTf = [[UITextField alloc] initWithFrame:CGRectMake(107*SCREEN_WIDTH/375, 179*SCREEN_HEIGHT/667, 150, 15)];
    phoneTf.placeholder = @"请输入手机号";
    phoneTf.keyboardType = UIKeyboardTypePhonePad;
    codeTf = [[UITextField alloc] initWithFrame:CGRectMake(107*SCREEN_WIDTH/375, 258*SCREEN_HEIGHT/667, 200, 15)];
    codeTf.placeholder = @"绘制手势获取验证码并输入";
    codeTf.keyboardType = UIKeyboardTypeNumberPad;
    passwrdTf = [[UITextField alloc] initWithFrame:CGRectMake(107*SCREEN_WIDTH/375, 480*SCREEN_HEIGHT/667, 150, 15)];
    passwrdTf.placeholder = @"请输入密码";
    passwrdTf.secureTextEntry = YES;
    phoneTf.font = codeTf.font = passwrdTf.font = [UIFont fontWithName:@"STHeitiSC-Light" size:15];
    
    [self.view addSubview:phoneTf];
    [self.view addSubview:codeTf];
    [self.view addSubview:passwrdTf];
    
    UIButton *clearPhoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearPhoneBtn setImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
    clearPhoneBtn.frame = CGRectMake(303*SCREEN_WIDTH/375, 183*SCREEN_HEIGHT/667, 17, 17);
    [clearPhoneBtn addTarget:self action:@selector(clearBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearPhoneBtn];
    
    UIButton *hideAndDisBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [hideAndDisBtn setImage:[UIImage imageNamed:@"hideAndDisplay"] forState:UIControlStateNormal];
    hideAndDisBtn.frame = CGRectMake(300*SCREEN_WIDTH/375, 339*SCREEN_HEIGHT/667, 23, 14);
    [hideAndDisBtn addTarget:self action:@selector(hideAndDisClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hideAndDisBtn];
    
    for(int i=0; i<2; i++){
        UILabel *lineLb = [[UILabel alloc] initWithFrame:CGRectMake(43*SCREEN_WIDTH/375, 206*SCREEN_HEIGHT/667 + i*77*SCREEN_HEIGHT/667, 290*SCREEN_WIDTH/375, 1 )];
        lineLb.layer.borderWidth = 1;
        lineLb.layer.borderColor = UIColorFromHex(0xdbdbdb, 1).CGColor;
        [self.view addSubview:lineLb];
    }
    
//    codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [codeBtn setTitleColor:UIColorFromHex(0xababab, 1) forState:UIControlStateNormal];
//    [codeBtn setBackgroundColor:[UIColor whiteColor]];
//    [codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
//    codeBtn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:15];
//    codeBtn.layer.cornerRadius = 5;
//    codeBtn.layer.borderWidth = 1;
//    codeBtn.layer.borderColor = UIColorFromHex(0xababab, 1).CGColor;
//    codeBtn.frame = CGRectMake(240*SCREEN_WIDTH/375, 246*SCREEN_HEIGHT/667, 87*SCREEN_WIDTH/375, 32);
//    [codeBtn addTarget:self action:@selector(getVcode) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:codeBtn];
    
    UIButton *regiestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [regiestBtn setTitle:@"注册" forState:UIControlStateNormal];
    [regiestBtn setBackgroundColor:UIColorFromHex(0xd0021b, 1)];
    [regiestBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    regiestBtn.frame = CGRectMake(43*SCREEN_WIDTH/375, 523*SCREEN_HEIGHT/667, 290*SCREEN_WIDTH/375, 40);
    [regiestBtn addTarget:self action:@selector(registBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:regiestBtn];
    
   

    
    embedManager.embedView.frame = CGRectMake(43*SCREEN_WIDTH/375,250*SCREEN_WIDTH/375, 290*SCREEN_WIDTH/375, 250*SCREEN_WIDTH/375);
    
}

- (VPEmbedManager *)getEmbedManager{
    if (!embedManager) {
        [VPSDKManager setVaptchaSDKVid:@"5c13583efc650e13f470ae29" scene:@"01"];
        embedManager = [VPEmbedManager new];
        
        embedManager.delegate = self;
    }
    return embedManager;
}

- (void)clearBtnClick{
    phoneTf.text = @"";
}

- (void)hideAndDisClick{
    passwrdTf.secureTextEntry = !passwrdTf.secureTextEntry;
}

- (void)embedManagerVerifyPassedWithToken:(NSString *)token{
    [self.view sendSubviewToBack:embedManager.embedView];
    [self getMsgCode:token];
}

- (void)getMsgCode:(NSString *)token{
    NSString *post = [NSString stringWithFormat:@"action=sendmobilecode&phone=%@&code_token=%@&userid=20000",phoneTf.text,token];
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
            getcode = JsonValue([returnDic objectForKey:@"msg"], CLASS_STRING);
        });
    });
    
}

//- (void)getVcode{
//    NSString *post = [NSString stringWithFormat:@"action=getcode_mobilelogin&username=%@&mobileTel=%@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID],[phoneTf.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSData *response = sendRequest(@"m.php", post);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (!response) {
//                [self presentAlert:@"验证码发送失败，请检查网络"];
//                return ;
//            }
//            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
//            NSLog(@"%@",strResp);
//
//            NSDictionary *returnDic = parseJsonResponse(response);
//            if (!returnDic) {
//                [self presentAlert:@"验证码发送失败，返回错误数据"];
//                return;
//            }
//            NSNumber *result = JsonValue([returnDic objectForKey:@"result"], CLASS_NUMBER);
//            if ([result integerValue] !=1) {
//                NSString *err = [returnDic objectForKey:@"msg"];
//                [self presentAlert:err];
//                return;
//            }
//            NSDictionary *codeDic = JsonValue([returnDic objectForKey:@"msg"], CLASS_DICTIONARY);
//            //getcode = [JsonValue([codeDic objectForKey:@"vcode"],CLASS_NUMBER) integerValue];
//            [self sendMsgButtonChange];
//        });
//    });
//}


- (void)registBtnClick{
    
    if (!phoneTf.text || phoneTf.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"注册"
                              message:@"请输入您要注册用户名"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!passwrdTf.text || passwrdTf.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"注册"
                              message:@"请输入您的密码"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!codeTf.text || codeTf.text.length <=0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"注册"
                              message:@"请输入验证码"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSString *code = codeTf.text;
    if ([code integerValue] != [getcode integerValue]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"注册"
                              message:@"验证码错误"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // 发送注册请求，获取验证码
    // 发送注册请求，如果失败则提示错误（回到根页面）；如果成功则回到登陆页面
    NSString *post = nil;
    NSData *returnData = nil;
    NSString *responseString = nil;
    
    // 发送注册信息请求
    NSString *encodeAddr = [CureMeUtils defaultCureMeUtil].encodedLocateInfo;
    NSString *encodedUserName = [[phoneTf text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedPassword = [[passwrdTf text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // 如果是“全新注册用户”
    
    post = [[NSString alloc] initWithFormat:@"action=register&username=%@&password=%@&addrdetail=%@&token=%@&city=&city2=&mobile=%@", encodedUserName, encodedPassword, encodeAddr ? encodeAddr : @"", nil,phoneTf.text];
    
    returnData = sendRequest(@"m.php", post);
    
    responseString = [[NSString alloc] initWithData:returnData encoding:NSASCIIStringEncoding];
    NSLog(@"action=register resp: %@", responseString);
    
    if (!returnData) {
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
    
    NSDictionary *jsonData = parseJsonResponse(returnData);
    NSNumber *result = [jsonData objectForKey:@"result"];
    if (!result || result.integerValue != 1) {
        NSLog(@"registerBtn register user result invalid");
        NSString *errorMsg = [jsonData objectForKey:@"msg"];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"注册"
                              message:errorMsg
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"注册"
                          message:@"注册成功！"
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    
    NSNumber *userID = [jsonData objectForKey:@"msg"];
    
    [[NSUserDefaults standardUserDefaults] setObject:phoneTf.text forKey:USER_REGISTERNAME];
    [[NSUserDefaults standardUserDefaults] setObject:passwrdTf.text forKey:USER_PASSWORD];
    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:USER_ID];
    NSNumber *SWTID = [[NSNumber alloc] initWithInteger:0];
    [[NSUserDefaults standardUserDefaults] setObject:SWTID forKey:USER_SWT_ID];
    // 保存上次用户登录ID
    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:USER_LASTUSERID];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_PERSONALNAME];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_PHONENO];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_AGE];
    
    if (![[NSUserDefaults standardUserDefaults] synchronize]) {
        NSLog(@"RegisterViewController NSUserDefaults synchronize failed!");
    }
    
//    [HiChat login:[NSString stringWithFormat:@"%ld",(long)[CureMeUtils defaultCureMeUtil].userID] withPassword:@"" completion:^(NSError *error){
//        if (error) {
//            NSLog(@"%@",error);
//        }
//        
//        NSData *deviceToken = [NSData dataWithData:[[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TOKEN_NSDATA]];
//        if (!deviceToken) {
//            NSLog(@"push token is nil fail to submit");
//        }
//        else{
//            [HiChat submitDeviceToken:deviceToken];
//        }
//    }];
    
    [[CureMeUtils defaultCureMeUtil] initUserLoginInfo];
    [[CureMeUtils defaultCureMeUtil] initUserPersonalInfo];
    
    updateIOSPushInfo();
    [[self navigationController] popToRootViewControllerAnimated:YES];
    
    if (_cmDelegate) {
        [_cmDelegate moreActionAfterLogin];
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)presentAlert:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"消息" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
