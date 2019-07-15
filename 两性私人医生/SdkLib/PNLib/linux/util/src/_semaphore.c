//
//  _semaphore.c
//  pn_test2
//
//  Created by xiaoshoucun on 15/8/26.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#include <semaphore.h>
#include <errno.h>
#include <stdlib.h>

#include "_semaphore.h"

_sem_t * _sem_init(char *pName, unsigned int initNum)
{
    _sem_t *pSem;
    
    pSem = (_sem_t *) malloc (sizeof(_sem_t));
    
    strcpy(pSem->name, pName);
    
    sem_t* semaphore = sem_open( pName, O_CREAT, 0644, initNum );
    
    if( semaphore == SEM_FAILED )
    {
        switch( errno )
        {
            case EEXIST:
                printf( "Semaphore with name '%s' already exists.\n", pName );
                break;
                
            default:
                printf ("failed to create semaphore:%s", pName);
                printf( "Unhandled error: %d.\n", errno );
                break;
        }
        
        free(pSem);
        return (_sem_t*) SEM_FAILED;
    }
    
    printf ("semaphore:%s is created successfully", pName);
    pSem->sem = semaphore;
    return pSem;
}

int _sem_destroy(_sem_t *sem)
{
//    sem_close(sem->sem);
    sem_unlink(sem->name);
    free(sem);
    return 0;
}

int _sem_post(_sem_t *sem)
{
    _sem_t *pSem;
    
    pSem = (_sem_t *)sem;
    
    while ( sem_post(pSem->sem) != 0 )
    {
        if ( errno != EINTR )
        {
            printf ("failed to take semaphore:%s", pSem->name);
            return -1;
        }
    }
    
    return 0;
}

int _sem_wait(_sem_t *sem)
{
    _sem_t *pSem = (_sem_t *)sem;
    
    while  ( sem_wait( pSem->sem ) != 0 )
    {
        if ( errno != EINTR )
        {
            printf ("failed to release semaphore:%s", pSem->name);
            return -1;
        }
    }
    
    return 0;
}