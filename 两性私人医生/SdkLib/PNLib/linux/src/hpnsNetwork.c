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

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/uio.h>
#include <sys/time.h>
#include <pthread.h>
#include <errno.h>
#include <netinet/in.h>
#include <pthread.h>
#include <netdb.h>
#include <unistd.h>

#include "hpnsPlatform.h"
#include "hpnsConfig.h"
#include "tmodule.h"
#include "_semaphore.h"

INT32 hpnsOpenUdpSocket(char *asyncFlag )
{
	struct sockaddr_in localAddr;
	int                sockFd;
	struct hostent     *hp;
	char               name[100];
	int                len = 100;
	int                reuse, nocheck;
	int				   ttl = 128;
	long ip = 0;

	if ( ip == 0 )
	{
		/* get the local IP address */
		if( 0 != gethostname(name, len)) 
			return -1;

		hp = gethostbyname(name);
		if ( hp != NULL && hp->h_addrtype == AF_INET) 
		{
            ip = htonl(INADDR_ANY);//*(unsigned int*)hp->h_addr;
		}
	}

	memset((char *) &localAddr, 0, sizeof (localAddr));
	localAddr.sin_family = AF_INET;
	localAddr.sin_addr.s_addr = ip;
	//localAddr.sin_port = 38220;

	if (( sockFd = socket (AF_INET, SOCK_DGRAM, 0)) < 0) {
		nprintf("failed to open udp socket");
		return -1;
	}

	reuse = 1;
	if ( setsockopt(sockFd, SOL_SOCKET, SO_REUSEADDR, (void *)&reuse, sizeof(reuse)) < 0 ) 
	{
		nprintf("setsockopt SO_REUSEADDR failed");
		close (sockFd);
		return -1;
	};

    nocheck = 1;
//    if ( setsockopt(sockFd, SOL_SOCKET, SO_NO_CHECK, (void *)&nocheck, sizeof(nocheck)) < 0 )
//    {
//		nprintf("setsockopt SO_NO_CHECK failed");
//		close (sockFd);
//		return -1;
//	}

	ttl = 128;
	if ( setsockopt(sockFd, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl)) < 0)
	{
		nprintf("setsockopt IP_TTL failed");
		close (sockFd);
		return -1;
	}
	/* bind socket to local address */
	if (bind (sockFd, (struct sockaddr *) &localAddr, sizeof(localAddr) ) < 0 )
	{ 
		nprintf("failed to bind udp socket: %d, %s", errno, strerror(errno));
		close(sockFd); 
		return -1;
	}

	taosCleanUpModule(&(moduleObj[1]));
	taosInitModule(&(moduleObj[1]));
	taosSendMsgToModule( &(moduleObj[1]), 0, 0, sockFd, 0);

	*asyncFlag = 0;
	
	return sockFd;
}

void hpnsCloseUdpSocket( UINT32 sockFd)
{
	close(sockFd);
}

int hpnsSendUdpData(UINT32 sockFd, UINT32 ip, UINT16 port, UINT8 *msg, int msgLen) 
{
	struct sockaddr_in destAdd;
	int                ret;

	destAdd.sin_family      = AF_INET;
	destAdd.sin_addr.s_addr = ip; 
	destAdd.sin_port        = port;

	ret = sendto( sockFd, msg, msgLen, 0, (struct sockaddr *)&destAdd, sizeof(destAdd));
	
	return ret;
}

int hpnsRecvUdpData(UINT32 sockFd, UINT8 *buffer, int bufferLen, UINT32 *ip, UINT16 *port)
{
	int                dataLen = -1;
	struct sockaddr_in sourceAdd;
	int                sourceAddLen;	

	sourceAddLen = sizeof(sourceAdd);
	
	dataLen = recvfrom( sockFd, buffer, bufferLen, 0, (struct sockaddr *) &sourceAdd, &sourceAddLen );

	if ( dataLen < 0 && errno == EINTR )
		return 0;
	
	*ip = sourceAdd.sin_addr.s_addr;
	*port = sourceAdd.sin_port;

	if ( dataLen < 0 )
		nprintf("socket error, reason:%s", strerror(errno));
	
	return dataLen;
}

int hpnsGetServerIpViaDNS(char domain[], UINT32 *serverIp)
{
	struct hostent     *hp;
	UINT32 ip = 0;
	
	hp = gethostbyname(domain);
	
	if ( hp != 0 && hp->h_addrtype == AF_INET) 
	{
		*serverIp = *(unsigned int*)hp->h_addr;
	}
	else
		return -1;

	return 1;
}

int  hpnsGetTtl()
{
	return 128;
}

UINT32 hpnsGetLocalIp(unsigned int sockFd)
{
	return 0;
}
#ifdef __PNS_TCP_CONNECT_SUPPORT__

UINT32 hpnsOpenTcpSocket()
{
	int sockFd = 0;

	sockFd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);

  	return sockFd;
}

void  hpnsCloseTcpSocket( UINT32 sockFd )
{
	 close ( sockFd);
}

int hpnsConnectTcpSocket(UINT32 sockFd, UINT32 destIp, UINT16 destPort)
{
  struct sockaddr_in serverAddr;
  int ret;

  memset((char *) &serverAddr, 0, sizeof (serverAddr));
  serverAddr.sin_family = AF_INET;
  serverAddr.sin_addr.s_addr = destIp;
  serverAddr.sin_port = destPort;   

  ret = connect(sockFd, (struct sockaddr *) &serverAddr, sizeof(serverAddr));
	
  if ( ret != 0 )
  {
	nprintf("failed to connect socket,error:%s",strerror(errno));
	sockFd = -1;
	return -1;
  }	

  taosSendMsgToModule( &(moduleObj[3]), 0, 0, sockFd, NULL);
  
  return 1;
}

int hpnsSendTcpData(UINT32 sockFd, UINT8 *msg, int msgLen)
{
    int ret = -1;
	//unsigned short len = hpnsHtons((UINT16)msgLen);
	//ret = write(sockFd, &len, 2);
	ret = write(sockFd, msg, msgLen);

	if(ret < 0)
		nprintf("tcp socket error, reason:%s", strerror(errno));
	
	return ret;
}

int hpnsRecvTcpData(UINT32 sockFd, UINT8 *msg, int msgLen)
{
    int ret = -1;

	ret = read(sockFd, msg, msgLen);
	if(ret < 0)
		nprintf("tcp socket error, reason:%s", strerror(errno));
	else if(ret != msgLen)
		ret = -1;
	
	return ret;
}


#endif
