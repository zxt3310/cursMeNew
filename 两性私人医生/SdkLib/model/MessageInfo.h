//
//  MessageInfo.h
//
//  Created by xiaoshoucun on 15/10/30.
//  Copyright (c) 2015年 Hesine. All rights reserved.
//

#import "JSONModel.h"
#import "AttachInfo.h"

@protocol MessageInfo @end

@interface MessageInfo : JSONModel

/**
 * 消息类型： 0-用户与客服单聊，1-客服间单聊，2-用户间单聊，3-用户间群聊，10-通知消息
 */
typedef enum {
    
    TYPE_COMMON_USER_AND_CUSTOMER = 0,
    TYPE_CUSTOMER_AND_CUSTOMER = 1,
    TYPE_COMMON_USER_AND_COMMON_USER =2,
    TYPE_COMMON_USER_GROUP =3,
    TYPE_COMMON_NOTIFY = 10
    
} TYPE_CHAT;

typedef enum {
    
    SUB_TYPE_CUSTOMER_AUTO_REPLY=1
} SUB_TYPE_CHAT;

@property (nonatomic, strong)NSString<JMPrimaryKey> *msgId;
@property (nonatomic, assign)long time;
@property (nonatomic, strong)NSString<JMText> *from;
@property (nonatomic, strong)NSString<JMText> *to;
@property (nonatomic, strong)NSString<JMText> *body;
@property (nonatomic, assign)int attachmentMark;
@property (nonatomic, assign)long chatId;
@property (nonatomic, assign)int unread;
@property (nonatomic, assign)int status;
@property (nonatomic, assign)int type;
@property (nonatomic, strong)NSString<JMText> *notifyType;
@property (nonatomic, strong)NSString<JMText> *subject;
@property (nonatomic, strong)AttachInfo<JMText> *attachInfo;
@property (nonatomic, assign)int subType;
@property (nonatomic, assign)int source;
@property (nonatomic, assign)long updateTime;


- (BOOL)save;


@end
