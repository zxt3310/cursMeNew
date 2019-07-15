//
//  Queuer.m
//  HiChat
//
//  Created by xiaoshoucun on 15/11/12.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Queuer.h"
#import "Gloabal.h"

static Queuer* ins = nil;

@implementation Queuer

//获得单例
+(id)instance
{
    if (ins == nil) {
        ins = [[self alloc] init];
    }
    return ins;
}

- (void)request:(JSONModel*)reqObj withResponse:(Class) responseCls Completed:(complete) callback {
    BoBase* bo = [[BoBase alloc] init];
    [bo setResponseCls:responseCls];
    [bo request:reqObj Completed:callback];
}

- (void)request:(JSONModel*)reqObj withResponse:(Class) responseCls withBaseUrl:(NSString*) url Completed:(complete) callback {
    BoBase* bo = [[BoBase alloc] init];
    [bo setResponseCls:responseCls];
    [bo request:reqObj withBaseUrl:url Completed:callback];
}

@end