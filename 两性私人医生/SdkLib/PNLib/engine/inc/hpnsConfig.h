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

#ifndef __HPNS_USER_CONFIG_H__
#define __HPNS_USER_CONFIG_H__

#include "hpnsPlatform.h"
#include "hpnsMsg.h"
#include "header.h"

#define HPNS_RID_NUM  	3
#define HPNS_APP_STATUS_OFF          0
#define HPNS_APP_STATUS_ON           1
#define HPNS_APP_STATUS_BUNDLING     2
#define HPNS_MAX_NOTIFICATION_NUM    10
#define HPNS_MIN_STARTTIME_SECOND    1323000000        

#define HPNS_STATIC_DATA_NOT_UPLOAD    0
#define HPNS_STATIC_DATA_UPLOAD_PN     1
#define HPNS_STATIC_DATA_UPLOAD_STATIC 2

#define HPNS_STATIC_DATA_RETRY_SEC     1800

#define HPNS_AP_NAME_LEN               20
#define HPNS_MAX_AP_NUM                10
#define HPNS_MAX_CLEAN_FAILED_HBI_SEC  24*3600
#define HPNS_MAX_BUF_SIZE              1024

/*
#ifndef __FEATURE_PHONE__
#define __FEATURE_PHONE__
#endif
*/


typedef struct 
{
    UINT32   ip;
    UINT16   port;
} SHpnsIpAddr;

typedef struct {
    UINT8       pos;
    SHpnsIpAddr ipPort[HPNS_RID_NUM];
} SHpnsMruIp;

typedef struct{
	UINT32    appId;
	UINT8     senderId[HPNS_SENDER_LEN+1];
	UINT8     regId[HPNS_REGID_LEN];	
	INT32  	  recvId;
	UINT32    numOfCTViaNCWithKey;
	UINT32    numOfCTViaNCNoKey;
	UINT32    numOfCTViaPopWithKey; 
	UINT32    numOfCTViaPopNoKey; 
	UINT32    numOfCTViaBannerWithKey; 
	UINT32    numOfCTViaBannerNoKey; 
	UINT32    numOfCTViaMenuWithBadge; 
	UINT32    numOfCTViaBadgeNoKey;
	UINT32    numOfCTViaOthers; 
	UINT8     status;
	UINT8     numOfNoRsp;
	UINT8     updateFlag;
}SHpnsAppProfile;

typedef struct 
{       
    UINT16 	majorVersion;
    UINT16 	minorVersion; 
    UINT32 	protocolVersion;    
    UINT32 	deviceID; 
	UINT32 	lang;
	UINT32  sizeOfRAM;
	UINT32  sizeOfROM;
    UINT32  voiceCap;
    UINT32 	imageCap;
	UINT32  videoCap;
	UINT32  otherCap;
	UINT16 	hSize;       
    UINT16 	vSize;  
	UINT8  	imei[HPNS_IMEI_LEN];
	INT8   	chipSet[HPNS_CHIPSET_LEN];
	INT8    clientOs[HPNS_CLIENT_OS_LEN];
	INT8    MREVersion[HPNS_MRE_VERSION_LEN];
	INT8    MACAddr[HPNS_MAC_ADDRESS_LEN];
	UINT8  	imsi[HPNS_MAX_IMSI_NUM][HPNS_IMSI_LEN];
} SDeviceInfo;

typedef struct
{
	UINT8   name[HPNS_AP_NAME_LEN+1];
	UINT32  HBI;
	UINT32  lastFailedHBI;
	UINT32  failedTimestamp;
	UINT32  lastUsedTimestamp;
}SHpnsAPInfo;

typedef struct
{
	INT8   			numOfBundled;
	INT8            updateFlag;
    UINT8  			secret[HPNS_KEY_LEN];
	UINT8  			hid[HPNS_HID_LEN];
	UINT8           latitude[HPNS_LATITUDE_LEN];
	UINT8           longitude[HPNS_LONGITUDE_LEN];
	long   			recvBytes;
	long   			sendBytes;
	INT8   			logIndex;
	INT8            connMode;
	INT8   			heartbeat;
	INT8            PNOnOrOff;
	INT8            staticDataFlag;
	SHpnsMruIp 		mruIp;
	SDeviceInfo 	deviceInfo;
	SHpnsAppProfile appBundled[HPNS_MAX_BUNDLE_APP_NUM];
	SHpnsAPInfo     APInfo[HPNS_MAX_AP_NUM];
} SHpnsInfo;

extern int    	channelId;
extern int      hpnsDeviceID;
extern UINT32 	serverIp1;
extern UINT32 	serverIp2;
extern UINT32   mobileIp;
extern UINT16 	serverPort;
#ifdef __PNS_TCP_CONNECT_SUPPORT__
extern INT32    hpnsPushTcpFd;
extern UINT16   serverTcpPort;
#endif
extern char         hpnsSupportTcp;
extern int      	 hpnsMaxLogSize;
extern char   		 hpnsSystemDirectory[];
extern char   		 hpnsLogFlag;
extern char          pushNotificaitonFlag; 
extern SHpnsInfo  	 hpnsInfo;
extern unsigned char defaultHid[];
extern char          hpnsDomainName[];
extern UINT32        hpnsMinHBI;
extern UINT32        hpnsMaxHBI;
extern UINT8         hpnsStep;
extern SHpnsInfo     *phpnsInfo;
extern unsigned char hpnsTryDns;
extern UINT8         hpnsUdpStatus;


#define mruIp  hpnsInfo.mruIp
#define HPNS_MAX_POLL_LIST_INDEX   10

int hpnsSaveHpnsInfo(void);
int hpnsReadHpnsInfo(void);
int hpnsInitHpnsInfo(void);
int hpnsGetAPInfo(UINT8 apName[]);
int hpnsGetDeviceInfo(SDeviceInfo *deviceInfo);
int hpnsSetSystemDirectory(char* dir);



#endif

