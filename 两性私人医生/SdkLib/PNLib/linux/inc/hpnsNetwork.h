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

#ifndef _hpns_network_h_
#define _hpns_network_h_

#include "header.h"
/*=====================================================================================
* function: hpnsGetTtl()
* note: 
*	1. it is used to get time to live(TTL)
*	2. returns TTL, the default value of TTL is 128.
*	
=====================================================================================*/
int    hpnsGetTtl(void);

/*=====================================================================================
* function: hpnsOpenUdpSocket( OUT char * asyncFlag)
* note:
*	1. it is used to open a UDP socket, returns socket ID
*	2. platform should calculate IAP itself
*	3. if this function is asynchronous, asyncFlag is set to 1, or it is 0.
*	
=====================================================================================*/
int    hpnsOpenUdpSocket(char *asyncFlag);

/*=====================================================================================
* function: hpnsCloseUdpSocket( IN unsigned int sockFd)
* note:
*	1. it is used to close UDP socket
*	
=====================================================================================*/
void   hpnsCloseUdpSocket( unsigned int sockFd);

/*=====================================================================================
* function: hpnsSendUdpData(IN unsigned int sockFd, IN unsigned int ip, IN unsigned short port, IN unsigned char *msg, IN int msgLen); 
* note:
*	1. it s used to send UDP data.
*	2. In the parameters, ip and port must be network order
*	3. It returns bytes that have been sent normally, and if failed to send data, returns negative error number; 
*	if the socket is blocking, returns 0.
*	
=====================================================================================*/
int    hpnsSendUdpData(unsigned int sockFd, unsigned int ip, unsigned short port, unsigned char *msg, int msgLen); 


/*=====================================================================================
* function: hpnsRecvUdpData(IN unsigned int sockFd, OUT unsigned char *buffer,IN  int bufferLen, OUT unsigned int *ip, OUT unsigned short *port);
* note:
*	1. it is used to read UDP data
*	2.  In the parameters, bufferLen is bytes to read, ip and port are the server's address
*	3.  It returns bytes that have been read, if failed to read data, returns a negative error number; 
*	and if socket is blocking, returns 0.
*	
=====================================================================================*/
int    hpnsRecvUdpData(unsigned int sockFd, unsigned char *buffer, int bufferLen, unsigned int *ip, unsigned short *port);

/*=====================================================================================
* function: hpnsGetServerIpViaDNS(IN char domain[], UINT32 *serverIP)
* note:
*	1. it is used to get IP address by domain name server, 
*	2. in the parameters, domain[] is the domain name, *serverIP is the retured server IP of domain name
*	3. This function may be an asynchronous operation. If it is asynchronous, returns 0,
*	and need to call the API that engine provides£ºint hpnsProcessDnsResult(UINT32 ip);
*	if failed to get IP address,returns a negative error number; and if it is successful to get IP,return 1
=====================================================================================*/
int hpnsGetServerIpViaDNS(char domain[], UINT32 *serverIP); 

/*=====================================================================================
* function: hpnsOpenTcpSocket()
* note:
*	1. it is used to open a TCP socket, returns socket ID
*	2. platform should calculate IAP itself
*	
=====================================================================================*/
#ifdef __PNS_TCP_CONNECT_SUPPORT__

unsigned int hpnsOpenTcpSocket(void);

/*=====================================================================================
* function: hpnsCloseTcpSocket( IN unsigned int sockFd)
* note:
*	1. it is used to close TCP socket
*	
=====================================================================================*/
void  hpnsCloseTcpSocket( unsigned int sockFd );

/*=====================================================================================
* function: hpnsConnectTcpSocket(IN int sockFd, IN unsigned int ip,IN UINT16 port)
* note:
*	1. it is used to connect TCP
*     2. it returns 1 when connecting succssfully;it returns 0 if socket is SOC_WOULDBLOCK, and returns negative error number if fialed
*	
=====================================================================================*/
int hpnsConnectTcpSocket(int sockFd, unsigned int ip, UINT16 port);

/*=====================================================================================
* function: hpnsRecvTcpData(IN unsigned int sockFd, IN unsigned char *msg, IN int msgLen)
* note:
*	1. it is used read TCP data
*     2.  In the parameters, msgLen is bytes to read
*	3.  It returns bytes that have been read, if failed to read data, returns a negative error number; 
*	and if socket is blocking, returns 0.
*	
=====================================================================================*/
int hpnsRecvTcpData(unsigned int sockFd, unsigned char *msg, int msgLen);

/*=====================================================================================
* function: hpnsSendTcpData(IN unsigned int sockFd, IN unsigned char *msg, IN int msgLen);
* note:
*	1. it is used to write TCP socket
*     2.In the parameters, msgLen is bytes to write
*	3.It returns bytes that have been sent normally, and if failed to send data, returns negative error number; 
*	if the socket is blocking, returns 0.
*	
=====================================================================================*/
int hpnsSendTcpData(unsigned int sockFd, unsigned char *msg, int msgLen);
#endif

#endif
