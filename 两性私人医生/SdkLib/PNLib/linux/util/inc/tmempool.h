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

#ifndef _mem_pool_header
#define _mem_pool_header

#define mpool_h void *

extern  int memDebugFlag;

mpool_h taosMemPoolInit(int maxNum, int blockSize );
char    *taosMemPoolMalloc(mpool_h handle);
void    taosMemPoolFree(mpool_h handle, char *p);
void    taosMemPoolCleanUp(mpool_h handle);

#endif


