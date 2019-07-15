//
//  ActionInfo.h
//  Exer
//
//  Created by xiaoshoucun on 15/9/11.
//  Copyright (c) 2015年 Hesine. All rights reserved.
//

#import "JSONModel.h"

@interface ActionInfo : JSONModel

typedef enum {
    
    ACTION_ID_LOGIN_CHAT = 203,
    ACTION_ID_LOGOUT_CHAT = 204,
    ACTION_ID_SEND_PNTOKEN = 205,
    ACTION_ID_SEND_MSG = 207,
    ACTION_ID_RECV_MSG = 208,
    ACTION_ID_RECEIPT_MSG = 219,
    ACTION_ID_GET_HIS_MSG = 209,
    ACTION_ID_GET_MEMBER_LIST = 308,
    ACTION_ID_CHAT_LIST = 211,
    ACTION_ID_CLOSE_CHAT = 215,
    ACTION_ID_NEW_MSG_NOTICE = 218,
    ACTION_ID_USER_INFO = 312,
    ACTION_ID_USER_ON_LINE = 313,
    ACTION_ID_USER_OFF_LINE = 314,
    
    ACTION_ID_JOIN_CHAT = 315,
    ACTION_ID_JOIN_NOTICE = 316,
    ACTION_ID_CANCEL_JOIN = 317,
    ACTION_ID_CHAT_STATISTIC = 318,
    ACTION_ID_KICKED_OFF = 319,
    
    ACTION_ID_ONLINE = 206,
    ACTION_ID_KICK_USER = 213,
    ACTION_ID_CHANGE_USER = 214,
    ACTION_ID_NOTIFY = 216,
    ACTION_ID_CREATE_CHAT = 217,
    ACTION_ID_READED_NOTICE = 263,
    
    
    ACTION_ID_GET_SYS_TIME = 226,
    
    ACTION_ID_GET_STATUS = 283,
    ACTION_ID_GET_USER_CHAT_STATUS = 248,
    ACTION_ID_GET_CHAT_STATUS = 249,
    ACTION_ID_GET_USER_CHAT_DESC = 250,
    ACTION_ID_GET_CHAT_DESC = 251,
    ACTION_ID_GET_UNREAD_USER = 286
    
} ACTION_ID;

typedef enum {
    
    ACTION_USRER_SRC_MOBILE = 0,
    ACTION_USRER_SRC_WEBPAGE = 1,
    ACTION_USRER_SRC_DOCTOR = 2
    
} ACTION_USRER_SRC;

typedef enum {
    
    ACTION_USRER_TYPE_COMMON_USER = 0,
    ACTION_USRER_TYPE_CUSTOMER = 1
    
} ACTION_USRER_TYPE;


@property (nonatomic, assign)int actionId;
@property (nonatomic, assign)long chatId;
@property (nonatomic, strong)NSString *userId;
@property (nonatomic, strong)NSString *password;
@property (nonatomic, strong)NSString *appKey;
@property (nonatomic, assign)int userSource;
@property (nonatomic, assign)int userType;
@property (nonatomic, strong)NSString *deviceToken;

@end
