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

#include "hpnsMsg.h"
#include "hpnsPushMsg.h"
#include "hpnsNetwork.h"
#include "hpnsTimer.h"
#include "hpnsStm.h"
#include "hpnsConfig.h"
#include "hpnsAppEngine.h"
#include "hpnsUtil.h"

#define hpnsPollingTime  hpnsPollingTimeList[hpnsInfo.heartbeat]
SHpnsContext  hpnsContext = {0};
SHpnsInfo 	  hpnsInfo;
SHpnsIpAddr   hpnsServer;
INT32         pushServerFd = -1;
#ifdef __PNS_TCP_CONNECT_SUPPORT__
INT32         hpnsPushTcpFd = -1;
#endif
int           numOfRound = 0;
UINT32        hpnsMinHBI = 120;  //2*60
UINT32        hpnsMaxHBI = 2700; //45*60
UINT8         hpnsStep = 60;
UINT32        staticFailedTime = 0;
UINT8         hpnsUdpStatus = 0;

static UINT32 hpnsConnectRetryCnt = 0;
static UINT32 hpnsNewIpFlg = 0;




void hpnsUpdateMruIp (SHpnsIpAddr *pIp)
{
    SHpnsIpAddr tIp;
    int i, j;
	UINT8 ipStr[4];

	if ( pIp == 0 || pIp->ip == 0 || pIp->port == 0 )
	{
		nprintf ("failed to update MRU IP, invalid parameters, pIp:%d", pIp);
		return;
    }

	// does this new RID exist 
	for ( i=0; i<HPNS_RID_NUM; ++i)
	{
		if ( memcmp( (unsigned char *)&(mruIp.ipPort[i]), (unsigned char *)pIp, sizeof(mruIp.ipPort[i]) ) == 0 )
			break;
	}

    if ( i != 0 ) 
    {
        if ( i == HPNS_RID_NUM )
        {
            // new RID is not there, shift all the entries
            for ( j = HPNS_RID_NUM-1; j>0; --j)
                mruIp.ipPort[j] = mruIp.ipPort[j-1];

            mruIp.ipPort[0] = *pIp;
			memcpy(ipStr, &pIp->ip, sizeof(ipStr));
            nprintf ("new ip:%d.%d.%d.%d, port:%d is inserted into MRU", ipStr[0], ipStr[1], ipStr[2], ipStr[3], hpnsHtons(pIp->port) );
        }
        else
        {
            // it is already there, but not the top one, just swap;
            nprintf ("MRU position 0 and position:%d is swapped", i);
            tIp = mruIp.ipPort[0];
            mruIp.ipPort[0] = mruIp.ipPort[i];
            mruIp.ipPort[i] = tIp;
        }
    }

    mruIp.pos = 0;        
	return;
}

int hpnsProcessDnsResult(UINT32 ip)
{
	SHpnsIpAddr     newIp;

	//mruIp.pos = HPNS_RID_NUM -1;
	//mruIp.ipPort[mruIp.pos].ip = ip;
	//mruIp.ipPort[mruIp.pos].port = hpnsHtons(serverPort);

	nprintf ("DNS return an IP:0x%x, try", ip); 
	newIp.ip = ip;
    newIp.port = hpnsHtons(serverPort);
	hpnsUpdateMruIp(&newIp);
	
	hpnsSendMsgToEngine(HPNS_MSG_NETWORK_STATE_CHANGED, (UINT8 *)((HPNS_NETWORK_STATE_ON<<16)+HPNS_APN_INTERNAL), 0);
	return (int)ip;
}


int hpnsSetServerIp(void) 
{
    int i=0, ret = 0;
	//static char neverTryDns = 1;

	hpnsServer.ip = 0;
	hpnsServer.port = hpnsHtons(serverPort);

	if((memcmp( hpnsInfo.hid, defaultHid, HPNS_HID_LEN) == 0) && (hpnsInfo.numOfBundled == 0) && hpnsTryDns)
	{
		i = HPNS_RID_NUM;
		goto _Retrydns;
	}

    for ( i = mruIp.pos; i< HPNS_RID_NUM; ++i) 
	{
		if ( mruIp.ipPort[i].ip != 0 && mruIp.ipPort[i].port != 0)
		{
			hpnsServer = mruIp.ipPort[i];
			break;
		}
	}

	// if all IPs are tried, pick up IP from DNS, but only one time
_Retrydns:

	if ( (i == HPNS_RID_NUM)&& hpnsTryDns)
	{
		ret = hpnsGetServerIpViaDNS("hpns.com", &(hpnsServer.ip));	
		
		if ( ret == 0 )
		{
			nprintf("it is asynchronous DNS");	
			ret = -1;
		}
		else if(ret < 0)
		{
			nprintf("failed to process DNS,errorcode:%d",ret);
			ret = 0;
		}
		else
		{
			nprintf("server ip from DNS is:0x%x", hpnsServer.ip);	
			ret = 1;
		}
		hpnsTryDns = 0;
			
		return ret;  
	}

	// all IP and DNS are tried, start over
	if(hpnsNewIpFlg == 0) //PN-128
		mruIp.pos = i+1;
	
	if ( mruIp.pos > HPNS_RID_NUM )
	{
		mruIp.pos = 0;
		hpnsTryDns = 1;
	}
	
	hpnsServer.port = hpnsHtons(serverPort + ((hpnsGetSystemTime()%3600)/3.6));//[2502-3501]
	
	return hpnsServer.ip;

}

void hpnsResetHeartBeatTimer(void)
{
    hpnsKillTimer( HPNS_TIMERID_HEART_BEAT );
    hpnsSetTimer ( HPNS_TIMERID_HEART_BEAT, hpnsContext.heartBeatPeriod );
	return;
}

int hpnsInitConnection(void)
{
    memset(&hpnsContext, 0, sizeof(hpnsContext));
 
    hpnsContext.localIp = 0;
    hpnsContext.localSessionId = hpnsGetSystemTime();
    hpnsContext.heartBeatPeriod  = 1750;
    hpnsContext.msgTranId = hpnsGetSystemTime();
	mruIp.pos = 0;

	hpnsContext.hpnsTtl = hpnsGetTtl();
	hpnsContext.securityFlag = HPNS_SECURITY_FLAG_ON;
	pushServerFd = -1;
	hpnsUdpStatus = HPNS_UDP_STATUS_DEFAULT;
	
    return 0;
}

void hpnsHandleConnectionError(UINT8 flag)
{
	int seconds = 0, i = 0;
	SHpnsRegInfo hpnsRegInfo = {0};

	mruIp.pos = 0;
	
	if(hpnsContext.tcpFlag == 1 && hpnsContext.ApIndex >= 0 && flag != HPNS_CONNECTION_ERROR_TCP_OPEN)
	{
		
		if(hpnsContext.ApIndex >= HPNS_MAX_AP_NUM)
		{
			nprintf("failed to get apInfo because index is wrong,%d", hpnsContext.ApIndex);
		}
		else
		{
			hpnsInfo.APInfo[hpnsContext.ApIndex].lastFailedHBI = hpnsInfo.APInfo[hpnsContext.ApIndex].HBI;
			hpnsInfo.APInfo[hpnsContext.ApIndex].failedTimestamp  = hpnsGetSystemTime();
			
			if( hpnsInfo.APInfo[hpnsContext.ApIndex].HBI - hpnsStep > hpnsMinHBI)
				hpnsInfo.APInfo[hpnsContext.ApIndex].HBI -= hpnsStep ;
			else
				hpnsInfo.APInfo[hpnsContext.ApIndex].HBI = hpnsMinHBI;
			
			hpnsSaveHpnsInfo();
		}
	}

	hpnsCloseConnectionToPushServer();

	for(i=0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
	{
		if( hpnsInfo.appBundled[i].appId != 0 && \
			( hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_OFF || hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_BUNDLING ))
		{
			hpnsRegInfo.appId = hpnsInfo.appBundled[i].appId;
			if(flag == HPNS_CONNECTION_ERROR_NETWORK ||  flag == HPNS_CONNECTION_ERROR_TCP_OPEN)
				hpnsRegInfo.appCode = HPNS_INVALID_DATA_CONNECTION;
			else if(flag == HPNS_CONNECTION_ERROR_SERVICE)
				hpnsRegInfo.appCode = HPNS_SERVICE_NOT_AVAILABLE;
			
			hpnsSendMsgToUI(HPNS_MSG_REG_RSP, (UINT8 *)(&hpnsRegInfo), sizeof(SHpnsRegInfo));
			hpnsMemSet(&(hpnsInfo.appBundled[i]), 0x0, sizeof(SHpnsAppProfile) );
		}
	}

	if(hpnsInfo.numOfBundled == 0 || hpnsInfo.PNOnOrOff == HPNS_PUSH_NOTIFICATION_OFF)
	{
		nprintf("there is no app(%d) in list or PN switch(%d) is off, do not need to retry again", hpnsInfo.numOfBundled, hpnsInfo.PNOnOrOff);
		return;
	}
		
	seconds = (1 << numOfRound) * RECONNECT_TIMER_STEP;
	if ( seconds > RECONNECT_MAX_TIMER ) 
		seconds = RECONNECT_MAX_TIMER;	
	
	numOfRound ++;
	if( numOfRound > 30)
		numOfRound = 30;
	
	hpnsSetTimer(HPNS_TIMERID_CONNECTION, seconds);	
	nprintf ("engine will sleep for %d seconds, then try again", seconds);
	
	return;
}

void hpnsProcessConnectionTimer(int param)
{
	nprintf("connet to server again, numOfRound:%d, PNswitch:%d", numOfRound, hpnsInfo.PNOnOrOff);
	if(hpnsInfo.PNOnOrOff == HPNS_PUSH_NOTIFICATION_ON)
		hpnsOpenConnectionToPushServer();

	return;
}

void hpnsCloseConnectionToPushServer(void)
{	
	hpnsKillTimer (HPNS_TIMERID_HEART_BEAT);
	hpnsKillTimer (HPNS_TIMERID_CONNECTION);
	hpnsKillTimer (HPNS_TIMERID_HEART_BEAT_RESP);

	if ( pushServerFd == -1
	#ifdef __PNS_TCP_CONNECT_SUPPORT__
	&& hpnsPushTcpFd == -1 
	#endif 
	)
		return;
	
    hpnsContext.remoteSessionId = 0;
    hpnsContext.outType = 0;
    hpnsContext.inType = 0;
	hpnsContext.inTranId = 0;
    hpnsContext.connStatus = HPNS_STATUS_UNCONNECTED;
    hpnsContext.numOfRetry = 0;
	hpnsContext.heartbeatRetry = 0;

    if (hpnsContext.rspMsg)
    {
        hpnsFreeL((void*)hpnsContext.rspMsg);
        hpnsContext.rspMsg = 0;
		hpnsContext.rspMsgLen = 0;
    }

    hpnsCancelTransactionToPushServer();
	
	if(pushServerFd != -1)
		hpnsCloseUdpSocket( pushServerFd );
	#ifdef __PNS_TCP_CONNECT_SUPPORT__
	if(hpnsPushTcpFd != -1 )
		hpnsCloseTcpSocket( hpnsPushTcpFd);
	#endif
	pushServerFd = -1;
	#ifdef __PNS_TCP_CONNECT_SUPPORT__
	hpnsPushTcpFd = -1;
	hpnsContext.tcpFlag = 0;
	#endif
	hpnsContext.ApIndex = -1;

	hpnsSaveHpnsInfo();
	nprintf ("connection to server is closed");
	
	return;
}

void hpnsStartRegistration(void)
{
	UINT8  *pData;
    int    msgLen;
	
	nprintf ("set up connection to server ...");

	if(hpnsInfo.numOfBundled == 0)
		msgLen = hpnsBuildRegReqMsg(&pData, &hpnsContext);
	else
		msgLen = hpnsBuildLoginReqMsg(&pData, &hpnsContext);
	
	hpnsSendMsgToPushServer(pData, msgLen);
	hpnsContext.connStatus = HPNS_STATUS_CONNECTING;
}

void hpnsOpenConnectionToPushServer(void)
{
	int    ret;
	UINT8  ipStr[4];
	char   asyncFlag = 0,connTypeFlg = 0;

	hpnsKillTimer(HPNS_TIMERID_CONNECTION);

	if( hpnsInfo.PNOnOrOff == HPNS_PUSH_NOTIFICATION_OFF)
	{
		nprintf("PN switch is off, can't open connection");
		return;
	}
	
	if ( pushServerFd != -1
	#ifdef __PNS_TCP_CONNECT_SUPPORT__
	|| hpnsPushTcpFd != -1 
	#endif
	 )
		hpnsCloseConnectionToPushServer();

	ret = hpnsSetServerIp();
	if ( ret == -1 )
	{
		nprintf ("try to get server IP from DNS ...");		
		hpnsSetTimer(HPNS_TIMERID_CONNECTION, 20);  // protect engine, in case DNS does not return 	
		return;
	}

	if ( ret == 0 )
	{
		if(hpnsConnectRetryCnt < HPNS_RID_NUM*2)
		{
			hpnsSetTimer(HPNS_TIMERID_CONNECTION, 5);  // protect engine, in case DNS does not return	
			return; 
		}
		else
		{
			hpnsConnectRetryCnt = 0;
			nprintf ("all possible IPs are tried!");
			hpnsHandleConnectionError(HPNS_CONNECTION_ERROR_SERVICE);
			return;
		}
	}
	else
	{
		if(hpnsConnectRetryCnt >=HPNS_RID_NUM*2)
		{
			hpnsConnectRetryCnt = 0;
			nprintf ("all possible IPs are tried!");
			hpnsHandleConnectionError(HPNS_CONNECTION_ERROR_SERVICE);
			return;		
		}
	}

	memcpy(ipStr, &hpnsServer.ip, sizeof(ipStr));
	nprintf("server ip:%d.%d.%d.%d, port:%d is picked up", ipStr[0], ipStr[1], ipStr[2], ipStr[3], hpnsHtons(hpnsServer.port) );
	
	if(hpnsNewIpFlg) //PN-128
	{
		if(hpnsConnectRetryCnt>=2) //redirect ip had tried UPD/TCP method.
		{
			hpnsConnectRetryCnt = 0;
			hpnsHandleConnectionError(HPNS_CONNECTION_ERROR_SERVICE);
			return;
		}
		
		connTypeFlg = hpnsConnectRetryCnt%2;
	}
	else
		connTypeFlg =(hpnsConnectRetryCnt/HPNS_RID_NUM)%2;

	nprintf("server ip:%d.%d.%d.%d, port:%d is picked up connType:%d ,RetryCnt:%d", ipStr[0], ipStr[1], ipStr[2], ipStr[3], hpnsHtons(hpnsServer.port),connTypeFlg,hpnsConnectRetryCnt);
	hpnsConnectRetryCnt++;

#ifdef __PNS_TCP_CONNECT_SUPPORT__
    if(connTypeFlg)
    {
        hpnsContext.tcpFlag = 1;
        hpnsOpenTcpConnectionToPushServer();
        return ;
    }
#endif

	pushServerFd = hpnsOpenUdpSocket(&asyncFlag);
	if(pushServerFd == -1)
	{

		hpnsHandleConnectionError(HPNS_CONNECTION_ERROR_NETWORK);
		return;
	}

	if ( asyncFlag )
	{
		nprintf("it is block mode,send empty paket");
		ret = hpnsSendUdpData(pushServerFd, hpnsServer.ip, hpnsServer.port, (UINT8 *)"testing", 7 );
		if(ret == 0)
		{
			hpnsContext.connStatus = HPNS_STATUS_BLOCKING;	
			return;
		}
	}

	hpnsStartRegistration();
	return;		
}

#ifdef __PNS_TCP_CONNECT_SUPPORT__

int hpnsOpenTcpConnectionToPushServer()
{
	int ret = 0;
	unsigned char *ipStr = (unsigned char*)(&(hpnsServer.ip));
	char apName[HPNS_AP_NAME_LEN + 1] = {0};

	ret = hpnsGetAPName((INT8 *)apName);
	if(ret >= 0)
	{
		memset(hpnsContext.APName, 0x0, sizeof(hpnsContext.APName));
		memcpy(hpnsContext.APName, apName, strlen(apName) > HPNS_AP_NAME_LEN ?HPNS_AP_NAME_LEN:strlen(apName) );
	}
	else
		sprintf((char *)(hpnsContext.APName), "defaultHpns");
	
	hpnsPushTcpFd = hpnsOpenTcpSocket();
	if ( hpnsPushTcpFd < 0 )
	{
		nprintf("failed to open TCP session");
		hpnsHandleConnectionError(HPNS_CONNECTION_ERROR_TCP_OPEN);
		return -1;
	}
	
	ret = hpnsConnectTcpSocket(hpnsPushTcpFd , hpnsServer.ip , hpnsHtons(serverTcpPort));
	if ( ret < 0 )
	{
		nprintf("failed to open connect server, ip:%d.%d.%d.%d	port:%d", ipStr[0], ipStr[1], ipStr[2], ipStr[3], serverTcpPort);
		hpnsHandleConnectionError(HPNS_CONNECTION_ERROR_TCP_OPEN);
		return -1;
	}
	
	if( ret == 0 )
	{
	    hpnsContext.connStatus = HPNS_STATUS_BLOCKING;
		return 0;
	}
	
	nprintf("TCP is created, ip:%d.%d.%d.%d, port:%d, FD: %d", ipStr[0], ipStr[1], ipStr[2], ipStr[3], serverTcpPort, hpnsPushTcpFd);

	hpnsStartRegistration();
		
	return 0;

}
#endif

void hpnsProcessNewPushServer(UINT32 ip, UINT32 port)
{
    SHpnsIpAddr     newIp;
	unsigned char  *pIp;

    newIp.ip = ip;
    newIp.port = (short) port;

	pIp = (unsigned char *) &ip;
    nprintf ("mobile will be redirected to new server, ip:%d.%d.%d.%d port:%d", pIp[0], pIp[1], pIp[2], pIp[3], hpnsHtons(port) );

    hpnsUpdateMruIp(&newIp);
    hpnsNewIpFlg = 1;
    hpnsOpenConnectionToPushServer();

	return;
}

int hpnsCompareAndMergeAppList(SHpnsReplyContext *pReply)
{
	int i = 0, numOfRegApp = 0, numOfMatch = 0;
	UINT32 j = 0;

	for(i=0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
	{
		if( hpnsInfo.appBundled[i].appId == 0)
			continue;
		
		for(j=0; j < pReply->numOfApp; j++)
		{
			if( pReply->appList[j].appId == 0 || hpnsInfo.appBundled[i].appId != pReply->appList[j].appId )
				continue;

			if( pReply->appList[j].appCode != 0)
			{
				hpnsSendMsgToUI(HPNS_MSG_REG_RSP, (UINT8 *)&(pReply->appList[j]), sizeof(SHpnsRegInfo));
				hpnsMemSet(&hpnsInfo.appBundled[i], 0x0, sizeof(SHpnsAppProfile ));
				continue;
			}
			else if( memcmp(pReply->appList[j].regId, defaultHid, HPNS_HID_LEN) != 0 && memcmp(hpnsInfo.appBundled[i].regId, defaultHid, HPNS_HID_LEN) == 0 )
			{
				hpnsInfo.appBundled[i].status = HPNS_APP_STATUS_ON;
				memcpy((void *)hpnsInfo.appBundled[i].regId, (void *)pReply->appList[j].regId, HPNS_REGID_LEN);
				hpnsByteArrayToHexStr((char *)(pReply->appList[j].regId), HPNS_REGID_LEN);
				hpnsSendMsgToUI(HPNS_MSG_REG_RSP, (UINT8 *)(&(pReply->appList[j])), sizeof(SHpnsRegInfo));
			}
			else if( memcmp(pReply->appList[j].regId, defaultHid, HPNS_HID_LEN) != 0 && memcmp( (void *)hpnsInfo.appBundled[i].regId, (void *)pReply->appList[j].regId, HPNS_REGID_LEN) != 0)
			{
				hpnsInfo.appBundled[i].status = HPNS_APP_STATUS_ON;
				memcpy((void *)hpnsInfo.appBundled[i].regId, (void *)pReply->appList[j].regId, HPNS_REGID_LEN);
				hpnsByteArrayToHexStr((char *)(pReply->appList[j].regId), HPNS_REGID_LEN);
				hpnsSendMsgToUI(HPNS_MSG_REGID_CHANGED_NOTIFICATION, (UINT8 *)(&(pReply->appList[j])), sizeof(SHpnsRegInfo));
			}	
			
			numOfMatch ++;
		}
		
		numOfRegApp ++;
	}

	if((numOfRegApp == numOfMatch) && (numOfMatch == pReply->numOfApp) )
		return numOfRegApp;

	nprintf("failed to compare app list,numOfRegApp:%d,numOfReplyApp:%d ,numOfMatch:%d", numOfRegApp, pReply->numOfApp, numOfMatch);
	return -1;
}

int hpnsProcessRespMsgFromPushServer(UINT8 type, SHpnsReplyContext *pReply )
{
	int    	i = 0, ret=0, msgLen =0, secretFlag = 0;
	UINT8	*pData = 0, idcId = 0, shardId =0;
	SHpnsRegInfo hpnsRegInfo = {0};
	UINT16  mobileId = 0;
	UINT32  appIdOfHid = 0;
	UINT8   tmpKey[HPNS_KEY_LEN+1] = {0};
		
    if ( pReply->code != 0 && pReply->code != HPNS_CODE_WRONG_SERVER_IP && pReply->code != HPNS_CODE_STATIC_DB_FAILURE)
    {
        nprintf ("failed to register to server, code: %d", pReply->code );	

		for(i=0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
		{
			if( hpnsInfo.appBundled[i].appId != 0 && hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_BUNDLING )		
			{
				hpnsRegInfo.appId = hpnsInfo.appBundled[i].appId;
				hpnsRegInfo.appCode = HPNS_SYSTEM_ERROR;
				hpnsSendMsgToUI(HPNS_MSG_REG_RSP, (UINT8 *)&hpnsRegInfo, sizeof(SHpnsRegInfo));
				hpnsMemSet(&(hpnsInfo.appBundled[i]), 0x0, sizeof(SHpnsAppProfile) );
			}
		}
			
        return pReply->code;
    }
	
    if ( pReply->pushIp.ip != 0 )
    {
        hpnsProcessNewPushServer(pReply->pushIp.ip, pReply->pushIp.port);
		return 0;
    }
#ifdef __PNS_TCP_CONNECT_SUPPORT__
    hpnsConnectRetryCnt = 0;
	if ( pReply->tcpFlag != 0)
	{
		nprintf("tcp connect should be used next time, tcpFlag:%d", pReply->tcpFlag);
		hpnsContext.tcpFlag = pReply->tcpFlag;
	    hpnsUdpStatus = HPNS_UDP_STATUS_DEFAULT;
    	hpnsOpenTcpConnectionToPushServer();
		return 0;
	}
#endif
	if(type == HPNS_MSG_TYPE_LOGIN_RSP)
		hpnsInfo.updateFlag =0;
	else if( type == HPNS_MSG_TYPE_STATICDATA_RSP && pReply->code != HPNS_CODE_STATIC_DB_FAILURE)
		hpnsInfo.staticDataFlag = HPNS_STATIC_DATA_UPLOAD_PN;

	numOfRound = 0; 
	hpnsUpdateMruIp (&hpnsServer);

	if( memcmp(hpnsInfo.hid, defaultHid, HPNS_HID_LEN) == 0)
		memcpy(hpnsInfo.hid, pReply->hid, HPNS_HID_LEN);

    if ( pReply->sessionId != 0 )
        hpnsContext.remoteSessionId = pReply->sessionId;

	if( (pReply->connMode != 0) && (pReply->connMode != hpnsInfo.connMode) )
	{
		nprintf("conn mode is changed by server,connMode:%d",  pReply->connMode);
		hpnsInfo.connMode = pReply->connMode ;

		if( hpnsInfo.connMode == HPNS_NCM_POLL )
		{
			hpnsPollingTimeList[HPNS_MAX_POLL_LIST_INDEX-1] = (pReply->heartBeatPeriod)/60;
			hpnsInfo.heartbeat = HPNS_MAX_POLL_LIST_INDEX-1;
		}
	}

	if ( hpnsInfo.connMode == HPNS_NCM_AUTO )	
	{
		if(1 == hpnsContext.tcpFlag)
		{
			hpnsContext.ApIndex = hpnsGetAPInfo(hpnsContext.APName);
			hpnsContext.heartBeatPeriod = hpnsInfo.APInfo[hpnsContext.ApIndex].HBI;
		}
		else	
		{
			if(pReply->code != HPNS_CODE_STATIC_DB_FAILURE)
				hpnsContext.heartBeatPeriod = pReply->heartBeatPeriod ;
		}
	}
	else
		hpnsContext.heartBeatPeriod = 60; 
	
    if ( pReply->secret != 0 &&  pReply->secret[0] != 0)
    {
		memcpy (tmpKey, hpnsInfo.secret, sizeof(hpnsInfo.secret));
		memcpy (hpnsInfo.secret, pReply->secret, sizeof (hpnsInfo.secret));
		ret = hpnsSaveHpnsInfo();
		if(ret < 0 )
		{
			memcpy (hpnsInfo.secret, tmpKey, sizeof (hpnsInfo.secret));
		}
		else
		{
			hpnsMemSet(tmpKey, 0x0, HPNS_KEY_LEN+1);
			secretFlag = 1;
		}
    }

    if ( pReply->securityFlag != HPNS_SECURITY_FLAG_ON)
        hpnsContext.securityFlag = pReply->securityFlag;

	memcpy((UINT8 *)(&idcId),      hpnsInfo.hid,   sizeof(UINT8));
	memcpy((UINT8 *)(&shardId),    hpnsInfo.hid + sizeof(UINT8), sizeof(UINT8));
	memcpy((UINT8 *)(&mobileId),   hpnsInfo.hid + sizeof(UINT8) + sizeof(UINT8), sizeof(UINT16));
	memcpy((UINT8 *)(&appIdOfHid), hpnsInfo.hid + sizeof(UINT8) + sizeof(UINT8) + sizeof(UINT16), sizeof(UINT32));
	nprintf ("msg:%s is ok,hid:%03d-%03d-%05d-%010d, server HBTimer:%d, local HBTimer:%d", hpnsMsgName[type], idcId, shardId, mobileId, appIdOfHid, pReply->heartBeatPeriod, hpnsContext.heartBeatPeriod );

	if ( hpnsContext.connStatus != HPNS_STATUS_CONNECTED )           
	{
		hpnsContext.connStatus = HPNS_STATUS_CONNECTED;
		hpnsResetHeartBeatTimer();
	}

	if(  type != HPNS_MSG_TYPE_STATICDATA_RSP)
	{
		ret = hpnsCompareAndMergeAppList(pReply);
		hpnsInfo.numOfBundled = ret;
		hpnsSaveHpnsInfo();
		if( ret < 0)
		{
			msgLen = hpnsBuildRegReqMsg(&pData, &hpnsContext);
			hpnsSendMsgToPushServer(pData, msgLen);
			hpnsSaveHpnsInfo();
			return 0;
		}
		else if(ret == 0 && hpnsInfo.staticDataFlag != HPNS_STATIC_DATA_UPLOAD_STATIC)
		{
			nprintf("there is no bundled app in app list,close connection to push");
			hpnsCloseConnectionToPushServer();
			return 0;
		}
			
		if( secretFlag)
		{
			nprintf("secret is changed, reset the connection");
			hpnsOpenConnectionToPushServer();
			return 0;
		}

		if( hpnsInfo.staticDataFlag == HPNS_STATIC_DATA_UPLOAD_STATIC)
		{
			hpnsSendStaticDataToServer();
			return 0;
		}
		
	}
	else
	{
		hpnsSaveHpnsInfo();
		if(hpnsInfo.numOfBundled == 0)
		{
			hpnsCloseConnectionToPushServer();
			return 0;
		}
	}
	
    return 0;
}

int hpnsProcessDeliverMsgFromPushServer(UINT8 *pMsg, int msgLen)
{
    SHpnsMsgHeader     *pHeader;
	SHpnsDeliverHeader *pDeliverHearder;
	SHpnsRegInfo       *pHpnsRegInfo;
    UINT8              code = 0, i = 0, messageFlag = 0; 
    int                dataLen = 0, regLen = 0;
	UINT8              *pNext = 0, *pEnd = 0, *pData = 0, *pRegData = 0;
	UINT32             appId = 0, msgId = 0, internalMsgId = 0;

    pHeader = (SHpnsMsgHeader *)pMsg;
	pDeliverHearder = (SHpnsDeliverHeader *)pHeader->content;
	
	pNext  = (unsigned char *)pDeliverHearder->content;
	pEnd   = pMsg + msgLen;
	msgLen = (msgLen - sizeof(SHpnsMsgHeader) - sizeof(SHpnsDeliverHeader) + 2);
	pNext += msgLen;
	if ( pNext > pEnd )
    {
		nprintf("failed to parse msg size from server,msg len:%d, content len:%d", msgLen, msgLen - sizeof(SHpnsMsgHeader) + 1 );
		code = HPNS_CODE_WRONG_MSG_SIZE;
	}
	
	appId         = hpnsNtohl(pDeliverHearder->appId);
	msgId         = hpnsNtohl(pDeliverHearder->msgId);
	internalMsgId = hpnsNtohl(pDeliverHearder->internalMsgId);
	messageFlag   = pDeliverHearder->reserved;
	pNext   = (unsigned char *)pDeliverHearder->content;

	dataLen = hpnsBuildReplyMsg( &pData, code, messageFlag, appId, msgId, internalMsgId, &hpnsContext);
	hpnsSendMsgToPushServer (pData, dataLen);

	for(i=0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
	{
		if( hpnsInfo.appBundled[i].appId == appId && (hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_ON))
			break;
	}

	if( i >= HPNS_MAX_BUNDLE_APP_NUM )
	{
		nprintf("application does not exist in app list, appId:%d", appId);
		regLen = hpnsBuildRegReqMsg(&pRegData, &hpnsContext);
		hpnsSendMsgToPushServer(pRegData, regLen);
	}
	else
	{	
		if(hpnsInfo.appBundled[i].recvId == internalMsgId)
		{
			nprintf("notification message is duplicated, drop it,msgId:%d", internalMsgId);
			return 0;
		}
		
		hpnsInfo.appBundled[i].recvId = internalMsgId;

		pHpnsRegInfo = (SHpnsRegInfo *)hpnsMallocL(msgLen+sizeof(SHpnsRegInfo)-1);
		pHpnsRegInfo->appId = appId;
		memcpy(pHpnsRegInfo->payload,	pNext, msgLen);
		hpnsSendMsgToUI(HPNS_MSG_NOTIFICATION, (UINT8 *)pHpnsRegInfo, msgLen + sizeof(SHpnsRegInfo) - 1);
		hpnsInfo.appBundled[i].numOfNoRsp ++;

		hpnsFreeL(pHpnsRegInfo);
	}
	
	return 0;
}

int hpnsProcessDetectMsgFromPushServer(UINT8 type, SHpnsReplyContext *pReply)
{
	int    ret = 0, dataLen = 0;
	UINT8  code, *pData;

	if ( pReply->code != 0)
	{
		nprintf("the detect msg code is %d", pReply->code);
	}

	if ( hpnsInfo.connMode == HPNS_NCM_AUTO )	
	{
		if(1 != hpnsContext.tcpFlag)
		{
			hpnsContext.heartBeatPeriod = pReply->heartBeatPeriod ;
		}
		else
			nprintf("the connection is TCP, but receive detect msg");
	}
	else
	{
		nprintf("the connection mode is not real-time mode,%d, but receive detect msg",hpnsInfo.connMode );
	}

	if ( hpnsContext.connStatus == HPNS_STATUS_CONNECTED )           
	{
		hpnsContext.connStatus = HPNS_STATUS_CONNECTED;
		hpnsResetHeartBeatTimer();
	}

	hpnsUdpStatus = HPNS_UDP_STATUS_NORMAL;

	dataLen = hpnsBuildDetectResp(&pData, &hpnsContext);
	hpnsSendMsgToPushServer(pData, dataLen);

   return 0;
}

void hpnsProcessMsgFromPushServer(UINT8 *pMsg, int msgLen, UINT32 ip, UINT16 port) 
{
    SHpnsMsgHeader         *pHeader;
    UINT8                  code, *pData;
    int                    dataLen;
	UINT32                 remoteSessId, reserved;
    SHpnsReplyContext      requstReply;

    pHeader = (SHpnsMsgHeader *)pMsg;

    if ( msgLen == HPNS_HB_PACKET_LEN )
    {
		if ( ip == hpnsServer.ip && port == hpnsServer.port )
            hpnsSendDataToPushServer((UINT8 *)&hpnsContext.remoteSessionId, sizeof(hpnsContext.remoteSessionId));
        else
            nprintf ("4 bytes are received NOT from server!!!,port:%d,server port:%d,",port, hpnsServer.port );
		
        return;
    }

    if ( msgLen == HPNS_UPDATE_PACKET_LEN )
    {
		hpnsMemCpy(&remoteSessId, pMsg, sizeof(UINT32));
		hpnsMemCpy(&reserved, pMsg+sizeof(UINT32), sizeof(UINT32));
		if (hpnsContext.remoteSessionId == remoteSessId && ( 0 == reserved ) )
        {
            nprintf ("reset signal from server is received");
			hpnsOpenConnectionToPushServer();
        } 
        else if ( hpnsServer.ip == ip  && hpnsServer.port == port )
        {
            hpnsProcessHeartbeatReceived();    
        }
        else
        {
            nprintf ("invalid 8 bytes long msg is received, discarded");
        }

        return;
    }

    code = hpnsPreProcessIncomingMsg(pMsg, msgLen);
	
    if ( code == 1 )   // re-transimission
        return;
	else if(code == HPNS_CODE_INVALID_HID)
	{
		nprintf("invalid hid, send new reg to ps");
		hpnsMemSet(hpnsInfo.hid, 0x0, HPNS_HID_LEN);
		hpnsContext.connStatus = HPNS_STATUS_UNCONNECTED;
		memcpy(hpnsInfo.secret, hpnsInfo.deviceInfo.imsi[0], sizeof(hpnsInfo.secret)); 
		dataLen = hpnsBuildRegReqMsg(&pData, &hpnsContext);
		hpnsSendMsgToPushServer(pData, dataLen);
		hpnsSaveHpnsInfo();
		return;
	}
	else if(code == HPNS_CODE_DB_FAILURE || code == HPNS_CODE_SERVER_UNAVAILABLE)
	{
		nprintf("invalid server, retry to connect again");
		hpnsHandleConnectionError(HPNS_CONNECTION_ERROR_SERVICE);
		return;
	}
	else if( code == HPNS_CODE_WRONG_SERVER_IP)
	{
		nprintf("the mobile need redirect to home cluster");
		code = 0;
	}
	else if( code == HPNS_CODE_STATIC_DB_FAILURE)
	{
		nprintf("static DB error is received from server, upload the data later");
		staticFailedTime = hpnsGetSystemTime();
		code = 0;
	}
	
    if ( code == 0 ) 
    {  
        nprintf ("msg:%s is received from push server", hpnsMsgName[pHeader->type]);

		if ( hpnsContext.connStatus == HPNS_STATUS_CONNECTED )
			 hpnsResetHeartBeatTimer();   // any packet from server will reset the registration timer
		
        switch ( pHeader->type )
        {
        case HPNS_MSG_TYPE_LOGIN_RSP:
		case HPNS_MSG_TYPE_REG_RSP:
		case HPNS_MSG_TYPE_STATICDATA_RSP:
            code = hpnsParseRespMsgFromServer(pMsg, &requstReply); 
			if(code == 0)
            	hpnsProcessRespMsgFromPushServer(pHeader->type, &requstReply);
            break;

		case HPNS_MSG_TYPE_DETECT:
            code = hpnsParseRespMsgFromServer(pMsg, &requstReply); 
			if(code == 0)
            	hpnsProcessDetectMsgFromPushServer(pHeader->type, &requstReply);
			break;
			
        case HPNS_MSG_TYPE_DELIVER:
            code = hpnsProcessDeliverMsgFromPushServer(pMsg, msgLen);
            break;

        default:
            nprintf ("msg type:%d from server is not handled, type:%d", pHeader->type);
            code = HPNS_CODE_INVALID_MSG_TYPE;
            break;

        } // switch (type)

    } // code == 0

    if ( code != 0 ) 
    {
        nprintf ("error in received message from server, msg type:%d, code:%d", pHeader->type, code);
		
        if ( (pHeader->type & 1) && (pHeader->type < HPNS_MSG_TYPE_INVALID) )
        {
        	hpnsContext.inType = pHeader->type;
			hpnsContext.inTranId = pHeader->tranId;
            dataLen = hpnsBuildReplyMsg( &pData, code, 0, 0, 0, 0, &hpnsContext);
            hpnsSendMsgToPushServer (pData, dataLen);
        }
    }

    return;
}

int hpnsProcessStatisticsInfo(void)
{
	int ret = 0, i = 0;
	SHpnsAppStatistics hpnsAppStatistics;
	
	for(i=0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
	{
		if(hpnsInfo.appBundled[i].appId != 0 && hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_ON)
		{

			hpnsMemSet(&hpnsAppStatistics, 0x0, sizeof(SHpnsAppStatistics));
			hpnsAppStatistics.appId = hpnsInfo.appBundled[i].appId ;
			ret = hpnsGetAppStatisticsInfo(&hpnsAppStatistics);
			if(ret < 0)
			{
				hpnsInfo.appBundled[i].updateFlag = 0;
				continue;
			}

			if(hpnsAppStatistics.numOfCTViaNCWithKey == 0 && hpnsAppStatistics.numOfCTViaNCNoKey == 0\
				&& hpnsAppStatistics.numOfCTViaBannerNoKey == 0 && hpnsAppStatistics.numOfCTViaBannerWithKey == 0\
				&& hpnsAppStatistics.numOfCTViaMenuWithBadge == 0 && hpnsAppStatistics.numOfCTViaBadgeNoKey == 0\
				&& hpnsAppStatistics.numOfCTViaPopNoKey ==0 && hpnsAppStatistics.numOfCTViaPopWithKey == 0\
				&& hpnsAppStatistics.numOfCTViaOthers == 0)
			{
				hpnsInfo.appBundled[i].updateFlag = 0;
			}
			else
			{
				hpnsInfo.appBundled[i].updateFlag = 1;
				hpnsInfo.appBundled[i].numOfCTViaBannerNoKey  += hpnsAppStatistics.numOfCTViaBannerNoKey;
				hpnsInfo.appBundled[i].numOfCTViaBannerWithKey+= hpnsAppStatistics.numOfCTViaBannerWithKey;
				hpnsInfo.appBundled[i].numOfCTViaMenuWithBadge+= hpnsAppStatistics.numOfCTViaMenuWithBadge;
				hpnsInfo.appBundled[i].numOfCTViaNCNoKey      += hpnsAppStatistics.numOfCTViaNCNoKey;
				hpnsInfo.appBundled[i].numOfCTViaNCWithKey    += hpnsAppStatistics.numOfCTViaNCWithKey;
				hpnsInfo.appBundled[i].numOfCTViaOthers       += hpnsAppStatistics.numOfCTViaOthers;
				hpnsInfo.appBundled[i].numOfCTViaPopNoKey     += hpnsAppStatistics.numOfCTViaPopNoKey;
				hpnsInfo.appBundled[i].numOfCTViaPopWithKey   += hpnsAppStatistics.numOfCTViaPopWithKey;
				hpnsInfo.appBundled[i].numOfCTViaBadgeNoKey   += hpnsAppStatistics.numOfCTViaBadgeNoKey;
			}
		}
	}

	hpnsSaveHpnsInfo();
	return 0;
}

int hpnsSendHeartbeatToServer(void)
{
    UINT32 tmp[2];
	
    tmp[0] = hpnsContext.localSessionId; 
    tmp[1] = hpnsContext.remoteSessionId;
	
    hpnsSendDataToPushServer((UINT8*)tmp, sizeof(tmp));

	hpnsKillTimer(HPNS_TIMERID_HEART_BEAT_RESP);
    hpnsSetTimer(HPNS_TIMERID_HEART_BEAT_RESP, HPNS_TRAN_WAIT_TIME);
    hpnsContext.heartbeatRetry ++;
	
    return 0;
}

int hpnsProcessHeartbeatReceived(void)
{
    hpnsKillTimer(HPNS_TIMERID_HEART_BEAT_RESP);
    hpnsContext.heartbeatRetry = 0;

	if(hpnsContext.tcpFlag == 1 && hpnsContext.ApIndex >= 0) 
	{
		if( hpnsGetSystemTime()- hpnsInfo.APInfo[hpnsContext.ApIndex].failedTimestamp > HPNS_MAX_CLEAN_FAILED_HBI_SEC)
		{
			hpnsInfo.APInfo[hpnsContext.ApIndex].failedTimestamp = 0;
			hpnsInfo.APInfo[hpnsContext.ApIndex].lastFailedHBI = 0;
		}

		if(hpnsInfo.APInfo[hpnsContext.ApIndex].lastFailedHBI == 0)
		{
			if(hpnsInfo.APInfo[hpnsContext.ApIndex].HBI + hpnsStep < hpnsMaxHBI)
				hpnsInfo.APInfo[hpnsContext.ApIndex].HBI += hpnsStep;
			else
				hpnsInfo.APInfo[hpnsContext.ApIndex].HBI = hpnsMaxHBI;
		}

		hpnsContext.heartBeatPeriod = hpnsInfo.APInfo[hpnsContext.ApIndex].HBI;
		hpnsSaveHpnsInfo();
	}
	
    hpnsResetHeartBeatTimer();

	return 0;
}

void hpnsProcessHeartbeatRespTimer(int param)
{
	nprintf("heart beat timer is expired, heartbeatRetry: %d", hpnsContext.heartbeatRetry);
	
    if ( hpnsContext.heartbeatRetry < HPNS_MAX_NUM_RETRY && hpnsContext.tcpFlag != 1 )
    {   
		hpnsSendHeartbeatToServer();		
        return;
    }

	nprintf ("failed to connect to server, try to establish the connection again");	
	
	if(hpnsContext.tcpFlag == 1 && hpnsContext.ApIndex >= 0)
	{
		hpnsInfo.APInfo[hpnsContext.ApIndex].lastFailedHBI = hpnsInfo.APInfo[hpnsContext.ApIndex].HBI;
		hpnsInfo.APInfo[hpnsContext.ApIndex].failedTimestamp  = hpnsGetSystemTime();
		
		if( hpnsInfo.APInfo[hpnsContext.ApIndex].HBI - hpnsStep > hpnsMinHBI)
			hpnsInfo.APInfo[hpnsContext.ApIndex].HBI -= hpnsStep ;
		else
			hpnsInfo.APInfo[hpnsContext.ApIndex].HBI = hpnsMinHBI;
		
		hpnsSaveHpnsInfo();
	}
	
    hpnsOpenConnectionToPushServer();

	return;
}

void hpnsProcessHeartbeatTimer(int param)
{	 
	
	if ( (HPNS_NCM_MANUAL == hpnsInfo.connMode || HPNS_NCM_POLL == hpnsInfo.connMode ) )
	{
		nprintf("stop network connection, network conn mode:%d", hpnsInfo.connMode); 				
		
		hpnsCloseConnectionToPushServer();
		
		if ( HPNS_NCM_POLL == hpnsInfo.connMode )
		{
			hpnsSetTimer(HPNS_TIMERID_CONNECTION, hpnsPollingTime*60);
			nprintf ("mobile will connect to server again in %d minutes", hpnsPollingTime);
		}		
		return;
	}
	
	if ( hpnsContext.connStatus == HPNS_STATUS_CONNECTED ) 
	{
		if(hpnsUdpStatus != HPNS_UDP_STATUS_NORMAL && hpnsUdpStatus != HPNS_UDP_STATUS_NTWKCHANGED)
			hpnsUdpStatus = HPNS_UDP_STATUS_ABNORMAL;
			
		hpnsSendHeartbeatToServer();
	}
	else
    {
        hpnsOpenConnectionToPushServer();
    }
	
	return;
}

int hpnsCancelTransactionToPushServer(void)
{
    hpnsKillTimer (HPNS_TIMERID_TRANSACTION);
    hpnsContext.outType = 0;  
    hpnsContext.numOfRetry = 0;

    if ( hpnsContext.msg )     
    {
        hpnsFreeL(hpnsContext.msg);
    }
    hpnsContext.msg = 0;
	hpnsContext.msgLen = 0;

    hpnsContext.msgTranId++;
	
    return 0;
}

void hpnsProcessTransactionTimer(int param)
{	
	int i = 0, isBundlingApp = 0;
	
	hpnsKillTimer (HPNS_TIMERID_TRANSACTION);

    if ( hpnsContext.outType == 0 || hpnsContext.msg == 0 )
    {
        nprintf("error, no pending transaction, outype:%d, msg:%x\n", hpnsContext.outType, hpnsContext.msg );
        return;
    }

	//if connection status is unconnected, before sending static data request, PE should send a reg/login request firstly, if there is no bundled and bundling APP, stop the connection.
	if( hpnsInfo.staticDataFlag == HPNS_STATIC_DATA_UPLOAD_STATIC)
	{		
		for(i=0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
		{
			if( hpnsInfo.appBundled[i].appId != 0)
			{
				isBundlingApp = 1;
				break;
			}
		}

		if( isBundlingApp == 0 )
		{
			nprintf ("no response from server for msg:%s,and no bundled APP, drop it", hpnsMsgName[hpnsContext.outType]);
			hpnsCloseConnectionToPushServer();
			return;	
		}
	}

    if ( hpnsContext.numOfRetry < HPNS_MAX_NUM_RETRY  )
    {
        nprintf ("no response from server for msg:%s, send msg again, retry:%d", hpnsMsgName[hpnsContext.outType], hpnsContext.numOfRetry);
        hpnsDeliverMsgToPushServer( hpnsContext.msg, hpnsContext.msgLen);
        return;
    }
    nprintf ("no response from server for msg:%s, transaction is cancelled", hpnsMsgName[hpnsContext.outType]);

	hpnsOpenConnectionToPushServer();

	return;
}

int hpnsSendStaticDataToServer()
{
	int     msgLen = 0;
    UINT8  *pData = NULL;
	UINT32  nowTime = 0;


	hpnsInfo.staticDataFlag = HPNS_STATIC_DATA_UPLOAD_STATIC;

	if(hpnsContext.outType != 0)
	{
		nprintf("last message is processing, send static data later");
		return 0;
	}

	nowTime = hpnsGetSystemTime();
	if(nowTime - staticFailedTime < HPNS_STATIC_DATA_RETRY_SEC)
	{
		nprintf("static DB is error, upload the data later");
		return 0;
	}
	
	if( hpnsContext.connStatus == HPNS_STATUS_CONNECTED )
	{
		msgLen = hpnsBuildStaticDataReqMsg(&pData, &hpnsContext);
		hpnsSendMsgToPushServer(pData, msgLen);
	}
	else
		hpnsOpenConnectionToPushServer();
	
	return 0;
}



