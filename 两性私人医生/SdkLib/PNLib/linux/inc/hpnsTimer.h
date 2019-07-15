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

#ifndef _HPNS_TIMER_HEADER
#define _HPNS_TIMER_HEADER

/*=====================================================================================
* function: hpnsInitTimer(IN int timerId, IN void (*callback)(int), IN char name[])
* note: 
*	1. it is used to initialize a timer
*	2. In the parameters, timerId is timer ID; callback is a functional pointer, it is called when timer is timeout; name is the timer name.
*	
=====================================================================================*/
void hpnsInitTimer(int timerId, void (*callback)(int), char name[]);

/*====================================================================================
* function: hpnsSetTimer(IN int nTimerId, IN int nTimeDurationInSecs)
* note: 
*	1. it is used to start a timer
*	2. In the parameters, nTimerId is timer ID and nTimeDurationInSecs is expired time, the precision is 1 second.
*	
=====================================================================================*/
void hpnsSetTimer(int nTimerId, int nTimeDurationInSecs);

/*====================================================================================
* function: hpnsKillTimer(IN int timerId)
* note: 
*	1. it is used to stop a timer
*	2. In the parameters, timerId is timer ID.
*	
======================================================================================*/
void hpnsKillTimer(int timerId);

#endif
