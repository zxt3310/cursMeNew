//
//  WebViewController.h
//  CureMe
//
//  Created by Tim on 12-11-19.
//  Copyright (c) 2012年 Tim. All rights reserved.
//

#import "WebViewJavascriptBridge.h"
#import "CustomBaseViewController.h"
#import <UIKit/UIKit.h>
#import "Mixpanel.h"
#import "WebViewCoverView.h"

@class LoadingView;

@interface WebViewController : CustomBaseViewController<UIWebViewDelegate,pageCoverDismissDelegate>
{
    NSURL *URL;
    WebViewJavascriptBridge *jsBridge;
    bool hasNavigated;
    
    UIBarButtonItem *leftBarButton;
    UIBarButtonItem *rightBarItem;
    NSString *navigationBarTitle;
    
    LoadingView *loadingView;
}

//#warning will be back
//@property (nonatomic, retain) NSArray *photos;

@property bool isMainTabPage;
@property (nonatomic, strong) NSString *strURL;
@property (strong, nonatomic) IBOutlet UIWebView *html5View;
@property NSInteger subOfficeId;
@property NSInteger childOfficeId;
@property BOOL isPaymentPage;

// 接收未读消息的更新通知
- (void)ntfUpdateUnreadMsgCount:(NSNotification *)note;

//- (void)navigateToURL:(NSString *)strURL;

- (void)processJSEvent:(NSData *)data;

- (void)processURL:(NSArray *)paramArray andFullURL:(NSString *)fullURL;

- (void)processOpenURL:(NSArray *)paramArray andFullURL:(NSString *)fullURL;
- (void)processHuodongChatURL:(NSArray *)paramArray;    // 处理huodong下的聊天页面请求
- (void)processMessageChatURL:(NSArray *)paramArray;    // 处理message下的聊天页面请求
- (void)processChatListURL:(NSArray *)paramArray;       // 处理聊天列表页面请求
- (void)processNewBookingURL:(NSArray *)paramArray;     // 处理新建预约请求
- (void)processBookingURL:(NSArray *)paramArray;        // 处理预约详情页面请求
- (void)processBookingListURL:(NSArray *)paramArray;    // 处理预约列表页面请求
- (void)processHuodongURL:(NSArray *)paramArray;        // 处理活动网页请求
- (void)processHuodongListURL:(NSArray *)paramArray;    // 处理活动列表页面请求


@end

