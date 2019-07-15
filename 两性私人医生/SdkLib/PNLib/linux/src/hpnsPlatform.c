#include <stdio.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/uio.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <netdb.h>
#include <string.h>
#include <time.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "hpnsUtil.h"
#include "tmodule.h"
#include "hpnsPlatform.h"
#include "_semaphore.h"

int HPNS_ENG_MSG_TIMER = 0xFFF0;

void   *hpnsMallocL(UINT32 size)
{
	if(0 == size) return NULL;
	return malloc(size);
}

void    hpnsFreeL(void* pMem)
{
	free (pMem);
}

HFILE hpnsFsOpen(char *name, UINT32 flag)
{
	int hFile = 0;

	if ( flag == HPNS_FS_CREATE )
		hFile = open(name, O_RDWR | O_CREAT, S_IRWXU);
	else if ( flag == HPNS_FS_CREATE_ALWAYS )
		hFile = open(name, O_RDWR | O_CREAT, S_IRWXU );
	else if ( flag == HPNS_FS_READ )
		hFile = open(name, O_RDONLY);
	else if ( flag == HPNS_FS_READ_WRITE)
		hFile = open(name, O_RDWR);

	if ( hFile < 0 )
	{
		printf("failed to open file:%s, reason:%s\n", name, strerror(errno));
		hFile = 0;
	}
	
	return hFile;
}


int hpnsFsRead(HFILE hFile, void *pData, int nLen, int *bytesread)
{
	*bytesread = read(hFile, pData, nLen);
	
	return *bytesread;
}

int hpnsFsWrite(HFILE hFile, void *pData, int nLen, int *written)
{
	int bytes;
	
	bytes = write(hFile, pData, nLen);

	if( written )
		*written = bytes;

	return bytes;
}

int hpnsFsSeek(HFILE hFile, int offset, int Whence)
{
	int flag = 0;
	
	if ( Whence == HPNS_FS_FILE_BEGIN ) flag = SEEK_SET;
	if ( Whence == HPNS_FS_FILE_CURRENT ) flag = SEEK_CUR;
	if ( Whence == HPNS_FS_FILE_END ) flag = SEEK_END;
	
    return lseek(hFile, offset, flag);
}

void hpnsFsClose(HFILE hFile)
{
	close (hFile);	
}

int hpnsFsDelete(char *file)
{
	return remove(file);
}

int hpnsFsFlush(HFILE hFile)
{
	return 0;
}

int hpnsFsGetFileSizeWithName(char *pName, int *size)
{
	struct stat st;
	
	stat(pName, &st);
	*size = st.st_size;

	return *size;
}

int hpnsFsFileExists (char *pName)
{
	struct stat st;
	int ret;

	ret = stat(pName, &st);

	if ( ret == 0 ) 
		ret = 1;
	else
		ret = 0;

	return ret;	
}

int hpnsFsFolderExists(char* folderName)
{
	struct stat st; 
	int ret; 
	
	ret = stat(folderName, &st); 
	
	if ( ret == 0 ) 
	ret = 1; 
	else 
	ret = 0; 
	
	return ret; 

}


int hpnsCreateFolder(char *name)
{
	if(mkdir(name,0777)) 
		return -1; 
	else 
		return 0; 
}


int hpnsSendMsgToEngineP(int mid, UINT8 *pMsg, int msgLen) 
{ 
	UINT8 *temp = 0;
	
	if ( msgLen > 0 )
	{
		temp = malloc(msgLen);
		memcpy(temp, pMsg, msgLen);
		pMsg = temp;
	}

	// msgLen is saved in tid, it is kind of hacker
	taosSendMsgToModule( &(moduleObj[2]), 0, mid, msgLen, pMsg);
    return 0;
}

int hpnsSendMsgToUIP(int mid, UINT8 *pMsg, int msgLen) 
{
	UINT8 *temp=0;

	if ( msgLen > 0 )
	{
		temp = malloc(msgLen);
		memcpy(temp, pMsg, msgLen);
		pMsg = temp;
	}

  	taosSendMsgToModule( &(moduleObj[0]), 0, mid, msgLen, pMsg);
    return 0;
}

void hpnsEngineProcessMsgQueue(msg_t *param)
{
	msg_t *pMsg;
	
	pMsg = (msg_t *)param;

	if( HPNS_ENG_MSG_TIMER == pMsg->mid )
	{
		nprintf("engine recv timer msg, timer id: %d", (UINT32)pMsg->msg);
		hpnsProcessTimer((UINT32)pMsg->msg);
		goto end;
	}
	hpnsHandleMsg( pMsg->mid, pMsg->msg, pMsg->tid);
end:
	if ( pMsg->tid == 0 ) 
		pMsg->msg = NULL;

}

void hpnsGetImsiImei(UINT8 imsi[][20], UINT8 *pImei)
{
	strcpy(imsi[0], "460000690224717");
	
	strcpy(pImei, "1234567890321");

	return;
}

UINT32 hpnsGetMobileLanguage(void)
{
	return 4;
}	

char *hpnsGetTimeStamp(void) {
  static char     tstamp[40];

  struct tm      *ptm;
  struct timeval timeSecs;
  
  gettimeofday ( &timeSecs, 0);
  ptm = localtime ( &timeSecs.tv_sec );
  timeSecs.tv_usec = timeSecs.tv_usec / 1000;
  sprintf(tstamp, "%02d:%02d:%02d:%03d ", ptm->tm_hour, ptm->tm_min, ptm->tm_sec, (int)timeSecs.tv_usec); 
  
  return tstamp;
}  

UINT32 hpnsGetSystemTime( )
{
	struct timeval systemTime;

	gettimeofday(&systemTime, 0);

	return systemTime.tv_sec;
}

UINT32 hpnsGetUsecTime()
{
	struct timeval systemTime;

	gettimeofday(&systemTime, 0);

	return systemTime.tv_usec;
}

UINT32 hpnsHtonl(UINT32 x)
{
	return htonl(x);
}

UINT32 hpnsNtohl(UINT32 x)
{
	return ntohl(x);
}

UINT16 hpnsHtons(UINT16 x)
{
	return htons(x);
}
	
UINT16 hpnsNtohs(UINT16 x)
{
	return ntohs(x);
}

void hpnsTrace(char* buf)
{
	fprintf(stdout, "%s", buf);
	return ;
}

int   hpnsGetDisplayMetrics(UINT16 *hSzie, UINT16 *vSize)
{
	*hSzie = 280;
	*vSize = 180;

	return 0;
}

int     hpnsGetOSInfo(INT8 clientOS[])
{
	strcpy(clientOS, "linux simulator" );
	return 0;
}

void    hpnsGetChipSet(INT8 chipSet[])
{
	strcpy(chipSet, "linux mobile");
	return;
}

int     hpnsGetMREVersionInfo(INT8 MREVersion[])
{
	strcpy(MREVersion, "mre 1.0");
	return 0;

}

void    hpnsGetMACAddress(INT8 macAddr[])
{
	strcpy(macAddr, "11:22:33:44:55:66");
	return;

}


int  hpnsGetMemoryConfig(UINT32 *sizeOfRAM, UINT32 *sizeOfROM)
{
	*sizeOfRAM = 100;
	*sizeOfROM = 200;
	return 0;
}

int     hpnsGetCapabilities(UINT32 *voiceCap, UINT32 *videoCap, UINT32 *imageCap, UINT32	*otherCap )
{
	*otherCap = 1234;
	
		*imageCap = 2345;
		*videoCap = 4567;
		*voiceCap = 6789;
	
	return 0;
}

int     hpnsGetLocationInfo(UINT8 *latitude, UINT8 *longitude)
{

	strcpy(latitude , "100.01");
	strcpy(longitude ," 200.22");
	return 0;
}

int     hpnsGetAPName(INT8 APName[])
{
	strcpy(APName, "xitang");
	return 0;
}

int     hpnsGetAPNType()
{
	return 1;
}



