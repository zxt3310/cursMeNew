/* 
 * File:   tlib.h
 * Author: root
 *
 * Created on 2009年2月19日, 下午2:57
 */

#ifndef _TLIB_H
#define	_TLIB_H

typedef enum
{
    TS_INT,
    TS_STR
}tstack_type_t;

typedef struct _tstack
{
    tstack_type_t type;
    int size;
    int used;
    int max;
    char **p;
}Tstack;

char *getCwd(char *argv[]);

Tstack *tstackInit(int size,tstack_type_t type);
int tstackPush(Tstack *p,const char *str);
char *tstackPop(Tstack *p);
int tstackDestroy(Tstack *p);

size_t getFileSize(const char *path);

char *mkSockStr(unsigned int ip, unsigned short port);

#endif	/* _TLIB_H */

