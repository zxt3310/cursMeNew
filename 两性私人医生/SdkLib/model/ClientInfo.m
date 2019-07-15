//
//  ClientInfo.m
//  Exer
//
//  Created by xiaoshoucun on 15/9/11.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//

#import "ClientInfo.h"

static ClientInfo *ins = nil;

@implementation ClientInfo

//获得单例
+(id)getSingleton
{
    @synchronized(self)
    {
        if (ins == nil) {
            ins = [[self alloc] init];
        }
    }
    return ins;
}

- (void)dealloc
{
    self.version = nil;        //客户端版本
    self.channelId = nil;      //渠道ID
    self.appName = nil;        //软件名称
}

- (id)init
{
    if(self = [super init]){
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        
        NSString *version = [infoDictionary objectForKey:@"CFBundleVersion"];
        NSString *build = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        
//        NSString *string1 = [version substringWithRange:NSMakeRange(0, 1)];
//        NSString *string2 = [version substringWithRange:NSMakeRange(2, 1)];
//        NSString *string3 = [version substringWithRange:NSMakeRange(4, 1)];
        
//        NSString* ver = [NSString stringWithFormat:@"%@.%@%@.%@%@",string1,string2,build];
        
        
        //客户端版本号
        self.version = @"1.0";
        
        //渠道ID
        self.channelId = @"";
        
        //软件名称
        self.appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        
        //假数据
        //客户端版本号
        //self.version = @"20130306";
        self.channelId = @"101";
        self.appName = @"sdkchat";
    }
    return  self;
}

@end