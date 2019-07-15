#ifndef _HPNS_APP_ENGINE_H_
#define _HPNS_APP_ENGINE_H_

#include "hpnsPlatform.h"


enum {
	HPNS_MSG_REG_REQ,
	HPNS_MSG_REG_RSP,
	HPNS_MSG_UNREG_REQ,
	HPNS_MSG_UNREG_RSP,	
	HPNS_MSG_REGID_CHANGED_NOTIFICATION,
	HPNS_MSG_NOTIFICATION,
	HPNS_MSG_NOTIFICATION_RSP,
	HPNS_MSG_PUSH_NOTIFICATION_SWITCH,
	HPNS_MSG_CHANGE_CONNECT_MODE,
	HPNS_MSG_NETWORK_STATE_CHANGED,
	HPNS_MSG_UPLOAD_STATIC_DATA,
	HPNS_MSG_DATA_READ_IND, // engine internal, but platform shall provide it
	HPNS_MSG_DATA_WRITE_IND,// engine internal, but platform shall provide it
	HPNS_MSG_NW_ERROR_IND,  // engine internal, but platform shall provide it
	HPNS_MSG_MAX
}; 

typedef struct {
	UINT32 appId;
	UINT8  senderId[HPNS_SENDER_LEN];
	UINT8  regId[HPNS_REGID_LEN*2];
	UINT8  appCode;
	UINT8  payload[1];
}SHpnsRegInfo;

typedef struct{
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
}SHpnsAppStatistics;

extern  char *hpnsAppEngineMsg[];
extern  unsigned short  hpnsPollingTimeList[];

#define HPNS_PUSH_NOTIFICATION_ON         1
#define HPNS_PUSH_NOTIFICATION_OFF        2

#define HPNS_NETWORK_STATE_ON             1
#define HPNS_NETWORK_STATE_OFF            2

#define HPNS_NCM_MANUAL                   1
#define HPNS_NCM_POLL                     2
#define HPNS_NCM_AUTO                     3

#define HPNS_APN_DEFAULT                  0
#define HPNS_APN_WIFI                     1
#define HPNS_APN_GPRS                     2
#define HPNS_APN_WCDMA                    3
#define HPNS_APN_INTERNAL                 4



#define HPNS_SERVICE_NOT_AVAILABLE       100
#define HPNS_TOO_MANY_REGISTRATIONS      101
#define HPNS_INVALID_DATA_CONNECTION     102
#define HPNS_LAST_MSG_ON_PROCESSING      103 
#define HPNS_SYSTEM_ERROR                104
#define HPNS_PUSH_NOTIFICATION_SUSPEND   105

#define HPNS_INVALID_APPID               151
#define HPNS_INVALID_SENDER              152


int   hpnsSendMsgToEngine(int mid, UINT8 *pMsg, int msgLen); 
int   hpnsSendMsgToUI(int mid, UINT8 *pMsg, int msgLen); 
int   hpnsInitTask(void);
int   hpnsGetAppStatisticsInfo(SHpnsAppStatistics  *hpnsAppStatistic);
int   hpnsApiQueryAppViaAppId(UINT32 appId, char regId[], UINT32 regIdLen);
int   hpnsApiGetConfigInfo(UINT16 *majorVersion, UINT16 *minorVersion, UINT32 *connStatus, char hidstr[]);
int   hpnsApiGetPushServiceStatus(void);
int   hpnsApiChangeNetworkStatusOn(UINT32 apnType);
int   hpnsApiChangeNetworkStatusOff(void);
int   hpnsStaticDataSendBack(UINT8 flag);




#endif

