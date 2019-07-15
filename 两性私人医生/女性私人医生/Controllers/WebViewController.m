//
//  WebViewController.m
//  CureMe
//
//  Created by Tim on 12-11-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "LoginViewController.h"
#import "BubbleViewController.h"
#import "WebViewController.h"
#import "CMMyChatListViewController.h"
#import "QueryViewController.h"
//#import "MyChatsViewController.h"
#import "MyBookListViewController.h"
#import "BookDetailInfoViewController.h"
#import "CMNewQueryViewController.h"
#import "CMQAProtocolView.h"

#define FF_HEADER_BGCOLOR [UIColor colorWithRed:255.0/255 green:140.0/255 blue:164.0/255 alpha:1.0]
#define FF_TEXTCOLOR_BLACK [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1.0]

@interface WebViewController ()
{
    CMQAProtocolView *protocolView;
    UIScrollView *navView;
    UIButton *currentNavBtn;
    CGFloat split_width;
    NSDictionary *typeDataQA;
    
    UIView *qa_selectNavView;
    CGPoint qa_navViewStartPosPoint;
    WebViewCoverView *coverView;
    NSString *paymentIdStr;
}
@end

@implementation WebViewController

@synthesize isMainTabPage = _isMainTabPage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isMainTabPage = false;
        _isPaymentPage = NO;
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _isPaymentPage = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    shareBtn.frame = CGRectMake(0, 0, 15, 18);
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    
    float topY = 140;
    if ([UIScreen mainScreen].bounds.size.height > 480.0) {
        topY += 40;
    }
    loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 35, topY, 80, 70)];
    loadingView.hidden = YES;
    [self.view addSubview:loadingView];
    
    if (_isMainTabPage) {
        [self.tabBarController.navigationController setNavigationBarHidden:NO];
        rightBarItem = self.tabBarController.navigationItem.rightBarButtonItem;
        rightBarItem.customView.hidden = YES;
        self.tabBarController.navigationItem.rightBarButtonItems = nil;
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 9, 18);
        [button setImage:[CMImageUtils defaultImageUtil].navBackBtnNormal forState:UIControlStateNormal];
        [button setImage:[CMImageUtils defaultImageUtil].navBackBtnSelected forState:UIControlStateHighlighted];
        [button setImage:[CMImageUtils defaultImageUtil].navBackBtnSelected forState:UIControlStateSelected];
        [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        
        leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        leftBarButton.customView.hidden = YES;
        if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7) {
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            negativeSpacer.width = -10;
            self.tabBarController.navigationItem.leftBarButtonItems = @[negativeSpacer, leftBarButton];
        }else{
            self.tabBarController.navigationItem.leftBarButtonItem = leftBarButton;
        }
    }
    
    hasNavigated = false;
    
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfUpdateUnreadMsgCount:) name:NTF_UNREADMSGCOUNT_UPDATED object:nil];
    
    protocolView = [[CMQAProtocolView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    split_width = 15;
    
    if ([_strURL containsString:@"http://new.medapp.ranknowcn.com/h5_new/news.html"]) {
        
        navView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        navView.showsHorizontalScrollIndicator = NO;
        navView.showsVerticalScrollIndicator = NO;
        navView.panGestureRecognizer.delaysTouchesBegan = YES;//按钮滑动流畅
        navView.backgroundColor = [UIColor whiteColor];
        navView.layer.shadowColor = [UIColor blackColor].CGColor;
        navView.layer.shadowOffset = CGSizeMake(0, 2);
        navView.layer.shadowOpacity = 0.3;
        navView.clipsToBounds = NO;
        
        CGFloat navStartPos = split_width;
        currentNavBtn = [self createNavButton:@"全部" index:0 startPos:navStartPos width:2*14+2];
        [currentNavBtn setTitleColor:FF_HEADER_BGCOLOR forState:UIControlStateNormal];
        [navView addSubview:currentNavBtn];
        navStartPos += 2*14+2 + split_width*2;
        
        typeDataQA = [CMDataUtils defaultDataUtil].officeSuperTypeDict; //objectForKey:[NSNumber numberWithInteger:_officeType]];
        
        if (typeDataQA) {
            for (NSString *key in typeDataQA) {
                NSString *btnName = [typeDataQA objectForKey:key];
                int length = [self countAsciiLength:btnName];
                CGFloat btnWidth = length*14+2;
                [navView addSubview:[self createNavButton:btnName index:[key integerValue] startPos:navStartPos width:btnWidth]];
                navStartPos += btnWidth + split_width*2;
            }
        }
        qa_selectNavView = [[UIView alloc] initWithFrame:CGRectMake(split_width, 35, 2*14+2, 3)];
        qa_selectNavView.backgroundColor = FF_HEADER_BGCOLOR;//[UIColor colorWithRed:255.0/255 green:205.0/255 blue:206.0/255 alpha:1.0];
        [navView addSubview:qa_selectNavView];
        CGSize contentSize = CGSizeMake(navStartPos + 35, 40);
        navView.contentSize = contentSize;
        
        [self.view addSubview:navView];
        
        UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 62, 0, 62, 40)];
        btnView.backgroundColor = [UIColor whiteColor];
        btnView.layer.shadowOffset = CGSizeMake(-2, 0);
        btnView.layer.shadowColor = [UIColor blackColor].CGColor;
        btnView.layer.shadowOpacity = 0.5;
        
        UIButton *listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        listBtn.frame = CGRectMake(22, 11, 18, 18);
        [listBtn setImage:[UIImage imageNamed:@"listBtn_woman"] forState:UIControlStateNormal];
        [btnView addSubview:listBtn];
        [listBtn addTarget:self action:@selector(btnViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnView];
        
        coverView = [[WebViewCoverView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
        coverView.hidden = YES;
        coverView.delegate = self;
        [self.view addSubview:coverView];
    }
}

-(UIButton *)createNavButton:(NSString *)title index:(NSInteger)index startPos:(CGFloat)startPos width:(CGFloat)width{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(startPos, 0+6, width, 28);
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button setTitle:title forState:UIControlStateNormal];
    //[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:FF_TEXTCOLOR_BLACK forState:UIControlStateNormal];
    [button addTarget:self action:@selector(navBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = index;
    return button;
}

- (int)countAsciiLength:(NSString*)strtemp {
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
}

-(void)navBtnClicked:(UIButton *)sender{
    [currentNavBtn setTitleColor:FF_TEXTCOLOR_BLACK forState:UIControlStateNormal];
    currentNavBtn = sender;
    [currentNavBtn setTitleColor:FF_HEADER_BGCOLOR forState:UIControlStateNormal];
    
    [self moveSelectView:sender.tag];
}

-(void)moveSelectView:(NSInteger)index{
    CGFloat spos = split_width;
    CGFloat swidth = 14*2+2;
    if (typeDataQA && index !=0) {
        
        for (NSString *key in typeDataQA) {
            NSString *btnName = [typeDataQA objectForKey:key];
            int length = [self countAsciiLength:btnName];
            spos += swidth + split_width*2;
            swidth = length*14+2;
            
            if ([key integerValue] == index)
                break;
        }
    }
    
    CGRect frame = CGRectMake(spos, 35, swidth, 3);
    qa_selectNavView.frame = frame;
}

- (void)btnViewClick:(UIButton *) sender{
    coverView.hidden = NO;
}

- (void)dismissPage{
    coverView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 如果是主界面的WebViewController
    if (_isMainTabPage) {
        if ([_html5View canGoBack]) {
            leftBarButton.customView.hidden = NO;
            self.tabBarController.navigationItem.leftBarButtonItem = leftBarButton;
        }
        else {
            leftBarButton.customView.hidden = YES;
            self.tabBarController.navigationItem.leftBarButtonItems = nil;
        }
        self.tabBarController.navigationItem.title = navigationBarTitle;
    }
    else {
        self.navigationItem.title = navigationBarTitle;
    }
    if (IOS_VERSION >= 7.0) {
        CGRect tableFrame = self.view.frame;
        //tableFrame.origin.y = 20 + NAVIGATIONBAR_HEIGHT;
        //tableFrame.size.height = SCREEN_HEIGHT - 20 - NAVIGATIONBAR_HEIGHT - 50;
        tableFrame.size.height = SCREEN_HEIGHT - 49 - 64;
        self.view.frame = tableFrame;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!jsBridge) {
        jsBridge = [WebViewJavascriptBridge bridgeForWebView:_html5View webViewDelegate:self handler:^(id data, WVJBResponse *response) {
            NSLog(@"ObjC received message from JS: %@", data);
            [self processJSEvent:data];
        }];
    }
    
    if (!hasNavigated) {
        if (!_strURL  || _strURL.length <= 0) {
            _strURL = [[NSString alloc] initWithFormat:@"http://%@/html5/?device=iphone&userid=%ld&city=%@&citycode=%ld&jingwei=%@,%@&deviceid=%@&token=%@",
                       DOMAIN_NAME,
                       (long)[CureMeUtils defaultCureMeUtil].userID,
                       [[CureMeUtils defaultCureMeUtil].province stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                       (long)[CureMeUtils defaultCureMeUtil].cityCode,
                       [CureMeUtils defaultCureMeUtil].latitude,
                       [CureMeUtils defaultCureMeUtil].longitude,
                       [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID],
                       [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TOKEN]];
        }
        
        URL = [[NSURL alloc] initWithString:[_strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"WebViewController URL: %@", URL);
        
        _html5View.scalesPageToFit = YES;
        [_html5View loadRequest:[NSURLRequest requestWithURL:URL]];
        hasNavigated = true;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setHtml5View:nil];
    [super viewDidUnload];
}

- (void)dealloc
{
    [self setHtml5View:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ntfUpdateUnreadMsgCount:(NSNotification *)note
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

- (IBAction)back:(id)sender
{
    if ([_html5View canGoBack])
        [_html5View goBack];
    else
        [super back:sender];
}

- (void)processJSEvent:(NSData *)data
{
    if (!data) {
        return;
    }
    
    NSString *jsMessage = (NSString *)data;
    NSLog(@"processJSEvent jsData: %@", jsMessage);
    
    NSArray *paramArray = [jsMessage componentsSeparatedByString:@"/"];
    if (!paramArray || paramArray.count <= 0) {
        return;
    }
    
    NSString *operation = [paramArray objectAtIndex:0];
    if ([[operation lowercaseString] isEqualToString:@"changetitle"]) {
        assert(paramArray && paramArray.count >= 2);
        
        NSString *title = [paramArray objectAtIndex:1];
        if (_isMainTabPage) {
            self.tabBarController.navigationItem.title = title;
        }
        else {
            self.navigationItem.title = title;
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // app://huodong/chat/14
    NSString *strURL = request.URL.absoluteString;
    NSLog(@"shouldStartLoadWithRequest url: %@", strURL);
    if ([[strURL lowercaseString] hasPrefix:@"app://"]) {
        NSString *subURl = [strURL substringFromIndex:[[NSString stringWithFormat:@"app://"] length]];
        NSArray *paramArray = [subURl componentsSeparatedByString:@"/"];
        NSLog(@"paramArray: %@", paramArray);
        [self processURL:paramArray andFullURL:subURl];
        
        return FALSE;
    }
    else if ([[strURL lowercaseString] hasPrefix:@"medapp://"]) {
        NSString *subURl = [strURL substringFromIndex:[[NSString stringWithFormat:@"medapp://"] length]];
        NSArray *paramArray = [subURl componentsSeparatedByString:@"/"];
        NSLog(@"paramArray: %@", paramArray);
        [self processURL:paramArray andFullURL:subURl];
        
        return FALSE;
    }
    
    else if ([[strURL lowercaseString] containsString:@"http://new.medapp.ranknowcn.com/famous_doctors/doctor_info.php?did="] && ![[strURL lowercaseString] containsString:@"&"]){
        
        if (_isPaymentPage == YES) {
            return TRUE;
        }
        
        WebViewController *newWeb = [[WebViewController alloc] init];
        newWeb.strURL = strURL;
        newWeb.isPaymentPage = YES;
        [self.navigationController pushViewController:newWeb animated:YES];
        return FALSE;
    }
    return TRUE;
}

//app://message/<type>/<id>
//A. type:chat: id:xxx
//B. type:mychatlist
//C. type:booking, id:xxx
//D type:mybookinglist
//E type:huodong, id:xxx
//F type:huodonglist
- (void)processURL:(NSArray *)paramArray andFullURL:(NSString *)fullURL
{
    if (!paramArray || paramArray.count < 2) {
        NSLog(@"processURL paramArray invalid: %@", paramArray);
        return;
    }
    
    NSLog(@"webView processURL: %@", fullURL);
    
    NSString *firstParam = [paramArray objectAtIndex:1];
    
    if ([[firstParam lowercaseString] isEqualToString:@"chat"]) {
        NSString *fromType = [paramArray objectAtIndex:0];
        // 通过活动ID打开的聊天窗口
        if ([[fromType lowercaseString] isEqualToString:@"huodong"]) {
            [self processHuodongChatURL:paramArray];
        }
        // 通过ChatID打开聊天窗口
        else if ([[fromType lowercaseString] isEqualToString:@"message"]) {
            [self processMessageChatURL:paramArray];
        }
    }
    else if ([[firstParam lowercaseString] isEqualToString:@"open"]) {
        [self processOpenURL:paramArray andFullURL:fullURL];
    }
    else if ([[firstParam lowercaseString] isEqualToString:@"mychatlist"]) {
        [self processChatListURL:paramArray];
    }
    else if ([[firstParam lowercaseString] isEqualToString:@"booking"]) {
        NSString *fromType = [paramArray objectAtIndex:0];
        // 网页端打开新预约
        if ([[fromType lowercaseString] isEqualToString:@"webview"]) {
            [self processNewBookingURL:paramArray];
        }
        // 网页端查看预约详情
        else if ([[fromType lowercaseString] isEqualToString:@"message"]) {
            [self processBookingURL:paramArray];
        }
        
    }
    else if ([[firstParam lowercaseString] isEqualToString:@"quickask"]){
        [self processNewChatQueryUrl:paramArray];
    }
    
    else if ([[firstParam lowercaseString] isEqualToString:@"mybookinglist"]) {
        [self processBookingListURL:paramArray];
    }
    else if ([[firstParam lowercaseString] isEqualToString:@"huodong"]) {
        [self processHuodongURL:paramArray];
    }
    else if ([[firstParam lowercaseString] isEqualToString:@"huodonglist"]) {
        [self processHuodongListURL:paramArray];
    }
    else if ([[firstParam lowercaseString] isEqualToString:@"weixin"]){
        [[Mixpanel sharedInstance] track:@"主页-退出-转到微信"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]];
    }
    else if ([[firstParam lowercaseString] isEqualToString:@"openurl"]){
        
        [[Mixpanel sharedInstance] track:@"主页-退出-转到微信"];
        NSString *urlStr = [fullURL stringByReplacingOccurrencesOfString:@"out/openurl/" withString:@""];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }
    else if ([[firstParam lowercaseString] isEqualToString:@"payment"]){
        NSString *nameStr = [paramArray[2] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *payNameStr;
        if (nameStr) {
            payNameStr = [NSString stringWithFormat:@"私人医生-%@",nameStr];
        }
        else{
            payNameStr = @"私人医生-医生沟通服务费";
        }
        paymentIdStr = paramArray[4];
        [self getPrePayId:[payNameStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] totalFee:paramArray[3] paymentId:paramArray[4] param1:paramArray[5]];
    }
}

- (void)getPrePayId:(NSString *)payName totalFee:(NSString *)fee paymentId:(NSString *)paymentId param1:(NSString *)param1{
    NSString *post = [NSString stringWithFormat:@"body=%@&total_fee=%@&paymentid=%@&param1=%@username=%@&userid=%ld",payName,fee,paymentId,param1,[CureMeUtils defaultCureMeUtil].userName,[CureMeUtils defaultCureMeUtil].userID];
    NSString *urlStr = [NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/WxpayAPI_v3.0.1/example/native_notify.php"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *response = sendRequestWithFullURL(urlStr, post);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!response) {
                return;
            }
            NSDictionary *returnDic = parseJsonResponse(response);
            if (!returnDic) {
                return;
            }
            
            PayReq *req = [[PayReq alloc] init];
            req.partnerId = [returnDic objectForKey:@"partnerid"];
            req.prepayId = [returnDic objectForKey:@"prepayid"];
            req.package = [returnDic objectForKey:@"package"];
            req.nonceStr = [returnDic objectForKey:@"noncestr"];
            req.timeStamp = [[returnDic objectForKey:@"timestamp"] intValue];
            req.sign = [returnDic objectForKey:@"sign"];
            if (![WXApi isWXAppInstalled]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
                return;
            }
            [WXApi sendReq:req];
        });
    });
}

- (void)processWeixinUrl:(NSArray *)paramArray{
    
    NSMutableString *urlStr = [[NSMutableString alloc] init];
    for (int i = 2; i<paramArray.count; i++) {
        [urlStr appendString:[NSString stringWithFormat:@"/%@",paramArray[i]]];
    }
    [urlStr replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[urlStr copy]]];
}


// app://message/open/(inner/outer)/ http:\/\/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
- (void)processOpenURL:(NSArray *)paramArray andFullURL:(NSString *)fullURL
{
    if (!paramArray || paramArray.count < 4 || !fullURL) {
        return;
    }
    
    NSString *where = [paramArray objectAtIndex:2];
    NSString *strURL = [fullURL substringFromIndex:[[NSString alloc] initWithFormat:@"message/open/%@/", where].length];
    NSLog(@"processOpenURL: strURL:%@", strURL);
    
    if ([[where lowercaseString] isEqualToString:@"inner"]) {
        URL = [[NSURL alloc] initWithString:strURL];
        [_html5View loadRequest:[NSURLRequest requestWithURL:URL]];
    }
    else if ([[where lowercaseString] isEqualToString:@"outer"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
    }
}

- (void)processHuodongURL:(NSArray *)paramArray
{
    // http://medapp.ranknowcn.com/html5/more.php?id=20&userid=0&city=&citycode=&jingwei=&deviceid=&token=
    if (!paramArray || paramArray.count < 3) {
        NSLog(@"processHuodongURL param invalid: %@", paramArray);
        return;
    }
    
    NSNumber *huodongID = [paramArray objectAtIndex:2];
    if (!huodongID || huodongID <= 0) {
        NSLog(@"processHuodongURL huodongID invalid: %@", paramArray);
        return;
    }
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"http://%@/html5/more.php?id=%ld&userid=%ld&city=%@&citycode=%ld&jingwei=%@,%@&deviceid=%@&token=%@",
                        DOMAIN_NAME,
                        (long)huodongID.integerValue,
                        (long)[CureMeUtils defaultCureMeUtil].userID,
                        [[CureMeUtils defaultCureMeUtil].province stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        (long)[CureMeUtils defaultCureMeUtil].cityCode,
                        [CureMeUtils defaultCureMeUtil].latitude,
                        [CureMeUtils defaultCureMeUtil].longitude,
                        [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID],
                        [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TOKEN]];
    URL = [[NSURL alloc] initWithString:strURL];
    
    NSLog(@"WebViewController URL: %@", URL);
    
    _html5View.scalesPageToFit = YES;
    [_html5View loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)processHuodongListURL:(NSArray *)paramArray
{
    if (!paramArray || paramArray.count < 2) {
        NSLog(@"processHuodongListURL param invalid: %@", paramArray);
        return;
    }
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"http://%@/html5/index.php?userid=%ld&city=%@&citycode=%ld&jingwei=%@,%@&deviceid=%@&token=%@",
                        DOMAIN_NAME,
                        (long)[CureMeUtils defaultCureMeUtil].userID,
                        [[CureMeUtils defaultCureMeUtil].province stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        (long)[CureMeUtils defaultCureMeUtil].cityCode,
                        [CureMeUtils defaultCureMeUtil].latitude,
                        [CureMeUtils defaultCureMeUtil].longitude,
                        [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID],
                        [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TOKEN]];
    URL = [[NSURL alloc] initWithString:strURL];
    
    NSLog(@"WebViewController URL: %@", URL);
    
    _html5View.scalesPageToFit = YES;
    [_html5View loadRequest:[NSURLRequest requestWithURL:URL]];
}

//C. type:booking, id:xxx
- (void)processBookingListURL:(NSArray *)paramArray
{
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [[CMAppDelegate Delegate].navigationController pushViewController:loginVC animated:YES];
        return;
    }
    
    MyBookListViewController *bookListVC = [[MyBookListViewController alloc] initWithNibName:@"MyBookListViewController" bundle:nil];//[[MyBookListViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [self.navigationController pushViewController:bookListVC animated:YES];
}

- (void)processNewChatQueryUrl:(NSArray *)paramArray{
    if (!paramArray || paramArray.count < 2) {
        NSLog(@"processNewBookingURL paramArray invalid: %@", paramArray);
        return;
    }
    // 准备提交咨询的时候，发起一次定位
    [[CureMeUtils defaultCureMeUtil] startLocationing];
    
    NSNumber *hasMarkApp = [[NSUserDefaults standardUserDefaults] objectForKey:HAS_AGREEPROTOCOL];
    if (!hasMarkApp || hasMarkApp.integerValue == 0) {
        [self.view addSubview:protocolView];
        return;
    }
    
    CMNewQueryViewController *queryVC = [CMNewQueryViewController new];
    queryVC.officeType = _childOfficeId;
    queryVC.subOfficeType = _subOfficeId;
    queryVC.chatUserID = [CureMeUtils defaultCureMeUtil].userID;
    [self.navigationController pushViewController:queryVC animated:YES];
    
}

- (void)processNewBookingURL:(NSArray *)paramArray
{
    if (!paramArray || paramArray.count < 3) {
        NSLog(@"processNewBookingURL paramArray invalid: %@", paramArray);
        return;
    }
    
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    
    QueryViewController *queryVC = [[QueryViewController alloc] initWithNibName:@"QueryViewController" bundle:nil];
    NSString *hospID = [paramArray objectAtIndex:2];
    queryVC.hospitalID = hospID.integerValue;
    NSString *encodedHospName = [paramArray objectAtIndex:3];
    encodedHospName = [encodedHospName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    queryVC.hospitalName = encodedHospName;
    [self.navigationController pushViewController:queryVC animated:YES];
}

- (void)processBookingURL:(NSArray *)paramArray
{
    if (!paramArray || paramArray.count < 3) {
        NSLog(@"processBookingListURL paramArray invalid: %@", paramArray);
        return;
    }
    
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    
    NSNumber *bookID = [paramArray objectAtIndex:2];
    if (!bookID || bookID.integerValue <= 0) {
        NSLog(@"processBookingListURL bookid invalid: %@", paramArray);
        return;
    }
    
    BookDetailInfoViewController *bookDetailVC = [[BookDetailInfoViewController alloc] initWithNibName:@"BookDetailInfoViewController" bundle:nil];
    [bookDetailVC setBookingID:bookID.integerValue];
    [self.navigationController pushViewController:bookDetailVC animated:YES];
}

- (void)processChatListURL:(NSArray *)paramArray
{
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    
    CMMyChatListViewController *chatListVC = [[CMMyChatListViewController alloc] initWithNibName:@"CMMyChatListViewController" bundle:nil]; //[[CMMyChatListViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:chatListVC animated:YES];
}

- (void)processHuodongChatURL:(NSArray *)paramArray
{
    if (!paramArray || paramArray.count < 3) {
        return;
    }
    
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    
    NSNumber *huodongID = [paramArray objectAtIndex:2];
    NSLog(@"huodong/chat ID: %ld", (long)huodongID.integerValue);
    if (!huodongID || huodongID.integerValue <= 0) {
        NSLog(@"app://huodong/chat ID invalid: %@", paramArray);
        return;
    }
    
    // 发送请求通过活动ID获得chatid
    // action=huodongchat&userid=xxxxxxx&id=123
    NSString *post = [[NSString alloc] initWithFormat:@"action=huodongchat&userid=%ld&id=%ld", (long)[CureMeUtils defaultCureMeUtil].userID, (long)huodongID.integerValue];
    NSData *response = sendRequest(@"m.php", post);
    
    NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"action=huodongchat resp: %@", strResp);
    
    // {"result":true,"msg":28341}
    NSDictionary *jsonData = parseJsonResponse(response);
    if (!jsonData || jsonData.count <= 0) {
        NSLog(@"action=huodongchat resp invalid %@", strResp);
        return;
    }
    
    NSNumber *result = [jsonData objectForKey:@"result"];
    if (!result || result.integerValue != 1) {
        NSString *error = [jsonData objectForKey:@"msg"];
        NSLog(@"action=huodongchat result invalid: %@", error);
        return;
    }
    
    NSNumber *chatID = [jsonData objectForKey:@"msg"];
    if (!chatID) {
        NSLog(@"action=huodongchat chatid invalid: %@", strResp);
        return;
    }
    
    BubbleViewController *chatVC = [[BubbleViewController alloc] initWithNibName:@"BubbleViewController" bundle:nil];
    
    [chatVC setChatOpenType:@"huodong"];
    [chatVC setChatID:chatID.integerValue];
    [chatVC setChatUserID:[CureMeUtils defaultCureMeUtil].userID];
    
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)processMessageChatURL:(NSArray *)paramArray
{
    if (!paramArray || paramArray.count < 3) {
        return;
    }
    
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    
    NSNumber *chatID = [paramArray objectAtIndex:2];
    if (!chatID || chatID.integerValue <= 0) {
        NSLog(@"processChatURL message chatID invalid: %@", paramArray);
        return;
    }
    
    BubbleViewController *chatVC = [[BubbleViewController alloc] initWithNibName:@"BubbleViewController" bundle:nil];
    
    [chatVC setChatOpenType:@"huodong"];
    [chatVC setChatID:chatID.integerValue];
    [chatVC setChatUserID:[CureMeUtils defaultCureMeUtil].userID];
    
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    loadingView.hidden = NO;
    //    [activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 载入中的动画
    loadingView.hidden = YES;
    //    [activityIndicator stopAnimating];
    
    // 返回按钮
    if (_isMainTabPage) {
        if ([_html5View canGoBack]) {
            leftBarButton.customView.hidden = NO;
            self.tabBarController.navigationItem.leftBarButtonItem = leftBarButton;
        }
        else {
            leftBarButton.customView.hidden = YES;
            self.tabBarController.navigationItem.leftBarButtonItems = nil;
            //            self.tabBarController.navigationItem.leftBarButtonItem = nil;
        }
    }
    
    if (_isMainTabPage) {
        navigationBarTitle = self.tabBarController.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    else {
        navigationBarTitle = self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    
    // 更新未读消息数
    [self ntfUpdateUnreadMsgCount:nil];
    
    NSLog(@"HTML5 Title: %@", [webView stringByEvaluatingJavaScriptFromString:@"document.title"]);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webView didFailLoadWithError: %@", error.description);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"news" ofType:@"html" inDirectory:@"local_h5"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

@end

