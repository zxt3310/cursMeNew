/*******************************************************************
 *             Copyright (c) 2001 by TAOS Networks, Inc.
 *                       All rights reserved.
 *  
 *  This file is proprietary and confidential to TAOS Networks, Inc.
 *  No part of this file may be reproduced, stored, transmitted,
 *  disclosed or used in any form or by any means other than as
 *  expressly provided by the written permission from Jianhui Tao
 * 
 ******************************************************************/

#include <stdio.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

#include "tmodule.h"
#include "hpnsUtil.h"
#include "_semaphore.h"

#define tfree(x) { if ( x ) { free(x); x = 0; } }


void      *taosProcessQueue(void *param);

char *taosDisplayModuleStatus(int moduleNum) {
  static char  status[256];
  int i;

  status[0] = 0;
  
  for (i=1; i < moduleNum; ++i)
    if ( moduleObj[i].thread != 0 )
      sprintf(status+strlen(status), "%s ", moduleObj[i].name);
  
  if ( status[0] == 0 ) 
    sprintf(status, "all module is down");
  else
    sprintf(status, " is(are) up");

  return status;
}

/*
 * allocate the storage
 * the module is used to store the corresponding message with a queue
 * the queue stat is reflected on the module's semaphore: fullSem and emptySem.
 */
taosInitModule (module_t *pMod)
{
  pthread_attr_t attr;
  char semName[20];
    
  if ( pthread_mutex_init ( &pMod->queueMutex, 0) < 0 ) {
    printf("ERROR: init %s queueMutex failed, reason:%s\n", pMod->name, strerror(errno));
    taosCleanUpModule(pMod);
    return -1;
  }
  
  if ( pthread_mutex_init ( &pMod->stmMutex, 0) < 0 ) {
    printf("ERROR: init %s stmMutex failed, reason:%s\n", pMod->name, strerror(errno));
    taosCleanUpModule(pMod);
    return -1;
  }

  strcpy(semName, pMod->name);
  strcat(semName, "_empty");
  pMod->emptySem = _sem_init(semName, pMod->queueSize);
  if ( pMod->emptySem < 0 ) {
    printf("ERROR: init %s empty semaphore failed, reason:%s\n", pMod->name, strerror(errno));
    taosCleanUpModule(pMod);
    return -1;
  }

  strcpy(semName, pMod->name);
  strcat(semName, "_full");
  pMod->fullSem = _sem_init(semName, 0);
  if ( pMod->fullSem < 0 )  {
    printf("ERROR: init %s full semaphore failed, reason:%s\n", pMod->name, strerror(errno));
    taosCleanUpModule(pMod);
    return -1;
  }

  if ( ( pMod->queue = (msg_t *)malloc(pMod->queueSize*sizeof(msg_t)) ) == 0 ) {
    printf("ERROR: %s no enough memory, reason:%s\n", pMod->name, strerror(errno));
    taosCleanUpModule(pMod);
    return -1;
  }
	   
  memset(pMod->queue, 0, pMod->queueSize * sizeof(msg_t) );
  pMod->fullSlot = 0;
  pMod->emptySlot = 0;

  pthread_attr_init ( &attr);
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
  
  if ( pthread_create(&pMod->thread, &attr, taosProcessQueue, (void *)pMod) != 0 ) {
    printf("ERROR: %s failed to create thread, reason:%s\n", pMod->name, strerror(errno));
    taosCleanUpModule(pMod);
    return -1;
  }

  if ( pMod->init )
    return (*(pMod->init))();

  return 0;
}

void *taosProcessQueue(void *param) {
  msg_t    msg;
  module_t *pMod = (module_t *)param;
  int      oldType;
  sigset_t intmask;
  
  //pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, &oldType);  
  
  signal( SIGINT, SIG_IGN);

  while ( 1 ) {
    _sem_wait ( pMod->fullSem );

    if ( pthread_mutex_lock ( &pMod->queueMutex) != 0 ) 
      printf("ERROR: lock %s queueMutex failed, reason:%s\n", pMod->name, strerror(errno));
    
    msg = pMod->queue[pMod->fullSlot];
    memset( &(pMod->queue[pMod->fullSlot]), 0, sizeof(msg_t));
    pMod->fullSlot = ( pMod->fullSlot + 1 ) % pMod->queueSize;

    if ( pthread_mutex_unlock ( &pMod->queueMutex) != 0 )
      printf("ERROR: unlock %s queueMutex failed, reason:%s\n", pMod->name, strerror(errno));

    _sem_post (pMod->emptySem);

    /* process the message */
    if ( msg.cid<0 || msg.cid >= maxCid ) {
      /*printf("ERROR: cid:%d is out of range, msg is discarded\n", msg.cid);*/
      continue;
    }

    if ( pthread_mutex_lock ( &(pMod->stmMutex)) != 0 )
      printf("ERROR: lock %s stmMutex failed, reason:%s\n", pMod->name, strerror(errno));
		      
    (*(pMod->processMsg)) ( &msg );

    tfree(msg.msg);
    
    if ( pthread_mutex_unlock ( &(pMod->stmMutex)) != 0 )
      printf("ERROR: unlock %s stmMutex failed, reason:%s\n", pMod->name, strerror(errno));

  }
}

int taosSendMsgToModule(module_t *pMod, int cid, int mid, int tid, char *msg) {
  
  _sem_wait( pMod->emptySem );
  if ( pthread_mutex_lock ( &pMod->queueMutex ) != 0 ) 
    printf("ERROR: lock %s queueMutex failed, reason:%s\n", pMod->name, strerror(errno));
  
  pMod->queue[pMod->emptySlot].cid = cid;
  pMod->queue[pMod->emptySlot].mid = mid;
  pMod->queue[pMod->emptySlot].tid = tid;
  pMod->queue[pMod->emptySlot].msg = msg;
  pMod->emptySlot = (pMod->emptySlot+1) % pMod->queueSize;

  if ( pthread_mutex_unlock( &pMod->queueMutex ) != 0 ) 
    printf("ERROR: unlock %s queueMutex failed, reason:%s\n", pMod->name, strerror(errno));
  
  _sem_post ( pMod->fullSem);
  return 0;
}

void taosCleanUpModule(module_t *pMod ) {
  int i;

  if ( pMod->cleanUp ) 
    pMod->cleanUp();

  if ( pMod->thread ) 
    pthread_cancel(pMod->thread);
  pMod->thread = 0;  
 
  _sem_destroy( pMod->emptySem);
  _sem_destroy( pMod->fullSem );
  pthread_mutex_destroy( &pMod->queueMutex );
  pthread_mutex_destroy( &pMod->stmMutex );

  for ( i=0; i<pMod->queueSize; ++i) {
    tfree(pMod->queue[i].msg);
  }

  tfree(pMod->queue);

  //memset(pMod, 0, sizeof(module_t));

}
