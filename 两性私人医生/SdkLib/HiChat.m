//
//  HiChat.m
//  HiChat
//
//  Created by xiaoshoucun on 15/11/6.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import "HiChat.h"
#import "Config.h"
#import "BoBase.h"
#import "ActionInfo.h"
#import "ReqBase.h"
#import "RespBase.h"
#import "RespLoginChat.h"
#import "Gloabal.h"
#import "RespCustomerList.h"
#import "ReqSendMsg.h"
#import "Queuer.h"
#import "RespRecvMsg.h"
#import "PNHandler.h"
#import "ReqReceiptMsg.h"
#import "ReqGetHisMsg.h"
#import "HisMsgParam.h"
#import "AttachInfo.h"
#import "HMessageInfo.h"
#import "GTMBase64.h"
#import <UIKit/UIApplication.h>
#import <UIKit/UIUserNotificationSettings.h>


@interface HiChat ()
{
    BoBase* boLogin;
    BoBase* boLogout;
    BoBase* boSendApnsToken;
    BoBase* boCustomList;
    BoBase* boSendMsg;
    ABlock pnBlock;
    BoBase* boMsgReceipt;
    BoBase* boHistoryList;
}

@end

@implementation HiChat

static HiChat *ins = nil;
static callBackReceiveMsg receiveMsgBlock;
static callBackReceiptMsg receiptMsgBlock;

//获得单例
+(id)instance
{
    if (ins == nil) {
        ins = [[self alloc] init];
    }
    return ins;
}

+ (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

+ (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

+ (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

+ (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void) initPN {
    pnBlock = ^(const char* msg) {
        if ([Config getLoginStatus] >= HICHAT_LOGOUT) {
            return ;
        }
        if (strcmp(msg, "8888801") == 0) {
            [HiChat procMsgReceive];
        } else if(strstr(msg, "8888802") != NULL) {
            char* msgIds = (char*)(msg+8);
//            [[HiChat instance] procMsgReceipt:msgIds];
        }
    };
    pnInit(1610746113, "4bcd68c659956190", pnBlock);
}

+ (void)submitDeviceToken:(NSData *)deviceToken
{
    NSString* apnsToken = [NSString stringWithFormat:@"%@",deviceToken];
    NSString* apnsToken2 = [apnsToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* apnsToken3 = [apnsToken2 stringByReplacingOccurrencesOfString:@"<" withString:@""];
    NSString* apnsToken4 = [apnsToken3 stringByReplacingOccurrencesOfString:@">" withString:@""];
    [Config saveApnsToken:apnsToken4];
    [[HiChat instance] submitDeviceToken:apnsToken4];
}

+ (BOOL)apnsInitInFinishLaunch:(UIApplication *)application  {
    
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound |
        UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [application registerForRemoteNotificationTypes:notificationTypes];
    }
    
    return YES;
}

- (void)submitDeviceToken:(NSString *)deviceToken
{
    if (nil != boSendApnsToken) {
        //[boSendApnsToken release];
        boSendApnsToken = nil;
    }
    
    if (![Config getUserAccount]) {
        [Config saveUserAccount:[CureMeUtils defaultCureMeUtil].uniID];
    }
    
    SystemInfo* si = [SystemInfo getSingleton];
    //NSString* hpnsToken = si.pnToken;
    NSString* hpnsType = si.pnType;
    si.pnToken =  deviceToken;
    si.pnType = DOUBLE;
    boSendApnsToken = [[BoBase alloc] init];
    ReqBase* req = [[ReqBase alloc] init];
    ActionInfo* actionInfo = [req actionInfo];
    [actionInfo setActionId:ACTION_ID_SEND_PNTOKEN];
    [actionInfo setUserId:[Config getUserAccount]];
    [actionInfo setAppKey:[Config getAppKey]];
    [actionInfo setUserSource:ACTION_USRER_SRC_MOBILE];
    [actionInfo setUserType:ACTION_USRER_TYPE_COMMON_USER];
    [actionInfo setDeviceToken:deviceToken];
    [boSendApnsToken setResponseCls: [RespBase class]];
    [boSendApnsToken request:req withBaseUrl:LOGIN_URL Completed: ^(NSObject* owner, NSObject* data, int code) {
        [Config savePnToken:deviceToken];
        si.pnToken =  deviceToken;
        si.pnType = hpnsType;
    }];
}

+(void)init:(NSString*)appKey {
    [Config saveAppKey:appKey];
    [Config saveLoginStatus:HICHAT_OFFLINE];
   // [[HiChat instance] initPN];
}

+(void)procMsgReceipt{
    [[HiChat instance] procMsgReceipt:nil];
}

-(void)procMsgReceipt: (NSArray *)listMsgIds {
    if (nil != boMsgReceipt) {
        //[boMsgReceipt release];
        boMsgReceipt = nil;
    }
    boMsgReceipt = [[BoBase alloc] init];
    ReqReceiptMsg* req = [[ReqReceiptMsg alloc] init];
    ActionInfo* actionInfo = [req actionInfo];
    [actionInfo setActionId:ACTION_ID_RECEIPT_MSG];
    [actionInfo setUserId:[Config getUserAccount]];
    [actionInfo setAppKey:[Config getAppKey]];
    [actionInfo setUserSource:ACTION_USRER_SRC_MOBILE];
    [actionInfo setUserType:ACTION_USRER_TYPE_COMMON_USER];
    [req setRecvMsgList:(NSArray<NSString>*)listMsgIds];
    [boMsgReceipt setResponseCls:[RespBase class]];
    [boMsgReceipt request:req Completed:^(NSObject *request, NSObject *data, int code) {
        if (code >= NET_SUCCESS) {
            
//            for (NSString* msgId in listMsgIds) {
//                MessageInfo* msg = [MessageInfo JM_find:msgId];
//                if(nil != msg) {
//                    [msg setStatus:MSG_STATUS_READ];
//                    [msg JM_save];
//                    HMessageInfo* hMessageInfo = [[HMessageInfo alloc] initWithMessageInfo:msg];
//                    receiptMsgBlock(hMessageInfo, nil);
//                }
//            }
        } else {
//            NSError *err =  [NSError errorWithDomain:@"msg receipt fail"
//                                                code:1
//                                            userInfo:nil];
//            receiptMsgBlock(nil, err);
        }
    }];
}

-(void)login:(NSString*)account withPassword:(NSString*)password completion:(callBackSimple) block {
    if (nil != boLogin) {
        //[boLogin release];
        boLogin = nil;
    }
    if (![Config getUserAccount]) {
        [Config saveUserAccount:account];
    }
    
    boLogin = [[BoBase alloc] init];
    ReqBase* req = [[ReqBase alloc] init];
    ActionInfo* actionInfo = [req actionInfo];
    [actionInfo setActionId:ACTION_ID_LOGIN_CHAT];
    [actionInfo setUserId:account];
    [actionInfo setAppKey:[Config getAppKey]];
    [actionInfo setPassword:password];
    [actionInfo setUserSource:ACTION_USRER_SRC_MOBILE];
    [actionInfo setUserType:ACTION_USRER_TYPE_COMMON_USER];
    [boLogin setResponseCls:[RespLoginChat class]];
    [boLogin request:req withBaseUrl:LOGIN_URL Completed:^(NSObject *request, NSObject *data, int code) {
        if (code >= NET_SUCCESS) {
            RespLoginChat* resp = (RespLoginChat*)data;
            [Config saveServerIp:[[resp hiChatServerInfo] serverIp]];
            [Config saveServerPort:[[resp hiChatServerInfo] serverPort]];
            [Config saveLoginStatus:HICHAT_ONLINE];
            [Config saveUserAccount:account];
            [Config saveFormerUser:[Config getCurServiceAccount]];
            block(nil);
        } else {
            NSError *err =  [NSError errorWithDomain:@"login fail"
                                                code:1
                                            userInfo:nil];
            block(err);
        }
    }];
}
                    
+(void)login:(NSString*)account withPassword:(NSString*)password completion:(callBackSimple) block {
    [[HiChat instance] login:account withPassword:password completion:block];
}

-(void)logout:(NSString*)account completion:(callBackSimple) block {
    if (nil != boLogout) {
        //[boLogout release];
        boLogout = nil;
    }
    boLogout = [[BoBase alloc] init];
    ReqBase* req = [[ReqBase alloc] init];
    ActionInfo* actionInfo = [req actionInfo];
    [actionInfo setActionId:ACTION_ID_LOGOUT_CHAT];
    [actionInfo setUserId:account];
    [actionInfo setPassword:[Config getPassword]];
    [actionInfo setAppKey:[Config getAppKey]];
    [actionInfo setUserSource:ACTION_USRER_SRC_MOBILE];
    [actionInfo setUserType:ACTION_USRER_TYPE_COMMON_USER];
    [boLogout setResponseCls:[RespBase class]];
    [boLogout request:req withBaseUrl:LOGIN_URL Completed:^(NSObject *request, NSObject *data, int code) {
        if (code >= NET_SUCCESS) {
            [Config saveUserAccount:nil];
            [Config savePassword:nil];
            [Config saveLoginStatus:HICHAT_OFFLINE];
            block(nil);
        } else {
            NSError *err =  [NSError errorWithDomain:@"logout fail"
                                                code:1
                                            userInfo:nil];
            block(err);
        }
    }];
}

+(void)logout:(NSString*)account completion:(callBackSimple) block {
    [[HiChat instance] logout:account completion:block];
}

-(void)requestCustomerServiceList:(callBackServiceList) block {
    if (nil != boCustomList) {
        //[boCustomList release];
        boCustomList = nil;
    }
    boCustomList = [[BoBase alloc] init];
    ReqBase* req = [[ReqBase alloc] init];
    ActionInfo* actionInfo = [req actionInfo];
    [actionInfo setActionId:ACTION_ID_GET_MEMBER_LIST];
    [actionInfo setUserId:[Config getUserAccount]];
    [actionInfo setPassword:[Config getPassword]];
    [actionInfo setAppKey:[Config getAppKey]];
    [actionInfo setUserSource:ACTION_USRER_SRC_MOBILE];
    [actionInfo setUserType:ACTION_USRER_TYPE_COMMON_USER];
    [boCustomList setResponseCls:[RespCustomerList class]];
    [boCustomList request:req Completed:^(NSObject *request, NSObject *data, int code) {
        if (code >= NET_SUCCESS) {
            RespCustomerList* resp = (RespCustomerList*)data;
            NSArray<CustomerInfo> *customerInfoList = [resp customerInfoList];
            NSMutableArray<HServiceInfo>* serviceInfoList = [NSMutableArray arrayWithCapacity:1];
            if (nil != customerInfoList) {
                for (CustomerInfo* ci in customerInfoList) {
                    HServiceInfo* hsi = [[HServiceInfo alloc] init];
                    
                    [hsi setAccount:[[ci accountInfo] userId]];
                    [hsi setNickName:[[ci accountInfo] nickName]];
                    [serviceInfoList addObject:hsi];
                }
            }
            block(serviceInfoList, nil);
        } else {
            [Config saveUploadPNTokenFlag:false];
            NSError *err =  [NSError errorWithDomain:@"get customer service list fail"
                                                code:1
                                            userInfo:nil];
            block(nil, err);
        }
    }];
}

+(void)requestCustomerServiceList:(callBackServiceList) block {
    [[HiChat instance] requestCustomerServiceList:block];
}

+(void)registerMessageReceiveCallback:(callBackReceiveMsg) block {
    receiveMsgBlock = block;
}

+(void)registerMessageReceiptCallback:(callBackReceiptMsg) block {
    receiptMsgBlock = block;
}

+(void) procMsgReceive {
    ReqBase* req = [[ReqBase alloc] init];
    ActionInfo* actionInfo = [req actionInfo];
    [actionInfo setActionId:ACTION_ID_RECV_MSG];
    [actionInfo setUserId:[Config getUserAccount]];
    [actionInfo setAppKey:[Config getAppKey]];
    [actionInfo setUserSource:ACTION_USRER_SRC_MOBILE];
    [actionInfo setUserType:ACTION_USRER_TYPE_COMMON_USER];
    
    Queuer* queuer = [Queuer instance];
    [queuer request:req withResponse:[RespRecvMsg class] Completed:^(NSObject *request, NSObject *data, int code) {
        if (code >= NET_SUCCESS) {
            RespRecvMsg* resp = (RespRecvMsg*)data;
            NSMutableArray *listMsgIds = [NSMutableArray array];
            NSMutableArray *list = [NSMutableArray array];
            NSArray<MessageInfo>* msgs = [resp messages];
            int i = 0;
            long currentTime = [[NSDate date] timeIntervalSince1970];

            for (MessageInfo* msg in msgs) {
                i++;
                [msg setUpdateTime:(currentTime+i)];
                AttachInfo* ai = [msg attachInfo];
                if (nil != ai) {
                    NSString* thumbnailStr = [ai attachment];
                    if (nil != thumbnailStr) {
                        NSString* thumbnailPath = [AttachInfo getAttachThumbnailPath:[ai name]];
                        NSData* gtmData = [GTMBase64 decodeString:thumbnailStr];
                        NSString *utf8Str = [[NSString alloc]initWithData:gtmData encoding:NSUTF8StringEncoding];
                        NSStringEncoding enc =      CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
                        NSData* data = [utf8Str dataUsingEncoding:enc];
                        if (nil != data) {
                            [data writeToFile:thumbnailPath atomically:YES];
                        }
                        [ai setAttachment:nil];
                    }
                }
                [msg save];
                HMessageInfo* hMessageInfo = [[HMessageInfo alloc] initWithMessageInfo:msg];
                [list addObject:hMessageInfo];
                [listMsgIds addObject:[hMessageInfo msgId]];
            }
            [[HiChat instance] procMsgReceipt:listMsgIds];
            receiveMsgBlock([list copy], nil);
        } else {
            NSError *err =  [NSError errorWithDomain:@"send msg fail"
                                                code:1
                                            userInfo:nil];
            receiveMsgBlock(nil,err);
        }
    }];
}

-(void)sendMessage:(NSString*)customerServiceAccount withBody:(NSString*)body withAttach:(AttachInfo*) attachInfo completion:(callBackSimple) block {
    ReqSendMsg* req = [[ReqSendMsg alloc] init];
    ActionInfo* actionInfo = [req actionInfo];
    [actionInfo setActionId:ACTION_ID_SEND_MSG];
    [actionInfo setUserId:[Config getUserAccount]];
    [actionInfo setAppKey:[Config getAppKey]];
    [actionInfo setUserSource:ACTION_USRER_SRC_MOBILE];
    //[actionInfo setUserType:ACTION_USRER_TYPE_COMMON_USER];
    MessageInfo* mi = [[MessageInfo alloc] init];

    [mi setTo:customerServiceAccount];
    [mi setFrom:[Config getUserAccount]];
    [mi setBody:body];
    [mi setStatus:MSG_STATUS_SENDING];
    long currentTime = [[NSDate date] timeIntervalSince1970];
    [mi setTime:currentTime];
    [mi setUpdateTime:currentTime];
    NSMutableString* msgId = [[NSMutableString alloc] initWithString:[[SystemInfo getSingleton] imei]];
    [msgId appendString:[NSString stringWithFormat:@"%zd", [mi time]]];
    [mi setMsgId:[NSString stringWithString:msgId]];
    [mi setAttachInfo:attachInfo];
    int mark = 0;
    NSString* attachment = nil;
    if(nil != attachInfo) {
        mark = 1;
        attachment = [attachInfo attachment];
        [attachInfo setAttachment:nil]; // for not save attachment to DB!
    }
    [mi setAttachmentMark:mark];
    [mi save];
    
    if (nil != attachInfo) {
        [attachInfo setAttachment:attachment]; // just recover attachment to AttachInfo for sending to server!
    }
    [mi setStatus:MSG_STATUS_UNREAD]; // send to server the sataus must be UNREAD, not the client's SENDING.
    [req setMessageInfo:mi];

    Queuer* queuer = [Queuer instance];
    [queuer request:req withResponse:[RespBase class] Completed:^(NSObject *request, NSObject *data, int code) {
        [mi setAttachInfo:nil];
        if (code >= NET_SUCCESS) {
            [mi setStatus:MSG_STATUS_SENT];
            if (nil != attachInfo) {
                [attachInfo setAttachment:nil]; // for not save attachment
            }
            [mi save];
            block(nil);
        } else {
            [mi setStatus:MSG_STATUS_FAILED];
            if (nil != attachInfo) {
                [attachInfo setAttachment:nil]; // for not save attachment
            }
            [mi save];
            NSError *err =  [NSError errorWithDomain:@"send msg fail"
                                                code:1
                                            userInfo:nil];
            block(err);
        }
    }];
}

+ (NSString *)URLEncodeValue:(NSString*) value
{
    NSString *string = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                              (CFStringRef) value,
                                                              NULL,
                                                              (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return string;
    
}

+(void)sendMessage:(NSString*)customerServiceAccount withBody:(NSString*)body withAttachType:(int) type withAttachName:(NSString*) name withAttachData:(NSData*) attachData completion:(callBackSimple) block {
    AttachInfo* ai = nil;
    if (ATTACHMENT_NONE != type && nil != attachData) {
        ai = [[AttachInfo alloc] init];
        [ai setType:type];
        [ai setName:name];
        NSString* path = [AttachInfo getAttachPath:type withName:name];
        [ai setPath:path];
        [attachData writeToFile:path atomically:YES];
        [ai setAttachment:[GTMBase64 stringByEncodingData:attachData]];
    }
    [HiChat sendMessage:customerServiceAccount withBody:body withAttach:ai completion:block];
}

+(void)sendMessage:(NSString*)customerServiceAccount withBody:(NSString*)body withAttachType:(int) type withAttachName: (NSString*) name withAttachPath:(NSString*) path completion:(callBackSimple) block {
    NSData* data = nil;
    if (ATTACHMENT_NONE != type && nil != path) {
        data = [NSData dataWithContentsOfFile:path];
    }
    [HiChat sendMessage:customerServiceAccount withBody:body withAttachType:type withAttachName:name withAttachData:data completion:block];
}

+(void)sendMessage:(NSString*)customerServiceAccount withBody:(NSString*)body withAttach:(AttachInfo*) attachInfo completion:(callBackSimple) block {
    [[HiChat instance] sendMessage:customerServiceAccount withBody:body withAttach:attachInfo completion:block];
}

+(NSArray<HMessageInfo>*)getAllMessages:(NSString*)customerServiceAccount {
    NSArray<MessageInfo>* array = [MessageInfo JM_where:[NSString stringWithFormat:@" (%@ = '%@' and %@ = '%@') or (%@ = '%@' and %@ = '%@') order by updateTime_hichat asc", @"from_hichat",  [HiChat URLEncodeValue:customerServiceAccount], @"to_hichat", [HiChat URLEncodeValue:[Config getUserAccount]], @"to_hichat",  [HiChat URLEncodeValue:customerServiceAccount], @"from_hichat", [HiChat URLEncodeValue:[Config getUserAccount]]]];
    NSMutableArray *list = [NSMutableArray array];
    for (MessageInfo* msg in array) {
        AttachInfo* ai = [AttachInfo JM_find:[HiChat URLEncodeValue:[msg msgId]]];
        if (ai != nil) {
            NSLog(@"attach info :%@,%d",ai,[array indexOfObject:msg]);
        }
        [msg setAttachInfo:ai];
        HMessageInfo* hMessageInfo = [[HMessageInfo alloc] initWithMessageInfo:msg];
        [list addObject:hMessageInfo];
    }
    return list;
}

+(int)getMessageCount:(NSString*)customerServiceAccount {
    NSArray<MessageInfo>* list = [MessageInfo JM_where:[NSString stringWithFormat:@" (%@ = '%@' and %@ = '%@') or (%@ = '%@' and %@ = '%@') ", @"from_hichat",  [HiChat URLEncodeValue:customerServiceAccount], @"to_hichat", [HiChat URLEncodeValue:[Config getUserAccount]], @"to_hichat",  [HiChat URLEncodeValue:customerServiceAccount], @"from_hichat", [HiChat URLEncodeValue:[Config getUserAccount]]]];
    return [list count];
}

+(int)getUnreadMessageCount:(NSString*)customerServiceAccount {
        NSArray<MessageInfo>* list = [MessageInfo JM_where:[NSString stringWithFormat:@" ((%@ = '%@' and %@ = '%@') or (%@ = '%@' and %@ = '%@')） and status_hichat = 0 ", @"from_hichat",  [HiChat URLEncodeValue:customerServiceAccount], @"to_hichat", [HiChat URLEncodeValue:[Config getUserAccount]], @"to_hichat",  [HiChat URLEncodeValue:customerServiceAccount], @"from_hichat", [HiChat URLEncodeValue:[Config getUserAccount]]]];
    return [list count];
}

+(void)setAllMessageRead:(NSString*)customerServiceAccount {
        NSArray<MessageInfo>* list = [MessageInfo JM_where:[NSString stringWithFormat:@" ((%@ = '%@' and %@ = '%@') or (%@ = '%@' and %@ = '%@')） and status_hichat = 0 ", @"from_hichat",  [HiChat URLEncodeValue:customerServiceAccount], @"to_hichat", [HiChat URLEncodeValue:[Config getUserAccount]], @"to_hichat",  [HiChat URLEncodeValue:customerServiceAccount], @"from_hichat", [HiChat URLEncodeValue:[Config getUserAccount]]]];
    for (MessageInfo* msg in list) {
        [msg setStatus:MSG_STATUS_READ];
        [msg JM_save];
    }
}

+(void)deleteMessage:(NSString*) msgId {
    //MessageInfo* msg = [MessageInfo JM_find:[HiChat URLEncodeValue:msgId]];
    //[msg JM_delete];
    [MessageInfo JM_deleteWhereRaw:[NSString stringWithFormat:@" msgId_hichat = '%@' ", [HiChat URLEncodeValue:msgId]]];
}

+(void)deleteConversation:(NSString*)customerServiceAccount {
//    int count1 = [HiChat getMessageCount:customerServiceAccount];
    NSArray<HMessageInfo>*message = [HiChat getAllMessages:customerServiceAccount];
//    [MessageInfo JM_deleteWhereRaw:[NSString stringWithFormat:@" (from_hichat = '%@' and to_hichat = '%@') or (from_hichat = '%@' and to_hichat = '%@') ", [HiChat URLEncodeValue:customerServiceAccount], [HiChat URLEncodeValue:[Config getUserAccount]], [HiChat URLEncodeValue:[Config getUserAccount]], [HiChat URLEncodeValue:customerServiceAccount]]];
    for (HMessageInfo* msg in message) {
        [HiChat deleteMessage:[msg msgId]];
    }
//    int count2 = [HiChat getMessageCount:customerServiceAccount];
//    NSArray<HMessageInfo>*message2 = [HiChat getAllMessages:customerServiceAccount];
}

+(void)pullNewestMessage {
    [HiChat procMsgReceive];
}

-(void)pullHistoryMessage: (NSString*) customerServiceAccount withLimit:(int) limit
               completion:(callBackReceiveMsg) block {
    if (nil != boHistoryList) {
        //[boHistoryList release];
        boHistoryList = nil;
    }
    boHistoryList = [[BoBase alloc] init];
    ReqGetHisMsg* req = [[ReqGetHisMsg alloc] init];
    ActionInfo* actionInfo = [req actionInfo];
    [actionInfo setActionId:ACTION_ID_GET_HIS_MSG];
    [actionInfo setUserId:[Config getUserAccount]];
    [actionInfo setPassword:[Config getPassword]];
    [actionInfo setAppKey:[Config getAppKey]];
    [actionInfo setUserSource:ACTION_USRER_SRC_MOBILE];
    [actionInfo setUserType:ACTION_USRER_TYPE_COMMON_USER];
    HisMsgParam* hisMsgParam = [[HisMsgParam alloc] init];
    [hisMsgParam setLimit:limit];
    //[hisMsgParam setDestUserId:customerServiceAccount];
    [req setHisMsgParam:hisMsgParam];
    [boHistoryList setResponseCls:[RespRecvMsg class]];
    [boHistoryList request:req Completed:^(NSObject *request, NSObject *data, int code) {
        if (code >= NET_SUCCESS) {
            RespRecvMsg* resp = (RespRecvMsg*)data;
            NSMutableArray *list = [NSMutableArray array];
            for (MessageInfo* msg in [resp messages]) {
                [msg setUpdateTime:[msg time]];
                AttachInfo* ai = [msg attachInfo];
                if (nil != ai) {
                    NSString* thumbnailStr = [ai attachment];
                    if (nil != thumbnailStr) {
                        NSString* thumbnailPath = [AttachInfo getAttachThumbnailPath:[ai name]];
                        NSData* gtmData = [GTMBase64 decodeString:thumbnailStr];
                        NSString *utf8Str = [[NSString alloc]initWithData:gtmData encoding:NSUTF8StringEncoding];
                        NSStringEncoding enc =      CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
                        NSData* data = [utf8Str dataUsingEncoding:enc];
                        if (nil != data) {
                            [data writeToFile:thumbnailPath atomically:YES];
                        }
                        [ai setAttachment:nil];
                    }
                }
                [msg save];
                HMessageInfo* hMessageInfo = [[HMessageInfo alloc] initWithMessageInfo:msg];
                [list addObject:hMessageInfo];
            }
            
            block(list, nil);
        } else {
            NSError *err =  [NSError errorWithDomain:@"pull history msg fail"
                                                code:1
                                            userInfo:nil];
            block(nil, err);
        }
    }];
}

+(void)pullHistoryMessage:(NSString*) customerServiceAccount withLimit:(int) limit completion:(callBackReceiveMsg) block {
    [[HiChat instance] pullHistoryMessage:customerServiceAccount withLimit:limit completion:block];
}


@end
