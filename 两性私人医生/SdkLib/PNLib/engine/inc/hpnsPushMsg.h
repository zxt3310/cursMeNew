/******************************************************************* 
* Copyright (c) 2010 by Hesine Technologies, Inc. 
* All rights reserved. 
* 
* This file is proprietary and confidential to Hesine Technologies. 
* No part of this file may be reproduced, stored, transmitted, 
* disclosed or used in any form or by any means other than as 
* expressly provided by the written permission from Jianhui Tao 
* 
* ****************************************************************/

#ifndef _hpns_push_msg_h_
#define _hpns_push_msg_h_

#include "hpnsStm.h"
#include "hpnsConfig.h"
#include "hpnsMsg.h"
#include "hpnsAppEngine.h"

#define HPNS_MAX_PAYLOAD_LEN     1024  //950

typedef struct {
    UINT8         code;
    UINT32        sessionId;
    UINT32        heartBeatPeriod ;
    SHpnsIpAddr   pushIp;
    UINT8         securityFlag;
	UINT8         connMode;
	UINT8         tcpFlag;
    UINT8         *secret;
    UINT8         *hid;
	UINT32        numOfApp;
	SHpnsRegInfo  appList[HPNS_MAX_BUNDLE_APP_NUM];
} SHpnsReplyContext;

int  hpnsPreProcessIncomingMsg(UINT8 *pMsg, int msgLen); 
int  hpnsSendMsgToPushServer(UINT8 *msg, int msgLen);
int  hpnsSendDataToPushServer(UINT8 *msg, int msgLen);
int  hpnsDeliverMsgToPushServer(UINT8 *msg, int msgLen);
void hpnsProcessUdpData(void);
#ifdef __PNS_TCP_CONNECT_SUPPORT__
void hpnsProcessTcpData(void);
#endif

int  hpnsVerifyTimeStamp(UINT32 remoteTime);
int  hpnsBuildRegReqMsg( UINT8 **pData, SHpnsContext *pContext);
int  hpnsBuildLoginReqMsg( UINT8 **pData, SHpnsContext *pContext);
int  hpnsBuildStaticDataReqMsg(UINT8 **pData, SHpnsContext *pContext);
int  hpnsBuildReplyMsg(UINT8 **pData, UINT8 code, UINT8 flag, UINT32 appId, UINT32 msgId, UINT32 internalId, SHpnsContext *pContext);
int  hpnsBuildDetectResp( UINT8 **pData, SHpnsContext *pContext);
int  hpnsParseRespMsgFromServer(UINT8 *pMsg, SHpnsReplyContext *pReply);
int  hpnsPreParseDeliverMsg(UINT8 *pMsg, UINT8* pType, UINT8* pCode);


#endif


