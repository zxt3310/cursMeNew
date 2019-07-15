//
//  FeedBackViewController.m
//  私密健康医生
//
//  Created by 张信涛 on 2017/4/19.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import "FeedBackViewController.h"

@interface FeedBackViewController ()
{
    UITextView *feedView;
    UITextField *placeHolder;
    UITextField *mailTf;
}
@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"用户反馈";
    
    UILabel *titleLb = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20,40)];
    titleLb.text = @"欢迎您提出宝贵意见和建议，您的建议对我们改善服务非常有帮助。";
    titleLb.font = [UIFont systemFontOfSize:14];
    titleLb.numberOfLines = 0;
    titleLb.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:titleLb];
    
    feedView = [[UITextView alloc] initWithFrame:CGRectMake(10, 60, SCREEN_WIDTH - 20, 150)];
    feedView.contentSize = CGSizeMake(SCREEN_WIDTH - 20 - 10, 10);
    feedView.delegate = self;
    feedView.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:feedView];
    
    placeHolder = [[UITextField alloc] initWithFrame:CGRectMake(5, 8, feedView.frame.size.width - 5, 15)];
    placeHolder.layer.borderWidth = 0;
    placeHolder.textColor = UIColorFromHex(0x9b9b9b, 1);
    placeHolder.enabled = NO;
    placeHolder.text = @"请输入您的反馈意见（字数500以内）";
    [feedView addSubview:placeHolder];
    
    UILabel *mailLb = [[UILabel alloc] initWithFrame:CGRectMake(10, 230, SCREEN_WIDTH - 20, 20)];
    mailLb.text = @"请留下您的邮箱地址";
    mailLb.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:mailLb];
    
    mailTf = [[UITextField alloc] initWithFrame:CGRectMake(10, 260, SCREEN_WIDTH - 20,40)];
    mailTf.font = [UIFont systemFontOfSize:15];
    mailTf.keyboardType = UIKeyboardTypeEmailAddress;
    mailTf.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mailTf];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(SCREEN_WIDTH/2 - 70, 400, 140, 45);
    [sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [sendBtn setTitle:@"提交反馈" forState:UIControlStateNormal];
    [sendBtn setBackgroundColor:UIColorFromHex(0xd0021b, 1)];
    sendBtn.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:sendBtn];
}

- (void)didTextViewChange:(NSNotification *)sender{
    UITextView *textView = (UITextView *)sender.object;
    if (textView.text.length == 0) {
        placeHolder.text = @"请输入您的反馈意见（字数500以内）";
    }
    else{
        placeHolder.text = @"";
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTextViewChange:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)sendBtnClick{
    if (![self isValidateEmail:mailTf.text]) {
        [self presentAlert:@"请正确输入邮箱地址"];
    }
    NSString *urlStr = @"http://new.medapp.ranknowcn.com/api/m.php?action=userfeedback&version=3.0";
    NSString *post = [NSString stringWithFormat:@"source=apple&os=ios&appid=7&version=3.3&deviceid=%@&userid=%ld&imei=%@&content=%@&contacts=%@",[CureMeUtils defaultCureMeUtil].uniID,[CureMeUtils defaultCureMeUtil].userID,[CureMeUtils defaultCureMeUtil].UDID,feedView.text,mailTf.text];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *response = sendFullRequest(urlStr, post, nil, NO, NO);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!response) {
                [self presentAlert:@"提交失败，请重试"];
                return ;
            }
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"%@",strResp);
            
            NSDictionary *returnDic = parseJsonResponse(response);
            if (!returnDic) {
                [self presentAlert:@"提交失败"];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentAlert:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"消息" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end
