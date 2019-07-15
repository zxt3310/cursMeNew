//
//  ReqBase.m
//  Exer
//
//  Created by xiaoshoucun on 15/9/11.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//

#import "ReqBase.h"

@implementation ReqBase

- (void)dealloc
{
    //self.systemInfo = nil;
    //self.clientInfo = nil;
    self.actionInfo = nil;
}

- (id)init
{
    if(self = [super init]){
        self.systemInfo = [SystemInfo getSingleton];
        self.clientInfo = [ClientInfo getSingleton];
        self.actionInfo = [[ActionInfo alloc] init];
        [self.actionInfo setDeviceToken:[[self systemInfo] imei]];
    }
    return  self;
}

@end
