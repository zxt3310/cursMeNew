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

#include "hpnsPlatform.h"
#include "hpnsConfig.h"
#include "hpnsUtil.h"
#include "hpnsAppEngine.h"

int    channelId = 805766018;//0x00000000;
int    hpnsDeviceID = 1234;
int    hpnsMaxLogSize = 1024*1024*10;
char   hpnsSystemDirectory[256] = ".";
char   imsiPreFixed[4] = "666";
char   pushNotificaitonFlag = 1;
char   hpnsLogFlag = 1;
unsigned char   hpnsTryDns = 0;
unsigned char   defaultHid[HPNS_HID_LEN]= {0};
unsigned short  hpnsPollingTimeList[10] = {5, 10, 15, 30, 60, 120, 180, 240, 0, 0};

#ifdef __FEATURE_PHONE__
	char hpnsSupportTcp = 0;
#else
	char hpnsSupportTcp = 1;
#endif

//118.26.192.178 :(0x761AC0B2)   114.242.137.251:(0x72F289FB);  118.26.192.194(0x761AC0C2)  118 0xAC1BE976
//118.26.192.179 :(0x761AC0B3)	  114.242.137.252:(0x72F289FC)	118.26.192.195(0x761AC0C3)  202 0x761AC0CA
UINT32 serverIp1 = 0x36DFDA79, serverIp2 = 0x36DFE631;
UINT32 mobileIp = 0x0A000012;
UINT16 serverPort = 2502;
UINT16 serverTcpPort = 80;

int hpnsSetSystemDirectory(char* dir) {
    strcpy(hpnsSystemDirectory, dir);
    return 0;
}


int hpnsGetDeviceInfo(SDeviceInfo *deviceInfo)
{	
	UINT8   tmpImsiPre[7] = {0};
	int     i = 0;
		
	memset (deviceInfo, 0, sizeof(deviceInfo));
	
    deviceInfo->majorVersion = 4;
    deviceInfo->minorVersion = 0;
    deviceInfo->protocolVersion = 7;
	deviceInfo->deviceID = hpnsDeviceID;
	deviceInfo->lang = hpnsGetMobileLanguage();
	
	hpnsGetOSInfo(deviceInfo->clientOs);
	hpnsGetChipSet(deviceInfo->chipSet);
	hpnsGetMREVersionInfo(deviceInfo->MREVersion);
	hpnsGetMACAddress(deviceInfo->MACAddr);
	hpnsGetImsiImei(deviceInfo->imsi, deviceInfo->imei);
	hpnsGetDisplayMetrics(&(deviceInfo->hSize), &(deviceInfo->vSize));
	hpnsGetMemoryConfig(&(deviceInfo->sizeOfRAM), &(deviceInfo->sizeOfROM));
	hpnsGetCapabilities(&(deviceInfo->voiceCap), &(deviceInfo->videoCap), &(deviceInfo->imageCap), &(deviceInfo->otherCap));

	/*for(i = 0; i < HPNS_MAX_IMSI_NUM; i++)
	{
		if(hpnsInfo.deviceInfo.imsi[i][0] != 0)
		{
			hpnsMemSet(tmpImsiPre, 0x0, sizeof(tmpImsiPre));
			hpnsMemCpy(tmpImsiPre, hpnsInfo.deviceInfo.imsi[i], 6);

			hpnsMemSet(hpnsInfo.deviceInfo.imsi[i], 0x0, HPNS_IMSI_LEN);
			sprintf((char *)hpnsInfo.deviceInfo.imsi[i], "%s%05d%04d", tmpImsiPre, (hpnsGetSystemTime()-HPNS_MIN_STARTTIME_SECOND)%100000, rand()%10000);
		}
	}*/
	
    return 0;
}

int hpnsInitHpnsInfo(void)
{		
	UINT32  seed = 0, second = 0, i = 0;
	
	memset(&hpnsInfo, 0, sizeof(hpnsInfo));

	mruIp.ipPort[0].ip = hpnsHtonl(serverIp1);  
	mruIp.ipPort[0].port =  hpnsHtons(serverPort);
	mruIp.ipPort[1].ip = hpnsHtonl(serverIp2); 
	mruIp.ipPort[1].port =  hpnsHtons(serverPort);	

	hpnsInfo.heartbeat = 0;
	hpnsInfo.connMode  = HPNS_NCM_AUTO;
	hpnsInfo.updateFlag = 1;
	hpnsInfo.PNOnOrOff = pushNotificaitonFlag;
	hpnsInfo.staticDataFlag = HPNS_STATIC_DATA_UPLOAD_PN;
	hpnsGetDeviceInfo(&(hpnsInfo.deviceInfo));
	hpnsGetLocationInfo(hpnsInfo.latitude, hpnsInfo.longitude);

	
	if(hpnsInfo.deviceInfo.imsi[0][0] == 0)
	{
		second = (hpnsGetSystemTime()-HPNS_MIN_STARTTIME_SECOND)%1000000;
		seed = hpnsGetUsecTime()%1000;
		srand(seed); 
		sprintf((char *)hpnsInfo.deviceInfo.imsi[0], "%s%06d%03d%03d", imsiPreFixed, second, seed, rand()%1000); //3c+6s+3us+3rand
	}

	memcpy(hpnsInfo.secret, hpnsInfo.deviceInfo.imsi[0], sizeof(hpnsInfo.secret)); 
	
	return 0;	
}

int hpnsSaveHpnsInfo(void)
{

	char fileName[HPNS_FILE_LEN];
	HFILE hFile;
	int  bytesToWrite, bytesWritten;
	int  ret = -1;

	sprintf(fileName, "%s%suser.cfg", hpnsSystemDirectory, HPNS_SLASH); 
	hFile = hpnsFsOpen(fileName, HPNS_FS_CREATE_ALWAYS);
	if ( hFile == 0 ) {
		nprintf ("failed to save user info, unable to open the file:%s", fileName);
		goto _error;
	}

	bytesToWrite = sizeof(hpnsInfo);
	hpnsFsWrite(hFile, &hpnsInfo, bytesToWrite, &bytesWritten);

	if ( bytesToWrite != bytesWritten)
	{
		nprintf ("failed to write the user info to:%s", fileName);
		goto _error;
	}

	ret = 0;
	
_error:
	if ( hFile )
		hpnsFsClose(hFile);
	
	return ret;
}

int hpnsReadHpnsInfo(void)
{
	char  fileName[HPNS_FILE_LEN];
	HFILE hFile = 0;
	int   bytesToRead, bytesRead;
	int   ret = -1, i = 0;
	int   fileSize, numOfBundled = 0;

	sprintf(fileName, "%s%suser.cfg", hpnsSystemDirectory, HPNS_SLASH); 

	if ( !hpnsFsFileExists(fileName) )
	{
		nprintf ("user info file:%s not there, set to default", fileName);
		return -1;
	}

	hpnsFsGetFileSizeWithName(fileName, &fileSize);
	if ( fileSize != sizeof(hpnsInfo))
	{
		nprintf("file size is messed up for file:%s", fileName);
		return -1;
	}
	
	hFile = hpnsFsOpen(fileName, HPNS_FS_READ);
	if ( hFile == 0 ) {
		nprintf ("failed to open the user info file:%s", fileName);
		goto _error;
	}

	bytesToRead = sizeof(hpnsInfo);
	hpnsFsRead(hFile, &hpnsInfo, bytesToRead, &bytesRead);

	if ( bytesToRead != bytesRead)
	{
		nprintf ("failed to read the user info from:%s", fileName);
		goto _error;
	}

	for(i=0; i < HPNS_MAX_BUNDLE_APP_NUM; i++)
	{
		if( hpnsInfo.appBundled[i].appId != 0 && \
			( hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_OFF || hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_BUNDLING ))
			hpnsMemSet(&(hpnsInfo.appBundled[i]), 0x0, sizeof(SHpnsAppProfile) );

		if( hpnsInfo.appBundled[i].appId != 0 && hpnsInfo.appBundled[i].status == HPNS_APP_STATUS_ON )
			numOfBundled ++;
	}

	hpnsInfo.numOfBundled = numOfBundled;
	ret = 0;
		
_error:
	if ( hFile )
		hpnsFsClose(hFile);

	return ret;
	
}

int hpnsGetAPInfo(UINT8 apName[])
{
	int    index = -1, i = 0, oldIndex = -1;
	UINT32 oldTime = 0;

	for(i = 0; i < HPNS_MAX_AP_NUM; i++)
	{
		if(0 == memcmp(hpnsInfo.APInfo[i].name, apName, HPNS_AP_NAME_LEN))
			break;
			
		if(hpnsInfo.APInfo[i].name[0] == 0)
			oldIndex = i;
	}

	if ( i < HPNS_MAX_AP_NUM )
	{ 
		index = i;
	} 
	else
	{
		if(oldIndex < 0) 
		{
			oldTime  = hpnsInfo.APInfo[0].lastUsedTimestamp;
			oldIndex = 0;
			for(i = 1; i < HPNS_MAX_AP_NUM; i++)
			{
				if( hpnsInfo.APInfo[i].lastUsedTimestamp < oldTime )
				{
					oldTime = hpnsInfo.APInfo[i].lastUsedTimestamp;
					oldIndex = i;
				}
			}
		}
		
		index = oldIndex;
		memset(&(hpnsInfo.APInfo[oldIndex]), 0x0, sizeof(SHpnsAPInfo));
		memcpy(hpnsInfo.APInfo[oldIndex].name, apName, strlen((const char *)apName) > HPNS_AP_NAME_LEN ? HPNS_AP_NAME_LEN:strlen((const char *)apName));
		hpnsInfo.APInfo[oldIndex].HBI = hpnsMinHBI;
	}
	
	hpnsInfo.APInfo[i].lastUsedTimestamp = hpnsGetSystemTime();
	hpnsSaveHpnsInfo();

	return index;
}



