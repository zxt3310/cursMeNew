#include "hpnsUtil.h"
#include "tmodule.h"
#include "hpnsAppEngine.h"
#include "hpnsConfig.h"
#include "hpnsHttpPost.h"
#include "PNHandler.h"

int  notificationRespFlag = 0;

void notificationMsgCallBack(char *msg, int msgLen);
void registerCallback(int appId, char regId[], int code);

int byteArrayToHexStr(char bytes[], int len, char hexstr[]) 
{ 
	int i; 
	char hexval[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'}; 

	for(i = 0; i < len; i++) 
	{ 
	hexstr[i*2] = hexval[((bytes[i] >> 4) & 0xF)]; 
	hexstr[(i*2) + 1] = hexval[(bytes[i]) & 0x0F]; 
	} 
	return 0;
} 


void registerCallback(int appId, char regId[], int code)
{
    pnRegister(appId, regId, code);
}

void notificationMsgCallBack(char *msg, int msgLen)
{
    pnNewNotification(msg);
}

int hpnsUiSendNotificationToNS(SHpnsRegInfo *pHpnsRegInfo)
{
	char* params[10];
	int i = 0,k;
	char  regStr[32] = {0};

	//byteArrayToHexStr(pHpnsRegInfo->regId, 12, regStr);

	registerCallback(pHpnsRegInfo->appId, pHpnsRegInfo->regId, pHpnsRegInfo->appCode);
	
	return 0;
}


int hpnsUiProcessNotification(UINT8 *pMsg, int msgLen)
{
	char msg[20]= {0};
	SHpnsRegInfo *pRegInfo = (SHpnsRegInfo *)pMsg;

	memcpy(msg, pRegInfo->payload, 19);
	
	nprintf("UI receive msg, msg len:%d ,the pre msg content:%s", msgLen - sizeof(SHpnsRegInfo) + 1, msg);

	if(notificationRespFlag ==0 )
		hpnsSendMsgToEngine(HPNS_MSG_NOTIFICATION_RSP, (UINT8 *)(pRegInfo->appId), 0);
	notificationMsgCallBack(pRegInfo->payload, msgLen - sizeof(SHpnsRegInfo) + 1);

	return 0;
}


int hpnsUiProcessMsgQueue(msg_t *param)
{
	msg_t *pMsg;
	SHpnsRegInfo *pHpnsRegInfo = 0;

	pMsg = (msg_t *)param;

	nprintf ("msg:%s is received by UI", hpnsAppEngineMsg[pMsg->mid]);

	if( HPNS_MSG_NOTIFICATION == pMsg->mid )
	{
		hpnsUiProcessNotification(pMsg->msg, pMsg->tid);
	}
	else if(HPNS_MSG_REG_RSP == pMsg->mid  )
	{
		if(pMsg->tid == 0 )
		{
			return 0;
		}
		
		pHpnsRegInfo = ( SHpnsRegInfo *)(pMsg->msg);
		nprintf("appid:%d, error code:%d", pHpnsRegInfo->appId, pHpnsRegInfo->appCode);

		if(pHpnsRegInfo->appCode == 0 )
		{
			nprintf("sends regId to AS, appId:%u, regId:%s", pHpnsRegInfo->appId, \
					pHpnsRegInfo->regId);
			hpnsUiSendNotificationToNS(pHpnsRegInfo);

			//for simulater
			if( pHpnsRegInfo->appId == 3)
				nprintf("send next app bunding");
			else if( pHpnsRegInfo->appId == 2)
				nprintf("send a error app bunding");
		}	}
	else if(HPNS_MSG_UNREG_RSP == pMsg->mid )
    {
		if(pMsg->tid == 0 )
		{
			return 0;
		}
		else
		{
			pHpnsRegInfo = ( SHpnsRegInfo *)(pMsg->msg);
			if(pHpnsRegInfo->appCode == 0)
				nprintf("unreg sucessfully.");
			else
			{
				nprintf("appid:%d, code:%d", pHpnsRegInfo->appId, pHpnsRegInfo->appCode);
			}
		}
		
	}

	if ( pMsg->tid == 0 ) 
		pMsg->msg = NULL;
	
	return 0;
}

int hpnsInitUi(void *param)
{
	return 0;
}

void hpnsCleanUpUi()
{
	return;
}


int   hpnsGetAppStatisticsInfo(SHpnsAppStatistics  *hpnsAppStatistic)
{
	//nprintf("collect statistics info, appId:%d", hpnsAppStatistic->appId);

	hpnsAppStatistic->numOfCTViaBannerNoKey = 1;
	hpnsAppStatistic->numOfCTViaBannerWithKey= 1;
	hpnsAppStatistic->numOfCTViaMenuWithBadge= 1;
	hpnsAppStatistic->numOfCTViaNCNoKey= 1;
	hpnsAppStatistic->numOfCTViaNCWithKey= 1;
	hpnsAppStatistic->numOfCTViaOthers= 1;
	hpnsAppStatistic->numOfCTViaBadgeNoKey = 1;
	hpnsAppStatistic->numOfCTViaPopNoKey= 1;
	hpnsAppStatistic->numOfCTViaPopWithKey= 1;
	
	return 0;
}


