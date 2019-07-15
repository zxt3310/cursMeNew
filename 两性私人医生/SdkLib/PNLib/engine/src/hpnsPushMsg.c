/******************************************************************* 
* Copyright (c) 2011 by Hesine Technologies, Inc. 
* All rights reserved. 
* 
* This file is proprietary and confidential to Hesine Technologies. 
* No part of this file may be reproduced, stored, transmitted, 
* disclosed or used in any form or by any means other than as 
* expressly provided by the written permission from Jianhui Tao 
* 
* ****************************************************************/

#include "hpnsPushMsg.h"
#include "hpnsUtil.h"


int hpnsBuildTypeLongIe(UINT8 type, UINT8 *pMsg, UINT32 value)
{	
    SHpnsTypeLongIe *pIe;

    pIe = (SHpnsTypeLongIe *) pMsg;
    pIe->type = type;

    pIe->value = hpnsHtonl(value);

    return sizeof (SHpnsTypeLongIe);
}

int hpnsBuildAppSenderIe(UINT8 *pMsg, SHpnsAppProfile appProfile)
{
	SHpnsAppSenderIe *pIe;
	int           len = 0;
	
	pIe = (SHpnsAppSenderIe *)pMsg;
    pIe->type  = HPNS_IE_SENDER_ID;
	pIe->appId = hpnsHtonl(appProfile.appId);

	len = strlen((char *)appProfile.senderId);
	len = len>HPNS_SENDER_LEN?HPNS_SENDER_LEN:len;
	memcpy( (char *)pIe->sender, (char *)appProfile.senderId, len);
	
	pIe->len = len+1;
	
	return sizeof(SHpnsAppSenderIe)+len;
}

int hpnsBuildTLVStrIe(UINT8 type, UINT8 *pMsg, INT8 *pValue)
{
 	SHpnsTypeLenIe *pIe;
    int           len;

    pIe = (SHpnsTypeLenIe *)pMsg;
    pIe->type = type;

    len = strlen( (char *)pValue);

    strcpy( (char *)pIe->pValue, (char *)pValue);

    len = sizeof (SHpnsTypeLenIe) + len + 1;
    pIe->len = hpnsNtohs((UINT16)len);

    return len;
}


int hpnsBuildImsiIe(UINT8 *pMsg, UINT8 *pImsi)
{
    SHpnsImsiIe  *pIe;

    pIe = (SHpnsImsiIe  *)pMsg;
    pIe->type = HPNS_IE_IMSI;

    memcpy ((void*)pIe->imsi, pImsi, sizeof(pIe->imsi));

    return sizeof(SHpnsImsiIe);
}

int hpnsBuildImeiIe(UINT8 *pMsg, UINT8 *pImei)
{
    SHpnsImeiIe  *pIe;

    pIe = (SHpnsImeiIe  *)pMsg;
    pIe->type = HPNS_IE_IMEI;

    memcpy ((void*)pIe->imei, (void*)pImei, sizeof(pIe->imei));
    return sizeof(SHpnsImeiIe);
}

int hpnsBuildSoftwareVersionIe(UINT8 *pMsg, SDeviceInfo deviceInfo)
{
    SHpnsSoftwareVersionIe *pIe;

    pIe = (SHpnsSoftwareVersionIe  *)pMsg;
    pIe->type = HPNS_IE_SOFTWARE_VERSION;

    pIe->majorVersion= hpnsNtohs( deviceInfo.majorVersion);
    pIe->minorVersion= hpnsNtohs( deviceInfo.minorVersion);

    return sizeof(SHpnsSoftwareVersionIe);
}

int hpnsBuildScreenInfoIe(UINT8 *pMsg, SDeviceInfo deviceInfo)
{
	SHpnsScreenInfoIe *pIe;
	
	pIe = (SHpnsScreenInfoIe  *)pMsg;
	pIe->type = HPNS_IE_SCREEN_INFO;

	pIe->hSize = hpnsNtohs( deviceInfo.hSize);
	pIe->vSize = hpnsNtohs( deviceInfo.vSize);

	return sizeof(SHpnsScreenInfoIe);
}

int hpnsBuildLocationInfoIe(UINT8 *pMsg)
{
	SHpnsLocationInfoIe *pIe;
		
	pIe = (SHpnsLocationInfoIe  *)pMsg;
	pIe->type = HPNS_IE_LOCATION_INFO;

	strncpy((char *)pIe->latitude, (char *)hpnsInfo.latitude, HPNS_LATITUDE_LEN);
	strncpy((char *)pIe->longitude , (char *)hpnsInfo.longitude, HPNS_LONGITUDE_LEN);

	return sizeof(SHpnsLocationInfoIe);
}

int hpnsBuildCapabilitiesIe(UINT8 *pMsg, SDeviceInfo deviceInfo)
{
	SHpnsCapabilitiesIe *pIe;
			
	pIe = (SHpnsCapabilitiesIe  *)pMsg;
	pIe->type = HPNS_IE_CAPABILITIES;

	pIe->voiceCap = hpnsHtonl(deviceInfo.voiceCap);
	pIe->videoCap = hpnsHtonl(deviceInfo.videoCap);
	pIe->imageCap = hpnsHtonl(deviceInfo.imageCap);
	pIe->otherCap = hpnsHtonl(deviceInfo.otherCap);

	return sizeof(SHpnsCapabilitiesIe);
}

int hpnsBuildIPAddressIe(UINT8 *pMsg, UINT32 mobileIP)
{
	SHpnsIpAddrIe *pIe;
			
	pIe = (SHpnsIpAddrIe *)pMsg;
	pIe->type = HPNS_IE_MOB_IP;

	pIe->ip = hpnsHtonl(mobileIP);

	return sizeof(SHpnsIpAddrIe);
}

int hpnsBuildMemoryConfigIe(UINT8 *pMsg, SDeviceInfo deviceInfo )
{
	SHpnsMemConfigIe *pIe;
			
	pIe = (SHpnsMemConfigIe  *)pMsg;
	pIe->type = HPNS_IE_MEMORY_CONFIG;

	pIe->RAMSize = hpnsNtohl( deviceInfo.sizeOfRAM);
	pIe->ROMSize = hpnsNtohl( deviceInfo.sizeOfROM);

	return sizeof(SHpnsMemConfigIe);
}

int hpnsBuildAppStatisticsIe(UINT8 *pMsg, SHpnsAppProfile appProfile)
{
	SHpnsAppStatisticsIe *pIe;
			
	pIe = (SHpnsAppStatisticsIe  *)pMsg;
	pIe->type = HPNS_IE_APP_STATISTICS;

	pIe->appId       = hpnsNtohl( appProfile.appId);
	pIe->numOfCTViaBannerNoKey   = hpnsNtohl( appProfile.numOfCTViaBannerNoKey);
	pIe->numOfCTViaBannerWithKey = hpnsNtohl( appProfile.numOfCTViaBannerWithKey);
	pIe->numOfCTViaMenuWithBadge = hpnsNtohl( appProfile.numOfCTViaMenuWithBadge);
	pIe->numOfCTViaNCNoKey       = hpnsNtohl( appProfile.numOfCTViaNCNoKey);
	pIe->numOfCTViaNCWithKey     = hpnsNtohl( appProfile.numOfCTViaNCWithKey);
	pIe->numOfCTViaOthers        = hpnsNtohl( appProfile.numOfCTViaOthers);
	pIe->numOfCTViaPopNoKey      = hpnsNtohl( appProfile.numOfCTViaPopNoKey);
	pIe->numOfCTViaPopWithKey    = hpnsNtohl( appProfile.numOfCTViaPopWithKey);
	pIe->numOfCTViaBadgeNoKey    = hpnsNtohl( appProfile.numOfCTViaBadgeNoKey);

	return sizeof(SHpnsAppStatisticsIe);
}

int hpnsVerifyTimeStamp(UINT32 remoteTime)
{
    UINT32 systemTime;
    int delta;

    systemTime = hpnsGetSystemTime();
    delta = hpnsHtonl (remoteTime) - systemTime;
    if ( abs(delta) > 80000 ) 
        return -1;
	
    return 0;
}

int hpnsBuildRegReqMsg( UINT8 **pData, SHpnsContext *pContext)
{
    SHpnsMsgHeader  *pHeader;
    UINT8          *pMsg;
    int            msgLen = 0, i = 0;

    pMsg = (UINT8 *)hpnsMallocL(HPNS_MAX_BUF_SIZE);
	if( 0 == pMsg )
	{
		nprintf ("failed to allocate memory when building reg req msg");
		return 0;
	}
	memset (pMsg, 0, HPNS_MAX_BUF_SIZE);
    *pData = pMsg;

    pHeader = (SHpnsMsgHeader *)pMsg;
    pHeader->timeStamp = hpnsHtonl( hpnsGetSystemTime());
    pHeader->tranId = pContext->msgTranId++;
	if(pHeader->tranId == 0)
		pHeader->tranId = pContext->msgTranId++;
    pHeader->sessionId = pContext->remoteSessionId;
	pHeader->localSessionId = pContext->localSessionId;
    pHeader->type = HPNS_MSG_TYPE_REG;
	memcpy((void *)pHeader->hid, (void *)hpnsInfo.hid, HPNS_HID_LEN);

    pMsg = (unsigned char*)pHeader->content;

	// include session ID 
	if ( pContext->connStatus != HPNS_STATUS_CONNECTED )
    {
        pHeader->sessionId = 0;
	}

	if(memcmp( hpnsInfo.hid, defaultHid, HPNS_HID_LEN ) == 0 )
	{
		for( i=0; i < HPNS_MAX_IMSI_NUM; i++  )
		{
			if( hpnsInfo.deviceInfo.imsi[i][0] != 0)
				pMsg += hpnsBuildImsiIe(pMsg, hpnsInfo.deviceInfo.imsi[i]);
		}

	}
	
	if(hpnsInfo.numOfBundled == 0 )
    { 
		pMsg += hpnsBuildSoftwareVersionIe(pMsg, hpnsInfo.deviceInfo);
		pMsg += hpnsBuildTypeLongIe(HPNS_IE_TTL, pMsg, pContext->hpnsTtl );
		pMsg += hpnsBuildTypeLongIe(HPNS_IE_NMS_VERSION, pMsg, hpnsInfo.deviceInfo.protocolVersion);
		pMsg += hpnsBuildTypeLongIe(HPNS_IE_DEVICE_ID, pMsg, hpnsInfo.deviceInfo.deviceID);
		pMsg += hpnsBuildTypeLongIe(HPNS_IE_PUBLISH_CHANNEL, pMsg, channelId);	
    }

	pMsg += hpnsBuildTypeLongIe(HPNS_IE_TCP_FLAG, pMsg, hpnsSupportTcp);

    if(hpnsUdpStatus == HPNS_UDP_STATUS_NTWKCHANGED)
        hpnsUdpStatus = HPNS_UDP_STATUS_DEFAULT;
	pMsg += hpnsBuildTypeLongIe(HPNS_IE_UDP_STATUS, pMsg, hpnsUdpStatus);
	
	pContext->apnType = hpnsGetAPNType();
	pMsg += hpnsBuildTypeLongIe(HPNS_IE_APN_TYPE, pMsg, pContext->apnType);
	
#ifdef __LINUXTEST__
    printf("set mobile IP");
	pMsg += hpnsBuildIPAddressIe(pMsg, mobileIp);
#endif
	
	for(i=0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
	{
		if( hpnsInfo.appBundled[i].appId != 0 && \
			(hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_ON || hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_BUNDLING))
		{
			if(hpnsInfo.appBundled[i].numOfNoRsp > HPNS_MAX_NOTIFICATION_NUM)
			{
				nprintf(" %d notification message have sent without resp,clean the app:%d", hpnsInfo.appBundled[i].numOfNoRsp, hpnsInfo.appBundled[i].appId );
				hpnsMemSet(&(hpnsInfo.appBundled[i]), 0x0, sizeof(SHpnsAppProfile));
				hpnsSaveHpnsInfo();	
				continue;
			}
			
			pMsg += hpnsBuildAppSenderIe(pMsg, hpnsInfo.appBundled[i]);
		}
	}				
    
    msgLen = pMsg - *pData;
    pHeader->length = hpnsHtons ((UINT16)msgLen);
	
    return msgLen;
}

int hpnsBuildLoginReqMsg( UINT8 **pData, SHpnsContext *pContext)
{
	SHpnsMsgHeader  *pHeader;
    UINT8          *pMsg;
    int            msgLen = 0, i = 0;

    pMsg = (UINT8 *)hpnsMallocL(HPNS_MAX_BUF_SIZE);
	if( 0 == pMsg )
	{
		nprintf ("failed to allocate memory when building login req msg");
		return 0;
	}
	memset (pMsg, 0, HPNS_MAX_BUF_SIZE);
    *pData = pMsg;

    pHeader = (SHpnsMsgHeader *)pMsg;
    pHeader->timeStamp = hpnsHtonl( hpnsGetSystemTime());
    pHeader->tranId = pContext->msgTranId++;
	if(pHeader->tranId == 0)
		pHeader->tranId = pContext->msgTranId++;
    pHeader->sessionId = pContext->remoteSessionId;
	pHeader->localSessionId = pContext->localSessionId;
    pHeader->type = HPNS_MSG_TYPE_LOGIN;
	memcpy((void *)pHeader->hid, (void *)hpnsInfo.hid, HPNS_HID_LEN);

    pMsg = (unsigned char*)pHeader->content;

	if ( pContext->connStatus != HPNS_STATUS_CONNECTED )
    {
        pHeader->sessionId = 0;
	}

	pMsg += hpnsBuildTypeLongIe(HPNS_IE_NMS_VERSION, pMsg, hpnsInfo.deviceInfo.protocolVersion);

	pMsg += hpnsBuildLocationInfoIe(pMsg);
	
	pMsg += hpnsBuildTypeLongIe(HPNS_IE_CONN_MODE, pMsg, hpnsInfo.connMode);

	pMsg += hpnsBuildTypeLongIe(HPNS_IE_TCP_FLAG, pMsg, hpnsSupportTcp);
    
    if(hpnsUdpStatus == HPNS_UDP_STATUS_NTWKCHANGED)
        hpnsUdpStatus = HPNS_UDP_STATUS_DEFAULT;
	pMsg += hpnsBuildTypeLongIe(HPNS_IE_UDP_STATUS, pMsg, hpnsUdpStatus);
	
	pContext->apnType = hpnsGetAPNType();
	pMsg += hpnsBuildTypeLongIe(HPNS_IE_APN_TYPE, pMsg, pContext->apnType);

    if(hpnsInfo.updateFlag && hpnsInfo.staticDataFlag)
    {
		for( i=0; i < HPNS_MAX_IMSI_NUM; i++  )
		{
			if( hpnsInfo.deviceInfo.imsi[i][0] != 0)
				pMsg += hpnsBuildImsiIe(pMsg, hpnsInfo.deviceInfo.imsi[i]);
		}
		
		
		pMsg += hpnsBuildImeiIe(pMsg, hpnsInfo.deviceInfo.imei);
		
		pMsg += hpnsBuildCapabilitiesIe(pMsg, hpnsInfo.deviceInfo);

		pMsg += hpnsBuildMemoryConfigIe(pMsg, hpnsInfo.deviceInfo);

		pMsg += hpnsBuildScreenInfoIe(pMsg, hpnsInfo.deviceInfo);
		
		pMsg += hpnsBuildSoftwareVersionIe(pMsg, hpnsInfo.deviceInfo);
		
		pMsg += hpnsBuildTypeLongIe(HPNS_IE_DEVICE_ID, pMsg, hpnsInfo.deviceInfo.deviceID);
		
		pMsg += hpnsBuildTypeLongIe(HPNS_IE_LANGUAGE, pMsg, hpnsInfo.deviceInfo.lang);

		pMsg += hpnsBuildTypeLongIe(HPNS_IE_PUBLISH_CHANNEL, pMsg, channelId);	

		pMsg += hpnsBuildTLVStrIe(HPNS_IE_MRE_VERSION, pMsg, hpnsInfo.deviceInfo.MREVersion);	

		pMsg += hpnsBuildTLVStrIe(HPNS_IE_MAC_ADD, pMsg, hpnsInfo.deviceInfo.MACAddr);	

		pMsg += hpnsBuildTLVStrIe(HPNS_IE_DEVICE_OS, pMsg, hpnsInfo.deviceInfo.clientOs);

		pMsg += hpnsBuildTLVStrIe(HPNS_IE_CHIPSET, pMsg, hpnsInfo.deviceInfo.chipSet);	
    }
	else
	{
		hpnsProcessStatisticsInfo();
		for(i=0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
		{
			if( hpnsInfo.appBundled[i].appId != 0 && hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_ON && hpnsInfo.appBundled[i].updateFlag)
				pMsg += hpnsBuildAppStatisticsIe(pMsg, hpnsInfo.appBundled[i]);
		}
	}
	
#ifdef __LINUXTEST__
	pMsg += hpnsBuildIPAddressIe(pMsg, mobileIp);
#endif
	
    msgLen = pMsg - *pData;
    pHeader->length = hpnsHtons ((UINT16)msgLen);
	
    return msgLen;
}


int hpnsBuildStaticDataReqMsg(UINT8 **pData, SHpnsContext *pContext)
{
	SHpnsMsgHeader	*pHeader;
	UINT8		   *pMsg;
	int 		   msgLen = 0, i = 0;

	pMsg = (UINT8 *)hpnsMallocL(HPNS_MAX_BUF_SIZE);
	if( 0 == pMsg )
	{
		nprintf ("failed to allocate memory when building reg req msg");
		return 0;
	}
	memset (pMsg, 0, HPNS_MAX_BUF_SIZE);
	*pData = pMsg;

	pHeader = (SHpnsMsgHeader *)pMsg;
	pHeader->timeStamp = hpnsHtonl( hpnsGetSystemTime());
	pHeader->tranId = pContext->msgTranId++;
	if(pHeader->tranId == 0)
		pHeader->tranId = pContext->msgTranId++;
	pHeader->sessionId = pContext->remoteSessionId;
	pHeader->localSessionId = pContext->localSessionId;
	pHeader->type = HPNS_MSG_TYPE_STATICDATA;
	memcpy((void *)pHeader->hid, (void *)hpnsInfo.hid, HPNS_HID_LEN);

	pMsg = (unsigned char*)pHeader->content;

	// include session ID 
	if ( pContext->connStatus != HPNS_STATUS_CONNECTED )
	{
		pHeader->sessionId = 0;
	}

	for( i=0; i < HPNS_MAX_IMSI_NUM; i++  )
	{
		if( hpnsInfo.deviceInfo.imsi[i][0] != 0)
			pMsg += hpnsBuildImsiIe(pMsg, hpnsInfo.deviceInfo.imsi[i]);
	}


	if(hpnsInfo.numOfBundled == 0 )
		pMsg += hpnsBuildTypeLongIe(HPNS_IE_TTL, pMsg, pContext->hpnsTtl );

	pMsg += hpnsBuildSoftwareVersionIe(pMsg, hpnsInfo.deviceInfo);

	pMsg += hpnsBuildTypeLongIe(HPNS_IE_NMS_VERSION, pMsg, hpnsInfo.deviceInfo.protocolVersion);
	
	pMsg += hpnsBuildImeiIe(pMsg, hpnsInfo.deviceInfo.imei);

	pMsg += hpnsBuildCapabilitiesIe(pMsg, hpnsInfo.deviceInfo);

	pMsg += hpnsBuildMemoryConfigIe(pMsg, hpnsInfo.deviceInfo);

	pMsg += hpnsBuildScreenInfoIe(pMsg, hpnsInfo.deviceInfo);
	
	pMsg += hpnsBuildTypeLongIe(HPNS_IE_DEVICE_ID, pMsg, hpnsInfo.deviceInfo.deviceID);
	
	pMsg += hpnsBuildTypeLongIe(HPNS_IE_LANGUAGE, pMsg, hpnsInfo.deviceInfo.lang);

	pMsg += hpnsBuildTypeLongIe(HPNS_IE_PUBLISH_CHANNEL, pMsg, channelId);	

	pMsg += hpnsBuildTLVStrIe(HPNS_IE_MRE_VERSION, pMsg, hpnsInfo.deviceInfo.MREVersion);	

	pMsg += hpnsBuildTLVStrIe(HPNS_IE_DEVICE_OS, pMsg, hpnsInfo.deviceInfo.clientOs);

	pMsg += hpnsBuildTLVStrIe(HPNS_IE_CHIPSET, pMsg, hpnsInfo.deviceInfo.chipSet);

	msgLen = pMsg - *pData;
    pHeader->length = hpnsHtons ((UINT16)msgLen);
	
    return msgLen;
}

int hpnsBuildDetectResp( UINT8 **pData, SHpnsContext *pContext)
{
	SHpnsMsgHeader	*pHeader;
	UINT8		   *pMsg;
	int 		   msgLen = 0, i = 0;

	pMsg = (UINT8 *)hpnsMallocL(HPNS_MAX_BUF_SIZE);
	if( 0 == pMsg )
	{
		nprintf ("failed to allocate memory when building detect resp msg");
		return 0;
	}
	memset (pMsg, 0, HPNS_MAX_BUF_SIZE);
	*pData = pMsg;

	pHeader = (SHpnsMsgHeader *)pMsg;
	pHeader->timeStamp = hpnsHtonl( hpnsGetSystemTime());
	pHeader->tranId = pContext->inTranId;
	pHeader->sessionId = pContext->remoteSessionId;
	pHeader->localSessionId = pContext->localSessionId;
	pHeader->type = HPNS_MSG_TYPE_DETECT_RSP;
	memcpy((void *)pHeader->hid, (void *)hpnsInfo.hid, HPNS_HID_LEN);

	pMsg = (unsigned char*)pHeader->content;

	msgLen = pMsg - *pData;
    pHeader->length = hpnsHtons ((UINT16)msgLen);
	
    return msgLen;
}

int hpnsBuildReplyMsg(UINT8 **pData, UINT8 code, UINT8 flag, UINT32 appId, UINT32 msgId, UINT32 internalId, SHpnsContext *pContext)
{
    SHpnsMsgHeader*      pHeader;
    SHpnsDeliverRspHeader  *pDeliverRspHeader;
    UINT8               *pMsg;
    int                 msgLen;

    pMsg = (UINT8 *)hpnsMallocL(128);

    if ( pMsg == 0 )
    {
        nprintf ("build reply msg, failed to allocate memory");
        return 0;
    }

    memset (pMsg, 0, 128);
    *pData = pMsg;

    pHeader            = (SHpnsMsgHeader *)pMsg;
    pHeader->timeStamp = hpnsHtonl( hpnsGetSystemTime() );
    pHeader->tranId    = pContext->inTranId;
    pHeader->sessionId = pContext->remoteSessionId;
	pHeader->localSessionId = pContext->localSessionId;
    pHeader->type = pContext->inType + 1; 
	memcpy((void *)pHeader->hid, (void *)hpnsInfo.hid, HPNS_HID_LEN);

    pDeliverRspHeader        = (SHpnsDeliverRspHeader*)(pHeader->content);
    pDeliverRspHeader->code  = code;
    pDeliverRspHeader->appId = hpnsHtonl(appId);
	pDeliverRspHeader->msgId = hpnsHtonl(msgId);
	pDeliverRspHeader->internalMsgId = hpnsHtonl(internalId);
	pDeliverRspHeader->reserved      = flag;

    pMsg += (sizeof(SHpnsMsgHeader)+sizeof(SHpnsDeliverRspHeader)-1);
    
    msgLen = pMsg - *pData;

    pHeader->length = hpnsNtohs((UINT16)msgLen);

    return msgLen;
}

int hpnsParseRespMsgFromServer(UINT8 *pMsg, SHpnsReplyContext *pReply)
{
    UINT8           *pNext = 0, *pEnd = 0;
    UINT8           type;
    SHpnsTypeLongIe *pTypeLong;
	SHpnsTypeLenIe  *pTypeLen;
    SHpnsIpAddrIe   *pIp;
    SHpnsKeyIe      *pKey;
	SHpnsRegIDIe    *pRegInfo;    
    SHpnsMsgHeader  *pHeader;
	INT32           numOfRegApp = -1;

    pHeader = (SHpnsMsgHeader *)pMsg;
    pEnd = pMsg + pHeader->length;
    pNext = (unsigned char*)pHeader->content;
    memset (pReply, 0, sizeof(SHpnsReplyContext));

	pReply->hid = pHeader->hid;
	pReply->sessionId = pHeader->localSessionId;
    pReply->securityFlag = HPNS_SECURITY_FLAG_ON;

    pReply->code = *pNext;
    ++pNext;

    while ( pNext < pEnd ) 
    {
        type = *pNext;
		if ( type == 0 )
        {
            pNext ++;
        }
        else if ( type == HPNS_IE_SESSION_ID ) 
        {
            pTypeLong = (SHpnsTypeLongIe *) pNext;
            pReply->sessionId = pTypeLong->value;
            pNext += sizeof (SHpnsTypeLongIe);
        } 
        else if ( type == HPNS_IE_REG_TIMER )
        {
            pTypeLong = (SHpnsTypeLongIe *) pNext;
            pReply->heartBeatPeriod  = hpnsHtonl(pTypeLong->value);
            pNext += sizeof (SHpnsTypeLongIe);
        }
        else if ( type == HPNS_IE_PUSH_IP ) 
        {
            pIp = (SHpnsIpAddrIe *)pNext;
            pReply->pushIp.ip = pIp->ip;
            pReply->pushIp.port = pIp->port;
            pNext += sizeof (SHpnsIpAddrIe);
        }
        else if ( type == HPNS_IE_SECRET )
        {
            pKey = (SHpnsKeyIe *)pNext;
            pReply->secret = (unsigned char*)pKey->key;
            pNext += sizeof (SHpnsKeyIe);
        }
        else if ( type == HPNS_IE_SECURITY_FLAG )
        {
            pTypeLong = (SHpnsTypeLongIe *) pNext;
            pReply->securityFlag = pTypeLong->value;
            pNext += sizeof (SHpnsTypeLongIe);
        }
		else if( type == HPNS_IE_CONN_MODE )
		{
			pTypeLong = (SHpnsTypeLongIe *) pNext;
            pReply->connMode = hpnsHtonl(pTypeLong->value);
            pNext += sizeof (SHpnsTypeLongIe);
		}
		else if (type == HPNS_IE_APP_ID )
		{
			numOfRegApp ++;	
			pTypeLong = (SHpnsTypeLongIe *)pNext;
			pReply->appList[numOfRegApp].appId = hpnsHtonl(pTypeLong->value);
			pNext += sizeof(SHpnsTypeLongIe);
		}
		else if( type == HPNS_IE_REG_INFO )
		{
			numOfRegApp ++;	
			pRegInfo = (SHpnsRegIDIe *)pNext;
			pReply->appList[numOfRegApp].appId = hpnsHtonl(pRegInfo->appId);
			memcpy((void *)pReply->appList[numOfRegApp].regId, (void *)pRegInfo->regId, HPNS_REGID_LEN);
			pReply->appList[numOfRegApp].appCode = pRegInfo->code;
			pNext += sizeof(SHpnsRegIDIe);
		}
		#ifdef __PNS_TCP_CONNECT_SUPPORT__
		else if( type == HPNS_IE_TCP_FLAG)
		{
			pTypeLen = (SHpnsTypeLenIe *)pNext;  
			memcpy(&pReply->tcpFlag, pTypeLen->pValue, sizeof(UINT8) );
			pNext += hpnsNtohs(pTypeLen->len);
		}
		#endif
        else
        {
			if ( type < 128 ) 
			{
            	nprintf("failed to parse msg,unrecognized ie id:%d", type); 
			    return HPNS_CODE_UNRECOGNIZED_IE;
            }
			else
            {
                pTypeLen = (SHpnsTypeLenIe *)pNext;    
				pNext += hpnsNtohs(pTypeLen->len);
            }
        }
    }
	
    if ( pNext > pEnd ) 
        return HPNS_CODE_WRONG_MSG_SIZE;

	pReply->numOfApp = numOfRegApp+1;
	
    return 0;
}

