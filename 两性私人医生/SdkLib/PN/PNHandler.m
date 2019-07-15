//
//  PNHandler.c
//  Exer
//
//  Created by xiaoshoucun on 15/9/16.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//

#include "PNHandler.h"
#import "SystemInfo.h"
#include <stdlib.h>
#import "ReqBase.h"
#import "BoBase.h"
#import "RespBase.h"
#import "Gloabal.h"
#include "hpnsAppEngine.h"
#include "hpnsConfig.h"
#import "Config.h"

BoBase* bo = nil;

ABlock blockx = nil;

void pnInit(int appId, char* accountId, ABlock callback) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    char *charDocDir = [docDir cStringUsingEncoding:NSASCIIStringEncoding];
    hpnsSetSystemDirectory(charDocDir);
    //blockx = Block_copy(callback);
    blockx = [callback copy];
    nmSystemInit();
    
    SHpnsRegInfo appprofile = {0};
    appprofile.appId = appId;
    memcpy(appprofile.senderId, accountId, strlen(accountId));
    hpnsSendMsgToEngine(HPNS_MSG_REG_REQ, (UINT8 *)(&appprofile), sizeof(SHpnsRegInfo));
}

void pnRegister(int appId, char regId[], int code)
{
    memcpy(REGID, regId, strlen(regId));
    regCode = code;
    SystemInfo* si = [SystemInfo getSingleton];
    si.pnToken = [NSString stringWithCString:regId encoding:NSUTF8StringEncoding];
    [Config savePnToken:si.pnToken];
    bo = [[BoBase alloc] init];
    ReqBase* req = [[ReqBase alloc] init];
    ActionInfo* actionInfo = [req actionInfo];
    [actionInfo setActionId:ACTION_ID_SEND_PNTOKEN];
    [actionInfo setUserId:[Config getUserAccount]];
    [actionInfo setAppKey:[Config getAppKey]];
    [actionInfo setUserSource:ACTION_USRER_SRC_MOBILE];
    [actionInfo setUserType:ACTION_USRER_TYPE_COMMON_USER];
    [bo setResponseCls: [RespBase class]];
    [bo request:req withBaseUrl:LOGIN_URL Completed: ^(NSObject* owner, NSObject* data, int code) {
        if (code >= NET_SUCCESS) {
            [Config saveUploadPNTokenFlag:true];
        } else {
            [Config saveUploadPNTokenFlag:false];
        }
    }];
}

void pnUnRegister()
{
    if (nil != blockx) {
        //Block_release(blockx);
        blockx = nil;
    }

    return;
}

void pnNewNotification(char msg[])
{
    if (nil != blockx) {
        NSString* data = [[NSString alloc] initWithUTF8String:msg];
        blockx(msg);
    }
}

// void pnReconnect();
// void pnRegIdChanged(char[] regId);
