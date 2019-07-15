//
//  HiChat.h
//  HiChat
//
//  Created by xiaoshoucun on 15/11/6.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMessageInfo.h"
#import "CustomerInfo.h"
#import "HServiceInfo.h"

#define DOUBLE @"APNS_double"
typedef void(^callBackSimple)(NSError* error);

typedef void(^callBackServiceList)(NSArray<HServiceInfo>* array, NSError* error);

typedef void(^callBackReceiveMsg)(NSArray<HMessageInfo>* array, NSError* error);

typedef void(^callBackReceiptMsg)(HMessageInfo* msg, NSError* error);

@class UIApplication;

@interface HiChat : NSObject

typedef enum {
    
    ATTACHMENT_NONE = 0,
    ATTACHMENT_IMAGE = 1,
    ATTACHMENT_VEDIO = 2,
    ATTACHMENT_AUDIO = 3
    
} ATTACHMENT_TYPE;

typedef enum {
    
    MSG_STATUS_UNREAD = 0,
    MSG_STATUS_READ = 1,
    MSG_STATUS_SENT = 2,
    MSG_STATUS_SENDING = 3,
    MSG_STATUS_FAILED = 4
    
} MSG_STATUS;

+ (void)applicationDidEnterBackground:(UIApplication *)application;

+ (void)applicationWillEnterForeground:(UIApplication *)application;

+ (void)applicationDidBecomeActive:(UIApplication *)application;

+ (void)applicationWillTerminate:(UIApplication *)application;

+ (BOOL)apnsInitInFinishLaunch:(UIApplication *)application;

+ (void)submitDeviceToken:(NSData *)deviceToken;

+(void)init:(NSString*)appKey;

+(void)login:(NSString*)account withPassword:(NSString*)password completion:(callBackSimple) block;

+(void)logout:(NSString*)account completion:(callBackSimple) block;

+(void)requestCustomerServiceList:(callBackServiceList) block;

+(void)sendMessage:(NSString*)customerServiceAccount withBody:(NSString*)body withAttachType:(int) type withAttachName: (NSString*) name withAttachData:(NSData*) data completion:(callBackSimple) block;

+(void)sendMessage:(NSString*)customerServiceAccount withBody:(NSString*)body withAttachType:(int) type withAttachName: (NSString*) name withAttachPath:(NSString*) path completion:(callBackSimple) block;

+(void)registerMessageReceiveCallback:(callBackReceiveMsg) block;

+(void)registerMessageReceiptCallback:(callBackReceiptMsg) block;

+(NSArray<HMessageInfo>*)getAllMessages:(NSString*)customerServiceAccount;

+(int)getMessageCount:(NSString*)customerServiceAccount;

+(int)getUnreadMessageCount:(NSString*)customerServiceAccount;

+(void)setAllMessageRead:(NSString*)customerServiceAccount;

+(void)deleteMessage:(NSString*) msgId;

+(void)deleteConversation:(NSString*)customerServiceAccount;

+(void)pullNewestMessage;

+(void)pullHistoryMessage:(NSString*) customerServiceAccount withLimit:(int) limit completion:(callBackReceiveMsg) block;

+(void)procMsgReceipt;

@end
