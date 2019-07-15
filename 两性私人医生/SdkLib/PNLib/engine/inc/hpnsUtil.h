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

#ifndef _hpns_util_header_
#define _hpns_util_header_

#include "hpnsPlatform.h"

int  hpnsInitLog(void); 
void nprintf (char *format,...);
void hpnsdump(char *msg, int len);
int hpnsByteArrayToHexStr(char bytes[], int bytesLen);
int hpnsOpenTcpConnectionToPushServer();
void hpnsProcessTimer ( UINT32 timerId);
void hpnsHandleMsg (int msgId, UINT8 *pMsg, int msgLen);

#endif

