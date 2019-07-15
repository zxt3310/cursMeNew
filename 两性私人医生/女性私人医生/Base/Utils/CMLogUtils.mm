//
//  CMLogUtils.m
//  私密健康医生
//
//  Created by Tim on 13-1-9.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#import "CMLogUtils.h"

static CMLogUtils *defaultLogUtil = nil;

bool WriteLog(NSString *format, ...)
{
    va_list marker;
	va_start( marker, format);
    NSLog(format, marker);
	va_end(marker);
    
    return true;
}

@implementation CMLogUtils

+ (CMLogUtils *)defaultLogUtils
{
    if (!defaultLogUtil) {
        NSLog(@"CureMeUtils defaultCureMeUtil");
        defaultLogUtil = [[super allocWithZone:NULL] init];
    }
    
    return defaultLogUtil;
}

+ (id) allocWithZone:(NSZone *)zone
{
    return [self defaultLogUtils];
}

- (id) init
{
    if (defaultLogUtil) {
        return defaultLogUtil;
    }
    
    NSLog(@"defaultLogUtil init");
    self = [super init];

    // LogUtil的初始化操作
    
    return self;
}

@end
