//
//  PNHandler.h
//  Exer
//
//  Created by xiaoshoucun on 15/9/16.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//

#ifndef Exer_PNHandler_h
#define Exer_PNHandler_h

char REGID[64];
int regCode;
char NOTIMSG[257];

typedef void (^ABlock)(const char*);

void pnInit(int appId, char* accountId, ABlock block);

void pnRegister(int appId, char regId[], int code);
void pnUnRegister();
void pnNewNotification(char msg[]);
// void pnReconnect();
// void pnRegIdChanged(char[] regId);

#endif
