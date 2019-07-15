/*******************************************************************
 *           Copyright (c) 2001 by TAOS Networks, Inc.
 *                     All rights reserved.
 *
 *  This file is proprietary and confidential to TAOS Networks, Inc. 
 *  No part of this file may be reproduced, stored, transmitted, 
 *  disclosed or used in any form or by any means other than as 
 *  expressly provided by the written permission from Jianhui Tao
 *
 * ****************************************************************/

#ifndef _taos_timer_header
#define _taos_timer_header

//#define tmr_h  void *
typedef void*  tmr_h;

extern  int tmrDebugFlag;

int     taosTmrInit (int maxTmr, int resoultion, int longest);
tmr_h   taosTmrStart(void (*fp)(long), int mseconds, long param1 );
tmr_h   taosTmrStartEx(void (*fpEx)(tmr_h, long/*param1*/), int mseconds, long param1 );
void    taosTmrStop( tmr_h tmrId);
void    taosTmrCleanUp ();
void    taosTmrList();

#endif

