#define _GNU_SOURCE 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <pthread.h>
#include <sys/select.h>
#include "hpnsPlatform.h"
#include "hpnsUtil.h"
#include "tmodule.h"
#include "hpnsAppEngine.h"
#include "hpnsConfig.h"
#include "hpnsStm.h"
#include "hpnsHttpPost.h"
#include "httpDigest.h"
#include "ttimer.h"

#define tfree(x) { if ( x ) { free(x); x = 0; } }

extern int  hpnsEngineProcessMsgQueue(msg_t * param);
extern int  byteArrayToHexStr(char bytes[], int len, char hexstr[]) ;
extern void hpnsCleanUpTask();
extern int  hpnsInitTask();
extern int  hpnsUiProcessMsgQueue(msg_t *param);
extern int  hpnsInitUi(void *param);
extern void hpnsCleanUpUi();
extern UINT32 pushServerFd;
extern INT32  hpnsPushTcpFd;
module_t      moduleObj[8];
_sem_t*         udpsem;
int           maxCid = 100;
int           msgID = 1;

extern  int  notificationRespFlag ;

typedef struct{
	UINT8  type;
	UINT8  method[10];
	UINT8  realm[100];
	UINT8  nonce[100];
	UINT8  opaque[100];
	UINT8  qop[100];
	UINT8  uri[100];
	UINT8  cnonce[100];
	UINT8  response[100];
	UINT8  nc[9];
	UINT8  userName[100];
	UINT8  passwd[100];	
}SHpnsHTTPAuthInfo;

//http auth info
#define HTTP_AUTH_INFO_REALM        "realm"
#define HTTP_AUTH_INFO_NONCE        "nonce"
#define HTTP_AUTH_INFO_URI          "uri"
#define HTTP_AUTH_INFO_QOP          "qop"
#define HTTP_AUTH_INFO_NC           "nc"
#define HTTP_AUTH_INFO_CNONCE       "cnonce"
#define HTTP_AUTH_INFO_RESPONSE     "response"
#define HTTP_AUTH_INFO_OPAQUE       "opaque"
#define HTTP_AUTH_INFO_USERNAME     "username"

//method
#define HTTP_METHOD_POST            "POST"
#define HTTP_METHOD_GET             "GET"



void wcToMbc (char *out, WCHAR *input)
{
	char *t;

	t = (char *)input;

	while ( *t != 0 )
	{
		*out ++ = *t++;
		t++;
	}

	*out++ = 0;
}

void mbsToWc (WCHAR *output, char *input) 
{
	int  i;
	char *t;

	t = (char *)output;

	while ( *input != 0 )
	{
		*t++ = *input++;
		*t++ = 0;
	}

	*t++ =0;
	*t++ = 0;
}

#ifndef __PNS_TCP_CONNECT_SUPPORT__
int hpnsWaitForTcpPkt(msg_t *param) 
{ 	
	fd_set readFdSet; 
	int mFd = -1; 
	int ret=-1, i = 0;

	FD_ZERO(&readFdSet);

	struct timeval   timeout;
	timeout.tv_sec = 3;
	timeout.tv_usec = 1000;

	//sleep(1);
	//nprintf("TCP session msg Q recvd msg.");
	
	if(hpnsPushTcpFd != -1)
	{
		//nprintf("socket: %d in socket pool", hpnsPushTcpFd);
		FD_SET(hpnsPushTcpFd, &readFdSet); 
		if( mFd < hpnsPushTcpFd) 
		{
			mFd = hpnsPushTcpFd;
		}
	}

	if( -1 == mFd )
	{
		nprintf("nothing in TCP socket pool");
		return 0;
	}

	ret = select( mFd+1, &readFdSet, NULL, NULL, &timeout);

	if ( ret < 0 && errno == EINTR ) // send msg to self;
	{
		nprintf("select error, so continue.");
		taosSendMsgToModule( &(moduleObj[3]), 0, 0, 0, NULL);
	}

	if ( ret > 0 )
	{ 
		if( hpnsPushTcpFd != -1 && FD_ISSET(hpnsPushTcpFd, &readFdSet))
		{
			//nprintf("socket: %d can read.", hpnsPushTcpFd);
			hpnsSendMsgToEngine(HPNS_MSG_DATA_READ_IND, (UINT8 *)hpnsPushTcpFd, 0); 
			sleep(1);
			taosSendMsgToModule( &(moduleObj[3]), 0, 0, 0, NULL);
		}
	} 
	else if (ret == 0)
	{
		//nprintf("time out, select next time");
		sleep(1);
		taosSendMsgToModule( &(moduleObj[3]), 0, 0, 0, NULL);
	}
	else
	{
		if ( errno != EBADF )
		{
			nprintf ("TCP select error, reason:%s, so close all tcp socket.", strerror(errno));
			
			if(hpnsPushTcpFd != -1)
			{
				hpnsSendMsgToEngine(HPNS_MSG_NW_ERROR_IND, (UINT8 *)hpnsPushTcpFd, 0); 
			}
		}
		
	} 

	return 0;

} 

#else
int hpnsWaitForTcpPkt(msg_t *param)
{
    return 0;

}

#endif

int hpnsWaitForUdpPkt(msg_t *param) 
{ 
	fd_set testFdSet, fdSet; 
	unsigned long mFd, sockFd; 
	int ret=-1;

	sockFd = param->tid;
	
	if ( sockFd  ==  -1 ) return 0;
	
	nprintf ("UDP socket is openned by engine, fd:%d", sockFd); 

	FD_ZERO(&fdSet); 
	FD_SET(sockFd, &fdSet); 
	mFd = sockFd; 

	while ( 1 ) 
	{ 
		testFdSet = fdSet; 

		ret = select( mFd+1, &testFdSet, 0, 0, 0);

		if ( ret <0 && errno == EINTR ) continue;

		if ( ret > 0 )
		{ 
			nprintf("UDP socket :%d can read", sockFd);
			hpnsSendMsgToEngine(HPNS_MSG_DATA_READ_IND, (UINT8 *)sockFd, 0); 
			sleep(1);
		} else {
			if ( errno != EBADF)
			{
				nprintf ("UDP select error, reason:%s", strerror(errno));
				hpnsSendMsgToEngine(HPNS_MSG_NW_ERROR_IND, (UINT8 *)sockFd, 0);
			}
			break; 
		} 
	} 
    return 0;
} 



int hpnsProcessUdpPkt(msg_t *param)
{
	pthread_attr_t attr;
	pthread_t       nsThread;

	pthread_attr_init (&attr);

	if ( pthread_create(&nsThread, &attr, (void *)hpnsWaitForUdpPkt, (void *)param) != 0 ) 
	{
		nprintf("failed to create process udp thread");
		
	}
    return 0;
}

int hpnsInitUdp(void *param)
{
	return 0;
}

void hpnsCleanUpUdp()
{

	return;
}

int hpnsInitTcp(void *param)
{
	return 0;
}

void hpnsCleanUpTcp()
{

	return;
}

int hpnsInitEng(void *param)
{
	return 0;
}

int nmSystemInit() 
{
  int i;
  
  moduleObj[0].name = "MMI";
  moduleObj[0].queueSize = 50;
  moduleObj[0].processMsg = hpnsUiProcessMsgQueue;
  moduleObj[0].debugFlag = 3;
  moduleObj[0].init = hpnsInitUi; 
  moduleObj[0].cleanUp = hpnsCleanUpUi; 

  moduleObj[1].name = "UDP";
  moduleObj[1].queueSize = 50;
  moduleObj[1].processMsg = hpnsWaitForUdpPkt;
  moduleObj[1].debugFlag = 3;
  moduleObj[1].init = hpnsInitUdp; 
  moduleObj[1].cleanUp = hpnsCleanUpUdp;
  
  moduleObj[2].name = "ENG";
  moduleObj[2].queueSize = 50;
  moduleObj[2].processMsg = hpnsEngineProcessMsgQueue;
  moduleObj[2].debugFlag = 3;
  moduleObj[2].init = hpnsInitEng; 
  moduleObj[2].cleanUp = hpnsCleanUpTask; 

  moduleObj[3].name = "TCP";
  moduleObj[3].queueSize = 50;
  moduleObj[3].processMsg = hpnsWaitForTcpPkt;
  moduleObj[3].debugFlag = 3;
  moduleObj[3].init = hpnsInitTcp; 
  moduleObj[3].cleanUp = hpnsCleanUpTcp; 

  for (i=0; i<4; ++i) {
      moduleObj[i].queueSize = maxCid;
      if ( taosInitModule( &moduleObj[i] ) < 0 )  
        return -1; 
	  printf ("module:%s is initialized\n", moduleObj[i].name);
  }

  taosTmrInit (100, 500, 3600000);

  hpnsInitTask();

  return 0;
}

int nsHttpGetHeaderValue(char* pCont, UINT8 *value)
{
	if(!(pCont))
		return -1;

	char *pMsg = pCont;
	char *pStart = NULL, *pEnd = NULL;

	pStart = strchr(pMsg, '"');
	if(pStart == NULL)
	{
		pStart = strchr(pMsg, '=');
		if(pStart != NULL)
			pEnd = strchr(pMsg, ',');	
	}
	else
		pEnd = strchr(pStart+1, '"');	
	
	if(pStart == NULL || pEnd == NULL)
	{
		nprintf("failed to get value");
		return -1;
	}
	else
	{
		strncpy(value, pStart+1, pEnd - pStart - 1);
	}
	
	return 0;
}

int nsHttpGetAuthInfo(char* pMsgHeader, SHpnsHTTPAuthInfo *pHttpAuthInfo)
{
	if(!(pMsgHeader))
		return -1;

	const char *pMsg  = ( const char *)pMsgHeader;
	char *pCont = NULL;
	char ncStr[20] = {0};

	pCont = strcasestr(pMsg, (const char *)HTTP_AUTH_INFO_USERNAME);
	if(pCont)
		nsHttpGetHeaderValue(pCont, pHttpAuthInfo->userName);

	pCont = strcasestr(pMsg, (const char *)HTTP_AUTH_INFO_REALM);
	if(pCont)
		nsHttpGetHeaderValue(pCont, pHttpAuthInfo->realm);

	pCont = strcasestr(pMsg, (const char *)HTTP_AUTH_INFO_NONCE);
	if(pCont)
		nsHttpGetHeaderValue(pCont, pHttpAuthInfo->nonce);
	
	pCont = strcasestr(pMsg, (const char *)HTTP_AUTH_INFO_URI);
	if(pCont)
	nsHttpGetHeaderValue(pCont, pHttpAuthInfo->uri);
	
	pCont = strcasestr(pMsg, (const char *)HTTP_AUTH_INFO_CNONCE);
	if(pCont)
		nsHttpGetHeaderValue(pCont, pHttpAuthInfo->cnonce);

	pCont = strcasestr(pMsg, (const char *)HTTP_AUTH_INFO_RESPONSE);
	if(pCont)
		nsHttpGetHeaderValue(pCont, pHttpAuthInfo->response);

	pCont = strcasestr(pMsg, (const char *)HTTP_AUTH_INFO_OPAQUE);
	if(pCont)
		nsHttpGetHeaderValue(pCont, pHttpAuthInfo->opaque);

	nprintf("http auth info,method:%s, userName:%s, realm:%s, nonce:%s",pHttpAuthInfo->method, pHttpAuthInfo->userName,\
						pHttpAuthInfo->realm, pHttpAuthInfo->nonce);
	nprintf("url:%s, qop:%s, nc:%s, cnonce:%s, response:%s,opaque:%s",\
						pHttpAuthInfo->uri, pHttpAuthInfo->qop,\
						pHttpAuthInfo->nc, pHttpAuthInfo->cnonce, pHttpAuthInfo->response, pHttpAuthInfo->opaque);
	return 0; 
}


int hpnsSendMsgToNs(UINT32 appId, UINT8 password[], UINT8 msg[])
{
	int i =0, len, msgid = 0 ;
	char  *urlmsg = 0, *urluser = 0;
	char   buf[20000] = {0};
	SHpnsHTTPAuthInfo httpAuthInfo = {0};

	char  authInfo[1024] = {0};
	
	HASHHEX HA1;
	HASHHEX HA2 = "";
	HASHHEX Response;

	strcpy(httpAuthInfo.cnonce, "0a4f113b");
	strcpy(httpAuthInfo.method, "POST");
	strcpy(httpAuthInfo.nc, "00000001");
	strcpy(httpAuthInfo.qop, "auth");
	strcpy(httpAuthInfo.uri, "/index.html");
	strcpy(httpAuthInfo.userName, "test@126.com");
	strcpy(httpAuthInfo.passwd, password);
	
	
	for(i = 0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
	{
		if(hpnsInfo.appBundled[i].appId == appId && hpnsInfo.appBundled[i].status == 1)
		{
			break;
		}
	}

	if( i >= HPNS_MAX_BUNDLE_APP_NUM)
	{
		printf("failed to find app in app list");
		return -1;
	}

	strcpy(httpAuthInfo.userName, hpnsInfo.appBundled[i].senderId);
	
	char* params[10];
	int k;
	char  regStr[32] = {0};

	for(k = 0; k < 10; k++)
	{
		params[k] = calloc(1, 2000);
	}

	byteArrayToHexStr(hpnsInfo.appBundled[i].regId, 12, regStr);
	sprintf(params[0], "registration_id=%s", regStr);

	msgid = ++msgID;
	sprintf(params[1], "message_id=%d", msgid);

	sprintf(params[2], "expiry=300");

	urluser = urlencode((char const*)httpAuthInfo.userName, strlen(httpAuthInfo.userName), &len);
	sprintf(params[3],"sender_id=%s",urluser);

	urlmsg = urlencode((char const*)msg, strlen(msg), &len);
	sprintf(params[4], "payload=%s", urlmsg);


	char *ret = postURL("http://118.26.192.202:7568", NULL, NULL, NULL, 0, (char **)&buf, params, 5);
	//nprintf("post return buf:%s\n", buf);
	nprintf("post url return cont:%s\n", ret ? ret : " ");

	if(ret && strcasecmp(ret, "200 OK") == 0)
	{
		nprintf("send msg to ns successfully\n");
	}
	else
	{
		//nprintf("return header info:%s\n",buf );
		nsHttpGetAuthInfo(buf, &httpAuthInfo);
		DigestCalcHA1("md5",httpAuthInfo.userName, httpAuthInfo.realm, httpAuthInfo.passwd, httpAuthInfo.nonce, httpAuthInfo.cnonce, HA1);
		nprintf("HA1:%s", HA1);
		DigestCalcResponse(HA1, httpAuthInfo.nonce, httpAuthInfo.nc, httpAuthInfo.cnonce, httpAuthInfo.qop,\
			httpAuthInfo.method, httpAuthInfo.uri, HA2, Response);
		nprintf("response:%s", Response);

		sprintf(authInfo, "username=\"%s\",realm=\"%s\",nonce=\"%s\",uri=\"%s\",qop=\"%s\",nc=%s,cnonce=\"%s\",response=\"%s\",opaque=\"%s\"",\
			httpAuthInfo.userName, httpAuthInfo.realm, httpAuthInfo.nonce, httpAuthInfo.uri, httpAuthInfo.qop, httpAuthInfo.nc, httpAuthInfo.cnonce,\
			Response, httpAuthInfo.opaque);

		sprintf(params[0], "registration_id=%s", regStr);
		sprintf(params[1], "message_id=%d", msgid);
		sprintf(params[2], "expiry=300");
		sprintf(params[3], "payload=%s", urlmsg);
		
		ret = postURL("http://172.27.233.210:7568", NULL, NULL, authInfo, 0, (char **)&buf, params, 4);
		nprintf("post url return cont:%s\n", ret ? ret : " ");
		if(ret && strcasecmp(ret, "200 OK") == 0)
		{
			nprintf("send msg to ns successfully\n");
		}
	}

	for(k = 0; k < 10; k++)
	{
		tfree(params[k]);
	}

	return 0;
}


void requstToken(unsigned int appId, char senderId[])
{
	SHpnsRegInfo appprofile = {0};
	appprofile.appId = appId;
	strncpy(appprofile.senderId, senderId, HPNS_SENDER_LEN);
	hpnsSendMsgToEngine(HPNS_MSG_REG_REQ, (UINT8 *)(&appprofile), sizeof(SHpnsRegInfo));

	return;
}

void hpnsPrintUserInfo()
{
	UINT8 tempMsg[30] = {0};
	int   i = 0;
	unsigned char  *pIp;
	
	printf("========user info list=========\n");
	printf("number of bundled APP:%d,\n", hpnsInfo.numOfBundled);
	printf("mobile info update flag:%d,\n", hpnsInfo.updateFlag);

	memcpy(tempMsg, hpnsInfo.secret, HPNS_KEY_LEN);
	printf("message secret:%s,\n", tempMsg);

	memset(tempMsg, 0x0, 30);
	memcpy(tempMsg, hpnsInfo.latitude, HPNS_LATITUDE_LEN);
	printf("latitude of the mobile location:%s,\n", tempMsg);

	memset(tempMsg, 0x0, 30);
	memcpy(tempMsg, hpnsInfo.longitude, HPNS_LATITUDE_LEN);
	printf("longitude of the mobile location:%s,\n", tempMsg);

	printf("receive bytes:%ld, send bytes:%ld,\n", hpnsInfo.recvBytes, hpnsInfo.sendBytes);
	printf("log index:%d, poll index:%d, connection mode:%d\n", hpnsInfo.logIndex, hpnsInfo.heartbeat, hpnsInfo.connMode);
	printf("PN switch:%d, static data flag:%d,\n", hpnsInfo.PNOnOrOff, hpnsInfo.staticDataFlag);

	printf("\n");
	printf("+++PS IP list info, current pos:%d+++\n", mruIp.pos);
	printf("    IP             port\n");
	for(i = 0; i < HPNS_RID_NUM; i++)
	{
		if(mruIp.ipPort[i].ip == 0)
			continue;
		
		pIp = (unsigned char *)&(mruIp.ipPort[i].ip);
		printf("%d.%d.%d.%d     %d", pIp[0], pIp[1], pIp[2], pIp[3], hpnsHtons(mruIp.ipPort[i].port));
	}
	
	printf("\n");
	printf("------mobile info list------");
	printf("majorVersion:%d, minorVersion:%d, protocolVersion:%d \n", hpnsInfo.deviceInfo.majorVersion,  hpnsInfo.deviceInfo.minorVersion,  hpnsInfo.deviceInfo.protocolVersion);
	printf("deviceID:%u, language id:%u \n", hpnsInfo.deviceInfo.deviceID, hpnsInfo.deviceInfo.lang);
	printf("sizeOfRAM:%u, sizeOfROM:%u \n", hpnsInfo.deviceInfo.sizeOfRAM, hpnsInfo.deviceInfo.sizeOfROM);
	printf("hSize:%u, vSize:%u \n", hpnsInfo.deviceInfo.hSize, hpnsInfo.deviceInfo.vSize);
	printf("videoCap:%u, imageCap:%u, voiceCap:%u, otherCap:%u \n", hpnsInfo.deviceInfo.videoCap, hpnsInfo.deviceInfo.imageCap, hpnsInfo.deviceInfo.voiceCap, hpnsInfo.deviceInfo.otherCap);
	
	memset(tempMsg, 0x0, 30);
	memcpy(tempMsg, hpnsInfo.deviceInfo.chipSet, HPNS_CHIPSET_LEN);
	printf("mobile chipset:%s,\n", tempMsg);

	memset(tempMsg, 0x0, 30);
	memcpy(tempMsg, hpnsInfo.deviceInfo.imei, HPNS_IMEI_LEN);
	printf("mobile IMEI:%s,\n", tempMsg);

	memset(tempMsg, 0x0, 30);
	memcpy(tempMsg, hpnsInfo.deviceInfo.clientOs, HPNS_CLIENT_OS_LEN);
	printf("mobile OS:%s,\n", tempMsg);

	memset(tempMsg, 0x0, 30);
	memcpy(tempMsg, hpnsInfo.deviceInfo.MACAddr, 30);
	printf("mobile MAC address:%s,\n", tempMsg);

	memset(tempMsg, 0x0, 30);
	memcpy(tempMsg, hpnsInfo.deviceInfo.MREVersion, HPNS_MRE_VERSION_LEN);
	printf("mobile MRE version:%s,\n", tempMsg);

	for(i=0; i< HPNS_MAX_IMSI_NUM; i++)
	{
		if(hpnsInfo.deviceInfo.imsi[i][0]== 0)
			continue;

			
		memset(tempMsg, 0x0, 30);
		memcpy(tempMsg, hpnsInfo.deviceInfo.imsi[i], HPNS_IMSI_LEN);
		printf("IMSI index:%d, IMSI:%s\n", i, tempMsg);
	}
	
	printf("\n====appId====== senderId ========status======regId===========\n");
	char regstr[30] = {0};
	for(i = 0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
	{

		if(hpnsInfo.appBundled[i].appId != 0)
		{
			hpnsMemCpy( regstr, hpnsInfo.appBundled[i].regId, HPNS_REGID_LEN);
			hpnsByteArrayToHexStr(regstr, HPNS_REGID_LEN);
			printf("    %d         %s        %d    %s\n",hpnsInfo.appBundled[i].appId,\
				hpnsInfo.appBundled[i].senderId, hpnsInfo.appBundled[i].status, regstr);
		}

	}
	
	printf("\n");
	printf("======access point info list======\n");
	printf("APName        HBI       lastFailedHBI      failedTimeStamp     lastUsedTimeStamp\n");
	for(i = 0; i < HPNS_MAX_AP_NUM; i++)
	{
		if( hpnsInfo.APInfo[i].name[0] != 0)
		{
			printf("%s        %u            %u            %u            %u", hpnsInfo.APInfo[i].name,hpnsInfo.APInfo[i].HBI, hpnsInfo.APInfo[i].lastFailedHBI, hpnsInfo.APInfo[i].failedTimestamp, hpnsInfo.APInfo[i].lastUsedTimestamp);
		}
	}

}

int mains (int argc, char *argv[])
{
	char     c;
	SHpnsRegInfo appprofile = {0};
	UINT32     newIp;
	UINT32   appId = 0, i = 0, ret;
	char     msg[1024] = {0}, password[36] = {0};
	UINT8    regid[12]= {0};
	UINT16 majorVer = 0, minorVer = 0 ;
	UINT32 connstatus = 0;
	char   hidstr[16] = {0}, regIdStr[25] = {0};

	if ( nmSystemInit() < 0 )
	{
		printf ("failed to initialize system, exit\n");
		exit(0);
	}
	
	c = 1;
	
	while ( 1 )
	{
		switch ( c ) 
		{
		
		case 'a':
			
			printf("Please input your appId:\n");
			scanf("%d",&(appprofile.appId));
			printf("Please input your app sender id:\n");
			scanf( "%s", appprofile.senderId);
			printf("appId:%d  senderId:%s\n", appprofile.appId, appprofile.senderId );
			hpnsSendMsgToEngine(HPNS_MSG_REG_REQ, (UINT8 *)(&appprofile), sizeof(SHpnsRegInfo));
			break;
			
		case 'b':
			printf("Please input your appId:\n");
			scanf("%d",&appId);
			nprintf("unbind appid:%d", appId);
			hpnsSendMsgToEngine(HPNS_MSG_UNREG_REQ, (UINT8 *)appId, 0);
			break;
			
		case 'c':
			printf("send a notification to ns,please input appId\n");
			scanf("%d",&appId);
			printf("please input developer password\n");
			scanf("%s",password);
			printf("please input your msg\n");
			scanf("%s",msg);
			printf("appId:%d, msg:%s\n", appId, msg);
			hpnsSendMsgToNs(appId, password, msg);
			break;

		case 'd':
			memset(&appprofile, 0x0, sizeof(SHpnsRegInfo));
			printf("Please input second appId:\n");
			scanf("%d",&(appprofile.appId));
			printf("Please input second app sender id:\n");
			scanf( "%s", appprofile.senderId);
			printf("appId:%d  senderId:%s\n", appprofile.appId, appprofile.senderId );
	
			hpnsSendMsgToEngine(HPNS_MSG_REG_REQ, (UINT8 *)(&appprofile), sizeof(SHpnsRegInfo));

			appprofile.appId = 1;
			strcpy(appprofile.senderId, "xitang@126.com");
			hpnsSendMsgToEngine(HPNS_MSG_REG_REQ, (UINT8 *)(&appprofile), sizeof(SHpnsRegInfo));
			break;

		case 'e':
			printf("Please input error your appId:\n");
			scanf("%d",&appId);

			hpnsSendMsgToEngine(HPNS_MSG_UNREG_REQ, (UINT8 *)appId, 0);
			break;

		case 'f':
			memset(&appprofile, 0x0, sizeof(SHpnsRegInfo));
			appprofile.appId = 2;
			hpnsSendMsgToEngine(HPNS_MSG_REG_REQ, (UINT8 *)(&appprofile), sizeof(SHpnsRegInfo));
			break;

		case 'g':
			appprofile.appId = 100;
			hpnsSendMsgToEngine(HPNS_MSG_REG_REQ, (UINT8 *)(&appprofile), sizeof(SHpnsRegInfo));
			break;

		case 'h':
			hpnsSendMsgToEngine(HPNS_MSG_UNREG_REQ, (UINT8 *)2, 0);
			break;

		case 'r':
			printf("Please input mobile IP(eg:0x0A000012):\n");
			scanf("%x",&mobileIp);
			printf("you input mobile ip is 0x%x:\n", mobileIp);
			hpnsSendMsgToEngine(HPNS_MSG_CHANGE_CONNECT_MODE, (UINT8 *)0, 0);
			break;

		case 'R':
			printf("Please input server IP(eg:0x0A000012):\n");
			scanf("%x",&(newIp));
			mruIp.ipPort[0].ip = hpnsHtonl(newIp);  
			mruIp.ipPort[0].port =  hpnsHtons(serverPort);
			printf("you input mobile ip is 0x%x:\n", newIp);
			hpnsSendMsgToEngine(HPNS_MSG_CHANGE_CONNECT_MODE, (UINT8 *)0, 0);
			break;
		
		case 'l':
			printf("\n====appId====== senderId ========status======regId===========\n");
			char regstr[30] = {0};
			for(i = 0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
			{

				if(hpnsInfo.appBundled[i].appId != 0)
				{
					hpnsMemCpy( regstr, hpnsInfo.appBundled[i].regId, HPNS_REGID_LEN);
					hpnsByteArrayToHexStr(regstr, HPNS_REGID_LEN);
					printf("    %d         %s        %d    %s\n",hpnsInfo.appBundled[i].appId,\
						hpnsInfo.appBundled[i].senderId, hpnsInfo.appBundled[i].status, regstr);
				}

			}
			break;

		case 'L':
			hpnsPrintUserInfo();
			break;

		case 's':
			printf("suspend push notification\n");
			hpnsSendMsgToEngine(HPNS_MSG_PUSH_NOTIFICATION_SWITCH, (UINT8 *)HPNS_PUSH_NOTIFICATION_OFF, 0);
			break;

		case 'o':
			printf("resume push notification\n");
			hpnsSendMsgToEngine(HPNS_MSG_PUSH_NOTIFICATION_SWITCH, (UINT8 *)HPNS_PUSH_NOTIFICATION_ON, 0);
			break;

		case 'p':
			printf("change connection mode to polling mode\n");
			hpnsSendMsgToEngine(HPNS_MSG_CHANGE_CONNECT_MODE, (UINT8 *)((HPNS_NCM_POLL<<16)+3), 0);
			break;
			
		case 'M':
			printf("change connection mode to manual mode\n");
			hpnsSendMsgToEngine(HPNS_MSG_CHANGE_CONNECT_MODE, (UINT8 *)(HPNS_NCM_MANUAL<<16), 0);
			break;

		case 'P':
			printf("change connection mode to auto\n");
			hpnsSendMsgToEngine(HPNS_MSG_CHANGE_CONNECT_MODE, (UINT8 *)(HPNS_NCM_AUTO<<16), 0);
			break;

		case 'v':
			hpnsApiGetConfigInfo( &majorVer, &minorVer, &connstatus, hidstr);
			printf("the mobile Hid is %s, hpsn version:%d.%d, connection status:%d\n", hidstr, majorVer, minorVer, connstatus);
			break;

		case 'q':
			printf("Please input appId that wants to query:\n");
			scanf("%d",&appId);
			ret = hpnsApiQueryAppViaAppId(appId, regIdStr, 24 );
			if(ret == 0)
				printf("query successfully, appId:%d, regID:%s\n", appId, regIdStr);
			else
				printf("this app has not been registered in HPNs\n");
			
			break;

		case 'B':
			printf("stop sending notification resp to PE\n");
			notificationRespFlag = 1;
			break;

		case 'A':
			printf("start sending notification resp to PE\n");
			notificationRespFlag = 0;
			break;
		case 'C':
			printf("change network on, apn is vifi");
			hpnsSendMsgToEngine(HPNS_MSG_NETWORK_STATE_CHANGED, (UINT8 *)((1<<16)+1), 0);
			break;

		case 'D':
			printf("change network on, apn is gprs");
			hpnsSendMsgToEngine(HPNS_MSG_NETWORK_STATE_CHANGED, (UINT8 *)((1<<16)+2), 0);
			break;

		case 'E':
			printf("change network off");
			hpnsSendMsgToEngine(HPNS_MSG_NETWORK_STATE_CHANGED, (UINT8 *)(2<<16), 0);
			break;

		case 'F':
			printf("upload the device info");
			hpnsSendMsgToEngine(HPNS_MSG_UPLOAD_STATIC_DATA, (UINT8 *)1, 0);
			break;

		case 'G':
			printf("not upload the device info");
			hpnsSendMsgToEngine(HPNS_MSG_UPLOAD_STATIC_DATA, (UINT8 *)0, 0);
			break;
			
		case 'x':
			printf ("thanks for using HPNs linux version\n");
			exit(0);
			
		case 'm':
			printf("\n========HPNs linux version======\n");

			printf("a: boundle a application\n");
			printf("b: unbundle a application\n");
			printf("c: send a notification\n");
			printf("l: list all app in app list\n");
			printf("r: change mobole ip to redirect\n");
			printf("R: change PS IP to redirect\n");
			printf("s: suspend push notification\n");
			printf("o: resume push notification\n");
			printf("v: get hpns config info\n");
			printf("q: query regId from PE via appID\n");
			printf("p: change to polling connect mode\n");
			printf("P: change to auto connect mode\n");
			printf("M: change to manual connect mode\n");

			printf("B: stop sending notification resp to PE\n");
			printf("A: start sending notification resp to PE\n");
			printf("C: change network on, use vifi\n");
			printf("D: change network on, use gprs\n");
			printf("E: change network off\n");
			printf("F: upload device info\n");
			printf("G: not upload device info\n");
			printf("L: print all user info\n");
			printf("\n");
			printf("x: exit hesine linux version\n");
			printf("\n\n");
			break;
			
		default:
			
			break;
			
		}

		c = getchar();
	}	

}



