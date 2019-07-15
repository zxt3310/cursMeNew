//
//  RespBase.m
//  Exer
//
//  Created by xiaoshoucun on 15/9/11.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//

#import "RespBase.h"

@implementation RespBase

- (void)dealloc
{
    self.actionId = nil;
    self.code = nil;
    self.message = nil;
}

@end