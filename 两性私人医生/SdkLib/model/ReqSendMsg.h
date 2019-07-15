//
//  ReqSendMsg.h
//
//  Created by xiaoshoucun on 15/10/30.
//  Copyright (c) 2015年 Hesine. All rights reserved.
//

#import "MessageInfo.h"
#import "ReqBase.h"

@interface ReqSendMsg : ReqBase

@property (nonatomic, strong)MessageInfo *messageInfo;

@end