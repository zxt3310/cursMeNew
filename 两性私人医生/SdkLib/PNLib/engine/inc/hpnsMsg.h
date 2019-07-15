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

#ifndef _hpns_msg_header_
#define _hpns_msg_header_

#include "hpnsPlatform.h"

static const char hpnsMsgName[][20] = {
    "null",
    "login req",
    "login rsp",
    "reg req",
    "reg resp",
    "deliver",
    "deliver rsp",
    "heart beat",
    "null",
    "static data",
    "static data rsp",
    "detect req",
    "detect resp",
    "invalid"
};

// message type
#define HPNS_MSG_TYPE_LOGIN          1
#define HPNS_MSG_TYPE_LOGIN_RSP      2
#define HPNS_MSG_TYPE_REG            3
#define HPNS_MSG_TYPE_REG_RSP        4
#define HPNS_MSG_TYPE_DELIVER        5
#define HPNS_MSG_TYPE_DELIVER_RSP    6
#define HPNS_MSG_TYPE_HEART_BEAT     7
#define HPNS_MSG_TYPE_STATICDATA     9
#define HPNS_MSG_TYPE_STATICDATA_RSP 10
#define HPNS_MSG_TYPE_DETECT         11
#define HPNS_MSG_TYPE_DETECT_RSP     12
#define HPNS_MSG_TYPE_INVALID        13

// status code in reply message, 255 (-1) is reserved for internal purpose
#define HPNS_CODE_SUCCESS                    0
#define HPNS_CODE_LAST_SESSION_NOT_FINISHED  129
#define HPNS_CODE_INVALID_SESSION_ID         130
#define HPNS_CODE_INVALID_TRAN_ID            131
#define HPNS_CODE_INVALID_MSG_TYPE           132
#define HPNS_CODE_MAPI_ERROR                 133
#define HPNS_CODE_AUTH_FAILURE               135
#define HPNS_CODE_UNRECOGNIZED_IE            136
#define HPNS_CODE_WRONG_MSG_SIZE             137
#define HPNS_CODE_INVALID_TIME_STAMP         138
#define HPNS_CODE_MISS_TIME_STAMP            139
#define HPNS_CODE_MISS_MANDATORY_IE          140
#define HPNS_CODE_INVALID_ERROR_TYPE         141
#define HPNS_CODE_INVALID_IE                 143
#define HPNS_CODE_UNEXPECTED_RESPONSE        144
#define HPNS_CODE_INVALID_RESPONSE_TYPE      145

#define HPNS_CODE_INVALID_APPID			     151
#define HPNS_CODE_INVALID_SENDERID			 152
#define HPNS_CODE_INVALID_HID			 	 153
#define HPNS_CODE_WRONG_SERVER_IP            154
#define HPNS_CODE_DB_FAILURE                 155
#define HPNS_CODE_STATIC_DB_FAILURE          156
#define HPNS_CODE_SERVER_UNAVAILABLE         157


// information element ID
#define HPNS_IE_SESSION_ID        1
#define HPNS_IE_SOFTWARE_VERSION  2
#define HPNS_IE_DEVICE_OS         3
#define HPNS_IE_SECRET            5
#define HPNS_IE_REG_TIMER         6
#define HPNS_IE_SECURITY_FLAG     7
#define HPNS_IE_PUSH_IP           8
#define HPNS_IE_IMSI              9
#define HPNS_IE_TTL               10
#define HPNS_IE_IMEI              11
#define HPNS_IE_NMS_VERSION       12
#define HPNS_IE_PUBLISH_CHANNEL   13
#define HPNS_IE_LANGUAGE          14
#define HPNS_IE_CAPABILITIES      15
#define HPNS_IE_HID               16
#define HPNS_IE_DEVICE_ID         17
#define HPNS_IE_APP_ID            18
#define HPNS_IE_REG_INFO          19
#define HPNS_IE_SENDER_ID         20
#define HPNS_IE_KEY               21
#define HPNS_IE_MEMORY_CONFIG     22
#define HPNS_IE_SCREEN_INFO       23
#define HPNS_IE_LOCATION_INFO     24
#define HPNS_IE_MRE_VERSION       25
#define HPNS_IE_CHIPSET           26
#define HPNS_IE_APP_STATISTICS    27
#define HPNS_IE_CONN_MODE         28
#define HPNS_IE_APN_TYPE          29
#define HPNS_IE_UDP_STATUS        30

#define HPNS_IE_MAC_ADD           129
#define HPNS_IE_SOFTWARE_UPDATE   130
#define HPNS_IE_TCP_FLAG          131
#define HPNS_IE_MOB_IP			  255


//parameters define
#define HPNS_KEY_LEN             16
#define HPNS_IMSI_LEN            20
#define HPNS_IMEI_LEN            20
#define HPNS_CHIPSET_LEN         20
#define HPNS_CLIENT_OS_LEN       20
#define HPNS_MRE_VERSION_LEN     20
#define HPNS_MAC_ADDRESS_LEN     30
#define HPNS_AUTH_LEN            16
#define HPNS_LATITUDE_LEN        16
#define HPNS_LONGITUDE_LEN       HPNS_LATITUDE_LEN
#define HPNS_MAX_IMSI_NUM        4

//language
#define HPNS_LANGUAGE_ENGLISH_2          0x00010000
#define HPNS_LANGUAGE_CHINESE            0x00000000
#define HPNS_LANGUAGE_ENGLISH            0x00000001
#define HPNS_LANGUAGE_CHINESE_TW         0x00000002
#define HPNS_LANGUAGE_SPAIN	             0x00000003
#define HPNS_LANGUAGE_GERMANY            0x00000004
#define HPNS_LANGUAGE_RUSSIA  	         0x00000005
#define HPNS_LANGUAGE_THAILAND           0x00000006
#define HPNS_LANGUAGE_VIETNAM            0x00000007
#define HPNS_LANGUAGE_INDONESIA          0x00000008

//security flag
#define HPNS_SECURITY_FLAG_INVALID   0x80
#define HPNS_SECURITY_FLAG_OFF       0x00
#define HPNS_SECURITY_FLAG_ON        0x01

//udp status
#define HPNS_UDP_STATUS_DEFAULT               0
#define HPNS_UDP_STATUS_NORMAL                1
#define HPNS_UDP_STATUS_ABNORMAL              2
#define HPNS_UDP_STATUS_NTWKCHANGED           3

#pragma pack (1)

HPNS__packed typedef struct {
    UINT8   type;
    UINT32  value;
} SHpnsTypeLongIe;

HPNS__packed typedef struct {
    UINT8  	type;
    UINT16 	majorVersion;
    UINT16 	minorVersion;
}  SHpnsSoftwareVersionIe;

HPNS__packed typedef struct {
    UINT8  	type;
    UINT8  	imsi[HPNS_IMSI_LEN];
}  SHpnsImsiIe;

HPNS__packed typedef struct {
    UINT8  	type;
    UINT8  	imei[HPNS_IMEI_LEN];
}  SHpnsImeiIe;

HPNS__packed typedef struct {
    UINT8 	type;
    UINT8 	key[HPNS_KEY_LEN];
}  SHpnsKeyIe;

HPNS__packed typedef struct {
    UINT8  	type;
    UINT16 	hSize;
    UINT16 	vSize;
} SHpnsScreenInfoIe;

HPNS__packed typedef struct {
    UINT8  	type;
    UINT8   latitude[HPNS_LATITUDE_LEN];
    UINT8  	longitude[HPNS_LONGITUDE_LEN];
} SHpnsLocationInfoIe;

HPNS__packed typedef struct {
    UINT8   type;
    UINT32  voiceCap;
    UINT32 	imageCap;
	UINT32  videoCap;
	UINT32  otherCap;
} SHpnsCapabilitiesIe;

HPNS__packed typedef struct {
	UINT8 type;
	UINT32 appId; 
	UINT32 numOfCTViaNCWithKey;
	UINT32 numOfCTViaNCNoKey;
	UINT32 numOfCTViaPopWithKey; 
	UINT32 numOfCTViaPopNoKey; 
	UINT32 numOfCTViaBannerWithKey; 
	UINT32 numOfCTViaBannerNoKey; 
	UINT32 numOfCTViaMenuWithBadge; 
	UINT32 numOfCTViaBadgeNoKey;
	UINT32 numOfCTViaOthers;
} SHpnsAppStatisticsIe;

HPNS__packed typedef struct {
    UINT8  	type;
    UINT32 	RAMSize;
    UINT32 	ROMSize;
} SHpnsMemConfigIe;

HPNS__packed typedef struct {
    UINT8   type;
    UINT16  len;
    UINT8   pValue[1];
}  SHpnsTypeLenIe;

HPNS__packed typedef struct {
    UINT8   type;
    UINT32  ip;
    UINT16  port;
}  SHpnsIpAddrIe;

HPNS__packed typedef struct {
    UINT8   type;
    UINT32  appId;
	UINT8   regId[HPNS_REGID_LEN];
    UINT8   code;
}  SHpnsRegIDIe;

HPNS__packed typedef struct {
    UINT8   type;
    UINT32  appId;
    UINT8   len;
    UINT8   sender[1];
}  SHpnsAppSenderIe;

HPNS__packed typedef struct {
    UINT8  auth[HPNS_AUTH_LEN];
    UINT8  spi;
    UINT8  encrypt;
    UINT32 timeStamp;
    UINT8  type;
    UINT8  tranId;
    UINT32 sessionId;
	UINT32 localSessionId;
	UINT8  hid[HPNS_HID_LEN];
    UINT16 length;
    UINT8  content[1];
}   SHpnsMsgHeader;

HPNS__packed typedef struct {
    UINT8  code;
}  SHpnsResponse, SHpnsMsgReply;

HPNS__packed typedef struct 
{
    UINT32 appId;
	UINT32 msgId;
	UINT32 internalMsgId;
	UINT8  reserved;
    UINT8  content[1];
}  SHpnsDeliverHeader;

HPNS__packed typedef struct
{
    UINT32 appId;
	UINT32 msgId;
	UINT32 internalMsgId;
	UINT8  reserved;
    UINT8  code;
}  SHpnsDeliverRspHeader;

#pragma pack ()


#endif

