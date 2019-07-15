#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>
#include <sys/stat.h>
#include <netinet/in.h>
#include "tlib.h"

Tstack *tstackInit(int size,tstack_type_t type)
{
    Tstack *p;
    p = malloc(sizeof(*p));
    p->type = type;
    p->size = size;
    p->used = 0;
    p->max = 0;
    p->p = malloc(size * sizeof(char *));
    return p;
}

int tstackPush(Tstack *p,const char *str)
{
    assert(p);
    if(p->used >= p->size)
    {
        p->size += 10;
        p->p = realloc(p->p,p->size*sizeof(char *));
    }
    if(p->type == TS_STR)
        p->p[p->used] = strdup(str);
    else p->p[p->used] = (char *)str;
    p->used++;
    if(p->used > p->max)
        p->max = p->used;
    return 0;
}

char *tstackPop(Tstack *p)
{
    assert(p);
    if(p->used <= 0)
        return 0;
    p->used--;
    return p->p[p->used];
}

int tstackDestroy(Tstack *p)
{
    int i;
    if(p == 0) return 0;
    for(i = 0; i<p->max; i++)
    {
        if(p->type == TS_STR)   free(p->p[i]);
        p->p[i] = 0;
    }
    free(p);
    return 0;
}

size_t getFileSize(const char *path)
{
    struct stat st;

    if(stat(path, &st) < 0) return -1;
    return st.st_size;
}


char *getCwd(char *argv[])
{
        char *p;
        static char dir[256];
        char buf[256];
        getcwd(buf,sizeof(buf));
        p = strrchr(argv[0],'/');
        if(p == 0)
        {
            strcpy(dir,"./");
            return dir;
        }
        snprintf(dir,p - argv[0] + 1,"%s",argv[0]);
        chdir(dir);
        getcwd(dir,sizeof(dir));
        chdir(buf);
        return dir;
}

