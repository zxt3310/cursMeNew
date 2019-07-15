/*******************************************************************
 *           Copyright (c) 2001 by TAOS Networks, Inc.
 *                     All rights reserved.
 *
 *  This file is proprietary and confidential to TAOS Networks, Inc. 
 *  No part of this file may be reproduced, stored, transmitted, 
 *  disclosed or used in any form or by any means other than as 
 *  expressly provided by the written permission from Jianhui Tao
 *
 *  This utility is used to maintain a free ID list. 
 * ****************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>

typedef struct {
  int  maxId;
  int  numOfFree;
  int  freeSlot;
  int  *freeList;
  pthread_mutex_t mutex;
} id_pool_t;

void *taosInitIdPool(int maxId) {
  id_pool_t *pIdPool;
  int       *idList, i;
  
  if ( maxId < 5) maxId = 5;
  
  pIdPool = (id_pool_t *)malloc( sizeof(id_pool_t));
  idList = (int *)malloc( sizeof(int)*maxId );

  if (pIdPool == 0 || idList == 0) 
    return 0;
  
  memset(pIdPool, 0, sizeof(id_pool_t));
  pIdPool->maxId = maxId;
  pIdPool->numOfFree = maxId -1;
  pIdPool->freeSlot = 0;
  pIdPool->freeList = idList;

  pthread_mutex_init( &pIdPool->mutex, 0 );

  for (i=1; i<maxId; ++i)
    idList[i-1] = i;
  
  return (void *)pIdPool;
}
  
int taosAllocateId(void *handle) {
  id_pool_t *pIdPool;
  int       id=-1;
  
  pIdPool = (id_pool_t *)handle;
  
  if ( pthread_mutex_lock( &pIdPool->mutex) != 0 ) 
    perror("lock pIdPool Mutex");
  
  if ( pIdPool->numOfFree > 1 ) { 
    id = pIdPool->freeList[pIdPool->freeSlot];
    pIdPool->freeSlot = (pIdPool->freeSlot+1) % pIdPool->maxId;
    pIdPool->numOfFree--;
  }

  if ( pthread_mutex_unlock( &pIdPool->mutex) != 0 )
    perror("unlock pIdPool Mutex");

  return id;
}

void taosFreeId(void *handle, int id) {
  id_pool_t *pIdPool;
  int       slot;
  
  pIdPool = (id_pool_t *)handle;
  if(pIdPool ->freeList == 0 || pIdPool ->maxId == 0)
  	return ;
  if ( pthread_mutex_lock( &pIdPool->mutex) != 0 ) 
    perror("lock pIdPool Mutex");

  slot = ( pIdPool->freeSlot + pIdPool->numOfFree ) % pIdPool->maxId;
  pIdPool->freeList[slot] = id;
  pIdPool->numOfFree++;

  if ( pthread_mutex_unlock( &pIdPool->mutex) != 0 )
    perror("unlock pIdPool Mutex");

}

void taosIdPoolCleanUp(void *handle) {
  id_pool_t *pIdPool;

  pIdPool = (id_pool_t *)handle;
  
  if ( pIdPool->freeList )
    free(pIdPool->freeList);

  pthread_mutex_destroy( &pIdPool->mutex);

  memset(pIdPool, 0, sizeof(id_pool_t));

  free(pIdPool);

}

int taosIdPoolNumOfUsed(void *handle) {
  id_pool_t *pIdPool = (id_pool_t *)handle;

  return pIdPool->maxId - pIdPool->numOfFree - 1;
}


