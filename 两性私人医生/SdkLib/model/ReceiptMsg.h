
//
//  ReceiptMsg.h
//  Exer
//
//  Created by xiaoshoucun on 15/9/11.
//  Copyright (c) 2015年 Sauchye. All rights reserved.
//

#import "RespBase.h"
#import "MessageInfo.h"

@interface ReceiptMsg : RespBase

@property (nonatomic, strong)NSArray<MessageInfo> *recvMsgList;

@end
