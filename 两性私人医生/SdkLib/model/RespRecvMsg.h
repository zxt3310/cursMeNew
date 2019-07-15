//
//  RespRecvMsg.h
//  HiChat
//
//  Created by xiaoshoucun on 15/11/2.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//

#import "RespBase.h"
#import "MessageInfo.h"

@interface RespRecvMsg : RespBase

@property (nonatomic, strong)NSArray<MessageInfo> *messages;

@end
