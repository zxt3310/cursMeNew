//
//  ChangePhoneNoViewController.m
//  私密健康医生
//
//  Created by 张信涛 on 2017/4/18.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import "ChangePhoneNoViewController.h"

@interface ChangePhoneNoViewController ()
{
    UITextField *PhoneTF;
    NSUInteger code;
    UITextField *codeTF;
    UIButton *codeBtn;
}
@end

@implementation ChangePhoneNoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"修改手机号码";
    
    PhoneTF = [[UITextField alloc] initWithFrame:CGRectMake(40, 80, SCREEN_WIDTH - 80, 40)];
    PhoneTF.placeholder = @"手机号码";
    PhoneTF.layer.borderWidth = 1;
    PhoneTF.layer.borderColor = [UIColor grayColor].CGColor;
    PhoneTF.keyboardType = UIKeyboardTypeNumberPad;
    PhoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:PhoneTF];
    
    codeTF = [[UITextField alloc] initWithFrame:CGRectMake(40, 140, SCREEN_WIDTH - 80 - 140, 40)];
    codeTF.placeholder = @"请输入验证码";
    codeTF.layer.borderWidth = 1;
    codeTF.layer.borderColor = [UIColor grayColor].CGColor;
    codeTF.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:codeTF];
    
    codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    codeBtn.frame = CGRectMake(40 + codeTF.frame.size.width + 10, 145, 130, 30);
    [codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [codeBtn setBackgroundColor:UIColorFromHex(0xd0021b, 1)];
    codeBtn.titleLabel.textColor = [UIColor whiteColor];
    [codeBtn addTarget:self action:@selector(codeBtnLimit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:codeBtn];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(SCREEN_WIDTH/2 - 90, 450 *SCREEN_HEIGHT/667, 180, 45);
    [sendBtn setTitle:@"提交修改" forState:UIControlStateNormal];
    sendBtn.backgroundColor = codeBtn.backgroundColor;
    sendBtn.titleLabel.textColor = [UIColor whiteColor];
    [sendBtn addTarget:self action:@selector(sendBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
}

- (void)codeBtnLimit:(id) sender{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(codeBtnAction) object:sender];
    [self performSelector:@selector(codeBtnAction) withObject:sender afterDelay:0.5f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)codeBtnAction{
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

- (void)sendBtnClickAction{
    if ([codeTF.text integerValue] != code) {
        [self presentAlert:@"验证码错误"];
        return;
    }
    
    NSString *urlStr = @"http://new.medapp.ranknowcn.com/api/m.php?action=upduserinfo&version=3.0";
    NSString *post = [NSString stringWithFormat:@"source=apple&os=ios&appid=7&version=3.3&mobile=%@&mobileverify=%@&deviceid=%@&userid=%ld&username=%@&imei=%@",PhoneTF.text,codeTF.text,[CureMeUtils defaultCureMeUtil].uniID,[CureMeUtils defaultCureMeUtil].userID,[CureMeUtils defaultCureMeUtil].userName,[CureMeUtils defaultCureMeUtil].UDID];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSData *response = sendFullRequest(urlStr, post, nil, NO, NO);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!response) {
            [self presentAlert:@"修改失败，请检查网络"];
            return ;
        }
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"%@",strResp);
        
        NSDictionary *returnDic = parseJsonResponse(response);
        if (!returnDic) {
            [self presentAlert:@"修改失败，返回错误数据"];
            return;
        }
        NSNumber *result = JsonValue([returnDic objectForKey:@"result"], CLASS_NUMBER);
        if ([result integerValue] !=1) {
            NSString *err = [returnDic objectForKey:@"msg"];
            [self presentAlert:err];
            return;
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    });
});

}


- (void)presentAlert:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"消息" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
