//
//  CMQueryViewController.m
//  私密健康医生
//
//  Created by Tim on 13-9-25.
//  Copyright (c) 2013年 Tim. All rights reserved.
//


#import "CMQueryViewController.h"
#import "CMMainTabViewController.h"
#import "CMMyChatListViewController.h"
#import "MyBookListViewController.h"
#import "KGModal.h"
#import "WebViewController.h"

// 基站定位文件
#import "CLGetGsmInfo.h"


@interface CMQueryViewController ()

@end


@implementation CMQueryViewController

@synthesize officeType = _officeType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _officeType = 0;
    }
    return self;
}

- (void)initialization
{
    [self.navigationItem setTitle:@"咨询"];
    
    if (_officeType <= 0)
        return;
    
    if (!officeSubTypeView) {
        officeSubTypeView = [[CMQAOfficeSubTypeView alloc] initWithFrame:CGRectZero];
        [officeSubTypeView setOfficeType:_officeType];
        [officeSubTypeView clearAllSubTypeBtns];
        [officeSubTypeView initSubTypeButtons];
        officeSubTypeView.delegate = self;
//        [officeSubTypeView switchViewTypeToQuery];
        [officeSubTypeView updateBackgroundImage:[UIImage imageNamed:@"layout_bg.png"]];
        [officeSubTypeView setHidden:NO];
        CGRect frame = officeSubTypeView.frame;
        if (IOS_VERSION >= 7.0) {
            //frame.origin.y = 20 + NAVIGATIONBAR_HEIGHT;
        }
        else {
            frame.origin.y = 0;
        }
        officeSubTypeView.frame = frame;
        [self.view addSubview:officeSubTypeView];
        [self.view sendSubviewToBack:officeSubTypeView];

        if (IOS_VERSION >= 7.0) {
            //frame = CGRectMake(0, officeSubTypeView.frame.size.height + 20 + NAVIGATIONBAR_HEIGHT, 320, 120);
            frame = CGRectMake(0, officeSubTypeView.frame.size.height, 320, 120);
        }
        else {
            frame = CGRectMake(0, officeSubTypeView.frame.size.height, 320, 120);
        }
        _sendAreaView.frame = frame;
//        frame = _sendAreaView.frame;
//        _sendAreaSendBtn.frame = CGRectMake(255, 120 - 38, 60, 36);
//        _inputField.frame = CGRectMake(5, 5, 310, 120 - 44);
        _sendAreaView.hidden = NO;
        NSLog(@"querySubTypeView: %@, sendAreaView: %@", officeSubTypeView, _sendAreaView);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    if (!officeSubTypeView) {
        [self initialization];
    }
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    NSNumber *hasMarkApp = [[NSUserDefaults standardUserDefaults] objectForKey:HAS_AGREEPROTOCOL];
    if (hasMarkApp && hasMarkApp.integerValue > 0) {
        _chooseBtn.hidden = YES;
        _protocolBtn.hidden = YES;
        _protocolLabel.hidden = YES;
    }
}

- (void)viewDidUnload {
    [self setSendAreaSendBtn:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chooseBtnClicked:(id)sender {
    _chooseBtn.selected = !_chooseBtn.selected;
}
- (IBAction)protocolBtnClicked:(id)sender {
    WebViewController *webVC = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    
    NSString* path=[[NSBundle mainBundle] pathForResource:@"protocol" ofType:@".html"];
    NSURL* url=[NSURL fileURLWithPath:path];
    NSString *str1 = [url absoluteString];
    [webVC setStrURL:str1];
    
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)sendBtnClicked:(id)sender {
    if (!_chooseBtn.hidden && !_chooseBtn.selected) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"咨询"
                                                        message:@"请先选择同意用户协议"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *oriQuestion = [_inputField text];
    NSString *question = [oriQuestion stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([question length] <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"咨询"
                                                        message:@"请输入要咨询的内容"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([question isEqualToString:[CureMeUtils defaultCureMeUtil].lastQueryString]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"咨询"
                                                        message:@"您已咨询过相同问题，请勿重复发送"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSNumber *hasAgreeProtocol = [NSNumber numberWithInt:1];
    [[NSUserDefaults standardUserDefaults] setObject:hasAgreeProtocol forKey:HAS_AGREEPROTOCOL];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // tim.wangj.remind 如果用户未登录，添加createuserdata调用
    // 1. 如果未登录，发送激活默认账户请求
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        NSString *post = [NSString stringWithFormat:@"action=createuserdata&deviceid=%@&appid=7&addrdetail=%@&token=%@", [CureMeUtils defaultCureMeUtil].uniID, [CureMeUtils defaultCureMeUtil].encodedLocateInfo, nil];
        NSData *response = sendRequest(@"m.php", post);
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"createuserdata resp: %@", strResp);
        NSDictionary *respDict = parseJsonResponse(response);
        NSNumber *result = [respDict objectForKey:@"result"];
        if (!result || [result integerValue] != 1) {
            NSLog(@"createuserdata result invalid %@", strResp);
            return;
        }

        NSNumber *userid = [respDict objectForKey:@"msg"];
        if (!userid || [userid integerValue] <= 0) {
            NSLog(@"createuserdata userid invalid %@", strResp);
            return;
        }
        
        [CureMeUtils defaultCureMeUtil].userID = [userid integerValue];
        [[NSUserDefaults standardUserDefaults] setObject:userid forKey:USER_ID];
        NSNumber *SWTID = [[NSNumber alloc] initWithInteger:0];
        [[NSUserDefaults standardUserDefaults] setObject:SWTID forKey:USER_SWT_ID];
        [CureMeUtils defaultCureMeUtil].userName = [CureMeUtils defaultCureMeUtil].uniID;
        [[NSUserDefaults standardUserDefaults] setObject:[CureMeUtils defaultCureMeUtil].uniID forKey:USER_REGISTERNAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    // 发送正式咨询请求
    NSString *sendQuestion = [question stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"sendQuestion: before encoding: %@ after encoding: %@", question, sendQuestion);
    
    NSString *encodeAddr = [CureMeUtils defaultCureMeUtil].encodedLocateInfo;
//    NSString *post = [NSString stringWithFormat:@"action=postquestion&userid=%d&type=%d&typechild=%d&question=%@&img=&addrdetail=%@", [CureMeUtils defaultCureMeUtil].userID, _officeType, _subOfficeType, sendQuestion, encodeAddr ? encodeAddr : @""];
    NSString *post = [NSString stringWithFormat:@"action=postquestion&userid=%ld&type=%ld&typechild=%ld&question=%@&img=&addrdetail=%@",
                      (long)[CureMeUtils defaultCureMeUtil].userID,
                      (long)_officeType, (long)_subOfficeType,
                      sendQuestion,
                      encodeAddr];
    NSLog(@"zixun: %@", post);
    NSData *response = sendRequest(@"m.php", post);
    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"zixun resp:%@", strResp);
    NSDictionary *respDict = parseJsonResponse(response);
    NSNumber *result = [respDict objectForKey:@"result"];
    if (!result || 0 == [result integerValue]) {
        NSString *error = [respDict objectForKey:@"msg"];
        NSLog(@"sendQuestion failed %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送咨询失败"
                                                        message:error
                                                        delegate:self
                                                        cancelButtonTitle:@"确定"
                                                        otherButtonTitles:nil];
        [alert show];
    }
    else {
        if (!alertViewController) {
            alertViewController= [[CMAlertViewController alloc] initWithNibName:@"CMAlertViewController" bundle:nil];
            alertViewController.delegate = self;
            [alertViewController setMsgTitle:@"发布咨询"];
            [alertViewController setMsgContent:@"咨询发布成功，进入我的咨询查看回复"];
        }
        
        [[KGModal sharedInstance] setModalBackgroundColor:[UIColor clearColor]];
        [[KGModal sharedInstance] showWithContentView:alertViewController.view andAnimated:YES];
    }
    
    [CureMeUtils defaultCureMeUtil].lastQueryString = _inputField.text;
    _inputField.text = @"";
    [_inputField resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*[super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    UIView *touchView = touch.view;
    if (![touchView isEqual:_inputField]) {
        [_inputField resignFirstResponder];
        [_inputField.superview resignFirstResponder];
    }*/
    
    NSSet *setTouches = [event allTouches];
    UITouch *touch = [setTouches anyObject];
    
    switch ([setTouches count]) {
        case 1:
            if (![touch isKindOfClass:[UITextField class]]) {
                [_inputField resignFirstResponder];
            }
            break;
            
        default:
            break;
    }
    
    [super touchesBegan:touches withEvent:event];
}

#pragma mark Properties
- (void)setOfficeType:(NSInteger)officeType
{
    _officeType = officeType;
    
    if (!officeSubTypeView) {
        [self initialization];
    }
}

- (void)setSubOfficeType:(NSInteger)subOfficeType
{
    _subOfficeType = subOfficeType;
    
    if (!officeSubTypeView) {
        [self initialization];
    }
    [officeSubTypeView setOfficeSubType:_subOfficeType];
}


#pragma mark CMQAOfficeSubTypeViewDelegate
- (void)officeSubTypeSelected:(NSInteger)subType
{
    _subOfficeType = subType;
}


#pragma mark CMAlertViewControllerDelegate
- (void)confirmBtnClickForDelegate
{
    // 跳转到“我的咨询”页面
    CMMainTabViewController *mainTabVC = (CMMainTabViewController *)[[self.navigationController viewControllers] objectAtIndex:0];

    {
        NSMutableArray *VCs = [[NSMutableArray alloc] initWithArray:[mainTabVC viewControllers]];
        // “我的咨询”页面
        UIViewController *listViewController = [VCs objectAtIndex:1];
        if (![listViewController isKindOfClass:[CMMyChatListViewController class]]) {
            CMMyChatListViewController *myChatListVC = [[CMMyChatListViewController alloc] initWithNibName:@"CMMyChatListViewController" bundle:nil];//[[CMMyChatListViewController alloc] initWithStyle:UITableViewStylePlain];
            [VCs setObject:myChatListVC atIndexedSubscript:1];
        }
        
        // “我的预约”页面
        listViewController = [VCs objectAtIndex:3];
        if (![listViewController isKindOfClass:[MyBookListViewController class]]) {
            MyBookListViewController *myBookListVC = [[MyBookListViewController alloc] initWithNibName:@"MyBookListViewController" bundle:nil]; //[[MyBookListViewController alloc] initWithStyle:UITableViewStylePlain];
            [VCs setObject:myBookListVC atIndexedSubscript:3];
        }
        [mainTabVC setViewControllers:[VCs copy]];
    }
    
    [mainTabVC setSelectedIndex:1];
    [mainTabVC.customTabBarView selectButtonAtIndex:1];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end




