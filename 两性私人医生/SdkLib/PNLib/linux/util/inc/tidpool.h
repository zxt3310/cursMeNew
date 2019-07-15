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
#ifndef _tid_pool_header_
#define _tid_pool_header_

void *taosInitIdPool(int maxId);
int  taosAllocateId(void *handle);
void taosFreeId(void *handle, int id);
void taosIdPoolCleanUp(void *handle);
int  taosIdPoolNumOfUsed(void *handle);

#endif

