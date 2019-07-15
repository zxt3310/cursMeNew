
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

#ifndef _tmodule_header_
#define _tmodule_header_

#include <pthread.h>
#include "_semaphore.h"

typedef struct _msg_header {
  int   mid;           /* message ID */
  int   cid;           /* call ID */
  int   tid;           /* transaction ID */
//  int   len;           /* length of msg */
  char  *msg;          /* content holder */
} msg_header_t, msg_t;

/*  msg processor module */
typedef struct {
  char      *name;      /* module name */
  pthread_t thread;     /* thread ID */
  _sem_t*     emptySem;
  _sem_t*     fullSem;
  int       fullSlot;
  int       emptySlot;
  int       debugFlag;
  int       queueSize;
  int       msgSize;
  pthread_mutex_t queueMutex;
  pthread_mutex_t stmMutex;             // what is this used to do?
  msg_t     *queue;
  int       (*processMsg)(msg_t *);
  int       (*init)();
  void      (*cleanUp)();
} module_t;

typedef struct {
  short         len;
  unsigned char data[0];
} sim_data_t;

extern int       maxCid;
extern module_t  moduleObj[];
extern char      *msgName[];

extern int  taosSendMsgToModule(module_t *mod_p, int cid, int mid, int tid, char *msg);
extern char *taosDisplayModuleStatus(int moduleNum);
extern int  taosInitModule(module_t *);
extern void taosCleanUpModule(module_t *);


#endif

