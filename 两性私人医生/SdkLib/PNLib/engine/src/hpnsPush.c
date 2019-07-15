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
#include "hpnsMd5.h" 
#include "hpnsStm.h"
#include "hpnsTimer.h" 
#include "hpnsConfig.h"
#include "hpnsAppEngine.h"
#include "hpnsUtil.h"
#include "hpnsNetwork.h"


extern INT32       pushServerFd;
extern SHpnsIpAddr hpnsServer;

int hpnsSendDataToPushServer(UINT8 *msg, int msgLen)
{
	int   ret;
	unsigned short port = 0;
#ifdef __PNS_TCP_CONNECT_SUPPORT__
	unsigned short len = 0;
#endif
	unsigned char *ipStr = (unsigned char *)(&(hpnsServer.ip));
#ifdef __PNS_TCP_CONNECT_SUPPORT__

	if(hpnsContext.tcpFlag == 1)
	{
		len = hpnsHtons((UINT16)msgLen);
		ret = hpnsSendTcpData(hpnsPushTcpFd ,(UINT8 *)&len, 2);
		ret = hpnsSendTcpData(hpnsPushTcpFd ,msg, msgLen);
	}
	else
#endif
		ret = hpnsSendUdpData(pushServerFd, hpnsServer.ip, hpnsServer.port, msg, msgLen );
	
	hpnsInfo.sendBytes += msgLen;

	if ( msgLen != 4 )
	{
	#ifdef __PNS_TCP_CONNECT_SUPPORT__
		if(hpnsContext.tcpFlag == 1 )
			port = serverTcpPort;
		else
	#endif
			port = hpnsHtons(hpnsServer.port);
		nprintf ("%d bytes data is sent to ip:%d.%d.%d.%d, port:%d", msgLen, ipStr[0], ipStr[1], ipStr[2], ipStr[3], port);
	}
	// don't handle send error in this function. 
	
	return 0;
}

int hpnsDeliverMsgToPushServer(UINT8 *msg, int msgLen)
{
    int            ret;
    SHpnsMsgHeader *pHeader;
	unsigned short port = 0;
#ifdef __PNS_TCP_CONNECT_SUPPORT__
	unsigned short len = 0;
#endif
	unsigned char *ipStr = (unsigned char *)(&(hpnsServer.ip));

    pHeader = (SHpnsMsgHeader *) msg;

	if ( msgLen != 4 )
	{
    #ifdef __PNS_TCP_CONNECT_SUPPORT__
		if(hpnsContext.tcpFlag == 1 )
			port = serverTcpPort;
		else
	#endif
			port = hpnsHtons(hpnsServer.port);
		nprintf ("%d bytes data is sent to ip:%d.%d.%d.%d, port:%d", msgLen, ipStr[0], ipStr[1], ipStr[2], ipStr[3], port);
	}
	
#ifdef __PNS_TCP_CONNECT_SUPPORT__
	if(hpnsContext.tcpFlag == 1)
	{
		len = hpnsHtons((UINT16)msgLen);
		ret = hpnsSendTcpData(hpnsPushTcpFd ,(UINT8 *)&len, 2);
		ret = hpnsSendTcpData(hpnsPushTcpFd ,msg, msgLen);
	}
	else
#endif
		ret = hpnsSendUdpData(pushServerFd, hpnsServer.ip, hpnsServer.port, msg, msgLen );
	hpnsInfo.sendBytes += msgLen;

    if ( ret < 0 ) 
        nprintf("failed to send msg:%s to push server", hpnsMsgName[pHeader->type]);
    else
        nprintf("msg:%s is sent to push server", hpnsMsgName[pHeader->type]);
	
    if ( (pHeader->type & 0x01) == 0 ) 
    {
        // response
        hpnsContext.inType = 0;
        if (hpnsContext.rspMsg)
        {
            hpnsFreeL(hpnsContext.rspMsg);
            hpnsContext.rspMsg = 0;
        }

        hpnsContext.rspMsg = msg;
        hpnsContext.rspMsgLen = msgLen;
    }
    else
    {
        // request
        hpnsContext.outTranId = pHeader->tranId;
        hpnsContext.outType = pHeader->type;
        hpnsContext.numOfRetry ++;
        hpnsContext.msg = msg;
        hpnsContext.msgLen = msgLen;
		
        hpnsSetTimer( HPNS_TIMERID_TRANSACTION, HPNS_TRAN_WAIT_TIME );
        hpnsKillTimer( HPNS_TIMERID_HEART_BEAT );
    }    

    return ret;
}

int hpnsSendMsgToPushServer(UINT8 *msg, int msgLen) 
{
    int            ret, i, j;
    SHpnsMsgHeader *pHeader;
    UINT8          *pContent;
    int            contentLen;
    char           secret[HPNS_AUTH_LEN];

    if (msgLen <= 0)
        return 0;

    pHeader = (SHpnsMsgHeader *) msg;

    if ( hpnsContext.securityFlag & HPNS_SECURITY_FLAG_ON )
        pHeader->encrypt = 1;
	
    hpnsBuildAuthHeader( (UINT8 *) &(pHeader->spi), msgLen - sizeof( pHeader->auth), (UINT8 *)pHeader->auth, hpnsInfo.secret);

    if ( pHeader->encrypt )
    {
        // encryt message body here 
        pContent = (unsigned char*)pHeader->content;
        contentLen = msgLen - (sizeof(SHpnsMsgHeader)-1);

        memcpy (secret, msg, sizeof(secret));
        //for (i=0; i<sizeof(secret); ++i)
          //  secret[i] ^= hpnsInfo.secret[i];

        for (i=0,j=0; i<contentLen; ++i)
        {
            *pContent ^= *(secret + j);
            *(secret + j) = *pContent;
            pContent++;
            j = (j+1) % sizeof(secret);
        }
    }

    if ( (hpnsContext.outType == 0) || (pHeader->type & 1) == 0 ) 
    {
        ret = hpnsDeliverMsgToPushServer(msg, msgLen);
        return ret;
    }
	
    nprintf("failed to send msg:%s, last message is sending ", hpnsMsgName[pHeader->type]);

    return 0;
}

int hpnsPreProcessIncomingMsg(UINT8 *pMsg, int msgLen) 
{
    SHpnsMsgHeader *pHeader;
    UINT8         *pContent, code = 0;
    int           contentLen;
    int           i, j, ret = 0;
    char          secret[HPNS_AUTH_LEN], ns;
#ifdef __PNS_TCP_CONNECT_SUPPORT__
	unsigned short len = 0;
#endif

    pHeader = (SHpnsMsgHeader *)pMsg;

    if ( msgLen < (sizeof (SHpnsMsgHeader)-1) ) 
        return HPNS_CODE_WRONG_MSG_SIZE;

    if ( hpnsVerifyTimeStamp (pHeader->timeStamp) < 0 )	
	{
		hpnsContext.connStatus = HPNS_STATUS_UNCONNECTED;
		hpnsSendMsgToEngine(HPNS_MSG_NETWORK_STATE_CHANGED, (UINT8 *)(HPNS_NETWORK_STATE_ON<<16), 0);
		return HPNS_CODE_INVALID_TIME_STAMP;
    }
	
	if ( pHeader->type >= HPNS_MSG_TYPE_INVALID )
		return HPNS_CODE_INVALID_MSG_TYPE;

	if( memcmp(hpnsInfo.hid, defaultHid, HPNS_HID_LEN) != 0 && memcmp(hpnsInfo.hid, (void *)pHeader->hid, HPNS_HID_LEN)!= 0)
		return HPNS_CODE_MAPI_ERROR;		

    if ( pHeader->encrypt )
    {
        // decryt message body here
        pContent = (unsigned char*)pHeader->content;
        contentLen = msgLen - (sizeof(SHpnsMsgHeader)-1);

        memcpy(secret, pMsg, sizeof(secret));
        for (i=0; i<sizeof(secret); ++i)
            secret[i] ^= hpnsInfo.secret[i];

        for (i=0, j=0; i<contentLen; ++i)
        {    
            ns = *pContent;
            *pContent ^= *(secret + j);
            *(secret + j) = ns; 
            pContent++;
            j = (j+1) % sizeof(secret);
        }
    }
	
	if( (pHeader->type & 1) == 0 )
	{
        if ( hpnsContext.outType == 0 ) 
            return HPNS_CODE_UNEXPECTED_RESPONSE;

        if ( pHeader->sessionId !=  hpnsContext.localSessionId )
            return HPNS_CODE_INVALID_SESSION_ID;

        if ( pHeader->tranId !=  hpnsContext.outTranId )
            return HPNS_CODE_INVALID_TRAN_ID;

        if ( pHeader->type !=  hpnsContext.outType + 1)
            return HPNS_CODE_INVALID_RESPONSE_TYPE;

		memcpy(&code, pHeader->content, sizeof(UINT8));
		if( code == HPNS_CODE_INVALID_HID || code == HPNS_CODE_WRONG_SERVER_IP || code == HPNS_CODE_DB_FAILURE \
			|| code == HPNS_CODE_STATIC_DB_FAILURE ||code == HPNS_CODE_SERVER_UNAVAILABLE)
			ret = code; 
	}
	
	if (ret ==0 && hpnsAuthenticateMsg( (UINT8 *)&(pHeader->spi), hpnsNtohs(pHeader->length) - sizeof(pHeader->auth), (UINT8 *)pHeader->auth, hpnsInfo.secret ) < 0 )	
		return HPNS_CODE_AUTH_FAILURE;
	
    pHeader->length = hpnsNtohs (pHeader->length);

    if ( pHeader->type & 1 )
    {
        if ( hpnsContext.inTranId == pHeader->tranId)
        {
            if (hpnsContext.inType == pHeader->type)
            {
                nprintf ("msg:%s is re-transmitted by server, ignore", hpnsMsgName[pHeader->type]);
                return 1;
            }
            else
            {
            #ifdef __PNS_TCP_CONNECT_SUPPORT__
				if(hpnsContext.tcpFlag == 1)
				{
					len = hpnsHtons(hpnsContext.rspMsgLen);
					hpnsSendTcpData(hpnsPushTcpFd ,(UINT8 *)&len, 2);
					hpnsSendTcpData(hpnsPushTcpFd ,hpnsContext.rspMsg, hpnsContext.rspMsgLen);
				}
				else
			#endif
					hpnsSendUdpData(pushServerFd, hpnsServer.ip, hpnsServer.port, hpnsContext.rspMsg, hpnsContext.rspMsgLen );

				hpnsInfo.sendBytes += hpnsContext.rspMsgLen;
                nprintf ("msg:%s is already processed, last response is re-sent", hpnsMsgName[pHeader->type]);
            }
            return 1;
        }

        hpnsContext.inTranId = pHeader->tranId;

        if (  hpnsContext.inType != 0 ) 
        {
            hpnsContext.inType = pHeader->type;
            return HPNS_CODE_LAST_SESSION_NOT_FINISHED;
        }

        hpnsContext.inType = pHeader->type;

        if ( pHeader->sessionId !=  hpnsContext.localSessionId )
            return HPNS_CODE_INVALID_SESSION_ID;        

    }

    if ( (pHeader->type & 1) == 0 ) 
    {  
		hpnsContext.outType = 0;
        hpnsContext.numOfRetry = 0;

        hpnsKillTimer(HPNS_TIMERID_TRANSACTION);

        if ( hpnsContext.msg ) 
        {
            hpnsFreeL(hpnsContext.msg);
        }
        else
            nprintf("bug, msg shall not be 0 !!!");

        hpnsContext.msg = 0;
    } 

    return ret;
}

UINT8 hpnsRecBuffer[HPNS_MAX_PAYLOAD_LEN + 64] = {0};
int   packetLen = 0;

void hpnsProcessUdpData(void)
{
	UINT32 ip;
	UINT16 port;
	int    dataLen = 0;
	unsigned char *ipStr=(unsigned char *)(&ip);

	dataLen = hpnsRecvUdpData( pushServerFd, hpnsRecBuffer, sizeof(hpnsRecBuffer), &ip, &port);

	if ( dataLen == 0 ) 
	{
		//nprintf ("empty UDP packet is received, no action");
		return;
	}

	if ( dataLen <0 )
	{
		hpnsHandleConnectionError(HPNS_CONNECTION_ERROR_NETWORK);
		return;
	}

	hpnsInfo.recvBytes += dataLen;
	
	if ( dataLen != 4 )
		nprintf ("%d bytes data is received from ip:%d.%d.%d.%d, port:%d", dataLen, ipStr[0], ipStr[1], ipStr[2], ipStr[3], hpnsHtons(port));
	
	hpnsProcessMsgFromPushServer(hpnsRecBuffer, dataLen, ip, port);
	
}

#ifdef __PNS_TCP_CONNECT_SUPPORT__
void hpnsProcessTcpData(void)
{
	UINT32 ip = hpnsServer.ip ;
	UINT16 port = hpnsServer.port;
	int    dataLen = 0;
	UINT16 len = 0;
	unsigned char *ipStr=(unsigned char *)(&ip);

	if(packetLen == 0)
	{
		dataLen = hpnsRecvTcpData( hpnsPushTcpFd, (UINT8*)&len, 2);
		if( dataLen < 0)
		{
			hpnsHandleConnectionError(HPNS_CONNECTION_ERROR_NETWORK);
			return;
		}
		packetLen  = hpnsNtohs(len);	
		nprintf("receive tcp msg len:%d, %d", packetLen, len);
	}
	
	dataLen = hpnsRecvTcpData( hpnsPushTcpFd, hpnsRecBuffer, packetLen);

	nprintf("receive tcp real data len =%d",dataLen);
	if ( dataLen == 0 ) 
	{
		nprintf ("empty TCP packet is received, no action");
		return;
	}

	if ( dataLen <0 )
	{
		hpnsHandleConnectionError(HPNS_CONNECTION_ERROR_NETWORK);
		packetLen= 0;
		return;
	}

	if(dataLen != packetLen )
	{
		nprintf("failed to read msg, lenToread:%d, lenRead:%d", packetLen, dataLen);
		packetLen = 0;
		return;
	}

	hpnsInfo.recvBytes += dataLen;
	packetLen = 0;
	
	if ( dataLen != 4 )
		nprintf ("%d bytes data is received from ip:%d.%d.%d.%d, port:%d", dataLen, ipStr[0], ipStr[1], ipStr[2], ipStr[3], serverTcpPort);
	
	hpnsProcessMsgFromPushServer(hpnsRecBuffer, dataLen, ip, port);


}
#endif

