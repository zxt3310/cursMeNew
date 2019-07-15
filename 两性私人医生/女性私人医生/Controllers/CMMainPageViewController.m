//
//  CMMainPageViewController.m
//  私密健康医生
//
//  Created by Tim on 13-1-9.
//  Copyright (c) 2013年 Tim. All rights reserved.
//


#import "CMMainPageViewController.h"
#import "LoginViewController.h"
#import "CMQAViewController.h"
#import "WebViewController.h"
#import "CMPickerViewController.h"
#import "KGModal.h"


@interface CMMainPageViewController ()
{
    WKWebView *html5WebView;
    UITextField *addressTF;
    UITextField *quickAskTF;
    UIView *coverView;
    
    NSInteger subId;
    NSInteger childId;
    NSString *key;
    NSString *lastLocateInfo;
}
@end

@implementation CMMainPageViewController
BOOL isLFMShow;

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
    isLFMShow = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfLocationSucceess:) name:NTF_LocationComfirmed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfLocationFailed:) name:NTF_LocateServiceNotAvailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfNetworkNotReachable:) name:NTF_NetNotReachable object:nil];

    // 2. 初始化所有科室的子分类(在后台线程完成)
    [[CMDataUtils defaultDataUtil] initAllOfficeSubTypeData];
    
    html5WebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 88, SCREEN_WIDTH, SCREEN_HEIGHT-(FitIpX(137)))];
    [self.view addSubview:html5WebView];
    html5WebView.navigationDelegate = self;
    NSURLRequest *url = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/h5_new/index_smjk.html?appid=7&addrdetail=%@&source=apple",[CureMeUtils defaultCureMeUtil].encodedLocateInfo]]];
    [html5WebView loadRequest:url];
    lastLocateInfo = [CureMeUtils defaultCureMeUtil].encodedLocateInfo;
    
    [self setTopView];
}

- (void)setTopView{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, FitIpX(88))];
    topView.backgroundColor = UIColorFromHex(0xf9f9f9, 1);
    topView.layer.shadowColor = [UIColor blackColor].CGColor;
    topView.layer.shadowOffset = CGSizeMake(0, 1);
    topView.layer.shadowOpacity = 0.3;
    [topView setClipsToBounds:NO];
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(19, FitIpX(50), 20, 20)];
    logoView.image = [CMImageUtils defaultImageUtil].logoImage;
    [topView addSubview:logoView];
    
    UILabel *logoLb = [[UILabel alloc] initWithFrame:CGRectMake(41, FitIpX(50), 150, 18)];
    logoLb.font = [UIFont systemFontOfSize:17];
    logoLb.textColor = UIColorFromHex(0xd0021b,1);
    logoLb.text = @"私密健康医生";
    [topView addSubview:logoLb];
    
    quickAskTF = [[UITextField alloc] initWithFrame:CGRectMake(14 *SCREEN_WIDTH/375, FitIpX(49), 354 * SCREEN_WIDTH/375, 30)];
    quickAskTF.layer.cornerRadius = 5;
    quickAskTF.backgroundColor = [UIColor whiteColor];
    quickAskTF.font = [UIFont systemFontOfSize:14];
    UIView *leftImg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 39, 28)];
    UIImageView *leftImgView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 7, 18, 16)];
    leftImgView.image = [CMImageUtils defaultImageUtil].qaListQuestionDefultImage;
    [leftImg addSubview:leftImgView];
    quickAskTF.leftView = leftImg;
    quickAskTF.leftViewMode = UITextFieldViewModeAlways;
    quickAskTF.placeholder = @"请输入您要咨询的问题";
    quickAskTF.delegate = self;
    quickAskTF.tag = 1;
    quickAskTF.layer.borderColor = UIColorFromHex(0xe8e8e8,1).CGColor;
    quickAskTF.layer.borderWidth = 0.5;
    //[topView addSubview:quickAskTF];
    
    addressTF = [[UITextField alloc] initWithFrame:CGRectMake(280 *SCREEN_WIDTH/375, FitIpX(51), 80 *SCREEN_WIDTH/375, 18)];
    addressTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 11, 18)];
    UIImageView *adLeftImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 11, 14)];
    adLeftImgView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ico_dizhi_and_pink" ofType:@"png" inDirectory:@"images"]];
    [addressTF.leftView addSubview:adLeftImgView];
    
    addressTF.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 18)];
    UIImageView *adRightImgVIew = [[UIImageView alloc] initWithFrame:CGRectMake(0, 4, 10, 6)];
    adRightImgVIew.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ico_chevron" ofType:@"png" inDirectory:@"images"]];
    [addressTF.rightView addSubview:adRightImgVIew];
    addressTF.leftViewMode = addressTF.rightViewMode = UITextFieldViewModeAlways;
    addressTF.textColor = UIColorFromHex(0xd0021b,1);
    addressTF.font = [UIFont systemFontOfSize:13];
    addressTF.tag = 2;
    addressTF.delegate = self;
    addressTF.text = @"定位中...";
    [topView addSubview: addressTF];
    
    [self.view addSubview:topView];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *schemeStr = navigationAction.request.URL.scheme;
    if ([navigationAction.request.URL.absoluteString containsString:@"index_smjk.html"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    if ([schemeStr isEqualToString:@"medapp"]) {
        if ([navigationAction.request.URL.absoluteString containsString:@"depart"]) {
            if ([navigationAction.request.URL.absoluteString containsString:@"depart_2"]) {
                NSArray *idAry = navigationAction.request.URL.pathComponents;
                if (idAry.count == 5 && ![(NSString*)idAry[4] isEqualToString:@"null"]) {
                    subId = [idAry[idAry.count - 3] integerValue];
                    childId = [idAry[idAry.count - 2] integerValue];
                    key = idAry[idAry.count - 1];
                    //新增广告图片
                    coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                    UIImageView *backImage = [[UIImageView alloc] initWithFrame:coverView.frame];
                    backImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pic.medapp.ranknowcn.com/client/image.php?key=%@&type=L&version=3.0",key]]]];
                    [coverView addSubview:backImage];
                    
                    UIButton *connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    connectBtn.frame = CGRectMake(0, SCREEN_HEIGHT - 50, SCREEN_WIDTH, 50);
                    [connectBtn setBackgroundColor:UIColorFromHex(0x0168b7,1)];
                    [connectBtn addTarget:self action:@selector(connectBtnClick) forControlEvents:UIControlEventTouchUpInside];
                    [connectBtn setTitle:@"立即咨询" forState:UIControlStateNormal];
                    [coverView addSubview:connectBtn];
                    
                    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewTapAction)];
                    backImage.userInteractionEnabled = YES;
                    [backImage addGestureRecognizer:gesture];
                    
                    [[UIApplication sharedApplication].keyWindow addSubview:coverView];
                }
                else{
                    if (idAry.count == 4) {
                        subId = [idAry[idAry.count - 2] integerValue];
                        childId = [idAry[idAry.count - 1] integerValue];
                    }
                    else{
                        subId = [idAry[idAry.count - 3] integerValue];
                        childId = [idAry[idAry.count - 2] integerValue];
                    }
                    [self connectBtnClick];
                }
            }
            else{
                NSInteger officeId = [navigationAction.request.URL.lastPathComponent integerValue];
                CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
                qaViewController.officeType = officeId;
                [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
            }
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        }
        else if ([navigationAction.request.URL.absoluteString containsString:@"ads"]){
            NSInteger officeId = [navigationAction.request.URL.lastPathComponent integerValue];
            CMNewQueryViewController *queryVC = [CMNewQueryViewController new];
            queryVC.officeType = officeId;
            queryVC.subOfficeType = 0;
            queryVC.chatUserID = [CureMeUtils defaultCureMeUtil].userID;
            [self.navigationController pushViewController:queryVC animated:YES];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        else if ([navigationAction.request.URL.absoluteString containsString:@"news"]){
            CMMainTabViewController *mainTabVC = (CMMainTabViewController *)[[self.navigationController viewControllers] objectAtIndex:0];
            [mainTabVC tabWasSelected:2];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        else if ([navigationAction.request.URL.absoluteString containsString:@"quickask"]){
            CMQuickAskChoosenAndLocationViewController *quickAskView = [[CMQuickAskChoosenAndLocationViewController alloc] init];
            
            quickAskView.isQuickAskView = YES;
            
            [[CMAppDelegate Delegate].navigationController pushViewController:quickAskView animated:YES];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    //19-04-16 新两性新增协议
    else if ([schemeStr isEqualToString:@"app"]){
        NSString *protocal = @"app://webview/depart/";
        NSString *adsProtocal = @"app://webview/ads/";
        NSString *strURL = navigationAction.request.URL.absoluteString;
        if ([strURL containsString:protocal] || [strURL containsString:adsProtocal]) {
            NSString *curallWeb = [strURL stringByReplacingOccurrencesOfString:protocal withString:@""];
            WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
            webViewController.strURL = curallWeb;
            [self.navigationController pushViewController:webViewController animated:YES];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    else{
        NSString *strURL = navigationAction.request.URL.absoluteString;
        if ([[strURL lowercaseString] containsString:@"http://new.medapp.ranknowcn.com/famous_doctors/doctor_info.php?did="] && ![[strURL lowercaseString] containsString:@"&"]){
            
            WebViewController *newWeb = [[WebViewController alloc] init];
            newWeb.strURL = strURL;
            newWeb.isPaymentPage = YES;
            [self.navigationController pushViewController:newWeb animated:YES];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        
        WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
        webViewController.strURL = navigationAction.request.URL.absoluteString;
        [self.navigationController pushViewController:webViewController animated:YES];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyCancel);
    return;
}

//protoclView
- (void)pushNewQuary:(NSInteger)office1 and:(NSInteger)office2{
    [coverView removeFromSuperview];
    CMNewQueryViewController *qureVc = [CMNewQueryViewController new];
    qureVc.officeType = office1;
    qureVc.subOfficeType = office2;
    [self.navigationController pushViewController:qureVc animated:YES];
}

- (void)coverViewTapAction{
    [coverView removeFromSuperview];
}
- (void)connectBtnClick{
    NSNumber *hasMarkApp = [[NSUserDefaults standardUserDefaults] objectForKey:HAS_AGREEPROTOCOL];
    if (!hasMarkApp || hasMarkApp.integerValue == 0) {
        CMQAProtocolView *protocl = [[CMQAProtocolView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        protocl.CmLocationDelegate = self;
        protocl.office1 = subId;
        protocl.office2 = childId;
        CGRect temp = protocl.protcolViewFrame;
        temp.origin.y += 50*SCREEN_HEIGHT/667;
        protocl.protcolViewFrame = temp;
        
        [[UIApplication sharedApplication].keyWindow addSubview:protocl];
    }
    else{
        [coverView removeFromSuperview];
        CMNewQueryViewController *queryVC = [CMNewQueryViewController new];
        queryVC.officeType = subId;
        queryVC.subOfficeType = childId;
        queryVC.chatUserID = [CureMeUtils defaultCureMeUtil].userID;
        [self.navigationController pushViewController:queryVC animated:YES];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NTF_LocationComfirmed object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NTF_LocateServiceNotAvailable object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // 0. 显示用户地区
    NSNumber *rID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGION];
    if (!rID || rID.integerValue <= 0) {
        _regionLabel.text = [CureMeUtils defaultCureMeUtil].province;
    }
    else {
        NSString *cityName = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CITY_NAME];
        _regionLabel.text = [NSString stringWithFormat:@"%@ %@", [[CureMeUtils defaultCureMeUtil] regionWithRegionID:rID.integerValue], cityName];
    }
    
//    // 1. 首次使用激活判断
//    [self performSelectorInBackground:@selector(threadFirstUseOperation) withObject:nil];

    NSLog(@"MainPageVC willAppear: %@", self.view);

    if (IOS_VERSION >= 7.0) {
       self.tabBarController.navigationController.navigationBar.alpha = 0;
    }
    [self.tabBarController.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self locateBtnClick:nil];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"MainPageVC willDisappear: %@", self.view);
    
    if (IOS_VERSION >= 7.0) {
        self.tabBarController.navigationController.navigationBar.alpha = 1.0;
    }
    [self.tabBarController.navigationController setNavigationBarHidden:NO];
    //else {
    //    [self.tabBarController.navigationController setNavigationBarHidden:NO];
    //}
}

- (void)confirmBtnClickForDelegate
{
    NSLog(@"MainPageVC confirmMark btn click");
    NSNumber *hasMarkApp = [NSNumber numberWithInt:1];
    [[NSUserDefaults standardUserDefaults] setObject:hasMarkApp forKey:HAS_MARKAPP];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)cancelBtnClickForDelegate
{
    NSLog(@"MainPageVC cancelMark btn click");
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LAST_REFUSEMARK_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)ntfUnreadMsgCountUpdated:(NSNotification *)note
{
    // 这里更新主界面TabBar的未读消息小圆圈
    NSLog(@"CMMainPageViewController ntfUnreadMsgCountUpdated");
}

- (void)threadFirstUseOperation
{
    @autoreleasepool {
        // 初始化首次使用信息
        NSNumber *hasFirstUsed = [[NSUserDefaults standardUserDefaults] objectForKey:HAS_FIRST_USED];
        if (!hasFirstUsed || hasFirstUsed.integerValue != 1) {
            NSNumber *hasSentLocationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:HAS_SENT_LOCATIONINFO];
            // 开始定位并发送用户位置
            if (!hasSentLocationInfo || hasSentLocationInfo.integerValue != 1) {
                // 标记还未定位
                [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc] initWithInt:0] forKey:HAS_SENT_LOCATIONINFO];
                [[NSUserDefaults standardUserDefaults] synchronize];
                // 开始定位
                [[CureMeUtils defaultCureMeUtil] startLocationing];
            }
            
            // 发送首次使用App请求
            NSString *post = [[NSString alloc] initWithFormat:@"action=jihuo&macaddr=%@", [CureMeUtils defaultCureMeUtil].UDID];
            NSData *response = sendRequest(@"m.php", post);
            
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"action=jihuo resp: %@", strResp);
            
            NSDictionary *jsonData = parseJsonResponse(response);
            NSNumber *result = [jsonData objectForKey:@"result"];
            if (!result || result.integerValue != 1) {
                NSLog(@"action=jihuo req failed: %@", strResp);
            }
            else {
                NSString *uniqueID = [jsonData objectForKey:@"msg"];
                NSLog(@"uniqueID: %@", uniqueID);
                [CureMeUtils defaultCureMeUtil].uniID = uniqueID;
                [[NSUserDefaults standardUserDefaults] setObject:uniqueID forKey:USER_UNIQUE_ID];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:HAS_FIRST_USED];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // 如果已经获得设备Push Token则发送更新Token请求
                updateIOSPushInfo();
                
                //                // 提交用户位置信息
                //                [[CureMeUtils defaultCureMeUtil] sendUserLocationInfo];
            }
        }
    }
}

- (void)ntfNetworkNotReachable:(NSNotification *)note
{
    if (!alertViewController) {
        alertViewController = [[CMAlertViewController alloc] initWithNibName:@"CMAlertViewController" bundle:nil];
        alertViewController.msgTitle = @"网络连接";
        alertViewController.msgContent = @"很抱歉当前网络连接存在异常，无法获取数据。";
    }
    
    [[KGModal sharedInstance] setModalBackgroundColor:[UIColor clearColor]];
    [[KGModal sharedInstance] showWithContentView:alertViewController.view andAnimated:YES];
}

- (void)ntfLocationSucceess:(NSNotification *)note
{
    [self updateRegionDisplay];
}

- (void)ntfLocationFailed:(NSNotification *)note
{
//    if (isLFMShow) return;
//    isLFMShow = YES;
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位" message:@"定位功能当前不可用" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
    
    NSLog(@"didFailLoadWithError");
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[CureMeUtils defaultCureMeUtil] startLocationing];
//    });
}

- (void)updateRegionDisplay
{
    // 0. 初始化地区Label
    NSString *locateAddr = [CureMeUtils defaultCureMeUtil].province;
    NSString *city2 = [CureMeUtils defaultCureMeUtil].cityOrDistrict;
    if (locateAddr && locateAddr.length > 0) {
        addressTF.text = [NSString stringWithFormat:@" %@ %@", locateAddr, city2];

        // 如果用户已经登录，更新用户的地区设置
        if ([CureMeUtils defaultCureMeUtil].hasLogin) {
            // 更新服务端用户地区信息
            NSNumber *rID = [[CureMeUtils defaultCureMeUtil] regionIDWithRegionName:locateAddr];
            NSNumber *cID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CITY];
            if (!cID)
                cID = [NSNumber numberWithInt:0];
            
            NSString *post = [NSString stringWithFormat:@"action=upduserinfo&userid=%ld&city=%ld&city2=%ld&addrdetail=%@", (long)[CureMeUtils defaultCureMeUtil].userID, (long)rID.integerValue, (long)cID.integerValue, [CureMeUtils defaultCureMeUtil].encodedLocateInfo];
            NSData *response = sendRequest(@"m.php", post);
            NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSLog(@"post: %@ resp: %@", post, strResp);
            
            [[CureMeUtils defaultCureMeUtil] updateUserRegion:rID];
        }
    }
    else {
        NSNumber *region = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGION];
        NSString *city = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CITY_NAME];
        if (region) {
            addressTF.text = [NSString stringWithFormat:@" %@ %@", [[CureMeUtils defaultCureMeUtil] regionWithRegionID:region.integerValue], city];
        }
    }
    
    CGRect temp = addressTF.frame;
    temp.size.width = addressTF.text.length * 13 + 12;
    temp.origin.x = quickAskTF.frame.origin.x + quickAskTF.frame.size.width - temp.size.width;
    addressTF.frame = temp;
    
    //reload 主页
    if (![[CureMeUtils defaultCureMeUtil].encodedLocateInfo isEqualToString:lastLocateInfo]) {
        lastLocateInfo = [CureMeUtils defaultCureMeUtil].encodedLocateInfo;
        NSURLRequest *url = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/h5_new/index_smjk.html?appid=7&addrdetail=%@&source=apple",[CureMeUtils defaultCureMeUtil].encodedLocateInfo]]];
        [html5WebView loadRequest:url];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setRegionLabel:nil];
    [self setEntranceScrollView:nil];
    [self setHomeTopView:nil];
    [self setChangeLocationBtn:nil];
    [self setLocateBtn:nil];
    [self setReaddImg:nil];
    [super viewDidUnload];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect frame = _homeTopView.frame;
    frame.origin.y = -_entranceScrollView.contentOffset.y > 0 ? 20 : 20+(-_entranceScrollView.contentOffset.y / 3);
    
    _homeTopView.frame = frame;
    
    CGRect locateBtnFrame = _locateBtn.frame;
    locateBtnFrame.origin.y = 93 + (_entranceScrollView.contentOffset.y / 3);
    _locateBtn.frame = locateBtnFrame;
    
    CGRect regionLabelFrame = _regionLabel.frame;
    regionLabelFrame.origin.y = 99 + (_entranceScrollView.contentOffset.y / 3);
    _regionLabel.frame = regionLabelFrame;
    
    CGRect changeLocateBtnFrame = _changeLocationBtn.frame;
    changeLocateBtnFrame.origin.y = 94 + (_entranceScrollView.contentOffset.y / 3);
    _changeLocationBtn.frame = changeLocateBtnFrame;
    
    CGRect readdImgFrame = _readdImg.frame;
    readdImgFrame.origin.y = 102 + (_entranceScrollView.contentOffset.y / 3);
    _readdImg.frame = readdImgFrame;
    
    NSLog(@"");
}

- (IBAction)meirongBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_MEIRONG;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)fukeBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_FUKE;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)chankeBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_CHANKE;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)pifukeBtnCick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_PIFUKE;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)zhongyiBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
//    qaViewController.officeType = OFFICE_ZHONGYI;
    qaViewController.officeType = OFFICE_KOUQIANG;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)yankeBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_YANKE;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)corpHospBtnClick:(id)sender {
    WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];

    NSNumber *region = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:USER_REGION];
    NSString *strUrl = [NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/hospital/?citycode=%ld&deviceid=%@", (long)region.integerValue, [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID]];
    [webViewController setStrURL:strUrl];
    NSLog(@"CorpHospital: %@", strUrl);

    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)activityBtnClick:(id)sender {
    WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)jiakangBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_JIAKANG;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)ganbingBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_GANBING;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)naotanBtnBlick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_NAOTAN;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)gukeBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_GUKE;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)dianxianBtnBlick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_DIANXIAN;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)gangchangBtnClick:(id)sender
{
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_GANGCHANG;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)bybyBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_BYBY;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)xinzangBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_XINZANG;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)shenjingBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_SHENJING;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)erbihouBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_ERBIHOU;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)weichangBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_WEICHANG;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)tangniaobingBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_TANGNIAOBING;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)zhongliuBtnClick:(id)sender {
    CMQAViewController *qaViewController = [[CMQAViewController alloc] initWithNibName:@"CMQAViewController" bundle:nil];
    qaViewController.officeType = OFFICE_ZHONGLIU;
    
    [[CMAppDelegate Delegate].navigationController pushViewController:qaViewController animated:YES];
}

- (IBAction)locateBtnClick:(id)sender {
    [[CureMeUtils defaultCureMeUtil] startLocationing];
}

- (IBAction)changeLocationBtnClick:(id)sender {
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    
    // 初始化选择地区的Modal ViewController
    if (!pickerViewController) {
        pickerViewController = [[CMPickerViewController alloc] initWithNibName:@"CMPickerViewController" bundle:nil];
        [pickerViewController setPickerColumnCount:PICKER_COLUMN_TWO];
    }
    NSDictionary *regionDict = [[CureMeUtils defaultCureMeUtil] regionDictionaryForUser];
    NSArray *regionArray = [[CureMeUtils defaultCureMeUtil] regionSortedKeys];
    NSMutableArray *pickerDataArray = [[NSMutableArray alloc] init];
    for (NSString *key in regionArray) {
        [pickerDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:key, @"id", [regionDict objectForKey:key], @"name", nil]];
    }
    NSLog(@"firstColumn: %@", pickerDataArray);
    // 设置省份
    [pickerViewController setFirstColumnData:pickerDataArray];

    // 设置市区
    NSNumber *firstID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_REGION];
    NSArray *cityArray = nil;
    if (firstID) {
        cityArray = [[CureMeUtils defaultCureMeUtil] cityArrayWithRegionID:firstID.integerValue];
    }
    else {
        firstID = [[pickerDataArray objectAtIndex:0] objectForKey:@"id"];
        cityArray = [[CureMeUtils defaultCureMeUtil] cityArrayWithRegionID:firstID.integerValue];
    }
    [pickerViewController setSecondColumnData:cityArray];

    // 设置选中的省、直辖市、市区数值
    NSNumber *secondID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CITY];
    if (!secondID) {
        secondID = [NSNumber numberWithInt:0];
    }
    [pickerViewController setSelectedIDAtFirstColumn:firstID.integerValue andSecondColumn:secondID.integerValue andThirdColumn:0];
    
    [pickerViewController setPickerDelegate:self];
    [pickerViewController.view setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
    //[pickerViewController.view setBackgroundColor:[UIColor clearColor]];
    [pickerViewController setPickerTitle:[NSString stringWithFormat:@"请选择您所在的地区"]];
    
    [[KGModal sharedInstance] setModalBackgroundColor:[UIColor clearColor]];
    [[KGModal sharedInstance] setYUpOffset:0];
    [[KGModal sharedInstance] showWithContentView:pickerViewController.view andAnimated:YES];
}

#pragma mark CMPickerDelegate
- (void)didSelectOK:(NSDictionary *)firstUnit andSecondColumn:(NSDictionary *)secondUnit andThirdColumn:(NSDictionary *)thirdUnit;
{
    if (!firstUnit) {
        return;
    }    
    
    regionID = [firstUnit objectForKey:@"id"];
    regionTitle = [firstUnit objectForKey:@"name"];
    // 更新内存中用户地区显示
    [[CureMeUtils defaultCureMeUtil] updateUserRegion:regionID];

    cityID = [secondUnit objectForKey:@"id"];
    cityTitle = [secondUnit objectForKey:@"name"];
    // 更新内存中用户地区显示
    [[CureMeUtils defaultCureMeUtil] updateUserCity:cityID andCityName:cityTitle];

    // 更新显示
    _regionLabel.text = [NSString stringWithFormat:@"%@ %@", regionTitle, cityTitle];
    
    // 发送请求
    NSString *post = [NSString stringWithFormat:@"action=upduserinfo&userid=%ld&city=%ld&city2=%ld&addrdetail=%@", (long)[CureMeUtils defaultCureMeUtil].userID, (long)regionID.integerValue, (long)cityID.integerValue, [CureMeUtils defaultCureMeUtil].encodedLocateInfo];
    NSData *response = sendRequest(@"m.php", post);
    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"post: %@ resp: %@", post, strResp);
}
#pragma mark UITextField Delegate QuickAskView
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    CMQuickAskChoosenAndLocationViewController *quickAskView = [[CMQuickAskChoosenAndLocationViewController alloc] init];

    if (textField.tag == 1) {
        quickAskView.isQuickAskView = YES;
    }
    else{
        quickAskView.isQuickAskView = NO;
        quickAskView.currentLocation = addressTF.text;
        quickAskView.chooseDelegate = self;
    }
    
    [[CMAppDelegate Delegate].navigationController pushViewController:quickAskView animated:YES];
       return NO;
}

- (void)refreshChosedLocation:(NSString *)province City:(NSString *)city Province:(NSInteger)city1 userCity:(NSInteger)city2{
    addressTF.text = [NSString stringWithFormat:@"%@ %@",province,city];
    
    CGRect temp = addressTF.frame;
    temp.size.width = addressTF.text.length * 13 + 22;
    temp.origin.x = quickAskTF.frame.origin.x + quickAskTF.frame.size.width - temp.size.width;
    addressTF.frame = temp;
}

@end
