//
//  RespUserInfo.h
//  HiChat
//
//  Created by xiaoshoucun on 15/11/2.
//  Copyright (c) 2015年 xiaoshoucun. All rights reserved.
//
#import "RespBase.h"
#import "AccountInfo.h"

@interface RespUserInfo : RespBase

@property (nonatomic, strong)AccountInfo *accountInfo;

@end