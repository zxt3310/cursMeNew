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

#include "hpnsStm.h"
#include "hpnsConfig.h"
#include "hpnsAppEngine.h"
#include "hpnsMsg.h"
#include "hpnsPushMsg.h"
#include "hpnsUtil.h"
#include "hpnsTimer.h"
//#include "tmodule.h"
//#include "hpnsNetwork.h"
#include "hpnsStm.h"
#include "header.h"

char *hpnsAppEngineMsg[] = {
	"reg-req",
	"reg-resp",
	"unreg-req",
	"unreg-resp",
	"regId-changed-notify",
	"new-msg-notify",
	"notification-resp",
	"push-notification-turn",
	"change-connect-mode",
	"network-state-changed",
	"upload-device-info",
	"data-read-ind",
	"data-write-ind",
	"nw-error-ind",
	"hpns-end"
};

extern INT32      pushServerFd;
extern INT32      numOfRound;


void hpnsProcessHeartbeatTimer(int param);
void hpnsProcessConnectionTimer(int param);
void hpnsProcessTransactionTimer(int param);
void hpnsProcessHeartbeatRespTimer(int param);

int hpnsSendMsgToEngine(int mid, UINT8 *pMsg, int msgLen) 
{
	hpnsSendMsgToEngineP(mid, pMsg, msgLen);

	if ( mid != HPNS_MSG_DATA_READ_IND && mid != HPNS_MSG_DATA_WRITE_IND)
		nprintf("msg:%s is sent to engine", hpnsAppEngineMsg[mid]);

	return 0;
}

int hpnsSendMsgToUI(int mid, UINT8 *pMsg, int msgLen) 
{
	hpnsSendMsgToUIP(mid, pMsg, msgLen);
	
	nprintf("msg:%s is sent to UI", hpnsAppEngineMsg[mid]);
	return 0;
}

void hpnsInitAllTimers()
{
    hpnsInitTimer(HPNS_TIMERID_HEART_BEAT, hpnsProcessHeartbeatTimer, "heart beat timer");
    hpnsInitTimer(HPNS_TIMERID_CONNECTION, hpnsProcessConnectionTimer, "conn timer");
    hpnsInitTimer(HPNS_TIMERID_TRANSACTION, hpnsProcessTransactionTimer, "tran timer");
    hpnsInitTimer(HPNS_TIMERID_HEART_BEAT_RESP, hpnsProcessHeartbeatRespTimer, "hb-resp timer");

	return;
}

int hpnsInitTask(void)
{		
	SDeviceInfo tmpDeviceInfo = {0};
	int         i = 0;
	
	hpnsInitAllTimers();
	hpnsInitConnection();
	hpnsInitLog();

	if(hpnsReadHpnsInfo() < 0 )
	{		
		nprintf("failed to read hpns info when initing task, init default hpnsinfo");
		hpnsInitHpnsInfo();
	}
	else
	{
		hpnsGetDeviceInfo(&tmpDeviceInfo);
		if(tmpDeviceInfo.imsi[0][0] == 0)
			memcpy(tmpDeviceInfo.imsi[0], hpnsInfo.deviceInfo.imsi[0], HPNS_IMSI_LEN );
		
		if(memcmp(&hpnsInfo.deviceInfo, &tmpDeviceInfo, sizeof(SDeviceInfo)-sizeof(tmpDeviceInfo.imsi)) != 0)
		{
			nprintf("device info is changed, need to update ");
			memcpy(&hpnsInfo.deviceInfo, &tmpDeviceInfo, sizeof(SDeviceInfo) );	
			hpnsInfo.updateFlag = 1;
		}
			
		for(i = 0; i < HPNS_MAX_IMSI_NUM; i++)
		{
			if(memcmp(tmpDeviceInfo.imsi[i], hpnsInfo.deviceInfo.imsi[i], 6) != 0)
			{			
				hpnsMemCpy(hpnsInfo.deviceInfo.imsi[i], tmpDeviceInfo.imsi[i], HPNS_IMSI_LEN);
				hpnsInfo.updateFlag = 1;
			}
		}

		if( memcmp( hpnsInfo.hid, defaultHid, HPNS_HID_LEN) == 0 )
				memcpy(hpnsInfo.secret, hpnsInfo.deviceInfo.imsi[0], sizeof(hpnsInfo.secret) );
		
		hpnsGetLocationInfo(hpnsInfo.latitude, hpnsInfo.longitude);

	}
	
	hpnsContext.connStatus = HPNS_STATUS_UNCONNECTED;	
	nprintf("push engine is ready, numofBundled:%d, PNturn:%d, connMode:%d, staticDataFlag:%d", hpnsInfo.numOfBundled, hpnsInfo.PNOnOrOff, hpnsInfo.connMode, hpnsInfo.staticDataFlag);

	//Two cases to connect to ps automatically when the PE restarts:
	//1. there are one or more bundled APPs and connection mode is not manual mode and PN service is not off
	//2.there is no bundled APP and user agrees to collect the static info
	if( (hpnsInfo.numOfBundled && (hpnsInfo.connMode != HPNS_NCM_MANUAL) && (hpnsInfo.PNOnOrOff != HPNS_PUSH_NOTIFICATION_OFF)) || \
		(hpnsInfo.numOfBundled == 0 && hpnsInfo.staticDataFlag == HPNS_STATIC_DATA_UPLOAD_STATIC))
		hpnsOpenConnectionToPushServer();

	return 0;
}

void hpnsProcessReceivedData(UINT32 sockFd)
{
	if ( sockFd == pushServerFd )
	{
		hpnsProcessUdpData();
	}
	#ifdef __PNS_TCP_CONNECT_SUPPORT__
	else if(sockFd == hpnsPushTcpFd)
	{
		hpnsProcessTcpData();
	}
	#endif
	
	return;
}

void hpnsProcessWriteDataInd(UINT32 sockFd)
{
	if ( sockFd == pushServerFd ) 
	{
		if ( hpnsContext.connStatus == HPNS_STATUS_BLOCKING )
			hpnsStartRegistration();	
		else
			hpnsProcessUdpData();		
	}
	#ifdef __PNS_TCP_CONNECT_SUPPORT__
	else if(sockFd == hpnsPushTcpFd)
	{
		
		if ( hpnsContext.connStatus == HPNS_STATUS_BLOCKING )
			hpnsStartRegistration();
		else
			hpnsProcessTcpData();
	}
	#endif
	
	return;
}

void hpnsProcessNetworkError(UINT32 sockFd)
{
	if ( sockFd == pushServerFd 
		#ifdef __PNS_TCP_CONNECT_SUPPORT__
		|| sockFd == hpnsPushTcpFd
		#endif
		)
	{	
		numOfRound = 0;
		hpnsKillTimer (HPNS_TIMERID_CONNECTION);
		mruIp.pos = 0;
		hpnsHandleConnectionError(HPNS_CONNECTION_ERROR_NETWORK);
	}

	return;
}

void hpnsProcessRegistrationReq(SHpnsRegInfo *pAppRegInfo)
{
    if (!pAppRegInfo)
        return;
    
	UINT8  *pData;
    int    msgLen = 0, i = 0, index = -1;
	SHpnsRegInfo hpnsRegInfo ={0};

	hpnsRegInfo.appId = pAppRegInfo->appId;

	if( hpnsInfo.PNOnOrOff == HPNS_PUSH_NOTIFICATION_OFF)
	{
		hpnsRegInfo.appCode = HPNS_PUSH_NOTIFICATION_SUSPEND;
		nprintf("push notification is suspend");
		hpnsSendMsgToUI(HPNS_MSG_REG_RSP, (UINT8 *)&hpnsRegInfo, sizeof(SHpnsRegInfo));
		return;
	}
	
	if(!pAppRegInfo || pAppRegInfo->senderId[0] == '\0')
	{
		hpnsRegInfo.appCode = HPNS_INVALID_SENDER;
		nprintf("senderId from app is null");
		hpnsSendMsgToUI(HPNS_MSG_REG_RSP, (UINT8 *)&hpnsRegInfo, sizeof(SHpnsRegInfo));
		return;
	}

	if(pAppRegInfo->appId == 0)
	{
		hpnsRegInfo.appCode = HPNS_INVALID_APPID;
		nprintf("appId from app is 0");
		hpnsSendMsgToUI(HPNS_MSG_REG_RSP, (UINT8 *)&hpnsRegInfo, sizeof(SHpnsRegInfo));
		return;
	}

	for(i=0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
	{
		if( hpnsInfo.appBundled[i].appId == pAppRegInfo->appId && (hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_ON))
		{
			hpnsMemCpy( hpnsRegInfo.regId, hpnsInfo.appBundled[i].regId, HPNS_REGID_LEN);
			hpnsByteArrayToHexStr((char *)hpnsRegInfo.regId, HPNS_REGID_LEN);
			hpnsSendMsgToUI(HPNS_MSG_REG_RSP, (UINT8 *)&hpnsRegInfo, sizeof(SHpnsRegInfo));
			return;
		}
		else if(hpnsInfo.appBundled[i].appId == pAppRegInfo->appId && (hpnsInfo.appBundled[i].status != HPNS_APP_STATUS_ON))
		{
			hpnsRegInfo.appCode = HPNS_LAST_MSG_ON_PROCESSING;
			nprintf("last msg is processing, wait for a monment");
			hpnsSendMsgToUI(HPNS_MSG_REG_RSP, (UINT8 *)&hpnsRegInfo, sizeof(SHpnsRegInfo));
			return;
		}
		
		if( hpnsInfo.appBundled[i].appId == 0 && index == -1)
			index = i;
	}

	if(hpnsContext.outType != 0 || hpnsContext.connStatus == HPNS_STATUS_BLOCKING || hpnsContext.connStatus == HPNS_STATUS_CONNECTING)
	{
		hpnsRegInfo.appCode = HPNS_LAST_MSG_ON_PROCESSING;
		nprintf("last msg is processing, wait for a monment");
		hpnsSendMsgToUI(HPNS_MSG_REG_RSP, (UINT8 *)&hpnsRegInfo, sizeof(SHpnsRegInfo));
		return;
	}

	if( (index < HPNS_MAX_BUNDLE_APP_NUM ) && (index != -1))
	{
		hpnsMemSet(&(hpnsInfo.appBundled[index]), 0x0, sizeof(SHpnsAppProfile));
		
		hpnsInfo.appBundled[index].appId = pAppRegInfo->appId;
		memcpy(hpnsInfo.appBundled[index].senderId, pAppRegInfo->senderId, HPNS_SENDER_LEN);
		hpnsInfo.appBundled[index].status = HPNS_APP_STATUS_BUNDLING;
	}
	else if(index == -1)
	{
		hpnsRegInfo.appCode = HPNS_TOO_MANY_REGISTRATIONS;
		nprintf("there are %d bundled app, it is up to maxnum.", hpnsInfo.numOfBundled);
		hpnsSendMsgToUI(HPNS_MSG_REG_RSP, (UINT8 *)&hpnsRegInfo, sizeof(SHpnsRegInfo));
		return;
	}

	hpnsSaveHpnsInfo();	

	if( hpnsContext.connStatus == HPNS_STATUS_UNCONNECTED || ( pushServerFd == -1 
	#ifdef __PNS_TCP_CONNECT_SUPPORT__
	&& hpnsPushTcpFd == -1 
	#endif
	))
	{
		numOfRound = 0;
		hpnsKillTimer (HPNS_TIMERID_CONNECTION);
		mruIp.pos = 0;
		hpnsOpenConnectionToPushServer();
		return;
	}
	
	msgLen = hpnsBuildRegReqMsg( &pData, &hpnsContext);
	hpnsSendMsgToPushServer(pData, msgLen);
	
	return;
}

void hpnsProcessUnRegistrationReq(UINT32 appId)
{
	UINT8  *pData;
    int    msgLen = 0, i = 0;
	SHpnsRegInfo hpnsRegInfo ={0};
	
	for(i=0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
	{
		if( hpnsInfo.appBundled[i].appId == appId)
			break;
	}

	if( i >= HPNS_MAX_BUNDLE_APP_NUM || appId == 0)
	{
		hpnsRegInfo.appId = appId;
		hpnsRegInfo.appCode = HPNS_INVALID_APPID;
		nprintf("failed to find app in app list,appId:%d", appId);
		hpnsSendMsgToUI(HPNS_MSG_UNREG_RSP, (UINT8 *)&hpnsRegInfo, sizeof(SHpnsRegInfo));
		return;
	}

	hpnsMemSet(&(hpnsInfo.appBundled[i]), 0x0, sizeof(SHpnsAppProfile) );
	hpnsRegInfo.appId = appId;
	
	if( hpnsInfo.PNOnOrOff == HPNS_PUSH_NOTIFICATION_OFF)
		hpnsRegInfo.appCode = HPNS_PUSH_NOTIFICATION_SUSPEND;
	
	hpnsSendMsgToUI(HPNS_MSG_UNREG_RSP, (UINT8 *)&hpnsRegInfo, sizeof(SHpnsRegInfo));
	hpnsSaveHpnsInfo();	

	if( hpnsInfo.PNOnOrOff == HPNS_PUSH_NOTIFICATION_OFF)
	{
		nprintf("push notification is off, can't connect to PS");
		return;
	}
	
	if( hpnsContext.connStatus == HPNS_STATUS_UNCONNECTED || (pushServerFd == -1
	#ifdef __PNS_TCP_CONNECT_SUPPORT__
	&& hpnsPushTcpFd == -1 
	#endif
	))
	{
		numOfRound = 0;
		hpnsKillTimer (HPNS_TIMERID_CONNECTION);
		mruIp.pos = 0;
		hpnsOpenConnectionToPushServer();
		return;
	}
	else if( hpnsContext.connStatus == HPNS_STATUS_BLOCKING || hpnsContext.connStatus == HPNS_STATUS_CONNECTING)
	{
		nprintf("the connection is processing,so no need to sync");
		return;
	}
	
	msgLen = hpnsBuildRegReqMsg(&pData, &hpnsContext);
	hpnsSendMsgToPushServer(pData, msgLen);
	
	return;
}

void hpnsProcessNotificaitonResp(UINT32 appId)
{
	int i = 0;

	if(appId == 0)
		return;

	for(i=0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
	{
		if( hpnsInfo.appBundled[i].appId == appId)
		{
			hpnsInfo.appBundled[i].numOfNoRsp = 0 ;
			break;
		}
	}

	hpnsSaveHpnsInfo();	
	return;
}

void hpnsProcessPushNotificationSwitch(UINT32 turnFlag)
{
	nprintf("set push notification on or off, flag:%d, numOfbundled:%d", turnFlag, hpnsInfo.numOfBundled);

	if(turnFlag == HPNS_PUSH_NOTIFICATION_OFF )
	{
		hpnsInfo.PNOnOrOff = HPNS_PUSH_NOTIFICATION_OFF;
		hpnsKillTimer (HPNS_TIMERID_CONNECTION);
		hpnsCloseConnectionToPushServer();
	}
	else if( turnFlag == HPNS_PUSH_NOTIFICATION_ON)
	{
		hpnsInfo.PNOnOrOff = HPNS_PUSH_NOTIFICATION_ON;
		if(hpnsInfo.numOfBundled)
		{
			numOfRound = 0;
			mruIp.pos = 0;
			hpnsOpenConnectionToPushServer();
		}
	}

	hpnsSaveHpnsInfo();	
	return;
}

void hpnsProcessChangeConnMode(UINT32 connMode)
{
	INT8 connectionMode = 0, pollIndex = 0;

	connectionMode = connMode>>16;
	pollIndex      = connMode&(0xFFFF);

	nprintf("change connection mode to:%d, pollIndex:%d", connectionMode, pollIndex);


	hpnsInfo.connMode = connectionMode;
	if( (connectionMode == HPNS_NCM_POLL) && (pollIndex < (HPNS_MAX_POLL_LIST_INDEX-2)))
		hpnsInfo.heartbeat = pollIndex;

	if(hpnsInfo.numOfBundled)
	{
		numOfRound = 0;
		mruIp.pos = 0;
		hpnsOpenConnectionToPushServer();
	}
	
	hpnsSaveHpnsInfo();	
	return ;
}

void hpnsProcessNetworkStatechanged(UINT32 flag)
{
	int i = 0, changeFlag = 0, apnType = 0;
	SHpnsRegInfo hpnsRegInfo ={0};

	changeFlag = flag >>16;
	apnType    = flag&(0xFFFF);

	nprintf("network state is changed to %d, apn type:%d, numOfbundled:%d, connStatus:%d", changeFlag, apnType, hpnsInfo.numOfBundled, hpnsContext.connStatus);

	if( (changeFlag == HPNS_NETWORK_STATE_ON) && ((hpnsInfo.numOfBundled) || (apnType == HPNS_APN_INTERNAL)))
	{
		if( apnType && (apnType != HPNS_APN_INTERNAL) )
			hpnsContext.apnType = apnType;

       if((apnType != HPNS_APN_INTERNAL))
       {
            nprintf("network changed reset usp status");
             hpnsUdpStatus = HPNS_UDP_STATUS_NTWKCHANGED;	
       }
	
		if( hpnsContext.connStatus == HPNS_STATUS_UNCONNECTED || (pushServerFd == -1
		#ifdef __PNS_TCP_CONNECT_SUPPORT__
		&& hpnsPushTcpFd == -1 
		#endif
		))
		{
			numOfRound = 0;
			mruIp.pos = 0;

//			if(apnType != HPNS_APN_INTERNAL )
//				hpnsUdpStatus = HPNS_UDP_STATUS_NTWKCHANGED;

			hpnsOpenConnectionToPushServer();


			return;
		}

		if(hpnsContext.connStatus == HPNS_STATUS_CONNECTING || hpnsContext.connStatus == HPNS_STATUS_BLOCKING)
			return;

		hpnsSendHeartbeatToServer();
		
		return;
	}
	else if(changeFlag == HPNS_NETWORK_STATE_OFF)
	{
		hpnsKillTimer (HPNS_TIMERID_CONNECTION);
		hpnsCloseConnectionToPushServer();
		nprintf("network is close, if there is bunding app, notifiy");
		for(i=0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
		{
			if( hpnsInfo.appBundled[i].appId != 0 && \
				( hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_OFF || hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_BUNDLING ))
			{
				hpnsRegInfo.appId = hpnsInfo.appBundled[i].appId;	
				hpnsRegInfo.appCode = HPNS_INVALID_DATA_CONNECTION;
				
				hpnsSendMsgToUI(HPNS_MSG_REG_RSP, (UINT8 *)(&hpnsRegInfo), sizeof(SHpnsRegInfo));
				hpnsMemSet(&(hpnsInfo.appBundled[i]), 0x0, sizeof(SHpnsAppProfile) );
			}
		}
	}

	return;
}

int hpnsProcessUploadStaticData(UINT32 flag)
{
	if(flag)
	{
		hpnsInfo.updateFlag = 1;
		hpnsSendStaticDataToServer();	
	}
	else
		hpnsInfo.staticDataFlag = HPNS_STATIC_DATA_NOT_UPLOAD;

	hpnsSaveHpnsInfo();	
	return 0;
}

int hpnsApiQueryAppViaAppId(UINT32 appId, char regId[], UINT32 regIdLen)
{
	int i = 0;

	if( regIdLen < (HPNS_REGID_LEN*2))
		return -2;

	for(i=0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
	{
		if( hpnsInfo.appBundled[i].appId == appId && hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_ON)
		{
			hpnsMemCpy( regId, hpnsInfo.appBundled[i].regId, HPNS_REGID_LEN);
			hpnsByteArrayToHexStr(regId, HPNS_REGID_LEN);
			return 0;
		}
	}

	return -1;
}

int hpnsApiGetConfigInfo(UINT16 *majorVersion, UINT16 *minorVersion, UINT32 *connStatus,char hidstr[])
{
	char hidhex[HPNS_HID_LEN*3] = {0};
	UINT8 hidKey[HPNS_HID_LEN] = {0};
	int i = 0;
	
	*((int*)hidKey) = 5250;
	*((int*)(hidKey+sizeof(int))) = 7568;

	*majorVersion = hpnsInfo.deviceInfo.majorVersion;
	*minorVersion = hpnsInfo.deviceInfo.minorVersion;
	*connStatus   = hpnsContext.connStatus;

	for(i=0; i<HPNS_HID_LEN; i++)
	{
		hidhex[i] = hpnsInfo.hid[i]^hidKey[i];
	}	
	
	hpnsByteArrayToHexStr(hidhex, HPNS_HID_LEN);
	hpnsMemCpy(hidstr, hidhex, HPNS_HID_LEN*2);

	return 0;
}

int hpnsApiChangeNetworkStatusOn(UINT32 apnType)
{
	hpnsSendMsgToEngine(HPNS_MSG_NETWORK_STATE_CHANGED, (UINT8 *)((HPNS_NETWORK_STATE_ON<<16)+apnType), 0);
	return 0;
}

int hpnsApiChangeNetworkStatusOff()
{
	hpnsSendMsgToEngine(HPNS_MSG_NETWORK_STATE_CHANGED, (UINT8 *)(HPNS_NETWORK_STATE_OFF<<16), 0);
	return 0;
}

int hpnsApiGetPushServiceStatus()
{
	return hpnsInfo.PNOnOrOff;
}

int hpnsStaticDataSendBack(UINT8 flag)
{
	hpnsSendMsgToEngine(HPNS_MSG_UPLOAD_STATIC_DATA, (UINT8 *)((UINT32)flag), 0);
	return 0;
}

void hpnsHandleMsg (int msgId, UINT8 *pMsg, int msgLen)
{	
	if ( msgId <0 || msgId >=  HPNS_MSG_MAX)
	{
		nprintf("msg id:%d is out of range", msgId);
		return;
	}

	if ( msgId != HPNS_MSG_DATA_READ_IND  && msgId != HPNS_MSG_DATA_WRITE_IND )
 		nprintf("msg:%s is received by engine", hpnsAppEngineMsg[msgId]);

	
    switch ( msgId )
    {
		case HPNS_MSG_DATA_READ_IND:	
			hpnsProcessReceivedData((UINT32)pMsg);
			break;

		case HPNS_MSG_DATA_WRITE_IND:
			hpnsProcessWriteDataInd((UINT32)pMsg);
			break;

		case HPNS_MSG_NW_ERROR_IND:
			hpnsProcessNetworkError((UINT32)pMsg);
			break;

		case HPNS_MSG_REG_REQ:
			hpnsProcessRegistrationReq((SHpnsRegInfo *)pMsg);
			break;

		case HPNS_MSG_UNREG_REQ:
			hpnsProcessUnRegistrationReq((UINT32)pMsg);
			break;

		case HPNS_MSG_NOTIFICATION_RSP:
			hpnsProcessNotificaitonResp((UINT32)pMsg);
			break;

		case HPNS_MSG_PUSH_NOTIFICATION_SWITCH:
			hpnsProcessPushNotificationSwitch((UINT32)pMsg);
			break;

		case HPNS_MSG_CHANGE_CONNECT_MODE:
			hpnsProcessChangeConnMode((UINT32)pMsg);
			break;

		case HPNS_MSG_NETWORK_STATE_CHANGED:
			hpnsProcessNetworkStatechanged((UINT32)pMsg);
			break;

		case HPNS_MSG_UPLOAD_STATIC_DATA:
			hpnsProcessUploadStaticData((UINT32)pMsg);
			break;

	    default :
	        nprintf("msg not handled, msgId: %d", msgId);
	        break;		
    }
}

void hpnsCleanUpTask()
{
	nprintf ("HPNS task is cleaned up");

	return;
}

