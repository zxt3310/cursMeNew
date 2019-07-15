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
#ifndef __HPNS_PLATFORM_H__
#define __HPNS_PLATFORM_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#define UINT32   unsigned int
#define INT32    int
#define UINT16   unsigned short
#define INT16    short
#define INT8     char
#define UINT8    unsigned char
#define TCHAR    unsigned short
#define S8       char
#define U8       UINT8
#define U32      UINT32 

//#ifdef __arm
//	#define  S64      long long
//	#define  HPNS__packed __packed
//#else
	#define  S64 	 long
	#define  HPNS__packed 
//#endif

#ifndef WCHAR
#define WCHAR  unsigned short
#endif

#define HPNS_FILE_LEN           256
#define HPNS_DIRECTORY_LEN      40
#define HPNS_MAX_LOG_BUFFER     256
#define HPNS_SENDER_LEN         36
#define HPNS_REGID_LEN          12
#define HPNS_HID_LEN            8
#define HPNS_MAX_BUNDLE_APP_NUM 20

#define HPNS_SLASH              "/"

/**************************************************************************************

                             ===========memory operation API==============
              
***************************************************************************************/
/*=============================================
* function: hpnsMallocL(IN UINT32 size)
* note: 
*	1. it is used to apply for memory, memory size is the parameters
*     2. It returns a pointer that point to the memory address.
*	
==============================================*/
void   *hpnsMallocL(UINT32 size);

/*=============================================
* function: hpnsFreeL(IN void* pMem)
* note: 
*	1. it is used to free the memory that has been allocated.
*	
==============================================*/
void    hpnsFreeL(void* pMem);

#define hpnsMemSet     memset
#define hpnsMemCpy     memcpy

/**************************************************************************************

                             ===========message queue API==============
              
***************************************************************************************/
/*=============================================
* function: hpnsSendMsgToEngineP(IN int mid, IN UINT8 *pMsg, IN int msgLen)
* note: 
*	1. it is used to send a message to Engine
*	2. In the parameters, mid is the message ID, pMsg is message 
*	     content, msgLen is message length.
*	
==============================================*/
int   hpnsSendMsgToEngineP(int mid, UINT8 *pMsg, int msgLen) ;

/*=============================================
* function: hpnsSendMsgToUIP(IN int mid, IN UINT8 *pMsg, IN int msgLen)
* note: 
*	1. it is used to send a message to UI
*     2. parameters is similar to hpnsSendMsgToEngineP().
*	
==============================================*/
int   hpnsSendMsgToUIP(int mid, UINT8 *pMsg, int msgLen) ; 

UINT32 hpnsHtonl(UINT32 x);
UINT32 hpnsNtohl(UINT32 x);
UINT16 hpnsHtons(UINT16 x);
UINT16 hpnsNtohs(UINT16 x);


/**************************************************************************************

                             ===========file operation API==============
              
***************************************************************************************/

typedef unsigned int           HFILE;

#define HPNS_FS_CREATE          0x00010000L
#define HPNS_FS_CREATE_ALWAYS   0x00020000L
#define HPNS_FS_READ            0x00000100L
#define HPNS_FS_READ_WRITE      0x00000000L

/*================================================
* function: hpnsFsOpen(IN char *name, IN UINT32 flag)
* note: 
*	1. it is used to open a file
*	2. In the parameters,  name is file name, flag refers to above definitions.
*	3. it returns file handle, and if error happens, return 0
*	
=================================================*/
HFILE   hpnsFsOpen(char *name,  UINT32 flag);

/*============================================================
* function: hpnsFsRead(IN HFILE hFile, OUT void *pData, IN int nLen, OUT int *Read);
* note: 
*	1. it is used to read from file
*	2. In the parameters, hFile is file handle, pData is a pointer that the read contents 
*	write to, len is the content length need to read, * read is the actual bytes being read, 
*	and it is the same to return number
*	
=============================================================*/
int     hpnsFsRead(HFILE hFile, void *pData, int nLen, int *Read);

/*============================================================
* function: hpnsFsWrite(IN HFILE hFile, IN void *pData, IN int nLen, OUT int *Written)
* note: 
*	1. it is used to write to file
*	2. In the parameters, hFile is file handle, pData is a pointer that the contents which want to 
*	write, len is the content length need to be written, * Written is the actual bytes being written, 
*	and it is the same to return number
*	
=============================================================*/
int     hpnsFsWrite(HFILE hFile, void *pData, int nLen, int *Written);


#define HPNS_FS_FILE_BEGIN      0
#define HPNS_FS_FILE_CURRENT    1
#define HPNS_FS_FILE_END        2
/*================================================
* function: hpnsFsSeek(IN HFILE hFile, IN int offset, IN int Whence)
* note: 
*	1. it is used to set the file position indicator for the stream.
*	2. parameters is similar to fseek();
*	
=================================================*/
int 	hpnsFsSeek(HFILE hFile, int offset, int Whence);

/*================================================
* function: hpnsFsFlush(IN HFILE hFile)
* note: 
*	1. it is used to  force  a  write  of all user-space buffered data 
*	similated  to fflush(). 
*	
=================================================*/
int     hpnsFsFlush(HFILE hFile) ;

/*================================================
* function: hpnsFsClose(IN HFILE hFile)
* note: 
*	1. it is used to  close file
*	
=================================================*/
void    hpnsFsClose(HFILE hFile);

/*================================================
* function: hpnsFsGetFileSizeWithName(IN char* filePath, OUT int* pSize)
* note: 
*	1. it is used to  get file size
*	2.  In the parameters,  filePath is file path and file name, pSize is the
*	file size, it is the same to return number
*	
=================================================*/
int     hpnsFsGetFileSizeWithName(char* filePath, int* pSize);

/*================================================
* function: hpnsFsFileExists(INT8* filename)
* note: 
*	1. it is used to check a file if exist
*	2. If return 1: exist; and return 0: not exist
*	
=================================================*/
int     hpnsFsFileExists(INT8* filename);

/**************************************************************************************

                             ===========device info API==============
              
***************************************************************************************/

/*================================================
* function: hpnsGetImsiImei(OUT UINT8 imsi[][20], OUT UINT8 *pImei)
* note: 
*	1. it is used to  get IMSI that the mobile uses and IMEI
*	
=================================================*/
void    hpnsGetImsiImei(UINT8 imsi[][20], UINT8 *pImei);

/*================================================
* function: hpnsGetMobileLanguage(void)
* note: 
*	1. it is used to get the mobile language,return the definition referred to hpnsMsg.h
*	
=================================================*/
UINT32  hpnsGetMobileLanguage(void);

/*================================================
* function: hpnsGetOSID(OUT INT8 clientOS[])
* note: 
*	1. it is used to get the OS info, the max length of clientOS is 20 bytes
*     2. if successful, it returns 0; or returns -1;
*	
=================================================*/
int     hpnsGetOSInfo(INT8 clientOS[]);

/*================================================
* function: hpnsGetLocationInfo(OUT float *latitude, OUT  float *longitude)
* note: 
*	1. it is used to get the location info,the max length of latitude is 16 byres
*     2.  if successful, it returns 0; or returns -1;
*	
=================================================*/
int     hpnsGetLocationInfo(UINT8 *latitude, UINT8 *longitude);

/*================================================
* function: hpnsGetMemoryConfig(OUT UINT32 *sizeOfRAM, OUT UINT32 *sizeOfROM)
* note: 
*	1. it is used to get memory config including RAM(M) and ROM(M)
*     2. if successful, it returns 0; or returns -1;
*	
=================================================*/
int  hpnsGetMemoryConfig(UINT32 *sizeOfRAM, UINT32 *sizeOfROM);

/*================================================
* function: hpnsGetMREVersionInfo(OUT INT8 MREVersion[])
* note: 
*	1. it is used to get the MRE version info, the max length of MREVersion is 16 bytes
*     2. if successful, it returns 0; or returns -1;
*	
=================================================*/
int     hpnsGetMREVersionInfo(INT8 MREVersion[]);

/*================================================
* function: hpnsGetCapabilities(UINT32 *voiceCap, UINT32 *videoCap, UINT32 *imageCap, UINT32	*otherCap )
* note: 
*	1. it is used to get the capabilities,the Audio/Video/Picture/Other related capabilities is
*       respectively represented by one integer defined by the platforms themselves.
*     2. if successful, it returns 0; or returns -1;
*	
=================================================*/
int     hpnsGetCapabilities(UINT32 *voiceCap, UINT32 *videoCap, UINT32 *imageCap, UINT32	*otherCap );

/*================================================
* function: hpnsGetDisplayMetrics(OUT UINT16 *hSize, OUT UINT16 *wSize)
* note: 
*	1. it is used to get the screen resolution 
*     2. if successful, it returns 0; or returns -1;
*	
=================================================*/
int     hpnsGetDisplayMetrics(UINT16 *hSize, UINT16 *wSize);

/*================================================
* function: hpnsGetChipSet(OUT INT8 chipSet[])
* note: 
*	1. it is used to get the chipset
*	
=================================================*/
void    hpnsGetChipSet(INT8 chipSet[]);

/*================================================
* function: hpnsGetMACAddress(OUT INT8 macAddr[])
* note: 
*	1. it is used to get the mobile MAC address
*	
=================================================*/
void    hpnsGetMACAddress(INT8 macAddr[]);

/*================================================
* function: hpnsGetAPName(INT8 APName[])
* note: 
*	1. it is used to get AP name , len is HPNS_AP_NAME_LEN
*	2. if successful, it returns 0; or returns -1;
=================================================*/
int     hpnsGetAPName(INT8 APName[]);

/*================================================
* function: hpnsGetAPNType(INT8 APName[])
* note: 
*#define HPNS_APN_DEFAULT                  0
*#define HPNS_APN_WIFI                     1
*#define HPNS_APN_GPRS                     2
*#define HPNS_APN_WCDMA                    3;
*it returns the above num
=================================================*/
int     hpnsGetAPNType(void);


/*================================================
* function: hpnsGetSystemTime(void)
* note: 
*	1. it is used to get seconds of the current system time in timeval struct
*	
=================================================*/
UINT32  hpnsGetSystemTime(void);

/*================================================
* function: hpnsGetUsecTime(void)
* note: 
*	1. it is used to get microseconds of the current system time in timeval struct.
*	
=================================================*/
UINT32  hpnsGetUsecTime(void);

/*================================================
* function: hpnsGetTimeStamp(void)
* note: 
*	1. it is used to get the current system time. But it returns a string
*	like "HH:MM:SS:UUU" .
*	
=================================================*/
char    *hpnsGetTimeStamp(void);
void    hpnsTrace(char* buf);


#endif
