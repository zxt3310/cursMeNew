/*******************************************************************
 *           Copyright (c) 2001 by TAOS Networks, Inc.
 *                     All rights reserved.
 *
 *  This file is proprietary and confidential to TAOS Networks, Inc. 
 *  No part of this file may be reproduced, stored, transmitted, 
 *  disclosed or used in any form or by any means other than as 
 *  expressly provided by the written permission from Jianhui Tao
 *
 *****************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>

#include "tmempool.h"
#include "hpnsUtil.h"

int memDebugFlag = 3;

#define memError(x) if ( memDebugFlag & 1 ) { nprintf x; }
#define memWarn(x) if ( memDebugFlag & 2 ) { nprintf x; }
#define memTrace(x) if ( memDebugFlag & 4 ) { nprintf x; }

typedef struct {
  int    numOfFree;     /* number of free slots */
  int    first;         /* the first free slot  */
  int    numOfBlock;    /* the number of blocks */
  int    blockSize;     /* block size in bytes  */
  int    *freeList;     /* the index list       */
  char   *pool;         /* the actual mem block */
  pthread_mutex_t  mutex;
} pool_t;

mpool_h taosMemPoolInit(int numOfBlock, int blockSize ) 
{
  int i;
  pool_t *pool_p;

  if ( numOfBlock <= 1 || blockSize <=1 ) {
    memError(("invalid parameter in memPoolInit\n"));
    return 0;
  }

  pool_p = (pool_t*)malloc(sizeof(pool_t)); 
  if ( pool_p == 0 ) {
    memError(("mempool malloc failed\n"));
    return 0;
  } else {
    memset(pool_p, 0, sizeof(pool_t));
  }
  
  pool_p->blockSize = blockSize;
  pool_p->numOfBlock = numOfBlock;
  pool_p->pool = malloc( blockSize*numOfBlock);
  pool_p->freeList = (int *)malloc(sizeof(int)*numOfBlock);

  if ( pool_p->pool == 0 || pool_p->freeList == 0 ) {
    memError(("failed to allocate memory\n"));
    free(pool_p->freeList);
    free(pool_p->pool);
    free(pool_p);
    return 0;
  }
 
  pthread_mutex_init(&(pool_p->mutex), 0);

  for ( i=0; i< pool_p->numOfBlock; ++i) 
    pool_p->freeList[i] = i;

  pool_p->first = 0;
  pool_p->numOfFree = pool_p->numOfBlock;

  return (mpool_h)pool_p;
}

char *taosMemPoolMalloc(mpool_h handle )
{
  char *pos = 0;
  pool_t *pool_p = handle;

  pthread_mutex_lock ( &(pool_p->mutex) );

  if ( pool_p->numOfFree <= 0 ) {
    memError(("out of memory"));
  } else {
    pos = pool_p->pool + pool_p->blockSize * (pool_p->freeList[pool_p->first]);
    pool_p->first++;
    pool_p->first = pool_p->first % pool_p->numOfBlock;
    pool_p->numOfFree--;
  }

  pthread_mutex_unlock( &(pool_p->mutex) );   

  memset(pos, 0, pool_p->blockSize);
  return pos;
}

void
taosMemPoolFree(mpool_h handle, char *pMem)
{
  int    index;
  pool_t *pool_p = handle;

  if ( pMem == 0 ) return;

  pthread_mutex_lock( &pool_p->mutex );

  index = ( pMem - pool_p->pool) % pool_p->blockSize;

  if ( index != 0 ) {
    memError(("invalid free address:%p\n", pMem));
  } else {
    index = ( pMem - pool_p->pool) / pool_p->blockSize;

    if ( index < 0 || index >= pool_p->numOfBlock ) {
      memError(("mempool: error, invalid address:%p\n", pMem));
    } else {  
      pool_p->freeList[(pool_p->first + pool_p->numOfFree) % pool_p->numOfBlock]= index;
      pool_p->numOfFree++;
	  memset(pMem, 0, pool_p->blockSize);
    }
  }
  
  pthread_mutex_unlock(&pool_p->mutex);
}

void taosMemPoolCleanUp (mpool_h handle)
{
  pool_t *pool_p = handle;

  pthread_mutex_destroy(&pool_p->mutex);
  if ( pool_p->pool ) free( pool_p->pool);
  if ( pool_p->freeList ) free(pool_p->freeList);
  memset(&pool_p, 0, sizeof(pool_p));
  free(pool_p);
}

