//
//  ChangePasswordViewController.m
//  CureMe
//
//  Created by Tim on 12-9-21.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController
@synthesize firstNewPWField;
@synthesize secondNewPWField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"修改密码"];
    
    // 未读消息数
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfUnreadMsgCountUpdated:) name:NTF_UNREADMSGCOUNT_UPDATED object:nil];
}

- (void)viewDidUnload
{
    [self setFirstNewPWField:nil];
    [self setSecondNewPWField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self ntfUnreadMsgCountUpdated:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ntfUnreadMsgCountUpdated:(NSNotification *)note
{
    NSInteger unreadCount = [CureMeUtils defaultCureMeUtil].unreadMessageCount;
    
    if (unreadCount > 0) {
        [[super unreadMsgBtn] setTitle:[NSString stringWithFormat:@"%ld", (long)unreadCount] forState:UIControlStateNormal];
        [super unreadMsgBtn].hidden = NO;
    }
    else {
        [super unreadMsgBtn].hidden = YES;
    }
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)confirmBtnClick:(id)sender {
    if (!firstNewPWField.text || firstNewPWField.text.length <= 0 || !secondNewPWField.text || secondNewPWField.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"修改密码"
                              message:@"请输入您的新密码"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (![firstNewPWField.text isEqualToString:secondNewPWField.text]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"修改密码"
                              message:@"请确保两次输入的新密码一致"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;        
    }
    
    if ([CureMeUtils defaultCureMeUtil].userID <= 0) {
        NSLog(@"confirmBtnClick changepwd userID invalid: %ld", (long)[CureMeUtils defaultCureMeUtil].userID);
        return;
    }
    
    // 发送修改密码请求
    NSString *post = [[NSString alloc] initWithFormat:@"action=changepwd&password=%@&userid=%ld", [firstNewPWField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], (long)[CureMeUtils defaultCureMeUtil].userID];
    
    NSData *response = sendRequest(@"m.php", post);

    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"action=resetpwd resp: %@", strResp);
    
    NSDictionary *jsonData = parseJsonResponse(response);
    NSNumber *result = [jsonData objectForKey:@"result"];
    if (!result || result.integerValue != 1) {
        NSLog(@"change password req result invalid");
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"修改密码"
                          message:@"密码修改成功"
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end





