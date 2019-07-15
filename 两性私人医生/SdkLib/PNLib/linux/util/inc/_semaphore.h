//
//  _semaphore.h
//  pn_test2
//
//  Created by xiaoshoucun on 15/8/26.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#ifndef __pn_test2___semaphore__
#define __pn_test2___semaphore__

typedef struct {
    int* sem;
    char  name[20];
} _sem_t;

_sem_t * _sem_init(char *pName, unsigned int initNum);
int   _sem_destroy(_sem_t *sem);
int _sem_post(_sem_t *sem);
int _sem_wait(_sem_t *sem);

#endif /* defined(__pn_test2___semaphore__) */
