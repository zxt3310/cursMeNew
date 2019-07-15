/*******************************************************************
 *           Copyright (c) 2001 by TAOS Networks, Inc.
 *                     All rights reserved.
 *
 *  This file is proprietary and confidential to TAOS Networks, Inc. 
 *  No part of this file may be reproduced, stored, transmitted, 
 *  disclosed or used in any form or by any means other than as 
 *  expressly provided by the written permission from Jianhui Tao
 *
 ******************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <signal.h>
#include <unistd.h>
#include <errno.h>
#include <sys/time.h>
#include <string.h>

#include "ttimer.h"
#include "tmempool.h"
#include "hpnsUtil.h"
#include "_semaphore.h"

#define tmrError(x) if (tmrDebugFlag & 1 ) { nprintf x; } 
#define tmrWarn(x) if (tmrDebugFlag & 2 ) { nprintf x; } 
#define tmrTrace(x) if (tmrDebugFlag & 4 ) { nprintf x; } 
#define tmrPrint(x) { nprintf x; }

#define tfree(x) { if ( x ) { free(x); x = 0; } }


typedef struct _tmr_obj {
  unsigned long   param1;
  void            (*fp)(long); 
  void            (*fpEx)(tmr_h /* timerId */, long /* para */); // dingfu extend this
  tmr_h           timerId;
  short           cycle;
  struct _tmr_obj *prev;
  struct _tmr_obj *next;
  int             index;
} tmr_obj_t;

typedef struct {
  tmr_obj_t  *head;
  int        count;
} tmr_list_t;

typedef struct {
  char            init;              /* set if timer is initialized */
  _sem_t*           semaphore;         /* semaphore to count ticks */
  pthread_mutex_t mutex;             /* mutex to protect critical resource */
  int             resolution;        /* resolution */
  int             numOfPeriods;      /* total number of periods */
  long            periodsFromStart;  /* count number of periods since start */
  pthread_t       thread;            /* timer thread ID */
  tmr_list_t      *tmrList;
  mpool_h         poolHandle;
} tmr_ctrl_t;

tmr_ctrl_t  tmrCtrl;
int         tmrDebugFlag = 3 ;// |DEBUG_TRACE;
void        *taosTmrProcessList(void *);
int         totalNumOfTmrs;

static void taosProcessAlarmSignal(int signo) {
  _sem_post( tmrCtrl.semaphore);
}

int taosTmrInit (int maxNumOfTmr, int resolution, int longest) {
  int    i;
  struct itimerval tv;
  int    ret;
  pthread_attr_t  attr;
  
  /* clear the control block */
  if (tmrCtrl.init) {
    tmrError (("Timer already initialized.\n"));
    return -1;
  }

  if ( ( tmrCtrl.poolHandle = taosMemPoolInit(maxNumOfTmr, sizeof(tmr_obj_t) ) ) == 0 ) {
    tmrError(("failed to allocate tmr pool\n"));
    taosMemPoolCleanUp(tmrCtrl.poolHandle);
    return -1;
  }
 
  tmrCtrl.resolution = resolution;
  tmrCtrl.numOfPeriods = longest/resolution;
  if ( tmrCtrl.numOfPeriods < 10 ) tmrCtrl.numOfPeriods = 10;
  
  tmrCtrl.tmrList = (tmr_list_t *)malloc(sizeof(tmr_list_t)*tmrCtrl.numOfPeriods);
  for (i = 0; i < tmrCtrl.numOfPeriods; i++) {
    tmrCtrl.tmrList[i].head = 0;
    tmrCtrl.tmrList[i].count = 0;
  }
  
  tmrCtrl.semaphore = _sem_init("tmr_ctrl", 0);
  if ( tmrCtrl.semaphore < 0 ) {
    tmrError(("failed to create semaphore\n"));
    taosTmrCleanUp();
    return -1;
  }
    
  if ( pthread_mutex_init ( &tmrCtrl.mutex, 0) < 0 ) { 
    tmrError (("failed to create the mutex.\n"));
    taosTmrCleanUp();
    return -1;
  }

  signal( SIGALRM, taosProcessAlarmSignal );

  tv.it_interval.tv_sec = 0;  /* my timer resolution */
  tv.it_interval.tv_usec = resolution*1000;  // resolution is in msecond
  tv.it_value = tv.it_interval;

  if ( setitimer (ITIMER_REAL, &tv, 0) < 0 ) {
    tmrError(("setitimer fail, reason:%s\n", strerror(errno)));    
    taosTmrCleanUp();
    return -1;
  }
 
  pthread_attr_init ( &attr);
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);

  if ( pthread_create(&tmrCtrl.thread, 0, taosTmrProcessList, 0) != 0 ) {
    tmrError(("failed to create thread\n"));
    taosTmrCleanUp();
    return -1;
  }

  tmrCtrl.init = 1;

  return 0;
}

void *taosTmrProcessList(void *param) {
  unsigned int index;  
  tmr_list_t   *pList;
  tmr_obj_t    *pObj, *header;
  int          oldType;

//  pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, &oldType);
  
  while (1) { 
    
    if( _sem_wait ( tmrCtrl.semaphore ) != 0 )
    {
        if(errno == EINTR) continue;
        tmrError(("sem_wait fail, reason:%s\n", strerror(errno)));
    }
    if ( pthread_mutex_lock( &tmrCtrl.mutex ) != 0 ) 
      tmrError(("mutex lock failed, reason:%s\n", strerror(errno) ));

    index = tmrCtrl.periodsFromStart % tmrCtrl.numOfPeriods;

    while ( 1 ) {

      pList = &tmrCtrl.tmrList[index];  
      header = pList->head;
      if ( header == 0 ) 
      	break;

      if ( header->cycle > 0 ) {
      	pObj = header;
      	while ( pObj ) {
      	  pObj->cycle--;
      	  pObj = pObj->next;
      	}
      	break;
      } 

      totalNumOfTmrs--;
      tmrTrace(("0x%06x timer expired, fp:%lx, total:%d\n", header->param1, header->fp, totalNumOfTmrs));

      pList->head = header->next;

      if ( header->next ) 
        header->next->prev = 0;

      // Gary Chen moves these two lines here on 2009-01-14
      pList->count--;
      header->timerId = 0;   
	
      if ( pthread_mutex_unlock( &tmrCtrl.mutex ) != 0 ) 
        tmrError(("mutex unlock failed, reason:%s\n", strerror(errno) ));
     
      /* call back function */
      if(header->fp) (*(header->fp))(header->param1);
      // Gary Chen comments this line on 2009-01-14
      //if(header->fpEx) (*(header->fpEx))(header->timerId, header->param1); // dingfu extend this
      taosMemPoolFree(tmrCtrl.poolHandle, (char *)header);

      if ( pthread_mutex_lock( &tmrCtrl.mutex ) != 0 ) 
        tmrError(("mutex lock failed, reason:%s\n", strerror(errno) ));

      // Gary Chen comments these two line on 2009-01-14
      // dingfu move it here!!!
      //pList->count--;
      //header->timerId = 0;    
    }

    if ( pthread_mutex_unlock( &tmrCtrl.mutex ) != 0 ) 
      tmrError(("mutex unlock failed, reason:%s\n", strerror(errno) ));

    tmrCtrl.periodsFromStart++;
  } 

  return 0;
}

void taosTmrCleanUp () {

  sigset_t set;

  if ( tmrCtrl.init == 0 ) return ;
	
  sigemptyset(&set);
  sigaddset(&set, SIGALRM);
  sigprocmask(SIG_BLOCK, &set, 0);
  
  pthread_cancel(tmrCtrl.thread);

  sleep(1);

  _sem_destroy( tmrCtrl.semaphore);
  tmrCtrl.semaphore = 0;
  if ( tmrCtrl.thread )
    pthread_mutex_destroy( &tmrCtrl.mutex);

  if ( tmrCtrl.poolHandle )
    taosMemPoolCleanUp(tmrCtrl.poolHandle);

  tfree(tmrCtrl.tmrList);

  bzero(&tmrCtrl, sizeof(tmrCtrl));

}

tmr_h taosTmrStart(void (*fp)(long), int mseconds, long param1 ) {

  tmr_obj_t  *pObj, *cNode, *pNode;
  tmr_list_t *pList;
  int index, period;

  pObj = (tmr_obj_t *)taosMemPoolMalloc(tmrCtrl.poolHandle);

  if ( pObj == 0 ) {
    tmrError(("failed to allocate tmr obj\n"));
    return 0;
  }
  
  period = mseconds / tmrCtrl.resolution + 1;
  pObj->cycle = period / tmrCtrl.numOfPeriods;		
  pObj->param1 = param1;
  pObj->fp = fp;
  pObj->timerId = pObj;

  if ( pthread_mutex_lock(&tmrCtrl.mutex) != 0 )
    tmrError(("mutex lock failed, reason:%s\n", strerror(errno) ));

  index = ( period + tmrCtrl.periodsFromStart ) % tmrCtrl.numOfPeriods;
  pList = &(tmrCtrl.tmrList[index]);

  pObj->index = index;
  cNode = pList->head;
  pNode = 0;

  while ( cNode != 0 ) {
    if ( cNode->cycle < pObj->cycle ) {
      pNode = cNode;
      cNode = cNode->next;
    } else {
      break;
    }
  }
  
  pObj->next = cNode;
  pObj->prev = pNode;

  if ( cNode != 0 ) {
    cNode->prev = pObj;
  } 
  
  if ( pNode != 0 ) {
    pNode->next = pObj;
  } else {
    pList->head = pObj;
  }

  pList->count++;
  totalNumOfTmrs++;

  if ( pthread_mutex_unlock(&tmrCtrl.mutex) != 0 )
    tmrError(("mutex unlock failed, reason:%s\n", strerror(errno) ));

  tmrTrace(("0x%06x, timer started, fp:%x, total:%d\n", param1, fp, totalNumOfTmrs));

  return (tmr_h) pObj;   
}

// taosTmrStop is not redefined, but is enough except some trace msg.
tmr_h taosTmrStartEx(void (*fpEx)(tmr_h, long/*param1*/), int mseconds, long param1 ) {

  tmr_obj_t  *pObj, *cNode, *pNode;
  tmr_list_t *pList;
  int index, period;

  pObj = (tmr_obj_t *)taosMemPoolMalloc(tmrCtrl.poolHandle);

  if ( pObj == 0 ) {
    tmrError(("failed to allocate tmr obj\n"));
    return 0;
  }
  
  period = mseconds / tmrCtrl.resolution + 1;
  pObj->cycle = period / tmrCtrl.numOfPeriods;		
  pObj->param1 = param1;
  pObj->fpEx = fpEx; // only this line is different from taosTmrStart function
  pObj->timerId = pObj;

  if ( pthread_mutex_lock(&tmrCtrl.mutex) != 0 )
    tmrError(("mutex lock failed, reason:%s\n", strerror(errno) ));

  index = ( period + tmrCtrl.periodsFromStart ) % tmrCtrl.numOfPeriods;
  pList = &(tmrCtrl.tmrList[index]);

  pObj->index = index;
  cNode = pList->head;
  pNode = 0;

  while ( cNode != 0 ) {
    if ( cNode->cycle < pObj->cycle ) {
      pNode = cNode;
      cNode = cNode->next;
    } else {
      break;
    }
  }
  
  pObj->next = cNode;
  pObj->prev = pNode;

  if ( cNode != 0 ) {
    cNode->prev = pObj;
  } 
  
  if ( pNode != 0 ) {
    pNode->next = pObj;
  } else {
    pList->head = pObj;
  }

  pList->count++;
  totalNumOfTmrs++;

  if ( pthread_mutex_unlock(&tmrCtrl.mutex) != 0 )
    tmrError(("mutex unlock failed, reason:%s\n", strerror(errno) ));

  tmrTrace(("0x%06x, timer started, fpEx:%x, total:%d\n", param1, fpEx, totalNumOfTmrs));

  return (tmr_h) pObj;   
}

void taosTmrStop(tmr_h timerId) {
  tmr_obj_t  *pObj;
  tmr_list_t *pList;

  pObj = (tmr_obj_t *)timerId;
  if ( pObj == 0 ) 
    return;

  //qcl 2002. 11. 25
  if(!tmrCtrl.tmrList)
    return;
  if(!tmrCtrl.poolHandle)
    return;
  
  if ( pthread_mutex_lock(&tmrCtrl.mutex)!= 0 ) 
    tmrError(("mutex lock failed, reason:%s\n", strerror(errno)));

  if (  pObj->timerId != 0 && pObj->timerId == timerId ) {       
    pList = &(tmrCtrl.tmrList[pObj->index]);
    if ( pObj->prev ) {
      pObj->prev->next = pObj->next;
    } else {
      pList->head = pObj->next;
    }

    if ( pObj->next ) {
      pObj->next->prev = pObj->prev;
    } 
	
    pList->count--;
    pObj->timerId = 0;
    totalNumOfTmrs--;

    tmrTrace(("0x%06x, timer stopped, fp:%x, total:%d\n", pObj->param1, pObj->fp, totalNumOfTmrs));
    taosMemPoolFree(tmrCtrl.poolHandle, (char *)(pObj));

  } else {
    if ( pObj->timerId != 0 )
      tmrError(("%x timer object not consistent, id:%x\n", (void *)timerId, pObj->timerId));
  }

  pthread_mutex_unlock( &tmrCtrl.mutex);

}

void taosTmrList( ) {
  int i;
  tmr_list_t *pList;
  tmr_obj_t  *pObj;

  for (i=0; i<tmrCtrl.numOfPeriods; ++i) {
    pList = &(tmrCtrl.tmrList[i]);  
    pObj = pList->head;
    if ( !pObj ) continue;
    printf("\nindex=%d count:%d\n", i, pList->count);
    while ( pObj ) {
      printf("0x%05x ", pObj->param1, pObj->timerId, pObj->cycle);
      pObj=pObj->next;
    }
  }

  printf("\nstart:%d total number of timers:%d\n", tmrCtrl.periodsFromStart, totalNumOfTmrs);

}
  
