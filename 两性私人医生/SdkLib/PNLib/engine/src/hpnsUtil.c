/******************************************************************* 
* Copyright (c) 2011 by Hesine Technologies, Inc. 
* All rights reserved. 
* 
* This file is proprietary and confidential to Hesine Technologies. 
* No part of this file may be reproduced, stored, transmitted, 
* disclosed or used in any form or by any means other than as 
* expressly provided by the written permission from Jianhui Tao 
* 
*******************************************************************/

#include "hpnsConfig.h"
#include "hpnsUtil.h"
#include "_semaphore.h"

HFILE  hpnsLogFd = 0;
int    hpnsLogFileSize = 0; 
void   *hpnsLogSem = 0;

int hpnsInitLog(void) 
{
	char name[HPNS_FILE_LEN]={0};

	if(hpnsLogSem == 0 )
		hpnsLogSem = _sem_init( "hpns_log", 1 );
	
	sprintf(name, "%s%shpns%d.log", hpnsSystemDirectory, HPNS_SLASH, hpnsInfo.logIndex);

	if(! hpnsFsFileExists( name ) )
	{
		hpnsLogFd = hpnsFsOpen(name, HPNS_FS_CREATE);
		if ( hpnsLogFd == 0 ) {
			nprintf ("failed to create log file:%s", name);
			goto _error;
		}
		
	} else {
	
		hpnsFsGetFileSizeWithName(name, &hpnsLogFileSize);	
		hpnsLogFd = hpnsFsOpen(name, HPNS_FS_READ_WRITE);
		if ( hpnsLogFd == 0 ) {
			nprintf ("failed to open log file:%s", name);
			goto _error;
		}
		hpnsFsSeek(hpnsLogFd, 0, HPNS_FS_FILE_END);		
	}

_error:
	
	if ( hpnsLogFileSize < 0 )
		hpnsLogFileSize = 0;

	return 0;
}

int hpnsCloseLog()
{
	if ( hpnsLogFd > 0 )
    {
        hpnsFsClose(hpnsLogFd);	
        hpnsLogFd = 0 ;
    }
    if(hpnsLogSem)
    {
        _sem_destroy(hpnsLogSem);
        hpnsLogSem = 0;
    }

	return 0;
}

void nprintf (char *format,...)
{
	va_list argpointer;

	char    buffer[HPNS_MAX_LOG_BUFFER] = {0};
	int     bufLen, bytesWrite;

	if(hpnsLogFlag == 0)
		return;
	
	if ( hpnsLogSem )
		_sem_post(hpnsLogSem);

	sprintf(buffer, "%s ", (char *)hpnsGetTimeStamp());

	va_start (argpointer, format);
	vsprintf (buffer + strlen(buffer), format, argpointer);
	va_end (argpointer);
	
	bufLen = strlen(buffer);
	buffer[bufLen] = '\n';
	buffer[bufLen+1] = 0;
	bufLen += 1;
	
	hpnsTrace(buffer);
	
	if ( hpnsLogFd )
	{ 
		hpnsFsWrite(hpnsLogFd, buffer, bufLen, &bytesWrite);
		hpnsFsFlush(hpnsLogFd);
	}

	hpnsLogFileSize += bufLen;	
	if ( hpnsLogFileSize >= hpnsMaxLogSize )
  	{
  		if ( hpnsLogFd )
	  		hpnsFsClose(hpnsLogFd);
		hpnsInfo.logIndex = 0x01^ hpnsInfo.logIndex;
		hpnsSaveHpnsInfo();

		sprintf(buffer, "%s%shpns%d.log", hpnsSystemDirectory, HPNS_SLASH, hpnsInfo.logIndex);
		hpnsLogFd = hpnsFsOpen(buffer, HPNS_FS_CREATE_ALWAYS);
		if ( hpnsLogFd == 0 )
			nprintf("failed to open log file:%s", buffer);
		hpnsLogFileSize = 0;
	}

	if ( hpnsLogSem)
		_sem_wait(hpnsLogSem);
  
}

void hpnsdump(char *msg, int len)
{
    int i, c=0;
    char dump[128];
    int nLen = len;

    dump[0] = 0;

    if ( nLen > 2048 ) 
        nLen = 2048;

    for (i = 0; i < nLen; ++i) 
    {
        sprintf(dump + 3 * c, "%02x ", msg[i]);
        c++;
        
        if ( c >= 16 ) 
        {
            nprintf ("%s", dump);
            c = 0;
        }
    }

    if ( c < 16 && c != 0)
        nprintf ("%s", dump); 
}

int hpnsByteArrayToHexStr(char bytes[], int bytesLen) 
{ 
	int i; 
	char hexval[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'}; 
	char *hexstr = hpnsMallocL(bytesLen*2);

	if(hexstr == NULL)
		return -1;

	for(i = 0; i < bytesLen; i++) 
	{ 
		hexstr[i*2] = hexval[((bytes[i] >> 4) & 0xF)]; 
		hexstr[(i*2) + 1] = hexval[(bytes[i]) & 0x0F]; 
	} 

	memcpy( bytes, hexstr, bytesLen*2);

	hpnsFreeL(hexstr);
	
	return 0; 
} 



