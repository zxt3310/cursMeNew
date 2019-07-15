//
//  LoginViewController.m
//  CureMe
//
//  Created by Tim on 12-8-13.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "CMMainTabViewController.h"
#import "CMMyChatListViewController.h"
#import "MyBookListViewController.h"
#import "JSONKit.h"
#import "CMCustomViews.h"

@interface LoginViewController ()
{
    LoadingView *loading;
}
@end

@implementation LoginViewController
@synthesize phoneNoField;
@synthesize passwordField;

// AlertView Delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

// LoginViewController methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //[self.navigationItem setTitle:@"登录账号"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"登录账号"];

    phoneNoField.placeholder = @"请输入账号的手机号码";
    
    passwordField.placeholder = @"请输入您的密码";
    passwordField.secureTextEntry = YES;
    
    loading = [[LoadingView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-40, SCREEN_HEIGHT/3, 80, 79)];
    loading.hidden = YES;
    [self.view addSubview:loading];
    
//    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
}

- (void)viewDidUnload
{
    [self setPhoneNoField:nil];
    [self setPasswordField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"LoginViewController didReceiveMemoryWarning");
    
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([CureMeUtils defaultCureMeUtil].hasLogin) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *setTouches = [event allTouches];
    UITouch *touch = [setTouches anyObject];
    
    switch ([setTouches count]) {
        case 1:
            if (![touch isKindOfClass:[UITextField class]]) {
                NSArray *subViews = self.view.subviews;
                for (UIView *subView in subViews) {
                    if ([subView isKindOfClass:[UITextField class]]) {
                        [subView resignFirstResponder];
                        [subView.superview resignFirstResponder];
                    }
                }
            }
            break;
            
        default:
            break;
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)login:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        loading.hidden = NO;
        phoneNo = [phoneNoField text];
        password = [passwordField text];

        if (!phoneNo || !password || phoneNo.length <= 0 || password.length <= 0) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"登录账号"
                                  message:@"您输入的手机号或密码错误"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0), ^{
            // 发送注册请求，获取验证码
            // 发送注册请求，如果失败则提示错误（回到根页面）；如果成功则回到登陆页面
            NSString *post = nil;
        //    NSString *responseString = nil;
            NSData *returnData = nil;
            // 获取注册验证码请求
            post = [[NSString alloc] initWithFormat:@"action=login&username=%@&password=%@", [phoneNo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            returnData = sendRequest(@"m.php", post);
        //    responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        //    NSLog(@"%@", responseString);

            dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *jsonDict = parseJsonResponse(returnData);
            NSNumber *result = [jsonDict objectForKey:@"result"];
            NSNumber *userID = nil;
            NSString *strUserID = nil;
                
                loading.hidden = YES;
                
            if ([result intValue] == 1) {
                strUserID = [jsonDict objectForKey:@"msg"];
                userID = [jsonDict objectForKey:@"msg"];
                NSLog(@"login ok");
            }
            else {
                NSString *msg = [jsonDict objectForKey:@"msg"];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"登录账号"
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
            }
        });
    });
}

- (IBAction)registry:(id)sender
{
    if (!registerViewController) {
        registerViewController = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController"
                                                                          bundle:nil];
    }
    
    if (registerViewController) {
        [[self navigationController] pushViewController:registerViewController animated:YES];
    }
}

@end
