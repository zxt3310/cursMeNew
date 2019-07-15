//
//  Gloab.h
//  Exer
//
//  Created by xiaoshoucun on 15/9/15.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//

#ifndef Exer_Gloab_h
#define Exer_Gloab_h

//PNtoken
#define NSU_PN_TOKEN @"HM_PN_TOKEN"

typedef enum {
    MEMORY_SUCCESS = 2,
    LOCAL_SUCCESS = 1,
    NET_SUCCESS = 0,
    PARSE_FAIL = -1,
    NET_FAIL = -2,
    NET_TIMEOUT = -3,
    SERVER_ERROR = -4
} NET_CODE;


#define SINGLE_CHAT 0
#define ADMIN_MSG 2
#define ROOT_DIR @"hichat"
#define PNType @"2"

#define MESSAGE_MAX_LENGTH 1000
#define HISTORY_MSG_LIMIT 20
#define CHANNEL_ID 000
#define MAX_VIDEO_SIZE 1024*1024*5
#define MAX_AUDIO_TIME 60;

#define LOGIN_URL @"http://180.76.137.158:8090"
#define DOMAIN_NAME @"hichat.hesine.com"

#define HICHAT_LOGIN 0
#define HICHAT_ONLINE 1
#define HICHAT_LOGOUT 2
#define HICHAT_OFFLINE 3


#endif
