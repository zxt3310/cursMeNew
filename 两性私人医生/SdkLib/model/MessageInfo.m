//
//  MessageInfo.m
//  Exer
//
//  Created by xiaoshoucun on 15/9/11.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//

#import "MessageInfo.h"

@implementation MessageInfo

- (void)dealloc
{
    self.to = nil;
    self.time = nil;
    self.from = nil;
    self.msgId = nil;
    self.body = nil;
    self.attachInfo = nil;
    _notifyType = nil;
    _subject = nil;
}

- (BOOL)save;
{
    if (nil != [self attachInfo]) {
        [[self attachInfo] setMsgId:[self msgId]];
        [[self attachInfo] JM_save];
    }
    return [self JM_save];
}

@end