//
//  CMAppDelegate.m
//  私密健康医生
//
//  Created by Tim on 13-1-9.
//  Copyright (c) 2013年 Tim. All rights reserved.
// 

#import "CMAppDelegate.h"
#import "CMMainTabViewController.h"
#import "CMMainPageViewController.h"
#import "WebViewController.h"
#import "MyBookListViewController.h"
#import "PerCenterViewController.h"
#import "CMMyChatListViewController.h"
#import "CMQAViewController.h"
#import "LoginViewController.h"
#import "CMMyChatListViewController.h"
#import "BubbleViewController.h"
#import "BookDetailInfoViewController.h"
#import "CMChooseQueryOfficeTableViewController.h"
#import "CMH5NewsWebViewController.h"

#import "CMMainPageViewController.h"

#import <sys/utsname.h>
#import "GuideView.h"
#import "HiChat.h"
#import "WXApi.h"

/**
 * 实现NSUncaughtExceptionHandler方法
 */
/*
NSString *getCrashFilePathName()
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ducomentFolder = [documentDirectories objectAtIndex:0];
    NSString *crashFilePath = [ducomentFolder stringByAppendingPathComponent:@"stack.crash"];
    
    return crashFilePath;
}

void uncaughtExceptionHandler(NSException *exception)
{
    // 调用堆栈
    NSArray *arr = [exception callStackSymbols];
    // 错误reaso
    NSString *reason = [exception reason];
    // exception name
    NSString *name = [exception name];
    // Stack return addresses
    NSArray *stackRetAddr = [exception callStackReturnAddresses];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *crashFilePath = getCrashFilePathName();
    
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:crashFilePath];
    if (fileHandler) {
        NSError *error = nil;
        [fileManager removeItemAtPath:crashFilePath error:&error];
    }
    
    [fileManager createFileAtPath:crashFilePath contents:nil attributes:nil];
    fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:crashFilePath];
    
    [fileHandler seekToEndOfFile];
    [fileHandler writeData:[[NSString stringWithFormat:@"%@", arr] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler writeData:[[NSString stringWithFormat:@"\r\n%@", reason] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler writeData:[[NSString stringWithFormat:@"\r\n%@", name] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler writeData:[[NSString stringWithFormat:@"\r\n%@", stackRetAddr] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}*/

@implementation CMAppDelegate
{
    CMH5NewsWebViewController *webVC;
}
@synthesize navigationController = _navigationController;

+ (CMAppDelegate *)Delegate
{
    return (CMAppDelegate *)[[UIApplication sharedApplication] delegate];
}

/*
//http://www.ranknowcn.com/webservices/android/report_crash.php?ios
//POST:
//appname
//appversion
//device
//imei
//osversion
//exception
//memo
- (void)threadUploadCrashDataWithFileHandle
{
    @autoreleasepool {
        NSString *filePathName = getCrashFilePathName();
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePathName];
        if (!handle)
            return;
        
        NSData *fileContent = [handle readDataToEndOfFile];
        NSString *strContent = [[NSString alloc] initWithData:fileContent encoding:NSUTF8StringEncoding];
        
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        
        NSString *post = [NSString stringWithFormat:@"appname=CureMe&appversion=%@&device=%@&imei=%@&osversion=%.f&exception=%@", APP_VERSION, deviceString, getUDID(), IOS_VERSION, [strContent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        //        [[BaseUtils defaultBaseUtil] writeDataToExceptionFile:@"threadUploadCrashDataWithFileHandle begin" withType:LOGTYPE_CRASH];
        
        NSData *response = sendRequestWithFullURL(@"http://www.ranknowcn.com/webservices/android/report_crash.php?ios", post);
        
        //        [[BaseUtils defaultBaseUtil] writeDataToExceptionFile:@"threadUploadCrashDataWithFileHandle end" withType:LOGTYPE_CRASH];
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"sendCrashReport: %@ withPost: %@", strResp, post);
        
        NSError *err = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePathName error:&err];
    }
}*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    //sleep(2);
    // ======== 1. 注册异常处理
    // Catch C Exception
   // InstallUncaughtExceptionHandler();
    
    // Catch NSException
    //NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    // 如果上次打开有crash，在此处或者rootviewcontroller处，开始一次Crash文件上传
    //[self performSelectorInBackground:@selector(threadUploadCrashDataWithFileHandle) withObject:nil];
    
    // Icon未读消息数清0
    application.applicationIconBadgeNumber = 1;
    
    if (launchOptions) {
        NSDictionary *options = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        if (options) {
            NSDictionary *allDataJson = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
            if (allDataJson) {
                alertJsonData = [allDataJson objectForKey:@"aps"];
                pushJsonData = [allDataJson objectForKey:@"data"];
            }
        }
    }
    else {
        alertJsonData = nil;
        pushJsonData = nil;
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    //    sleep(1);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 1. 初始化用户账号信息
    [CureMeUtils defaultCureMeUtil];
    NSString *userUniID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID];
    if (userUniID)
        [CureMeUtils defaultCureMeUtil].uniID = userUniID;
        
    // 2. 更新上次UserID
    NSNumber *lastUserID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_LASTUSERID];
    if (lastUserID) {
        [[CureMeUtils defaultCureMeUtil] setLastUserID:lastUserID.integerValue];
    }

    // 3. 如果UserID有效，则更新一次LoginCookie
    // {"result":true,"msg":1000001,"unreadcount":{"replycount":0,"channelcount":0,"chatcount":0},"chatservers":{"chatserver":"n2.medapp.ranknowcn.com","chatport":"3810","chatnport":"3820"}}
    if ([CureMeUtils defaultCureMeUtil].userID > 0) {
        NSString *urlStr = @"http://new.medapp.ranknowcn.com/api/m.php?action=login&version=3.0";
        
        NSString *post = [NSString stringWithFormat:@"username=%@&password=%@&token=%@&version=3.3&deviceid=%@&source=apple",[CureMeUtils defaultCureMeUtil].userName,[CureMeUtils defaultCureMeUtil].password,nil,[CureMeUtils defaultCureMeUtil].uniID];
        NSData *response = sendRequestWithCookie(urlStr, post, @"", true);
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"application loading loginCookie resp: %@", strResp);
        [[CureMeUtils defaultCureMeUtil] updatePollServerInfo:strResp];
    }

    mainTabViewController = [[CMMainTabViewController alloc] init];
    
    // 1. 主界面Page
    CMMainPageViewController *mainPageVC = [[CMMainPageViewController alloc] init]; //initWithNibName:@"CMMainPageViewController" bundle:nil];
    
    // 2. 我的咨询Page
    UIViewController *listViewController = nil;
//    if ([CureMeUtils defaultCureMeUtil].hasLogin) {
        CMMyChatListViewController *myChatListVC = [[CMMyChatListViewController alloc] initWithNibName:@"CMMyChatListViewController" bundle:nil];//[[CMMyChatListViewController alloc] initWithStyle:UITableViewStylePlain];
        myChatListVC.isMainTabController = true;
        listViewController = myChatListVC;
 //   }
//    else {
//        CMChooseQueryOfficeTableViewController *chooseVC = [[CMChooseQueryOfficeTableViewController alloc] initWithNibName:@"CMChooseQueryOfficeTableViewController" bundle:nil]; //[[CMChooseQueryOfficeTableViewController alloc] initWithStyle:UITableViewStylePlain];
//        listViewController = chooseVC;
//    }
    
    // 3. 我的消息Page
//    WebViewController *webVC = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
//    //[webVC setStrURL:[[NSString alloc] initWithFormat:@"%@/html5/myxiaoxi.php?userid=%ld&deviceid=%@", MEDAPP_MAINDOMAIN, (long)[CureMeUtils defaultCureMeUtil].userID, [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID]]];
//    [webVC setStrURL:[[NSString alloc] initWithFormat:@"http://new.medapp.ranknowcn.com/h5_new/news.html?appid=7&addrdetail=%@&source=apple",[CureMeUtils defaultCureMeUtil].encodedLocateInfo]];
//    webVC.isMainTabPage = true;
    webVC = [[CMH5NewsWebViewController alloc] init];
    [self getAllOfficeTypeAndUrl];

    // 4. 我的预约Page
    UIViewController *bookListViewController = nil;
   // if ([CureMeUtils defaultCureMeUtil].hasLogin) {
        MyBookListViewController *myBookListVC = [[MyBookListViewController alloc] initWithNibName:@"MyBookListViewController" bundle:nil]; //[[MyBookListViewController alloc] initWithStyle:UITableViewStylePlain];
        myBookListVC.isMainTabPage = true;
        bookListViewController = myBookListVC;
    //}
//    else {
//        CMChooseQueryOfficeTableViewController *chooseVC = [[CMChooseQueryOfficeTableViewController alloc] initWithNibName:@"CMChooseQueryOfficeTableViewController" bundle:nil]; //[[CMChooseQueryOfficeTableViewController alloc] initWithStyle:UITableViewStylePlain];
//        bookListViewController = chooseVC;
//    }
    
    // 5. 个人中心Page
    PerCenterViewController *perCenterVC = [[PerCenterViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    mainTabViewController.viewControllers = [NSArray arrayWithObjects:mainPageVC, listViewController, webVC, /*bookListViewController,*/ perCenterVC, nil];
    mainTabViewController.selectedIndex = 0;
    
    _navigationController = [[CureMeNavigationController alloc] initWithRootViewController:mainTabViewController];
    
    if (pushJsonData) {
        UIViewController *viewController = [self processBackgroundPush];
        if (viewController)
            [_navigationController pushViewController:viewController animated:NO];
    }

//    [self.window addSubview:navigationController.view];
    [[self window] setRootViewController:_navigationController];
    [self.window makeKeyAndVisible];
    
    if([self isFirstLauch])
    {
        GuideView *guide = [[GuideView alloc] initWithFrame:self.window.bounds];
        [self.window addSubview:guide];
    }

    //初始化Hichat 并注册APNS
    [HiChat init:Hichat_App_Key];
    
    [HiChat apnsInitInFinishLaunch:[UIApplication sharedApplication]];
    //注册微信
    [WXApi registerApp:WX_BOTH_ID];
    
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    [Mixpanel sharedInstance].useIPAddressForGeoLocation = YES;
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    if ([url.scheme isEqualToString:WX_BOTH_ID]) {
        WeixinBackTools *wxResp = [WeixinBackTools sharedInstance];
        return [WXApi handleOpenURL:url delegate:wxResp];
    }
    return YES;
}


- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings{
    
    if (notificationSettings.types != UIRemoteNotificationTypeNone){
        
    }
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    //    NSString* oldToken = [dataModel deviceToken];
    NSString* newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&lt;&gt;"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"My token is: %@", newToken);
    
    newToken = [newToken substringFromIndex:1];
    newToken = [newToken substringToIndex:newToken.length - 1];
    NSLog(@"newToken: %@", newToken);
    //注册成功，将deviceToken保存到应用服务器数据库中
    
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TOKEN];
    // 如果获得的token与保存的一致，不做操作
    if ([newToken isEqualToString:savedToken]) {
        NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken same token has been saved.");
        return;
    }
    
    // 如果获得的token与保存的不一致
    [[NSUserDefaults standardUserDefaults] setObject:newToken forKey:PUSH_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:PUSH_TOKEN_NSDATA];
    [[NSUserDefaults standardUserDefaults] synchronize];   
    
    // 如果此时已经获得激活的GUID，则发送更新Token请求
    updateIOSPushInfo();
    
    if (!deviceToken) {
        NSLog(@"push token is nil fail to submit");
    }
    else{
        [HiChat submitDeviceToken:deviceToken];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    // 处理推送消息
    
    NSLog(@"%@", userInfo);
    
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    
    
    NSInteger usserAcount = [[aps objectForKey:@"sound"] integerValue];
    if (usserAcount != [CureMeUtils defaultCureMeUtil].userID) {
        NSLog(@"push wrong user");
        return;
    }
    
    if (application.applicationState == UIApplicationStateActive) {
        
        NSInteger count = [CureMeUtils defaultCureMeUtil].unreadMessageCount;
        [CureMeUtils defaultCureMeUtil].unreadMessageCount = count+1;
        [[NSNotificationCenter defaultCenter] postNotificationName:NTF_UNREADMSGCOUNT_UPDATED object:nil];
    }
    if (application.applicationState == UIApplicationStateInactive) {
        [mainTabViewController tabWasSelected:1];
    }
    
    [HiChat registerMessageReceiveCallback:^(NSArray <MessageInfo *> *array,NSError *error){
        if (array) {
            NSLog(@"");
        }
    }];
    
    [HiChat registerMessageReceiptCallback:^(HMessageInfo *msg,NSError *error){
        if (msg) {
            
        }
    }];
    [HiChat pullNewestMessage];
}

// 当App处于后台/未启动时，处理Json并返回相应ViewController
- (UIViewController *)processBackgroundPush
{
    if (!pushJsonData)
        return nil;
    
    NSString *pushType = [pushJsonData objectForKey:@"type"];
    NSString *lowerPushType = [pushType lowercaseString];
    if (!pushType || pushType.length <= 0)
        return nil;
    
    [self sendPushMsgReadRequest];
    
    if ([[pushType lowercaseString] isEqualToString:@"chat"]) {
        return [self processChatPush];
    }
    else if ([lowerPushType isEqualToString:@"mychatlist"]) {
        return [self processChatListPush];
    }
    else if ([lowerPushType isEqualToString:@"booking"]) {
        return [self processBookingPush];
    }
    else if ([lowerPushType isEqualToString:@"mybookinglist"]) {
        return [self processBookingListPush];
    }
    else if ([lowerPushType isEqualToString:@"huodong"]) {
        return [self processHuodongPush];
    }
    else if ([lowerPushType isEqualToString:@"huodonglist"]) {
        return [self processHuodongListPush];
    }
    else if ([lowerPushType isEqualToString:@"open"]) {
        return [self processOpenURLPush];
    }
    else if ([lowerPushType isEqualToString:@"newapp"]) {
        return [self processNewAppPush];
    }
    
    return nil;
}

- (UIViewController *)processNewAppPush
{
    WebViewController *webVC = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    [webVC setStrURL:[NSString stringWithFormat:@"http://app.imeirong.com/applist.php?appid=7"]];
    
    return webVC;
}

// App正在运行中，会弹出Alert，处理页面跳转
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // 如果是cancel按钮
    if (buttonIndex == 0) {
    }
    // 如果是view按钮
    if (buttonIndex == 1) {
        NSString *pushType = [pushJsonData objectForKey:@"type"];
        if (!pushType || pushType.length <= 0)
            return;
        
        UIViewController *viewController = nil;
        NSString *lowerPushType = [pushType lowercaseString];
        // 如果是聊天页面的Push
        if ([lowerPushType isEqualToString:@"chat"]) {
            viewController = [self processChatPush];
        }
        // 如果是聊天列表
        else if ([lowerPushType isEqualToString:@"mychatlist"]) {
            viewController = [self processChatListPush];
        }
        else if ([lowerPushType isEqualToString:@"booking"]) {
            viewController = [self processBookingPush];
        }
        else if ([lowerPushType isEqualToString:@"mybookinglist"]) {
            viewController = [self processBookingListPush];
        }
        else if ([lowerPushType isEqualToString:@"huodong"]) {
            viewController = [self processHuodongPush];
        }
        else if ([lowerPushType isEqualToString:@"huodonglist"]) {
            viewController = [self processHuodongListPush];
        }
        else if ([lowerPushType isEqualToString:@"open"]) {
            viewController = [self processOpenURLPush];
        }
        
        if (viewController) {
            assert([self.window.rootViewController isKindOfClass:[UINavigationController class]]);
            UINavigationController *navVC = ((UINavigationController *)self.window.rootViewController);
            [navVC pushViewController:viewController animated:YES];
        }
        
        [self sendPushMsgReadRequest];
        
        // 清除push消息
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
}

- (void)sendPushMsgReadRequest
{
    // 发送已读通知
    NSNumber *msgID = [pushJsonData objectForKey:@"msgid"];
    if (msgID && msgID.integerValue > 0) {
        NSString *post = [[NSString alloc] initWithFormat:@"action=updiospushmsgstate&msgids=%ld&userid=%ld", (long)msgID.integerValue, (long)[CureMeUtils defaultCureMeUtil].userID];
        NSData *response = sendRequest(@"m.php", post);
        
        NSString *strResp = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSLog(@"action=updiospushmsgstate resp: %@", strResp);
    }
}

- (UIViewController *)processChatPush
{
    if (!pushJsonData) {
        return nil;
    }
    
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        return loginVC;
    }

    NSNumber *chatID = [pushJsonData objectForKey:@"id"];
    if (!chatID) {
        NSLog(@"pushnote detaildata chat id invalid %@", pushJsonData);
        return nil;
    }
    
    // 展开具体聊天窗口
    BubbleViewController *chatViewController = [[BubbleViewController alloc] initWithNibName:@"BubbleViewController" bundle:nil];
    
    [chatViewController setChatOpenType:@"notification"];
    [chatViewController setChatID:chatID.integerValue];
    [chatViewController setChatUserID:[CureMeUtils defaultCureMeUtil].userID];
    return chatViewController;
}

- (UIViewController *)processChatListPush
{
    if (!pushJsonData)
        return nil;
    
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        return loginVC;
    }
    else {
        CMMyChatListViewController *chatListVC = [[CMMyChatListViewController alloc] initWithNibName:@"CMMyChatListViewController" bundle:nil]; //[[CMMyChatListViewController alloc] initWithStyle:UITableViewStylePlain];
        return chatListVC;
    }
}

- (UIViewController *)processBookingPush
{
    if (!pushJsonData) {
        return nil;
    }
    
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        return loginVC;
    }
    
    NSLog(@"AppDelegate processBookingPush: %@", pushJsonData);
    NSNumber *ID = [pushJsonData objectForKey:@"id"];
    if (!ID || ID.integerValue <= 0) {
        return nil;
    }
    
    BookDetailInfoViewController *bookDetailVC = [[BookDetailInfoViewController alloc] initWithNibName:@"BookDetailInfoViewController" bundle:nil];
    [bookDetailVC setBookingID:ID.integerValue];
    return bookDetailVC;
}

- (UIViewController *)processBookingListPush
{
    if (!pushJsonData) {
        return nil;
    }
    
    if (![CureMeUtils defaultCureMeUtil].hasLogin) {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        return loginVC;
    }
    
    MyBookListViewController *bookListVC = [[MyBookListViewController alloc] initWithNibName:@"MyBookListViewController" bundle:nil]; //[[MyBookListViewController alloc] initWithStyle:UITableViewStylePlain];
    return bookListVC;
}

- (UIViewController *)processHuodongPush
{
    if (!pushJsonData) {
        return nil;
    }
    
    NSNumber *huodongID = [pushJsonData objectForKey:@"id"];
    if (!huodongID || huodongID.integerValue <= 0) {
        return nil;
    }
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"http://new.medapp.ranknowcn.com/html5/more.php?id=%ld&userid%ldd&city=%@&citycod%ld&jingwei=%@,%@&deviceid=%@&token=%@",
                        (long)huodongID.integerValue,
                        (long)[CureMeUtils defaultCureMeUtil].userID,
                        [[CureMeUtils defaultCureMeUtil].province stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        (long)[CureMeUtils defaultCureMeUtil].cityCode,
                        [CureMeUtils defaultCureMeUtil].latitude,
                        [CureMeUtils defaultCureMeUtil].longitude,
                        [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID],
                        [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TOKEN]];
    NSLog(@"AppDelegate processHuodongPush: %@", strURL);
    
    WebViewController *webVC = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    [webVC setStrURL:strURL];
    return webVC;
}

- (UIViewController *)processHuodongListPush
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"http://new.medapp.ranknowcn.com/html5/index.php?&userid=%ld&city=%@&citycode%ldd&jingwei=%@,%@&deviceid=%@&token=%@",
                        (long)[CureMeUtils defaultCureMeUtil].userID,
                        [[CureMeUtils defaultCureMeUtil].province stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        (long)[CureMeUtils defaultCureMeUtil].cityCode,
                        [CureMeUtils defaultCureMeUtil].latitude,
                        [CureMeUtils defaultCureMeUtil].longitude,
                        [[NSUserDefaults standardUserDefaults] objectForKey:USER_UNIQUE_ID],
                        [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_TOKEN]];
    
    WebViewController *webVC = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    [webVC setStrURL:strURL];
    return webVC;
}

// {"type":"open", "method":'inner/outer', "url":<url>, "popup":true/false, "time":13810292328}
- (UIViewController *)processOpenURLPush
{
    if (!pushJsonData) {
        return nil;
    }
    
    NSString *strURL = [pushJsonData objectForKey:@"pageurl"];
    NSString *openMethod = [pushJsonData objectForKey:@"method"];
    if ([openMethod isEqualToString:@"inner"]) {
        WebViewController *webVC = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
        [webVC setStrURL:strURL];
        return webVC;
    }
    else if ([openMethod isEqualToString:@"outer"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
    }

    return nil;
}

#pragma mark - 判断是不是首次登录或者版本更新
-(BOOL )isFirstLauch{
    //获取当前版本号
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentAppVersion = infoDic[@"CFBundleShortVersionString"];
    //获取上次启动应用保存的appVersion
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAppVersion"];
    //版本升级或首次登录
    if (version == nil || ![version isEqualToString:currentAppVersion]) {
        [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:@"kAppVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - 获取健康咨询所有栏目

- (void)getAllOfficeTypeAndUrl{
    NSString *encodedLocateInfo = nil;
    //新增虚拟定位
    NSString *addressStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"emulateLocationAddress"];
    if (!addressStr || addressStr.length <= 0) {
        encodedLocateInfo = [CureMeUtils defaultCureMeUtil].encodedLocateInfo;
    }else{
        encodedLocateInfo = addressStr;
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"http://new.medapp.ranknowcn.com/api/m.php?action=getallqtypebyappidandgps&appid=7&addrdetail=%@&version=3.0",encodedLocateInfo];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *response = sendGETRequest(urlStr);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!response) {
                NSLog(@"network error!");
                return ;
            }
            NSDictionary *returnDic = parseJsonResponse(response);
            if (!returnDic) {
                NSLog(@"Data error!");
                return;
            }
            NSNumber *result = [returnDic objectForKey:@"result"];
            if ([result integerValue] != 1) {
                NSLog(@"%@",[returnDic objectForKey:@"errmsg"]);
                return;
            }
            NSArray *msgArray = [returnDic objectForKey:@"msg"];
            webVC.officeTypeArray = msgArray;
        });
    });
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Regist fail%@",error);
    /*UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"failed"
                          message:[error localizedDescription]
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];*/
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [application cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
//    [self saveContext];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
