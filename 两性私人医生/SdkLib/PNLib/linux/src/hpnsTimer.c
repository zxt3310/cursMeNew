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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "ttimer.h"
#include "hpnsPlatform.h"

typedef struct
{
	tmr_h tmrHandle;
	char  str[20];
	void  (*callback)();
	int   param;
} SNmsTimer;

SNmsTimer hpnsTimer[100] = {0};
extern int HPNS_ENG_MSG_TIMER;


void hpnsInitTimer(int timerId, void (*callback)(int), char name[])
{
	hpnsTimer[timerId].callback = callback;
	strcpy(hpnsTimer[timerId].str, name);
	hpnsTimer[timerId].param = timerId;
}

void hpnsProcessTimer ( UINT32 timerId)
{
	printf("Timer: %s is expired.", hpnsTimer[timerId].str);
	hpnsTimer[timerId].tmrHandle = 0;
	(*hpnsTimer[timerId].callback)(timerId);
}

void hpnsProcessTimerFunc(long param)
{
	int timerId = (int)param;
	hpnsSendMsgToEngineP(HPNS_ENG_MSG_TIMER, (UINT8 *)timerId, 0);
}

void hpnsSetTimer(int timerId, int seconds)
{
	hpnsTimer[timerId].tmrHandle = taosTmrStart ( hpnsProcessTimerFunc, seconds*1000, timerId);
	printf("timer: %s is set to: %d seconds.",hpnsTimer[timerId].str, seconds);
}

void hpnsKillTimer(int timerId)
{
	if ( hpnsTimer[timerId].tmrHandle == 0 )
		return ;
	
	 taosTmrStop ( hpnsTimer[timerId].tmrHandle );
	 hpnsTimer[timerId].tmrHandle = 0;	
	 printf("timer: %s is killed.",hpnsTimer[timerId].str);
}

void hpnsSleep(int time)
{
	sleep (time);
}