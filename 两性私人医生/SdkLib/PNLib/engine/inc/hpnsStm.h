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
#ifndef _hpns_stm_header_
#define _hpns_stm_header_

#include "hpnsConfig.h"

#define RECONNECT_TIMER_STEP    60     // seconds   
#define RECONNECT_MAX_TIMER     3600   // seconds
#define HPNS_MAX_NUM_RETRY       3    //3
#define HPNS_TRAN_WAIT_TIME      10
#define HPNS_REPOST_TIME         60   // seconds

#define HPNS_HB_PACKET_LEN       4
#define HPNS_UPDATE_PACKET_LEN   8

#define HPNS_STATUS_INIT             0
#define HPNS_STATUS_UNCONNECTED      1
#define HPNS_STATUS_BLOCKING         2
#define HPNS_STATUS_CONNECTING       3
#define HPNS_STATUS_CONNECTED        4

enum {
    HPNS_TIMERID_HEART_BEAT,
    HPNS_TIMERID_CONNECTION,
    HPNS_TIMERID_TRANSACTION,
    HPNS_TIMERID_HEART_BEAT_RESP,
	HPNS_TIMERID_MAX
};

typedef struct 
{
    INT16    connStatus;
	UINT8    apnType;
    UINT8    outTranId;
    UINT8    inTranId;
    UINT8    msgTranId;
    UINT8    outType;
    UINT8    inType;
    UINT32   numOfRetry;
    UINT32   heartbeatRetry;
    UINT32   remoteSessionId;
    UINT32   localSessionId;
    UINT32   heartBeatPeriod; //seconds
	UINT32   localIp; 
	UINT8    tcpFlag;
	INT8     ApIndex;
	UINT8    APName[HPNS_AP_NAME_LEN + 1];
	
    UINT8    *msg;
    UINT16    msgLen;

    UINT8    *rspMsg;
    UINT16    rspMsgLen;

    UINT32    spi;
    UINT8     securityFlag;

    UINT8    *pError;   
	UINT8     hpnsTtl;	
} SHpnsContext;

extern SHpnsContext hpnsContext;

#define HPNS_CONNECTION_ERROR_NETWORK   1
#define HPNS_CONNECTION_ERROR_SERVICE   2
#define HPNS_CONNECTION_ERROR_TCP_OPEN  3

int  hpnsInitConnection(void);
void hpnsHandleConnectionError(UINT8 flag);
void hpnsOpenConnectionToPushServer(void);
void hpnsCloseConnectionToPushServer(void);
void hpnsStartRegistration(void);
int  hpnsProcessDnsResult(UINT32 ip);
int  hpnsCancelTransactionToPushServer(void);
int  hpnsProcessHeartbeatReceived(void);
void hpnsProcessMsgFromPushServer(UINT8 *pMsg, int msgLen, UINT32 ip, UINT16 port);
int  hpnsProcessStatisticsInfo(void);
int  hpnsSendStaticDataToServer(void);
void hpnsHandleMsg (int msgId, UINT8 *pMsg, int msgLen);
int hpnsSendHeartbeatToServer(void);





#endif

